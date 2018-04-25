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
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Remove-PolarisRouteMiddleware -Name JsonBodyParser
.EXAMPLE
    Remove-PolarisRouteMiddleware
    Removes all route middleware.
.EXAMPLE
    Remove-PolarisRouteMiddleware -Name ParamCheck*, ParamVerify*
    Removes any route middleware with names starting with ParamCheck or ParamVerify.
.EXAMPLE
    Get-PolarisRouteMiddleware | Remove-PolarisRouteMiddleware
    Removes all route middleware.
#>
function Remove-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Name = '*',

        
        $Polaris = $Script:Polaris
    )
    
    process {
        if ( $Polaris  ) {
            $Middleware = Get-PolarisRouteMiddleware -Name $Name

            ForEach ( $Ware in $Middleware ) {
                $Polaris.RemoveMiddleware( $Ware.Name )
            }
        }
    }
}
