#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
    Add web route.
.DESCRIPTION
    Create web route for server to serve.
.PARAMETER Path
    The path for which the given scriptblock or script is invoked; can be any of:
        * A string representing a path.
        * A path pattern.
        * A regular expression to match paths.
    For examples, see Path examples.
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
        $Path,

        [Parameter( Mandatory = $True, Position = 1 )]
        [ValidateSet( 'GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'CONNECT', 'OPTIONS', 'TRACE' )]
        [string]
        $Method,

        [Parameter( Mandatory = $True, Position = 2, ParameterSetName = 'Scriptblock' )]
        [scriptblock]
        $Scriptblock,

        [Parameter( Mandatory = $True, ParameterSetName = 'ScriptPath' )]
        [ValidateScript( {
                if (-Not ($_ | Test-Path) ) {
                    throw "File does not exist"
                }
                if (-Not ($_ | Test-Path -PathType Leaf) ) {
                    throw "The Path argument must be a file. Folder paths are not allowed."
                }
                if ([System.IO.Path]::GetExtension($_) -ne ".ps1") {
                    throw "The file specified in the path argument must be of type .ps1"
                }
                return $true
            })]
        [string]
        $ScriptPath,

        [switch]
        $Force,

        $Polaris = $Script:Polaris
    )
    $Method = $Method.ToUpper()
    $ExistingWebRoute = Get-PolarisRoute -Path $Path -Method $Method

    if ( $ExistingWebRoute ) {
        if ( -not $Force ) {
            $Exception = [System.Exception]'WebRoute already exists.'
            $ErrorId = "Polaris.Webroute.RouteAlreadyExists"
            $ErrorCategory = [System.Management.Automation.ErrorCategory]::ResourceExists
            $TargetObject = "$Path,$Method"

            $WebRouteExistsError = [System.Management.Automation.ErrorRecord]::new(
                $Exception,
                $ErrorId,
                $ErrorCategory,
                $TargetObject
            )

            throw $WebRouteExistsError
            # If $Force is specified and there is an existing webroute we remove it
        }
        Remove-PolarisRoute -Path $Path -Method $Method
    }

    CreateNewPolarisIfNeeded
    if ( -not $Polaris) {
        $Polaris = $Script:Polaris
    }

    if ( $Path -is [string] -and -not $Path.StartsWith( '/' ) ) {
        $Path = '/' + $Path
    }

    switch ( $PSCmdlet.ParameterSetName ) {
        'Scriptblock' {
            $Polaris.AddRoute( $Path, $Method, $Scriptblock )
        }
        'ScriptPath' {
            $Script = Get-Content -Path $ScriptPath -Raw
            $Polaris.AddRoute( $Path, $Method, [scriptblock]::Create($Script) )
        }
    }
}
