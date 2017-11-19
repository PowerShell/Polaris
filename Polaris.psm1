if ($PSVersionTable.PSEdition -eq "Core") {
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/netstandard2.0/Polaris.dll"
} else {
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/net451/Polaris.dll"
}
$global:Polaris = $null

# Handles the removal of the module
$m = $ExecutionContext.SessionState.Module
$m.OnRemove = {
    Stop-Polaris
    Remove-Variable -Name Polaris -Scope global
}.GetNewClosure()

##############################
#.SYNOPSIS
# Adds a new HTTP Route
#
#.DESCRIPTION
# This cmdlet defines an HTTP route that your server will listen for
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER Method
# The HTTP Verb/Method for this request
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PolarisWebRoute -Path "/helloworld" -Method "GET" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PolarisWebRoute -Path "/helloworld" -Method "GET" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-PolarisWebRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Mandatory=$True, Position=1)]
        [string]
        $Method,

        [Parameter(Position=2)]
        [scriptblock]
        $ScriptBlock,

        [Parameter()]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded
    if ($ScriptPath -ne $null -and $ScriptPath -ne "") {
        if(-Not (Test-Path -Path $ScriptPath)) {
            ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "File does not exist at path $ScriptPath"
        }

        $ScriptBlock = [ScriptBlock]::Create((Get-Content -Path $ScriptPath -Raw))
    }
    $global:Polaris.AddRoute($Path, $Method, $ScriptBlock.ToString())
}

<#
.SYNOPSIS
Removes the web route.

.DESCRIPTION
Removes the web route with the specified path and method.

.PARAMETER Path
The path of the route you want to remove.

.PARAMETER Method
The method of the route you want to remove.

.EXAMPLE
Remove-PolarisWebRoute -Path /out -Method PUT

#>
function Remove-PolarisWebRoute {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Mandatory=$True, Position=1)]
        [string]
        $Method
    )
    if ($global:Polaris -ne $null) {
        $global:Polaris.RemoveRoute($Path, $Method)
    }
}

<#
.SYNOPSIS
Get the object containing the routes.

.DESCRIPTION
Get the object containing the routes. They are organized by Path -> Method -> Script block

.EXAMPLE
Get-PolarisWebRoute

#>
function Get-PolarisWebRoute {
    [CmdletBinding()]
    param()

    if ($global:Polaris -ne $null) {
        return $global:Polaris.ScriptBlockRoutes
    }
}

