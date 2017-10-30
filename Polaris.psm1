if (Test-Path "$PSScriptRoot/PolarisCore/bin/Debug/net451/") {
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/net451/Polaris.dll"
} else {
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/netstandard2.0/Polaris.dll"
}
$global:Polaris = $null

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
# New-WebRoute -Path "/helloworld" -Method "GET" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-WebRoute -Path "/helloworld" -Method "GET" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-WebRoute {
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
Remove-WebRoute -Path /out -Method PUT

#>
function Remove-WebRoute {
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
        $global:Polaris.RemoveRoute($Path, $Method);
    }
}

<#
.SYNOPSIS
Get the object containing the routes.

.DESCRIPTION
Get the object containing the routes. They are organized by Path -> Method -> Script block

.EXAMPLE
Get-WebRoute

#>
function Get-WebRoute {
    [CmdletBinding()]
    param()

    if ($global:Polaris -ne $null) {
        return $global:Polaris.ScriptBlockRoutes;
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
# New-StaticRoute -Path ./public
#
##############################
function New-StaticRoute {
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
`$bytes = Get-Content "$_" -Encoding Byte -ReadCount 0
`$response.SetContentType(([PolarisCore.PolarisResponse]::GetContentType("$_")))
`$response.ByteResponse = `$bytes
"@

        New-GetRoute -Path "$($RoutePath.TrimEnd("/"))$($_.Substring($resolvedPath.Length).Replace('\','/'))" `
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
New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddleware

#>
function New-RouteMiddleware {
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
    CreateNewPolarisIfNeeded;
    if ($ScriptPath -ne $null -and $ScriptPath -ne "") {
        if(-Not (Test-Path -Path $ScriptPath)) {
            ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "File does not exist at path $ScriptPath";
        }

        $ScriptBlock = [ScriptBlock]::Create((Get-Content -Path $ScriptPath -Raw));
    }
    $global:Polaris.AddMiddleware($Name, $ScriptBlock.ToString());
}

<#
.SYNOPSIS
Removes the middleware.

.DESCRIPTION
Removes the middleware from the list of middleware.

.PARAMETER Name
The name of the middleware you want to remove.

.EXAMPLE
Remove-RouteMiddleware -Name JsonBodyParser

#>
function Remove-RouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Name
    )
    if ($global:Polaris -ne $null) {
        $global:Polaris.RemoveMiddleware($Name);
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
Get-RouteMiddleware

Get-RouteMiddleware -Name JsonBodyParser

#>

function Get-RouteMiddleware {
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
        return $global:Polaris.RouteMiddleware;
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
        New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware
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
        finally {
            Write-Verbose "Server Stopped"
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
# A shorthand version of doing New-WebRoute -Method "GET"
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
# New-GetRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-GetRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-GetRoute {
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
    New-WebRoute -Path $Path -Method "GET" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "POST"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "POST"
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
# New-PostRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PostRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a POST request would display the example.
#
##############################
function New-PostRoute {
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
    New-WebRoute -Path $Path -Method "POST" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "PUT"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "PUT"
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
# New-PutRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-PutRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a PUT request would display the example.
#
##############################
function New-PutRoute {
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
    New-WebRoute -Path $Path -Method "PUT" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "DELETE"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "DELETE"
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
# New-DeleteRoute -Path "/helloworld" -ScriptBlock {
#    $response.Send('Hello World')
# }
#
# New-DeleteRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a DELETE request would display the example.
#
##############################
function New-DeleteRoute {
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
    New-WebRoute -Path $Path -Method "DELETE" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath
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

    New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware;
}

##############################
# INTERNAL
##############################
function CreateNewPolarisIfNeeded () {
    if ($global:Polaris -eq $null) {
        [Action[string]]$logger = { param($str) Write-Verbose "$str" }
        $global:Polaris = [PolarisCore.Polaris]::new($logger)
    }
}

$JsonBodyParserMiddlerware = {
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}

Export-ModuleMember -Function `
    New-WebRoute, `
    Remove-WebRoute, `
    Get-WebRoute, `
    New-GetRoute, `
    New-PostRoute, `
    New-PutRoute, `
    New-DeleteRoute, `
    New-StaticRoute, `
    New-RouteMiddleware, `
    Remove-RouteMiddleware, `
    Get-RouteMiddleware, `
    Use-JsonBodyParserMiddleware, `
    Start-Polaris, `
    Stop-Polaris