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
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Remove-PolarisRoute
    Removes all existing web routes.
.EXAMPLE
    Remove-PolarisRoute -Path 'helloworld' -Method GET
    Removes the web route for method GET for path helloworld.
.EXAMPLE
    Remove-PolarisRoute -Path 'sub1/sub2/*'
    Removes all web routes for all methods for paths starting with sub1/sub2/.
.EXAMPLE
    Remove-PolarisRoute -Path 'sub1/sub2/*' -Method GET, POST
    Removes all web routes for GET and POST methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-PolarisRoute -Method Delete | Remove-Method
    Removes all web routes for DELETE methods for all paths.
#>
function Remove-PolarisRoute {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Path = '*',

        [Parameter( ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Method = '*',

        
        $Polaris = $Script:Polaris
    )

    process {
        if ( $Polaris ) {
            $WebRoutes = Get-PolarisRoute -Path $Path -Method $Method
            
            ForEach ( $Route in $WebRoutes ) {
                $Polaris.RemoveRoute( $Route.Path, $Route.Method )
            }
        }
    }
}
