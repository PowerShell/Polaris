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
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
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
        $UseJsonBodyParserMiddleware = $False,

        [Polaris]
        $Polaris = $script:Polaris
    )

    CreateNewPolarisIfNeeded

    if ( $UseJsonBodyParserMiddleware ) {
        New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware
    }

    $Polaris.Start( $Port, $MinRunspaces, $MaxRunspaces )
    
    return $Polaris
}
