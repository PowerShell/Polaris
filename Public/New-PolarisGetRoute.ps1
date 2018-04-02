<#
.SYNOPSIS
    Add web route with method GET
.DESCRIPTION
    Wrapper for New-PolarisRoute -Method GET
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER ScriptBlock
    ScriptBlock that will be triggered when web route is called.
.PARAMETER ScriptPath
    Full path and name of script that will be triggered when web route is called.
.PARAMETER Force
    Use -Force to overwrite any existing web route for the same path and method.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    New-PolarisGetRoute -Path "helloworld" -ScriptBlock { $response.Send( 'Hello World' ) }
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

        [Parameter( Mandatory = $True, Position = 1, ParameterSetName = 'ScriptBlock' )]
        [scriptblock]
        $ScriptBlock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force,

        
        $Polaris = $script:Polaris
    )

    switch ( $PSCmdlet.ParameterSetName ) {
        'ScriptBlock' { New-PolarisRoute -Path $Path -Method "GET" -ScriptBlock $ScriptBlock -Force:$Force }
        'ScriptPath' { New-PolarisRoute -Path $Path -Method "GET" -ScriptPath  $ScriptPath  -Force:$Force }
    }
}

