class Polaris {

    [int]$Port
    [System.Collections.Generic.List[PolarisMiddleWare]]$RouteMiddleWare = [System.Collections.Generic.List[PolarisMiddleWare]]::new()
    [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, scriptblock]]]]$ScriptblockRoutes = [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, scriptblock]]]]::new()
    hidden [Action[string]]$Logger
    hidden [System.Net.HttpListener]$Listener
    hidden [bool]$StopServer = $False
    [string]$GetLogsString = "PolarisLogs"
    [string]$ClassDefinitions = $Script:ClassDefinitions
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
            [System.Net.HttpListenerResponse]$RawResponse = $Context.Response

            $Polaris.Log("request came in: " + $RawRequest.HttpMethod + " " + $RawRequest.RawUrl)

            [PolarisRequest]$Request = [PolarisRequest]::new($RawRequest)
            [PolarisResponse]$Response = [PolarisResponse]::new()


            [string]$Route = $RawRequest.Url.AbsolutePath
            
            [System.Management.Automation.InformationRecord[]]$InformationVariable = @()

            if ([string]::IsNullOrEmpty($Route)) { $Route = "/" }

            try {

                # Run middleware in the order in which it was added
                foreach ($Middleware in $Polaris.RouteMiddleware) {
                    $InformationVariable += $Polaris.InvokeRoute(
                            $Middleware.Scriptblock,
                            $Null,
                            $Request,
                            $Response
                        )
                }

                $Polaris.Log("Parsed Route: $Route")
                $Polaris.Log("Request Method: $($RawRequest.HttpMethod)")
                $Routes = $Polaris.ScriptblockRoutes

                #
                # Searching for the first route that matches by the most specific route paths first.
                #
                $MatchingRoute = $Routes.keys | Sort-Object -Property Length -Descending | Where-Object { $Route -match [Polaris]::ConvertPathToRegex($_) } | Select-Object -First 1
                $Request.Parameters = ([PSCustomObject]$Matches)
                Write-Debug "Parameters: $Parameters"
                $MatchingMethod = $false

                if ($MatchingRoute) {
                    $MatchingMethod = $Routes[$MatchingRoute].keys -contains $Request.Method
                }

                if ($MatchingRoute -and $MatchingMethod) {
                    try {

                        $InformationVariable += $Polaris.InvokeRoute(
                            $Routes[$MatchingRoute][$Request.Method],
                            $Parameters,
                            $Request,
                            $Response
                        )
                        
                    }
                    catch {
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
                [Polaris]::Send($RawResponse, $Response)

            }
            catch {
                $Polaris.Log(($_ | Out-String))
                $Response.SetStatusCode(500)
                $Response.Send($_)
                try{
                    [Polaris]::Send($RawResponse, $Response)
                } catch {
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
        [string]$Path,
        [string]$Method,
        [scriptblock]$Scriptblock
    ) {
        if ($null -eq $Scriptblock) {
            throw [ArgumentNullException]::new("scriptBlock")
        }

        [string]$SanitizedPath = [Polaris]::SanitizePath($Path)

        if (-not $this.ScriptblockRoutes.ContainsKey($SanitizedPath)) {
            $this.ScriptblockRoutes[$SanitizedPath] = [System.Collections.Generic.Dictionary[string, string]]::new()
        }
        $this.ScriptblockRoutes[$SanitizedPath][$Method] = $Scriptblock
    }

    RemoveRoute (
        [string]$Path,
        [string]$Method
    ) {
        if ($null -eq $Path) {
            throw [ArgumentNullException]::new("path")
        }
        if ($null -eq $Method) {
            throw [ArgumentNullException]::new("method")
        }

        [string]$SanitizedPath = [Polaris]::SanitizePath($Path)

        $this.ScriptblockRoutes[$SanitizedPath].Remove($Method)
        if ($this.ScriptblockRoutes[$SanitizedPath].Count -eq 0) {
            $this.ScriptblockRoutes.Remove($SanitizedPath)
        }
    }

    static [string] SanitizePath([string]$Path){
        $SanitizedPath = $Path.TrimEnd('/')

        if ([string]::IsNullOrEmpty($SanitizedPath)) { $SanitizedPath = "/" }

        return $SanitizedPath
    }

    static [RegEx] ConvertPathToRegex([string]$Path){
        Write-Debug "Path: $path"
        # Replacing all periods with an escaped period to prevent regex wildcard
        $path = $path -replace '\.', '\.'
        # Replacing all - with \- to escape the dash
        $path = $path -replace '-', '\-'
        # Replacing the wildcard character * with a regex aggressive match .*
        $path = $path -replace '\*', '.*'
        # Creating a strictly matching regular expression that must match beginning (^) to end ($)
        $path = "^$path$"
        # Creating a route based parameter
        #   Match any and all word based characters after the : for the name of the parameter
        #   Use the name in a named capture group that will show up in the $matches variable
        #   References:
        #       - https://docs.microsoft.com/en-us/dotnet/standard/base-types/grouping-constructs-in-regular-expressions#named_matched_subexpression
        #       - https://technet.microsoft.com/en-us/library/2007.11.powershell.aspx
        #       - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-6#matches
        $path = $path -replace ":(\w+)(\?{0,1})", '(?<$1>.+)$2'

        Write-Debug "Parsed Regex: $path"
        return [RegEx]::New($path)
    }

    static [RegEx] ConvertPathToRegex([RegEx]$Path){
        Write-Debug "Path is a RegEx"
        return $Path
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
        [int]$Port = 3000
    ) {
        $this.StopServer = $false
        $this.InitListener($Port)
        $this.Listener.BeginGetContext($this.ContextHandler, $this)
        $this.Log("App listening on Port: " + $Port + "!")
    }

    [void] Stop () {
        $this.StopServer = $true
        $this.Listener.Close()
        $this.Listener.Dispose()
        $this.Log("Server Stopped.")
        
    }
    [void] InitListener ([int]$Port) {
        $this.Port = $Port

        $this.Listener = [System.Net.HttpListener]::new()

        # If user is on a non-windows system or windows as administrator
        if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT -or
            ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT -and
                ([System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
            $this.Listener.Prefixes.Add("http://+:" + $this.Port + "/")
        }
        else {
            $this.Listener.Prefixes.Add("http://localhost:" + $this.Port + "/")
        }

        $this.Listener.IgnoreWriteExceptions = $true
        if([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT -and $this.Listener.TimeoutManager){
            $this.Listener.TimeoutManager.RequestQueue = [timespan]::FromMinutes(5)
            $this.Listener.TimeoutManager.IdleConnection = [timespan]::FromSeconds(45)
            $this.Listener.TimeoutManager.EntityBody = [timespan]::FromSeconds(50)
            $this.Listener.TimeoutManager.HeaderWait = [timespan]::FromSeconds(5)
        }

        $this.Listener.Start()
    }

    static [void] Send (
        [System.Net.HttpListenerResponse]$RawResponse, 
        [PolarisResponse]$Response
    ) {
        if ($Response.StreamResponse) {
            [Polaris]::Send(
                $RawResponse,
                $Response.StreamResponse,
                $Response.StatusCode,
                $Response.ContentType,
                $Response.Headers
            )
        }
        else {
            [Polaris]::Send(
                $RawResponse,
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
        $RawResponse.StatusCode = $StatusCode;
        $RawResponse.Headers = $Headers;
        $RawResponse.ContentType = $ContentType;
        $RawResponse.ContentLength64 = $ByteResponse.Length;
        $RawResponse.OutputStream.Write($ByteResponse, 0, $ByteResponse.Length);
        $RawResponse.OutputStream.Close();
    }
    
    static [void] Send (
        [System.Net.HttpListenerResponse]$RawResponse, 
        [System.IO.Stream]$StreamResponse, 
        [int]$StatusCode, 
        [string]$ContentType, 
        [System.Net.WebHeaderCollection]$Headers
    ) {
        $RawResponse.StatusCode = $StatusCode;
        $RawResponse.Headers = $Headers;
        $RawResponse.ContentType = $ContentType;
        $StreamResponse.CopyTo($RawResponse.OutputStream);
        $RawResponse.OutputStream.Close();
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
            $this.Logger($LogString)
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
