
using namespace System.Collections
using namespace System.Management.Automation
using namespace System.Net
using namespace System.Security.Principal

function Test-WindowsElevation {
    $currentPrincipal = [WindowsPrincipal]::new([WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([WindowsBuiltInRole]::Administrator)
}





$StaticHandler = {
    Param($Request, $Response)
    $relativePath = $Request.Path -replace "^$VirtualRoot"
    $absolutePath = "$PhysicalPath$relativePath"
    if (Test-Path $absolutePath -PathType Leaf) {
        $Response.Body = Get-Content $absolutePath -Raw
    } elseif ($AllowDirectoryBrowsing) {
        $files = Get-ChildItem $absolutePath `
            | Select -ExpandProperty "Name" `
            | % {"<li><a href=`"$relativePath$_`">$_</a></li>"}
        $Response.Body = "
            <h1>Index of $relativePath</h1>
            <ol>
                $files
            </ol>
        "
    } else {
        $Response.StatusCode = 403
        $Response.Body = "Forbidden"
    }
}


function Receive-Request($Context, $Server) {
    try {
        # create default response object
        $response = [PSCustomObject]@{
            StatusCode  = 200
            Body        = ""
            ContentType = "text/plain"
        }

        # get matching middleware handlers
        $matchedRoutes = $Server.Routes | ? {
            $routeParams = $_.Handler.Ast.ParamBlock.Parameters.Extent.Text -replace "^\$"
            if ($Context.Request.HttpMethod -ne $_.Method) {
                $false
            } elseif ("Matches" -in $routeParams) {
                $Context.Request.Url.AbsolutePath -match $_.Path
            } else {
                $Context.Request.Url.AbsolutePath -like $_.Path
            }
        }

        # apply handlers to request
        if ($matchedRoutes) {
            $pipeline = [System.Collections.Queue]::new($matchedRoutes)
            try {
                # process each matching route in order of definition
                while ($pipeline.Count) {
                    $route = $pipeline.Dequeue()

                    # determine parameters supported by the handler
                    $handlerParameters = @{}
                    $supportedParameters = $route.Handler.Ast.ParamBlock.Parameters.Extent.Text -replace "^\$"
                    if ("Matches" -in $supportedParameters) {
                        $Request.Url.AbsolutePath -match $route.Path
                        $handlerParameters["Matches"] = $Matches
                    }
                    if ("Request" -in $supportedParameters) {
                        $handlerParameters["Request"] = $Context.Request
                    }
                    if ("Response" -in $supportedParameters) {
                        $handlerParameters["Response"] = $response
                    }

                    # process the handler, break out of the pipeline if the handler returns
                    if (&$route.Handler @handlerParameters) {
                        break
                    }
                }
            } catch {
                # unexpected server error (500)
                $response.StatusCode = 500
                if ($Server.Debug) {
                    $response.Body = (
                        "Server Error:",
                        $_,
                        $_.Exception,
                        $_.Exception.Message,
                        $_.Exception.InnerException,
                        $_.Exception.StackTrace
                    ) -join "`n"
                } else {
                    $response.Body = "Server Error"
                }
            }
        } else {
            # route not found (404)
            $response.StatusCode = 404
            $response.Body = "File Not Found"
        }

        # send response
        $byteResponse = $response.Body -as [char[]] -as [byte[]]
        $Context.Response.StatusCode = $response.StatusCode
        $Context.Response.ContentType = $response.ContentType
        $Context.Response.ContentLength64 = $byteResponse.Length
        $Context.Response.OutputStream.Write($byteResponse, 0, $byteResponse.Length)
    } catch {
        throw $_
    } finally {
        $Context.Response.OutputStream.Close()
    }
}
<#
.SYNOPSIS
Determines if 

.DESCRIPTION
Long description

.PARAMETER Handler
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Test-ValidHandler {
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Handler
    )

    $params = $Handler.Ast.ParamBlock.Parameters.Extent.Text -replace "\$"
    $diffs = Compare $params ("Matches", "Request", "Response") `
        | ? {$_.SideIndicator -eq "<="} `
        | % {$_.InputObject}
    return $diffs -as [bool]
}



<#
.SYNOPSIS
Registers a route with the server

.DESCRIPTION
Appends a route to the server's route list

.PARAMETER Server
The server to add the route to

