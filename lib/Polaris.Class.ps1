#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

class Polaris {

    [int]$Port
    [System.Collections.Generic.List[PolarisMiddleware]]$RouteMiddleWare = [System.Collections.Generic.List[PolarisMiddleWare]]::new()
    [PolarisRoute[]]$Routes = @()
    hidden [Action[string]]$Logger
    hidden [System.Net.HttpListener]$Listener
    hidden [bool]$StopServer = $False
    [string]$GetLogsString = "PolarisLogs"
    [string]$ClassDefinitions = $Script:ClassDefinitions
    [string]$UriPrefix
    $ContextHandler = (New-ScriptblockCallback -Callback {

            param(
                [System.IAsyncResult]
                $AsyncResult
            )

            [Polaris]$Polaris = $AsyncResult.AsyncState
            $Context = $Polaris.Listener.EndGetContext($AsyncResult)


            if ($Polaris.StopServer -or $null -eq $Context) {
                if ($null -ne $Polaris.Listener) {
                    $Polaris.Listener.Close()
                }
                break
            }

            $Polaris.Listener.BeginGetContext($Polaris.ContextHandler, $Polaris)

            [System.Net.HttpListenerRequest]$RawRequest = $Context.Request

            $Polaris.Log("request came in: " + $RawRequest.HttpMethod + " " + $RawRequest.RawUrl)

            [PolarisRequest]$Request = [PolarisRequest]::new($RawRequest, $Context.User)
            [PolarisResponse]$Response = [PolarisResponse]::new($Context.Response)


            [string]$RequestedRoute = $RawRequest.Url.AbsolutePath

            [System.Management.Automation.InformationRecord[]]$InformationVariable = @()

            if ([string]::IsNullOrEmpty($RequestedRoute)) { $RequestedRoute = "/" }

            try {

                # Run middleware in the order in which it was added
                foreach ($Middleware in $Polaris.RouteMiddleware) {
                    if ($Response.Sent -eq $false) {
                        Write-Debug "Executing middleware: $( $Middlware | ConvertTo-Json )"
                        $InformationVariable += $Polaris.InvokeRoute(
                            $Middleware.Scriptblock,
                            $Null,
                            $Request,
                            $Response
                        )
                    }
                }

                if ($Response.Sent -eq $false) {
                    $Polaris.Log("Parsed Route: $RequestedRoute")
                    $Polaris.Log("Request Method: $($RawRequest.HttpMethod)")
                    $Routes = $Polaris.Routes

                    #
                    # Searching for the first route that matches by the most specific route paths first.
                    #
                    $MatchingRoute = $Null
                    $HasMatchingMethod = $false
                    foreach ($Route in $Routes) {
                        Write-Debug "Testing Route: `n`n $( $Route | ConvertTo-Json )"
                        $IsMatchingMethod = $Route.Method -eq $Request.Method
                        Write-Debug "`$IsMatchingMethod = `$Route.Method($($Route.Method)) -eq `$Request.Method($($Request.Method))"
                        $IsMatchingRoute = $RequestedRoute -match $Route.Regex
                        Write-Debug "`$IsMatchingRoute = `$RequestedRoute($($RequestedRoute)) -match `$Route.Regex($($Route.Regex))"
                        if ( $IsMatchingRoute ) {
                            $MatchingRoute = $Route
                            if ( $IsMatchingMethod ) {
                                $HasMatchingMethod = $true
                                break
                            }
                        }
                    }

                    $Request.Parameters = ([PSCustomObject]$Matches)
                    Write-Debug "Parameters: $($Request.Parameters)"

                    if ($MatchingRoute -and $HasMatchingMethod) {
                        try {
                            $InformationVariable += $Polaris.InvokeRoute(
                                $MatchingRoute.ScriptBlock,
                                $Parameters,
                                $Request,
                                $Response
                            )
                        }
                        catch {
                            $ErrorsBody = ''
                            $ErrorsBody += $_.Exception.ToString()
                            $ErrorsBody += $_.InvocationInfo.PositionMessage + "`n`n"
                            $Response.Send($ErrorsBody)
                            $Polaris.Log($_)
                            $Response.SetStatusCode(500)
                        }
                    }
                    elseif ($MatchingRoute) {
                        $Response.Send("Method not allowed")
                        $Response.SetStatusCode(405)
                    }
                    else {
                        $Response.Send("Not found")
                        $Response.SetStatusCode(404)
                    }
                }

                # Handle logs
                if ($Request.Query -and $Request.Query[$Polaris.GetLogsString]) {
                    $InformationBody = "`n"
                    for ([int]$i = 0; $i -lt $InformationVariable.Count; $i++) {
                        foreach ($tag in $InformationVariable[$i].Tags) {
                            $InformationBody += "[" + $tag + "]"
                        }

                        $InformationBody += $InformationVariable[$i].MessageData.ToString() + "`n"
                    }
                    $InformationBody += "`n"

                    # Set response to the logs and the actual response (could be errors)
                    $LogBytes = [System.Text.Encoding]::UTF8.GetBytes($InformationBody)
                    $Bytes = [byte[]]::new($LogBytes.Length + $Response.ByteResponse.Length)
                    $LogBytes.CopyTo($Bytes, 0)
                    $Response.ByteResponse.CopyTo($Bytes, $LogBytes.Length)
                    $Response.ByteResponse = $Bytes
                }
                [Polaris]::Send($Response)

            }
            catch {
                $Polaris.Log(($_ | Out-String))
                $Response.SetStatusCode(500)
                $Response.Send($_)
                try {
                    [Polaris]::Send($Response)
                }
                catch {
                    $Polaris.Log($_)
                }
                $Polaris.Log($_)
            }
        })

