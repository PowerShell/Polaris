<#
.SYNOPSIS
    Add new route middleware.
.DESCRIPTION
    Creates new route middleware. Route middleware scripts are used to
    manipulate request and response objects and run before web route scripts.
.PARAMETER Name
    Name of the middleware.
.PARAMETER ScriptBlock
    ScriptBlock to run when middleware is triggered.
.PARAMETER ScriptPath
    Full path and name to script to run when middleware is triggered.
.PARAMETER Force
    Use -Force to overwrite any existing middleware with the same name.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
$JsonBodyParserMiddlerware =
{
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}
New-PolarisRouteMiddleware -Name JsonBodyParser -ScriptBlock $JsonBodyParserMiddleware
#>
function New-PolarisRouteMiddleware {
    [CmdletBinding()]
    param(
        [Parameter( Mandatory = $True, Position = 0 )]
        [string]
        $Name,

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
        if( -not $Polaris){
            $Polaris = $script:Polaris
        }

        switch ( $PSCmdlet.ParameterSetName ) {
            'ScriptBlock' {
                $Polaris.AddMiddleware( $Name, [string]$ScriptBlock )
            }
            'ScriptPath' {
                if ( Test-Path -Path $ScriptPath ) {
                    $Script = Get-Content -Path $ScriptPath -Raw
                    $Polaris.AddMiddleware( $Name, $Script )
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
