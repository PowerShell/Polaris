#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
    Add web route with method GET
.DESCRIPTION
    Wrapper for New-PolarisRoute -Method GET
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER Scriptblock
    Scriptblock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    New-PolarisGetRoute -Path "helloworld" -Scriptblock { $Response.Send( 'Hello World' ) }
    To view results:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
.EXAMPLE
    New-PolarisGetRoute -Path "helloworld" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
#>
function New-PolarisGetRoute {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'Scriptblock' )]
        [scriptblock]
        $Scriptblock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force,

        
        $Polaris = $Script:Polaris
    )

    switch ( $PSCmdlet.ParameterSetName ) {
        'Scriptblock' { New-PolarisRoute -Path $Path -Method "GET" -Scriptblock $Scriptblock -Force:$Force }
        'ScriptPath' { New-PolarisRoute -Path $Path -Method "GET" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}
