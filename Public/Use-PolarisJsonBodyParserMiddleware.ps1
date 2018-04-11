<#
.SYNOPSIS
    Helper function that turns on the Json Body parsing middleware.
.DESCRIPTION
    Helper function that turns on the Json Body parsing middleware.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Use-PolarisJsonBodyParserMiddleware
#>
function Use-PolarisJsonBodyParserMiddleware {
    [CmdletBinding()]
    param()

    New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddleware -Force
}
