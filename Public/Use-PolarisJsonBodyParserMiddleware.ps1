<#
.SYNOPSIS
    Helper function that turns on the Json Body parsing middleware.
.DESCRIPTION
    Helper function that turns on the Json Body parsing middleware.
.EXAMPLE
    Use-PolarisJsonBodyParserMiddleware
#>
function Use-PolarisJsonBodyParserMiddleware {
    [CmdletBinding()]
    param()

    New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddlerware -Force
}
