<#
.SYNOPSIS
    Add new route middleware.
.DESCRIPTION
    Creates new route middleware. Route middleware scripts are used to
    manipulate request and response objects and run before web route scripts.
.PARAMETER Name
    Name of the middleware.
.PARAMETER Scriptblock
    Scriptblock to run when middleware is triggered.
.PARAMETER ScriptPath
    Full path and name to script to run when middleware is triggered.
.PARAMETER Force
    Use -Force to overwrite any existing middleware with the same name.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
$JsonBodyParserMiddleware =
{
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}
New-PolarisRouteMiddleware -Name JsonBodyParser -Scriptblock $JsonBodyParserMiddleware
#>
function New-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Name,

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
    # Checking if middleware already exists
    $ExistingMiddleWare = Get-PolarisRouteMiddleware -Name $Name -Polaris $Polaris

    # If Force option is specified remove the existing middleware
    if ( $ExistingMiddleWare -and $Force ) {
        Remove-PolarisRouteMiddleware -Name $Name -Polaris $Polaris
        $ExistingMiddleWare = Get-PolarisRouteMiddleware -Name $Name -Polaris $Polaris
    }

    if ( $ExistingMiddleWare ) {
        $PSCmdlet.WriteError( (
                New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                    [System.Exception]'RouteMiddleware already exists.'
                    $Null
                    [System.Management.Automation.ErrorCategory]::ResourceExists
                    "$Name" ) ) )
    }
    else {
        CreateNewPolarisIfNeeded
        if ( -not $Polaris) {
            $Polaris = $Script:Polaris
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            'Scriptblock' {
                $Polaris.AddMiddleware( $Name, $Scriptblock )
            }
            'ScriptPath' {
                if ( Test-Path -Path $ScriptPath ) {
                    $Script = Get-Content -Path $ScriptPath -Raw
                    $Polaris.AddMiddleware( $Name, [scriptblock]::Create($Script) )
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
