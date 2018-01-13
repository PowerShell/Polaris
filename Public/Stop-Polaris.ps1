<#
.SYNOPSIS
    Stop Polaris web server.
.DESCRIPTION
    Stop Polaris web server.
.PARAMETER ServerContext
    Polaris instance to stop.
    Defaults to the global instance.
.EXAMPLE
    Stop-Polaris
.EXAMPLE
    Stop-Polaris -ServerContext $app
#>
function Stop-Polaris {
    [CmdletBinding()]
    param(
        [PolarisCore.Polaris]
        $ServerContext = $script:Polaris )

    if ( $ServerContext ) {
        $ServerContext.Stop()
    }
}
