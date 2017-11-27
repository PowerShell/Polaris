
using namespace System.Collections
using namespace System.Management.Automation
using namespace System.Net
using namespace System.Security.Principal


enum HttpMethod {
    GET
    HEAD
    POST
    PUT
    DELETE
    CONNECT
    OPTIONS
    TRACE
    PATCH
}


function Test-WindowsElevation {
    $currentPrincipal = [WindowsPrincipal]::new([WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([WindowsBuiltInRole]::Administrator)
}


function Invoke-SafeSplat($ScriptBlock, $Hash) {
    $supportedParams = $ScriptBlock.Ast.ParamBlock.Parameters.Extent.Text -replace "\`$"
    $params = @{}
    $Hash.Keys | ? {$supportedParams -contains $_} | % {$params[$_] = $Hash[$_]}
    return &$ScriptBlock @params
}


class PolarisServer {

    [ValidateRange(0, 65535)]
    [int]$Port
    [PolarisRoute[]]$Routes = @()
    [int]$JobID

    [void] Start() {
        $isWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
        $hostname = @{$true = "+"; $false = "localhost"}[-not $isWindows -or (Test-WindowsElevation)]
        $listener = [HttpListener]::new()
        $listener.Prefixes.Add("http://$hostname`:$($this.Port)/")
        $listener.Start()
        while ($true) {
            try {
                $context = $listener.GetContext()
                $response = $this.HandleRequest($context.Request)
                $byteResponse = [byte[]][char[]]$response.Body
                $context.Response.StatusCode = $response.StatusCode
                $context.Response.ContentType = $response.ContentType
                $context.Response.ContentLength64 = $byteResponse.Length
                $context.Response.OutputStream.Write($byteResponse, 0, $byteResponse.Length)
            } catch {
                throw $_
            } finally {
                $context.Response.OutputStream.Close()
            }
        }
    }

    [PolarisResponse] HandleRequest([HttpListenerRequest]$Request, [PolarisResponse]$Response) {
        $matchedRoutes = [Queue]::new(($this.Routes | ? {$Request.HttpMethod -eq $_.Method -and $Request.Url.AbsolutePath -match $_.Path}))
        if ($matchedRoutes) {
            try {
                # process each matching route in order of definition
                while ($matchedRoutes.Count) {
                    $route = $matchedRoutes.Dequeue()
                    # populate $Matches with regex matches from the URI path
                    $Request.Url.AbsolutePath -match $route.Path
                    $res = Invoke-SafeSplat `
                        -ScriptBlock $route.Handler `
                        -Hash @{Request = $Request; Response = $Response; Matches = $Matches}
                    # break out of the middleware pipeline early if value is returned
                    if ($res) {
                        return $Response
                    }
                }
                return $Response
            } catch {
                return [PolarisResponse]::ServerError
            }
        } else {
            # route not found (404)
            return [PolarisResponse]::NotFound
        }
    }
}


class PolarisResponse {

    [ValidateRange(100, 600)]
    [int]$StatusCode
    [ValidateNotNull()]
    [string]$Body
    [ValidatePattern(".+/.+")]
    [string]$ContentType

    static [PolarisResponse]$Forbidden = @{
        StatusCode = 403
        Body = "Forbidden"
    }

    static [PolarisResponse]$NotFound = @{
        StatusCode = 404
        Body = "Not Found"
    }

    static [PolarisResponse]$ServerError = @{
        StatusCode = 500
        Body = "Server Error"
    }

}


class PolarisRoute {
    [ValidateNotNull()]
    [string]$Path
    [ValidateNotNullOrEmpty()]
    [HttpMethod]$Method
    [ValidateNotNullOrEmpty()]
    [scriptblock]$Handler
}

