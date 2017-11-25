
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
        [PolarisServer]$Server,
        [Parameter(Mandatory, ParameterSetName="Object")]
        [PolarisRoute]$Route,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [HttpMethod]$Method,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [scriptblock]$Handler
    )

    if (-not $route) {
        $route = [PolarisRoute]@{
            Method = $Method
            Path = $Path
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
        [PolarisServer]$Server,
        [Parameter(Mandatory, ParameterSetName="Object")]
        [PolarisRoute]$Route,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [HttpMethod]$Method,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName="Properties")]
        [scriptblock]$Handler
    )

    if (-not $route) {
        $route = [PolarisRoute]@{
            Method = $Method
            Path = $Path
            Handler = $Handler
        }
    }

    $Server.Routes = $Server.Routes | ? {$_ -ne $route}
}


function Add-Middleware {
    throw "NYI"
}


function Remove-Middleware {
    throw "NYI"
}


function Add-StaticRoute {
    throw "NYI"
}


function Remove-StaticRoute {
    throw "NYI"
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
        [PolarisServer]$Server
    )

    $Server.JobID = Start-Job `
        -ScriptBlock {([PolarisServer]$using:server).Start()} `
        -InitializationScript ([scriptblock]::create((Get-Content "$PSScriptRoot\types.ps1" -Raw)))
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
        [PolarisServer]$Server
    )

    Stop-Job -Id $Server.JobID
    Remove-Job -Id $Server.JobID
}

