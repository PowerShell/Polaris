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
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Get-PolarisRouteMiddleware
.EXAMPLE
    Get-PolarisRouteMiddleware -Name JsonBodyParser
.EXAMPLE
    Get-PolarisRouteMiddleware -Name ParamCheck*, ParamVerify*
#>
function Get-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Name = '*',

        
        $Polaris = $Script:Polaris
    )

    process {
        if ( $Polaris ) {
            $Filter = [scriptblock]::Create( ( $Name.ForEach( { "`$_.Name   -like `"$_`"" }) -join ' -or ' ) )

            return $Polaris.RouteMiddleware.Where( $Filter )
        }
    }
}
