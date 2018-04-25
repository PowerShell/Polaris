<#
.SYNOPSIS
    Add web route.
.DESCRIPTION
    Create web route for server to serve.
.PARAMETER Path
    Path (path/route/endpoint) of the web route to to be serviced.
.PARAMETER Method
    HTTP verb/method to be serviced.
    Valid values are GET, HEAD, POST, PUT, DELETE, CONNECT, OPTIONS, TRACE
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
    New-PolarisRoute -Path "helloworld" -Method "GET" -Scriptblock { $Response.Send( 'Hello World' ) }
    To view results:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
.EXAMPLE
    New-PolarisRoute -Path "helloworld" -Method "GET" -ScriptPath D:\Scripts\Example.ps1
    To view results, assuming default port:
    Start-Polaris
    Start-Process http://localhost:8080/helloworld
#>
function New-PolarisRoute {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Path,

        [Parameter( Mandatory = $True, Position = 1 )]
        [ValidateSet( 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE' )]
        [string]
        $Method,

        [Parameter( Mandatory = $True, Position = 2, ParameterSetName = 'Scriptblock' )]
        [scriptblock]
        $Scriptblock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [string]
        $ScriptPath,
        
        [switch]
        $Force,

        $Polaris = $Script:Polaris
    )
    $Method = $Method.ToUpper()
    $ExistingWebRoute = Get-PolarisRoute -Path $Path -Method $Method

    if ( $ExistingWebRoute -and $Force ) {
        Remove-PolarisRoute -Path $Path -Method $Method
        $ExistingWebRoute = Get-PolarisRoute -Path $Path -Method $Method
    }

    if ( $ExistingWebRoute ) {
        $PSCmdlet.WriteError( (
                New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                    [System.Exception]'WebRoute already exists.'
                    $Null
                    [System.Management.Automation.ErrorCategory]::ResourceExists
                    "$Path,$Method" ) ) )
    }
    else {
        CreateNewPolarisIfNeeded
        if( -not $Polaris){
            $Polaris = $Script:Polaris
        }

        if ( -not $Path.StartsWith( '/' ) ) {
            $Path = '/' + $Path
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            'Scriptblock' {
                $Polaris.AddRoute( $Path, $Method, $Scriptblock )
            }
            'ScriptPath' {
                if ( Test-Path -Path $ScriptPath ) {
                    $Script = Get-Content -Path $ScriptPath -Raw
                    $Polaris.AddRoute( $Path, $Method, [scriptblock]::Create($Script) )
                }
                else {
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