.PARAMETER Route
The route object to add to the server

.PARAMETER Method
The method of the route to add to the server

.PARAMETER Path
The path of the route to add to the server

.PARAMETER Handler
The handler of the route to add to the server

.EXAMPLE
Add-Route -Route @{
    Method = "GET"
    Path = "^/helloworld/?$"
    Handler = $Handler
}
#>
function Add-Route {
    Param(
        [Parameter(Mandatory, ParameterSetName="Object")]
        [Parameter(Mandatory, ParameterSetName="Properties")]
        $Server,
        [Parameter(Mandatory, ParameterSetName="Object")]
        $Route,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        $Method,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [ValidateScript( {Test-ValidHandler $_} )]
        [scriptblock]$Handler
    )

    if (-not $route) {
        $route = @{
            Method  = $Method
            Path    = $Path
            Handler = $Handler
        }
    }

    $Server.Routes += $route
}


<#
.SYNOPSIS
Removes a route from the server

.DESCRIPTION
Removes all routes equal to the passed in route serialized

.PARAMETER Server
The server containing the route to be removed

.PARAMETER Route
The route object to remove from the server

.PARAMETER Method
The method of the route to remove from the server

.PARAMETER Path
The path of the route to remove from the server

.PARAMETER Handler
The handler of the route to remove from the server

.EXAMPLE
Remove-Route -Route @{
    Method = "GET"
    Path = "^/helloworld/?$"
    Handler = $Handler
}

.NOTES
Will not error if the route is not registered
#>
function Remove-Route {
    Param(
        [Parameter(Mandatory, ParameterSetName="Object")]
        [Parameter(Mandatory, ParameterSetName="Properties")]
        $Server,
        [Parameter(Mandatory, ParameterSetName="Object")]
        $Route,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        $Method,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [ValidateScript( {Test-ValidHandler $_} )]
        [scriptblock]$Handler
    )

    if (-not $route) {
        $route = @{
            Method  = $Method
            Path    = $Path
            Handler = $Handler
        }
    }

    $Server.Routes = $Server.Routes | ? {$_ -ne $route}
}


function Add-StaticRoute {
    Param(
        [Parameter(Mandatory)]
        $Server,
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path $_} )]
        [string]$PhysicalRoot,
        [Parameter(Mandatory)]
        [string]$VirtualRoot,
        [switch]$AllowDirectoryBrowsing
    )

    Add-Route -Route @{
        Method  = "GET"
        Path    = "$VirtualRoot/*"
        Handler = $staticHandler.GetNewClosure()
    }
}



<#
.SYNOPSIS
Starts the server

.DESCRIPTION
Starts and returns a job with the server's loop

.PARAMETER Server
The Polaris server to start

.EXAMPLE
Start-Server $PolarisServer
#>
function Start-Server {
    Param(
        [Parameter(Mandatory)]
        $Server
    )

    $ErrorActionPreference = "Stop"
    $runspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Server.MaxThreadCount)
    $runspacePool.Open()

    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add("http://localhost:$($Server.Port)/")
    $listener.Start()
    Write-Information "Listening on port $($Server.Port)"

    while ($true) {
        & {
            # remove completed threads
            $threads | ? {$_.IsCompleted} | % {$_.Dispose()}
            $threads = @($threads | ? {-not $_.IsCompleted})
    
            # prepare thread
            $thread = [powershell]::Create()
            $thread.AddScript(${function:Receive-Request})
            $thread.RunspacePool = $runspacePool
    
            # block until we receive a new request
            $context = $listener.GetContext()

            # process the request in a separate thread
            $thread.AddArgument($context)
            $thread.AddArgument($Server)
            if ($Server.Debug) {
                $thread.Invoke()
            } else {
                $thread.BeginInvoke()
            }
            $threads += $thread
        } | Out-Null
    }
}


<#
.SYNOPSIS
Stops the running server

.DESCRIPTION
Kills the job spawned by the passed-in Polaris server

.PARAMETER Server
The running PolarisServer object

.EXAMPLE
Stop-Server $PolarisServer
#>
function Stop-Server {
    Param(
        [Parameter(Mandatory)]
        $Server
    )

    Stop-Job -Id $Server.JobID
    Remove-Job -Id $Server.JobID
    $Server.JobId = $null
}