    hidden [object] InvokeRoute (
        [Scriptblock]$Route,
        [PSCustomObject]$Parameters,
        [PolarisRequest]$Request,
        [PolarisResponse]$Response
    ) {

        $InformationVariable = ""

        $Scriptblock = [scriptblock]::Create(
            "param(`$Parameters,`$Request,`$Response)`r`n" +
            $Route.ToString()
        )

        Invoke-Command -Scriptblock $Scriptblock `
            -ArgumentList @($Parameters, $Request, $Response) `
            -InformationVariable InformationVariable `
            -ErrorAction Stop

        return $InformationVariable
    }


    [void] AddRoute (
        $Path,
        [string]$Method,
        [scriptblock]$Scriptblock
    ) {
        if ($null -eq $Scriptblock) {
            throw [ArgumentNullException]::new("ScriptBlock")
        }

        $this.Routes += [PolarisRoute]::new($Method, $Path, $Scriptblock)
        $this.Routes = $this.Routes | Sort-Object -Property { $_.Path.Length } -Descending
    }

    RemoveRoute (
        [string]$Path,
        [string]$Method
    ) {
        if ($null -eq $Path) {
            throw [ArgumentNullException]::new("Path")
        }
        if ($null -eq $Method) {
            throw [ArgumentNullException]::new("Method")
        }

        $this.Routes = $this.Routes | Where-Object { -not ($_.Path -eq $Path -and $_.Method -eq $Method) }
    }

    AddMiddleware (
        [string]$Name,
        [scriptblock]$Scriptblock
    ) {
        if ($null -eq $Scriptblock) {
            throw [ArgumentNullException]::new("scriptBlock")
        }
        $this.RouteMiddleware.Add([PolarisMiddleware]@{
                'Name'        = $Name
                'Scriptblock' = $Scriptblock
            })
    }

    RemoveMiddleware ([string]$Name) {
        if ($null -eq $Name) {
            throw [ArgumentNullException]::new("name")
        }
        $this.RouteMiddleware.RemoveAll(
            [Predicate[PolarisMiddleWare]]([scriptblock]::Create("`$args[0].Name -eq '$Name'"))
        )
    }

    [void] Start (
        [int]$Port = 3000,
        [bool]$Https,
        [string]$Auth,
        [string]$HostName
    ) {
        $this.StopServer = $false
        if($this.Listener -eq $null) {
            Write-Debug "Creating new listener"
            $this.InitListener($Port, $Https, $Auth, $HostName)
            $this.Listener.BeginGetContext($this.ContextHandler, $this)
        } else {
            Write-Debug "Listener object already created"
            if($this.Listener.IsListening){
                Write-Debug "Listener is already in a listening state. Doing nothing"
            } else {
                Write-Debug "Listener object exists but has shut down. Reinitializing..."
                $this.Stop()
                $this.InitListener($Port, $Https, $Auth, $HostName)
                $this.Listener.BeginGetContext($this.ContextHandler, $this)
            }
        }
    }

    [void] Stop () {
        $this.StopServer = $true
        $this.Listener.Close()
        $this.Listener.Dispose()
        $this.Log("Server Stopped.")
    }

    [void] InitListener (
        [int]$Port,
        [bool]$Https,
        [string]$Auth,
        [string]$HostName
    ) {
        $this.Port = $Port

        $this.Listener = [System.Net.HttpListener]::new()

        if ($Https) {
            $ListenerPrefix = "https"
        }
        else {
            $ListenerPrefix = "http"
        }

        $this.UriPrefix = $ListenerPrefix + '://' + $HostName + ':' + $this.Port + '/'

        $this.Listener.Prefixes.Add($this.UriPrefix)

        $this.Log("URI Prefix set to: $($this.UriPrefix)")

        $this.Listener.AuthenticationSchemes = $Auth

        $this.Log("Authentication Scheme set to: $Auth")

        $this.Listener.IgnoreWriteExceptions = $true
        if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT -and $this.Listener.TimeoutManager) {
            $this.Listener.TimeoutManager.RequestQueue = [timespan]::FromMinutes(5)
            $this.Listener.TimeoutManager.IdleConnection = [timespan]::FromSeconds(45)
            $this.Listener.TimeoutManager.EntityBody = [timespan]::FromSeconds(50)
            $this.Listener.TimeoutManager.HeaderWait = [timespan]::FromSeconds(5)
        }

        $this.Listener.Start()
    }

    static [void] Send (
        [PolarisResponse]$Response
    ) {
        if ($Response.StreamResponse) {
            [Polaris]::Send(
                $Response.RawResponse,
                $Response.StreamResponse,
                $Response.StatusCode,
                $Response.ContentType,
                $Response.Headers
            )
        }
        else {
            [Polaris]::Send(
                $Response.RawResponse,
                $Response.ByteResponse,
                $Response.StatusCode,
                $Response.ContentType,
                $Response.Headers
            )
        }
    }

    static [void] Send (
        [System.Net.HttpListenerResponse]$RawResponse,
        [byte[]]$ByteResponse,
        [int]$StatusCode,
        [string]$ContentType,
        [System.Net.WebHeaderCollection]$Headers
    ) {
        $RawResponse.StatusCode = $StatusCode
        foreach ($Header in $Headers.Keys) {
            $RawResponse.AddHeader($Header, $Headers.Get($Header))
        }
        if ($ByteResponse.Length -gt 0) {
            $RawResponse.ContentType = $ContentType
        }
        $RawResponse.ContentLength64 = $ByteResponse.Length
        $RawResponse.OutputStream.Write($ByteResponse, 0, $ByteResponse.Length)
        $RawResponse.OutputStream.Close()
    }

    static [void] Send (
        [System.Net.HttpListenerResponse]$RawResponse,
        [System.IO.Stream]$StreamResponse,
        [int]$StatusCode,
        [string]$ContentType,
        [System.Net.WebHeaderCollection]$Headers
    ) {
        $RawResponse.StatusCode = $StatusCode
        $RawResponse.Headers = $Headers
        $RawResponse.ContentType = $ContentType
        $StreamResponse.CopyTo($RawResponse.OutputStream)
        $RawResponse.OutputStream.Close()
    }

    static [void] Send (
        [System.Net.HttpListenerResponse]$RawResponse,
        [byte[]]$ByteResponse,
        [int]$StatusCode,
        [string]$ContentType
    ) {
        [Polaris]::Send($RawResponse, $ByteResponse, $StatusCode, $ContentType, $Null)
    }

    [void] Log ([string]$LogString) {
        try {
            $this.Logger.Invoke($LogString)
        }
        catch {
            Write-Host $_.Message
            Write-Host $LogString
        }
    }


    Polaris (
        [Action[string]]$Logger
    ) {
        if ($Logger) {
            $this.Logger = $Logger
        }
        else {
            $this.Logger = {
                param($LogItem)
                Write-Host $LogItem
            }
        }

    }
}