##############################
#.SYNOPSIS
# Defines routes to serve a folder at the "/" endpoint
#
#.DESCRIPTION
# Defines routes to serve a folder at the "/" endpoint. Perfect for static websites.
#
#.PARAMETER RoutePath
# (Optional) Root route that the folder path will be served to. Defaults to "/"
#
#.PARAMETER FolderPath
# Path to the folder you want to serve.
#
#.EXAMPLE
# New-PolarisStaticRoute -Path ./public
#
##############################
function New-PolarisStaticRoute {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $RoutePath = "/",

        [Parameter(Mandatory=$True, Position=1)]
        [string]
        $FolderPath)
    CreateNewPolarisIfNeeded
    if(-Not (Test-Path -Path $FolderPath)) {
        ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "Folder does not exist at path $FolderPath"
    }

    $allPaths = Get-ChildItem -Path $FolderPath -Recurse | ForEach-Object { $_.FullName }
    $resolvedPath = (Resolve-Path -Path $FolderPath).Path


    $allPaths | ForEach-Object {
    $scriptTemplate = @"
if(`$PSVersionTable.PSEdition -eq "Core") {
    `$bytes = Get-Content "$_" -AsByteStream -ReadCount 0
} else {
    `$bytes = Get-Content "$_" -Encoding Byte -ReadCount 0
}
`$response.SetContentType(([PolarisCore.PolarisResponse]::GetContentType("$_")))
`$response.ByteResponse = `$bytes
"@

        New-PolarisGetRoute -Path "$($RoutePath.TrimEnd("/"))$($_.Substring($resolvedPath.Length).Replace('\','/'))" `
            -ScriptBlock ([ScriptBlock]::Create($scriptTemplate))
    }
}

<#
.SYNOPSIS
Add a new route middleware.

.DESCRIPTION
Route middleware is used to manipulate request and response objects before it makes it to your route logic.

.PARAMETER Name
The name of the middleware.

.PARAMETER ScriptBlock
The middleware script block that will be executed

.PARAMETER ScriptPath
A path to the middleware script that will be executed

.EXAMPLE
$JsonBodyParserMiddlerware = {
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}
New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddleware

#>
function New-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Name,

        [Parameter(Position=1)]
        [scriptblock]
        $ScriptBlock,

        [Parameter()]
        [string]
        $ScriptPath
    )
    CreateNewPolarisIfNeeded
    if ($ScriptPath -ne $null -and $ScriptPath -ne "") {
        if(-Not (Test-Path -Path $ScriptPath)) {
            ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "File does not exist at path $ScriptPath"
        }

        $ScriptBlock = [ScriptBlock]::Create((Get-Content -Path $ScriptPath -Raw))
    }
    $global:Polaris.AddMiddleware($Name, $ScriptBlock.ToString())
}

<#
.SYNOPSIS
Removes the middleware.

.DESCRIPTION
Removes the middleware from the list of middleware.

.PARAMETER Name
The name of the middleware you want to remove.

.EXAMPLE
Remove-PolarisRouteMiddleware -Name JsonBodyParser

#>
function Remove-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Name
    )
    if ($global:Polaris -ne $null) {
        $global:Polaris.RemoveMiddleware($Name)
    }
}

<#
.SYNOPSIS
Get the route middlewares.

.DESCRIPTION
Get the route middlewares. You can optionally specify a name for a filter.

.PARAMETER Name
(Optional) The specific middleware you're looking for.

.EXAMPLE
Get-PolarisRouteMiddleware

Get-PolarisRouteMiddleware -Name JsonBodyParser

#>

function Get-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Name
    )

    if ($global:Polaris -ne $null) {
        if ($Name -ne $null -and $Name -ne "") {
            return $global:Polaris.RouteMiddleware.Where({ $_.Name -eq $Name })
        }
        return $global:Polaris.RouteMiddleware
    }
}

##############################
#.SYNOPSIS
# Starts the web server.
#
#.DESCRIPTION
# Starts the web server.
#
#.PARAMETER Port
# (Optional) The port you want the web server to run on. Defaults to 8080.
#
#.PARAMETER MinRunspaces
# (Optional) The minimum ammount of PowerShell runspaces you'd like to use. Defaults to 1.
#
#.PARAMETER MaxRunspaces
# (Optional) The maximum ammount of PowerShell runspaces you'd like to use. Defaults to 1.
#
#.PARAMETER UseJsonBodyParserMiddleware
# (Optional) Will enable the Json body parser middleware.
#
#.EXAMPLE
# Start-Polaris
#
# Start-Polaris -Port 8081
#
##############################
function Start-Polaris {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [Int32]
        $Port = 8080,

        [Parameter(Position=1)]
        [Int32]
        $MinRunspaces = 1,

        [Parameter(Position=2)]
        [Int32]
        $MaxRunspaces = 1,

        [Parameter()]
        [switch]
        $UseJsonBodyParserMiddleware = $false
        )
    CreateNewPolarisIfNeeded

    if ($UseJsonBodyParserMiddleware) {
        New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware
    }

    $global:Polaris.Start($Port, $MinRunspaces, $MaxRunspaces)
    return $global:Polaris
}

##############################
#.SYNOPSIS
# Stops the web server.
#
#.DESCRIPTION
# Stops the web server.
#
#.PARAMETER ServerContext
# (Optional) The server that you wish to stop. Defaults to the global instance.
#
#.EXAMPLE
# Stop-Polaris
#
# Stop-Polaris -ServerContext $app
#
##############################
function Stop-Polaris {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [PolarisCore.Polaris]
        $ServerContext = $global:Polaris)
    if ($ServerContext -ne $null) {
        $ServerContext.Stop()
        try {
            Invoke-RestMethod "http://localhost:$($global:Polaris.Port)/ping"
        }
        catch {
            Write-Verbose "Server already stopped."
        }
    }
}

##############################
# HELPERS
##############################

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "GET"
#
#.DESCRIPTION
# A shorthand version of doing New-PolarisWebRoute -Method "GET"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PolarisGetRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PolarisGetRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-PolarisGetRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    New-PolarisWebRoute -Path $Path -Method "GET" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "POST"
#
#.DESCRIPTION
# A shorthand version of doing New-PolarisWebRoute -Method "POST"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PolarisPostRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PolarisPostRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a POST request would display the example.
#
##############################
function New-PolarisPostRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    New-PolarisWebRoute -Path $Path -Method "POST" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "PUT"
#
#.DESCRIPTION
# A shorthand version of doing New-PolarisWebRoute -Method "PUT"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PolarisPutRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PolarisPutRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a PUT request would display the example.
#
##############################
function New-PolarisPutRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    New-PolarisWebRoute -Path $Path -Method "PUT" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "DELETE"
#
#.DESCRIPTION
# A shorthand version of doing New-PolarisWebRoute -Method "DELETE"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PolarisDeleteRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PolarisDeleteRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a DELETE request would display the example.
#
##############################
function New-PolarisDeleteRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded
    New-PolarisWebRoute -Path $Path -Method "DELETE" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

<#
.SYNOPSIS
Helper function that turns on the Json Body parsing middleware.

.DESCRIPTION
Helper function that turns on the Json Body parsing middleware.

.EXAMPLE
Use-JsonBodyParserMiddleware

#>
function Use-JsonBodyParserMiddleware {
    [CmdletBinding()]
    param()

    New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware
}

##############################
# INTERNAL
##############################
function CreateNewPolarisIfNeeded () {
    if ($global:Polaris -eq $null) {
        [Action[string]]$logger = { param($str) Write-Verbose "$str" }
        $global:Polaris = New-Object -TypeName PolarisCore.Polaris -ArgumentList $logger
    }
}

$JsonBodyParserMiddlerware = {
    if ($Request.BodyString -ne $null) {
        try {
            $Request.Body = $Request.BodyString | ConvertFrom-Json
        } catch {
            Write-Verbose "Failed to convert body from json"
        }
    }
}

Export-ModuleMember -Function `
    New-PolarisWebRoute, `
    Remove-PolarisWebRoute, `
    Get-PolarisWebRoute, `
    New-PolarisGetRoute, `
    New-PolarisPostRoute, `
    New-PolarisPutRoute, `
    New-PolarisDeleteRoute, `
    New-PolarisStaticRoute, `
    New-PolarisRouteMiddleware, `
    Remove-PolarisRouteMiddleware, `
    Get-PolarisRouteMiddleware, `
    Use-JsonBodyParserMiddleware, `
    Start-Polaris, `
    Stop-Polaris