class Polaris {
    
    [Int]$Port
    [System.Collections.Generic.List[PolarisMiddleWare]]$RouteMiddleWare = [System.Collections.Generic.List[PolarisMiddleWare]]::new()
    [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, scriptblock]]]]$ScriptBlockRoutes = [System.Collections.Generic.Dictionary[string, [System.Collections.Generic.Dictionary[string, scriptblock]]]]::new()
    hidden [Action[string]]$Logger
    hidden [System.Net.HttpListener]$Listener
    hidden [System.Management.Automation.Runspaces.RunspacePool]$PowerShellPool = [RunspaceFactory]::CreateRunspacePool()
    hidden [bool]$StopServer = $False
    [string]$getLogsString = "PolarisLogs"
    [string] $ClassDefinitions = $script:ClassDefinitions
    $ContextHandler = (New-ScriptBlockCallback -Callback {

        param(
            [System.IAsyncResult]
            $AsyncResult
        ) 

        [Polaris]$Polaris = $AsyncResult.AsyncState
        $context = $Polaris.Listener.EndGetContext($AsyncResult)
        

        if ($Polaris.StopServer -or $null -eq $context) {
            if ($null -ne $Polaris.Listener) {
                $Polaris.Listener.Close()
            }
            break
        }

        $Polaris.Listener.BeginGetContext($Polaris.ContextHandler, $Polaris)

        [System.Net.HttpListenerRequest] $rawRequest = $context.Request
        [System.Net.HttpListenerResponse] $rawResponse = $context.Response

        $Polaris.Log("request came in: " + $rawRequest.HttpMethod + " " + $rawRequest.RawUrl)

        [PolarisRequest] $request = [PolarisRequest]::new($rawRequest)
        [PolarisResponse] $response = [PolarisResponse]::new()

            
        [string] $route = $rawRequest.Url.AbsolutePath.TrimEnd('/').TrimStart('/')

        try {

            # Run middleware in the order in which it was added
            foreach ($middleware in $Polaris.RouteMiddleware) {
                $middleware.ScriptBlock.Invoke()
            }
            $Polaris.Log("Parsed Route: $Route")
            $Polaris.Log("Request Method: $($rawRequest.HttpMethod)")
            $Routes = $Polaris.ScriptBlockRoutes
            $MatchingRoute = $Routes.keys.where( {$route -match $_})[0]
            $MatchingMethod = $false

            if ($MatchingRoute) {
                $MatchingMethod = $Routes[$MatchingRoute].Keys -contains $request.Method
            }

            if ($MatchingRoute -and $MatchingMethod) {
                try {
                    $ScriptBlock = [scriptblock]::Create(
                        "param(`$request,`$Response)`r`n" +
                            $Routes[$MatchingRoute][$request.Method].ToString()
                    )
                    $ScriptBlock.Invoke(@($request,$response))
                }
                catch {
                    $errorsBody += $_.Exception.ToString()
                    $errorsBody += $_.InvocationInfo.PositionMessage + "`n`n"
                    $response.Send($errorsBody)
                    $Polaris.Log(($PowerShellInstance | ConvertTo-Json -Depth 3 | Out-String))
                    $response.SetStatusCode(500)
                }
            }
            elseif ($MatchingRoute) {
                $response.Send("Method not allowed")
                $response.SetStatusCode(405)
            }
            else {
                $response.send("Not found")
                $response.SetStatusCode(404)
            }
            
            [Polaris]::Send($rawResponse, $response)
                
        }
        catch {
            $Polaris.Log(($_ | out-string))
            $response.SetStatusCode(500)
            $response.Send($_)
            $response.Close()
            throw $_
        }
    })


    [Void] AddRoute(
        [string]$path,
        [string]$method,
        [scriptblock]$scriptBlock
    ) {
        if ($null -eq $scriptBlock) {
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
        if ($null -eq $path) {
            throw [ArgumentNullException]::new("path")
        }
        if ($null -eq $method) {
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
        [scriptblock]$scriptBlock
    ) {
        if ($null -eq $scriptBlock) {
            throw [ArgumentNullException]::new("scriptBlock")
        }
        $this.RouteMiddleWare.Add
        $this.RouteMiddleware.Add([PolarisMiddleware]@{
                'Name'        = $name
                'ScriptBlock' = $scriptBlock
            })
    }

    RemoveMiddleware([string]$name) {
        if ($null -eq $name) {
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
        $this.PowerShellPool.SetMinRunspaces($minRunspaces)
        $this.PowerShellPool.SetMaxRunspaces($maxRunspaces)
        $this.PowerShellPool.Open()
        $this.InitListener($port)
        $this.Listener.BeginGetContext($this.ContextHandler, $this)
        $this.Log("App listening on Port: " + $port + "!")
    }

    [void] Stop() {
        $this.StopServer = $true
        $this.PowerShellPool.Close()
        $this.Listener.Close()
        $this.Listener.Dispose()
        $this.Log("Server Stopped.")
    }    

    [void] InitListener([int] $port) {
        $this.Port = $port

        $this.Listener = [System.Net.HttpListener]::new()

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
            Write-Host $_.Message
            Write-Host $logString
        }
    }


    Polaris(
        [Action[string]]$Logger
    ) {
        if($Logger){
            $this.Logger = $Logger
        } else {
            $this.Logger = {
                param($LogItem)
                Write-Host $LogItem
            }
        }

    }
}
