if ($PSVersionTable.PSEdition -eq "Core")
{
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/netstandard2.0/Polaris.dll"
}
else
{
    Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/net451/Polaris.dll"
}
$global:Polaris = $null

# Handles the removal of the module
$ExecutionContext.SessionState.Module.OnRemove =
{
    If ( $global:Polaris )
    {
        Stop-Polaris -ErrorAction SilentlyContinue
        Remove-Variable -Name Polaris -Scope global
    }
}.GetNewClosure()

<#
.SYNOPSIS
    Add web route.
.DESCRIPTION
    Create web route for server to serve.
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER Method
    HTTP verb/method to be serviced.
    Valid values are GET, POST, PUT, and DELETE
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.EXAMPLE
    New-WebRoute -Path "helloworld" -Method "GET" -ScriptBlock { $response.Send( 'Hello World' ) }
    To view results:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
.EXAMPLE
    New-WebRoute -Path "helloworld" -Method "GET" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
#>
function New-WebRoute
{
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1 )]
        [ValidateSet( 'GET', 'POST', 'PUT', 'DELETE' )]
        [string]
        $Method,

        [Parameter( Mandatory = $True, Position = 2, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    $ExistingWebRoute = Get-WebRoute -Path $Path -Method $Method

    if ( $ExistingWebRoute -and $Force )
    {
        Remove-WebRoute -Path $Path -Method $Method
        $ExistingWebRoute = Get-WebRoute -Path $Path -Method $Method
    }

    if ( $ExistingWebRoute )
    {
        $PSCmdlet.WriteError( (
            New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                [System.Exception]'WebRoute already exists.'
                $Null
                [System.Management.Automation.ErrorCategory]::ResourceExists
                "$Path,$Method" ) ) )
    }
    else
    {
        CreateNewPolarisIfNeeded

        if ( -not $Path.StartsWith( '/' ) )
        {
            $Path = '/' + $Path
        }

        switch ( $PSCmdlet.ParameterSetName )
        {
            'ScriptBlock'
            {
                $global:Polaris.AddRoute( $Path, $Method, [string]$ScriptBlock )
            }
            'ScriptPath'
            {
                if ( Test-Path -Path $ScriptPath )
                {
                    $Script = Get-Content -Path $ScriptPath -Raw
                    $global:Polaris.AddRoute( $Path, $Method, $Script )
                }
                else
                {
                    $PSCmdlet.WriteError( (
                        New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                            [System.Exception]'ScriptPath not found.'
                            $Null
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound
                            $ScriptPath ) ) )
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Removes the web route.
.DESCRIPTION
    Removes the web route(s) matching the specified path(s) and method(s).
.PARAMETER Path
    Path(s) of the route(s) to remove.
    Accepts multiple values and wildcards.
    Accepts pipeline input.
    Accepts pipeline input by property name.
    Defaults to all paths (*).
.PARAMETER Method
    Method(s) of the route(s) to remove.
    Accepts pipeline input by property name.
    Accepts multiple values and wildcards.
    Defaults to all methods (*).
.EXAMPLE
    Remove-WebRoute
    Removes all existing web routes.
.EXAMPLE
    Remove-WebRoute -Path 'helloworld' -Method GET
    Removes the web route for method GET for path helloworld.
.EXAMPLE
    Remove-WebRoute -Path 'sub1/sub2/*'
    Removes all web routes for all methods for paths starting with sub1/sub2/.
.EXAMPLE
    Remove-WebRoute -Path 'sub1/sub2/*' -Method GET, POST
    Removes all web routes for GET and POST methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-WebRoute -Method Delete | Remove-Method
    Removes all web routes for DELETE methods for all paths.
#>
function Remove-WebRoute
{
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Path = '*',

        [Parameter( ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Method = '*' )

    process
    {
        if ( $global:Polaris )
        {
            $WebRoutes = Get-WebRoute -Path $Path -Method $Method
            
            ForEach ( $Route in $WebRoutes )
            {
                $global:Polaris.RemoveRoute( $Route.Path, $Route.Method )
            }
        }
    }
}

<#
.SYNOPSIS
    Get web routes.
.DESCRIPTION
    Get web routes filtered by Path and Method, as specified.
.PARAMETER Path
    Path of the route(s) to get.
    Accepts pipeline input.
    Accepts pipeline input by property name.
    Accepts multiple values and wildcards.
    Defaults to all paths (*).
.PARAMETER Method
    Method(s) of the route(s) to get.
    Accepts pipeline input by property name.
    Accepts multiple values and wildcards.
    Defaults to all methods (*).
.EXAMPLE
    Get-WebRoute
    Gets all web routes.
.EXAMPLE
    Get-WebRoute -Path 'helloworld' -Method 'GET'
    Gets the web route for method GET for path helloworld.
.EXAMPLE
    Get-WebRoute -Path 'sub1/sub2/*'
    Gets all web routes for all methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-WebRoute -Path 'sub1/sub2/*' -Method GET, POST
    Gets all web routes for GET and POST methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-WebRoute -Method Delete
    Gets all web routes for DELETE methods for all paths.
#>
function Get-WebRoute
{
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Path = '*',

        [Parameter( ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Method = '*' )
    
    process
    {
        if ( $global:Polaris )
        {
            $WebRoutes = [System.Collections.ArrayList]@()

            ForEach ( $Route in $global:Polaris.ScriptBlockRoutes.GetEnumerator() )
            {
                ForEach ( $RouteMethod in $Route.Value.GetEnumerator() )
                {
                    $Null = $WebRoutes.Add( [pscustomobject]@{ Path = $Route.Key; Method = $RouteMethod.Key; Scriptblock = $RouteMethod.Value } )
                }
            }

            $Filter = [scriptblock]::Create( (
                '( ' + 
                ( $Path.ForEach({   "`$_.Path   -like `"$_`"" } ) -join ' -or ' ) + 
                ' ) -and ( ' +
                ( $Method.ForEach({ "`$_.Method -like `"$_`"" } ) -join ' -or ' ) +
                ' )' ) )

            $WebRoutes = $WebRoutes.Where( $Filter )

            return $WebRoutes
        }
    }
}

<#
.SYNOPSIS
    Creates web routes to recursively serve folder contents
.DESCRIPTION
    Creates web routes to recursively serve folder contents. Perfect for static websites.
.PARAMETER RoutePath
    Root route that the folder path will be served to.
    Defaults to "/".
.PARAMETER FolderPath
    Full path and name of the folder to serve.
.PARAMETER Force
    Use -Force to overwrite existing web route(s) for the same paths.
.EXAMPLE
    New-StaticRoute -RoutePath 'public' -Path D:\FolderShares\public
    Creates web routes for GET method for each file recursively within D:\FolderShares\public
    at relative path /public, for example, http://localhost:8080/public/File1.html
.EXAMPLE
    Get-WebRoute -Path 'public/*' -Method GET | Remove-WebRoute
    New-StaticRoute -RoutePath 'public' -Path D:\FolderShares\public
    Updates website web routes. (Deletes all existing web routes and creates new web routes
    for all existing folder content.)
.NOTES
    Folders are not browsable. New files are not added dynamically.
#>
function New-StaticRoute
{
    [CmdletBinding()]
    param(
        [string]
        $RoutePath = "/",

        [Parameter( Mandatory = $True )]
        [string]
        $FolderPath,
        
        [switch]
        $Force )
    
    $ErrorAction = $PSBoundParameters["ErrorAction"]
    If ( -not $ErrorAction )
    {
        $ErrorAction = $ErrorActionPreference
    }
    
    CreateNewPolarisIfNeeded
    
    if ( -not ( Test-Path -Path $FolderPath ) )
    {
        ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "Folder does not exist at path $FolderPath"
    }

    $allPaths = Get-ChildItem -Path $FolderPath -Recurse -File | ForEach-Object { $_.FullName }
    $resolvedPath = ( Resolve-Path -Path $FolderPath ).Path

    $RoutePath = $RoutePath.TrimEnd( '/' )

    ForEach ( $Path in $AllPaths )
    {
        $StaticPath = "$RoutePath$( $Path.Substring( $ResolvedPath.Length ).Replace( '\' , '/' ) )"
        
        If ( $PSVersionTable.PSEdition -eq "Core" )
        {
            $ByteParam = '-AsByteStream'
        }
        Else
        {
            $ByteParam = '-Encoding Byte'
        }

        $ScriptBlock = [ScriptBlock]::Create( @"
            `$bytes = Get-Content -LiteralPath "$Path" $ByteParam -ReadCount 0
            `$response.SetContentType( ( [PolarisCore.PolarisResponse]::GetContentType( "$Path" ) ) )
            `$response.ByteResponse = `$bytes
"@ )

        New-WebRoute -Path $StaticPath -Method GET -ScriptBlock $ScriptBlock -Force:$Force -ErrorAction:$ErrorAction
    }
}

<#
.SYNOPSIS
    Add new route middleware.
.DESCRIPTION
    Creates new route middleware. Route middleware scripts are used to
    manipulate request and response objects and run before web route scripts.
.PARAMETER Name
    Name of the middleware.
.PARAMETER ScriptBlock
    ScriptBlock to run when middleware is triggered.
.PARAMETER ScriptPath
    Full path and name to script to run when middleware is triggered.
.PARAMETER Force
    Use -Force to overwrite any existing middleware with the same name.
.EXAMPLE
$JsonBodyParserMiddlerware =
{
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}
New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddleware
#>
function New-RouteMiddleware
{
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Name,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    $ExistingMiddleWare = Get-RouteMiddleware -Name $Name

    if ( $ExistingMiddleWare -and $Force )
    {
        Remove-RouteMiddleware -Name $Name
        $ExistingMiddleWare = Get-RouteMiddleware -Name $Name
    }

    if ( $ExistingMiddleWare )
    {
        $PSCmdlet.WriteError( (
            New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                [System.Exception]'RouteMiddleware already exists.'
                $Null
                [System.Management.Automation.ErrorCategory]::ResourceExists
                "$Name" ) ) )
    }
    else
    {
        CreateNewPolarisIfNeeded

        switch ( $PSCmdlet.ParameterSetName )
        {
            'ScriptBlock'
            {
                $global:Polaris.AddMiddleware( $Name, [string]$ScriptBlock )
            }
            'ScriptPath'
            {
                if ( Test-Path -Path $ScriptPath )
                {
                    $Script = Get-Content -Path $ScriptPath -Raw
                    $global:Polaris.AddMiddleware( $Name, $Script )
                }
                else
                {
                    $PSCmdlet.WriteError( (
                        New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                            [System.Exception]'ScriptPath not found.'
                            $Null
                            [System.Management.Automation.ErrorCategory]::ObjectNotFound
                            $ScriptPath ) ) )
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Remove route middleware.
.DESCRIPTION
    Remove route middleware matching the specified name(s).
.PARAMETER Name
    Name of the middleware to remove.
    Accepts multiple values and wildcards.
    Accepts pipeline input.
    Accepts pipeline input by property name.
    Defaults to all names (*).
.EXAMPLE
    Remove-RouteMiddleware -Name JsonBodyParser
.EXAMPLE
    Remove-RouteMiddleware
    Removes all route middleware.
.EXAMPLE
    Remove-RouteMiddleware -Name ParamCheck*, ParamVerify*
    Removes any route middleware with names starting with ParamCheck or ParamVerify.
.EXAMPLE
    Get-RouteMiddelware | Remove-RouteMiddleware
    Removes all reoute middleware.
#>
function Remove-RouteMiddleware
{
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Name = '*' )
    
    process
    {
        if ( $global:Polaris  )
        {
            $Middleware = Get-RouteMiddleware -Name $Name

            ForEach ( $Ware in $MiddleWare )
            {
                $global:Polaris.RemoveMiddleware( $Ware.Name )
            }
        }
    }
}

<#
.SYNOPSIS
    Get route middleware.
.DESCRIPTION
    Get route middleware matching the specified name(s).
.PARAMETER Name
    Name of the middleware to get.
    Accepts pipeline input.
    Accepts pipeline input by property name.
    Accepts multiple values and wildcards.
    Defaults to all names (*).
.EXAMPLE
    Get-RouteMiddleware
.EXAMPLE
    Get-RouteMiddleware -Name JsonBodyParser
.EXAMPLE
    Get-RouteMiddleware -Name ParamCheck*, ParamVerify*
#>
function Get-RouteMiddleware
{
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
                    ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Name = '*' )

    process
    {
        if ( $global:Polaris )
        {
            $Filter = [scriptblock]::Create( ( $Name.ForEach({ "`$_.Name   -like `"$_`"" }) -join ' -or ' ) )

            return $global:Polaris.RouteMiddleware.Where( $Filter )
        }
    }
}

<#
.SYNOPSIS
    Start Polaris web server.
.DESCRIPTION
    Start Polaris web server.
.PARAMETER Port
    Port number to listen on.
    Defaults to 8080.
.PARAMETER MinRunspaces
    Minimum number of PowerShell runspaces for web server to use.
    Defaults to 1.
.PARAMETER MaxRunspaces
    Maximum number of PowerShell runspaces for web server to use.
    Defaults to 1.
.PARAMETER UseJsonBodyParserMiddleware
    When present, JSONBodyParser middleware will be created, if needed.
.EXAMPLE
    Start-Polaris
.EXAMPLE
    Start-Polaris -Port 8081 -MinRunspaces 2 -MaxRunspaces 10 -UseJsonBodyParserMiddleware
#>
function Start-Polaris {
    [CmdletBinding()]
    param(
        [Int32]
        $Port = 8080,

        [Int32]
        $MinRunspaces = 1,

        [Int32]
        $MaxRunspaces = 1,

        [switch]
        $UseJsonBodyParserMiddleware = $False )

    CreateNewPolarisIfNeeded

    if ( $UseJsonBodyParserMiddleware )
    {
        New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware
    }

    $global:Polaris.Start( $Port, $MinRunspaces, $MaxRunspaces )
    
    return $global:Polaris
}

<#
.SYNOPSIS
    Stop Polaris web server.
.DESCRIPTION
    Stop Polaris web server.
.PARAMETER ServerContext
    Polaris instance to stop.
    Defaults to the global instance.
.EXAMPLE
    Stop-Polaris
.EXAMPLE
    Stop-Polaris -ServerContext $app
#>
function Stop-Polaris
{
    [CmdletBinding()]
    param(
        [PolarisCore.Polaris]
        $ServerContext = $global:Polaris )

    if ( $ServerContext )
    {
        $ServerContext.Stop()
    }
}

##############################
# HELPERS
##############################

<#
.SYNOPSIS
    Add web route with method GET
.DESCRIPTION
    Wrapper for New-WebRoute -Method GET
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptBlock { $response.Send( 'Hello World' ) }
    To view results:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
#>
function New-GetRoute
{
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    switch ( $PSCmdlet.ParameterSetName )
    {
        'ScriptBlock' { New-WebRoute -Path $Path -Method "GET" -ScriptBlock $ScriptBlock -Force:$Force }
        'ScriptPath'  { New-WebRoute -Path $Path -Method "GET" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}

<#
.SYNOPSIS
    Add web route with method POST
.DESCRIPTION
    Wrapper for New-WebRoute -Method POST
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptBlock { $response.Send( 'Hello World' ) }
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method POST
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method POST
#>
function New-PostRoute
{
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    switch ( $PSCmdlet.ParameterSetName )
    {
        'ScriptBlock' { New-WebRoute -Path $Path -Method "POST" -ScriptBlock $ScriptBlock -Force:$Force }
        'ScriptPath'  { New-WebRoute -Path $Path -Method "POST" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}

<#
.SYNOPSIS
    Add web route with method PUT
.DESCRIPTION
    Wrapper for New-WebRoute -Method PUT
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptBlock { $response.Send( 'Hello World' ) }
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method PUT
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method PUT
#>
function New-PutRoute {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    switch ( $PSCmdlet.ParameterSetName )
    {
        'ScriptBlock' { New-WebRoute -Path $Path -Method "PUT" -ScriptBlock $ScriptBlock -Force:$Force }
        'ScriptPath'  { New-WebRoute -Path $Path -Method "PUT" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}

<#
.SYNOPSIS
    Add web route with method DELETE
.DESCRIPTION
    Wrapper for New-WebRoute -Method DELETE
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptBlock { $response.Send( 'Hello World' ) }
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method DELETE
.EXAMPLE
    New-GetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Invoke-WebRequest -Uri http://localhost:8080/helloworld -Method DELETE
#>
function New-DeleteRoute {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force )

    switch ( $PSCmdlet.ParameterSetName )
    {
        'ScriptBlock' { New-WebRoute -Path $Path -Method "DELETE" -ScriptBlock $ScriptBlock -Force:$Force }
        'ScriptPath'  { New-WebRoute -Path $Path -Method "DELETE" -ScriptPath  $ScriptPath  -Force:$Force }
    }
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

    New-RouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware -Force
}

##############################
# INTERNAL
##############################

function CreateNewPolarisIfNeeded ()
{
    if ( -not $global:Polaris )
    {
        $global:Polaris = New-Object -TypeName PolarisCore.Polaris -ArgumentList @(
            [Action[string]]{ param($str) Write-Verbose "$str" } )
    }
}

$JsonBodyParserMiddlerware =
{
    if ( $Request.BodyString -ne $Null )
    {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}

Export-ModuleMember -Function `
    New-WebRoute,
    Remove-WebRoute,
    Get-WebRoute,
    New-GetRoute,
    New-PostRoute,
    New-PutRoute,
    New-DeleteRoute,
    New-StaticRoute,
    New-RouteMiddleware,
    Remove-RouteMiddleware,
    Get-RouteMiddleware,
    Use-JsonBodyParserMiddleware,
    Start-Polaris,
    Stop-Polaris
