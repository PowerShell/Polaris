class Polaris {
    
    [Int]$Port
    [System.Collections.Generic.List[PolarisMiddleWare]]$RouteMiddleWare = [System.Collections.Generic.List[PolarisMiddleWare]]::new()
    [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, string]]]]$ScriptBlockRoutes = [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, string]]]]::new()
    hidden [Action[string]]$Logger
    hidden [System.Net.HttpListener]$Listener
    hidden [System.Management.Automation.Runspaces.RunspacePool]$PowerShellPool = [RunspaceFactory]::CreateRunspacePool()
    hidden [bool]$StopServer = $False
    [string]$getLogsString = "PolarisLogs"


    [Void] AddRoute(
        [string]$path,
        [string]$method,
        [string]$scriptBlock
    ) {
        if ($scriptBlock -eq $null) {
            throw [ArgumentNullException]::new("scriptBlock")
        }

        [string]$sanitizedPath = $path.TrimEnd('/').TrimStart('/')

        if (-not $this.ScriptBlockRoutes.ContainsKey($sanitizedPath)) {
            $this.ScriptBlockRoutes[$sanitizedPath] = [System.Collections.Generic.Dictionary[string, string]]::new()
        }
        $this.ScriptBlockRoutes[$sanitizedPath][$method] = $scriptBlock
    }
        
    RemoveRoute(
        [string]$path, 
        [string]$method
    ) {
        if ($path -eq $null) {
            throw [ArgumentNullException]::new("path")
        }
        if ($method -eq $null) {
            throw [ArgumentNullException]::new("method")
        }

        [string]$sanitizedPath = $path.TrimEnd('/').TrimStart('/')
        $this.ScriptBlockRoutes[$sanitizedPath].Remove($method)
        if ($this.ScriptBlockRoutes[$sanitizedPath].Count -eq 0) {
            $this.ScriptBlockRoutes.Remove($sanitizedPath)
        }
    }

    AddMiddleware(
        [string]$name,
        [string]$scriptBlock
    ) {
        if ($scriptBlock -eq $null) {
            throw [ArgumentNullException]::new("scriptBlock")
        }
        $this.RouteMiddleWare.Add
        $this.RouteMiddleware.Add([PolarisMiddleware]@{
                'Name'        = $name
                'ScriptBlock' = $scriptBlock
            })
    }

    RemoveMiddleware([string]$name) {
        if ($name -eq $null) {
            throw [ArgumentNullException]::new("name")
        }
        $this.RouteMiddleware.RemoveAll(
            [Predicate[PolarisMiddleWare]]([scriptblock]::Create("`$args[0].Name -eq '$name'"))
        )
    }

    [Void] Start(
        [int]$port = 3000,  
        [int]$minRunspaces = 1,
        [int]$maxRunspaces = 1
    ) {
        $this.StopServer = $false

        $this.Listener = $this.InitListener($port)

        $this.ListenerLoop()

        $this.Log("App listening on Port: " + $port + "!")
    }

    [void] Stop() {
        $this.StopServer = $true
        $this.PowerShellPool.Close()
        $this.Log("Server Stopped.")
    }

    [void] ListenerLoop() {

        $PolarisCore = [Polaris.PolarisCore]::new()
        $PolarisCore.Start($this.Listener)
        Register-ObjectEvent -InputObject $PolarisCore -EventName "myEvent" -Action {
            param(
                [System.Net.HttpListenerContext]$context
            )

            if ($this.StopServer -or $context -eq $null) {
                if ($this.Listener -ne $null) {
                    $this.Listener.Close()
                }
                break
            }

            [System.Net.HttpListenerRequest] $rawRequest = $context.Request
            [System.Net.HttpListenerResponse] $rawResponse = $context.Response

            $this.Log("request came in: " + $rawRequest.HttpMethod + " " + $rawRequest.RawUrl)

            [PolarisRequest] $request = [PolarisRequest]::new($rawRequest)
            [PolarisResponse] $response = [PolarisResponse]::new()

            [string] $route = $rawRequest.Url.AbsolutePath.TrimEnd('/').TrimStart('/')
            [PowerShell] $PowerShellInstance = [PowerShell]::Create()
            $PowerShellInstance.RunspacePool = $this.PowerShellPool
            try {
                # Set up PowerShell instance by making request and response global
                $PowerShellInstance.AddScript([PolarisHelperScripts]::InitializeRequestAndResponseScript()) | Out-Null
                $PowerShellInstance.AddParameter("req", $request)
                $PowerShellInstance.AddParameter("res", $response)

                $newRunspace = [runspacefactory]::CreateRunspace()
                $newRunspace.ApartmentState = "STA"
                $newRunspace.ThreadOptions = "ReuseThread"
                $newRunspace.Open()
                $newRunspace.SessionStateProxy.SetVariable("syncHash", $syncHash)

                $PowerShellInstance.Runspace = $newRunspace

                # Run middleware in the order in which it was added
                foreach ($middleware in $this.RouteMiddleware) {
                    $PowerShellInstance.AddScript($middleware.ScriptBlock)
                }
                $Polaris.Log("Parsed Route: $Route")
                $Polaris.Log("Request Method: $($rawRequest.HttpMethod)")
                try {
                    $PowerShellInstance.AddScript($this.ScriptBlockRoutes[$route][$rawRequest.HttpMethod])
                }
                catch {
                    $FirstMatchingRoute = $this.ScriptBlockRoutes.where( {$route -match $_.Key})[0]
                    $Polaris.Log("First Matching Route Keys: $( $FirstMatchingRoute.Keys)")
                    $Script = $this.ScriptBlockRoutes[$FirstMatchingRoute.Keys[0]][$rawRequest.HttpMethod]
                    $PowerShellInstance.AddScript($Script) 
                }
                $PowerShellInstance.Invoke()
                # Handle errors
                if ($PowerShellInstance.InvocationStateInfo.State -eq [System.Management.Automation.PSInvocationState]::Failed) {
                    $this.Log($PowerShellInstance.InvocationStateInfo.Reason.ToString())
                    $response.Send($PowerShellInstance.InvocationStateInfo.Reason.ToString())
                    $response.SetStatusCode(500)
                }
                elseif ($PowerShellInstance.Streams.Error.Count) {
                    $errorsBody = "\n"
                    if ($PowerShellInstance.Streams.Error.Count) {
                        for ([int] $i = 0; $i -lt $PowerShellInstance.Streams.Error.Count; $i++) {
                            $errorsBody += "[" + $i + "]:\n"
                            $errorsBody += $PowerShellInstance.Streams.Error[$i].Exception.ToString()
                            $errorsBody += $PowerShellInstance.Streams.Error[$i].InvocationInfo.PositionMessage + "\n\n"
                        }
                    }
                    
                    $response.Send($errorsBody)
                    $this.Log(($PowerShellInstance | ConvertTo-Json -Depth 3 | Out-String))
                    $response.SetStatusCode(500)
                }
                
                $this.Log(($PowerShellInstance.Streams | ConvertTo-Json -Depth 3 | Out-String))
                # Handle logs
                if ($request.Query -and $request.Query[$this.GetLogsString]) {
                    $this.Log(($request.Query[$this.GetLogsString] | ConvertTo-Json -Depth 3 | Out-String))
                    $informationBody = "`n"
                    for ([int] $i = 0; $i -lt $PowerShellInstance.Streams.Information.Count; $i++) {
                        foreach ($tag in $PowerShellInstance.Streams.Information[$i].Tags) {
                            $informationBody += "[" + $tag + "]"
                        }

                        $informationBody += $PowerShellInstance.Streams.Information[$i].MessageData.ToString() + "`n"
                    }
                    $informationBody += "`n"

                    # Set response to the logs and the actual response (could be errors)
                    $logBytes = [System.Text.Encoding]::UTF8.GetBytes($informationBody)
                    $bytes = [byte[]]::new($logBytes.Length + $response.ByteResponse.Length)
                    $logBytes.CopyTo($bytes, 0)
                    $response.ByteResponse.CopyTo($bytes, $logBytes.Length)
                    $response.ByteResponse = $bytes
                }
                $rawResponse.StatusCode = $response.statusCode;
                $rawResponse.Headers = $response.Headers;
                $rawResponse.ContentType = $response.contentType;
                $rawResponse.ContentLength64 = $response.byteResponse.Length;
                $rawResponse.OutputStream.Write($response.byteResponse, 0, $response.byteResponse.Length);
                $rawResponse.OutputStream.Close();
                    
            }
            catch [System.Collections.Generic.KeyNotFoundException] {
        
                ($this.GetType())::Send($rawResponse, [System.Text.Encoding]::UTF8.GetBytes("Not Found"), 404, "text/plain; charset=UTF-8")
                $syncHash.Polaris.Log("404 Not Found")
        
            }
            catch {
                $this.Log(($_ | out-string))
                $syncHash.Polaris.Log(($PowerShellInstance.Commands | Format-List * | Out-String))
                $response.SetStatusCode(500)
                $response.Send($_)
                $response.Close()
                throw $_
            }
        }
    }
    

    [System.Net.HttpListener] InitListener([int] $port) {
        $this.Port = $port

        [System.Net.HttpListener] $this.Listener = [System.Net.HttpListener]::new()

        # If user is on a non-windows system or windows as administrator
        if ([system.environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT -or
            ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT -and
                ([System.Security.Principal.WindowsPrincipal]::new([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))) {
            $this.Listener.Prefixes.Add("http://+:" + $this.Port + "/")
        }
        else {
            $this.Listener.Prefixes.Add("http://localhost:" + $this.Port + "/")
        }

        $this.Listener.Start()
        return $this.Listener
    }

    static [void] Send([System.Net.HttpListenerResponse]$rawResponse, [PolarisResponse]$response) {
        try {
            [Polaris]::Send($rawResponse, $response.ByteResponse, $response.StatusCode, $response.ContentType, $response.Headers );
        }
        catch {
            throw $_         
        }
    }

    static [void] Send([System.Net.HttpListenerResponse] $rawResponse, [byte[]]$byteResponse, [int]$statusCode, [string]$contentType, [System.Net.WebHeaderCollection]$Headers) {
        $rawResponse.StatusCode = $statusCode;
        $rawResponse.Headers = $Headers;
        $rawResponse.ContentType = $contentType;
        $rawResponse.ContentLength64 = $byteResponse.Length;
        $rawResponse.OutputStream.Write($byteResponse, 0, $byteResponse.Length);
        $rawResponse.OutputStream.Close();
    }        
		
    static [void] Send(
        [System.Net.HttpListenerResponse] $rawResponse,
        [byte[]] $byteResponse,
        [int] $statusCode,
        [string] $contentType
    ) {
        $rawResponse.StatusCode = $statusCode;
        $rawResponse.ContentType = $contentType;
        $rawResponse.ContentLength64 = $byteResponse.Length;
        $rawResponse.OutputStream.Write($byteResponse, 0, $byteResponse.Length);
        $rawResponse.OutputStream.Close();
    }

    [Void] Log([string] $logString) {
        try {
            $this.Logger($logString)
        }
        catch {
            [Console]::WriteLine($_.Message)
            [Console]::WriteLine($logString)
        }
    }


    Polaris(
        [Action[string]]$Logger
    ) {
        $this.Logger = $Logger
    }
}
