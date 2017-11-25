

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


class PolarisServer {

    [ValidateRange(0, 65535)]
    [int]$Port
    [string]$LogPath
    [PolarisRoute[]]$Routes = @()
    [int]$JobID

    [void] Start() {
        $isWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
        $hostname = @{$true = "+"; $false = "localhost"}[-not $isWindows -or (Test-WindowsElevation)]
        $listener = [Net.HttpListener]::new()
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

    [PolarisResponse] HandleRequest([HttpListenerRequest]$Request) {
        $route = $this.Routes `
            | Where-Object {$Request.HttpMethod -eq $_.Method -and $Request.Url.AbsolutePath -match $_.Path} `
            | Select-Object -First 1
        if ($route) {
            try {
                $Request.Url.AbsolutePath -match $route.Path
                return &$route.Handler $Request $Matches
            } catch {
                return [PolarisResponse]::ServerError
            }
        } else {
            return [PolarisResponse]::FileNotFound
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

    static [PolarisResponse]$Unauthorized = @{
        StatusCode = 403
        Body = "Unauthorized"
    }

    static [PolarisResponse]$FileNotFound = @{
        StatusCode = 404
        Body = "File not found"
    }

    static [PolarisResponse]$ServerError = @{
        StatusCode = 500
        Body = "An unknown server error occurred"
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


class PolarisStaticRoute : PolarisRoute {
    [bool]$AllowDirectoryBrowsing = $false
    [string]$Root
    [scriptblock]$Handler = {
        Param()
    }
}

