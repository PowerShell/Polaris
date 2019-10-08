#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

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
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Get-PolarisRoute
    Gets all web routes.
.EXAMPLE
    Get-PolarisRoute -Path 'helloworld' -Method 'GET'
    Gets the web route for method GET for path helloworld.
.EXAMPLE
    Get-PolarisRoute -Path 'sub1/sub2/*'
    Gets all web routes for all methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-PolarisRoute -Path 'sub1/sub2/*' -Method GET, POST
    Gets all web routes for GET and POST methods for paths starting with sub1/sub2/.
.EXAMPLE
    Get-PolarisRoute -Method Delete
    Gets all web routes for DELETE methods for all paths.
#>
function Get-PolarisRoute {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Path = @('*'),

        [Parameter( ValueFromPipelineByPropertyName = $True )]
        [string[]]
        $Method = @('*'),

        $Polaris = $Script:Polaris
    )

    process {
        if ( $Polaris ) {
            $MatchingRoutes = foreach ($Pattern in $Path) {
                $Polaris.Routes | where { $_.Path -like $Pattern -or $_.Path -like "/$Pattern" }
            }
            $MatchMethodAndRoutes = foreach ($Pattern in $Method) {
                $MatchingRoutes | where { $_.Method -like $Pattern }
            }

            return $MatchMethodAndRoutes | Sort-Object -Property Path, Method -Unique
        }
    }
}
