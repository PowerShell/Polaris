<#
.SYNOPSIS
    Stop Polaris web server.
.DESCRIPTION
    Stop Polaris web server.
.PARAMETER ServerContext
    Polaris instance to stop.
    Defaults to the global instance.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Stop-Polaris
.EXAMPLE
    Stop-Polaris -ServerContext $app
#>
function Stop-Polaris {
    [CmdletBinding()]
    param(
        $ServerContext = $Script:Polaris
    )

    if ( $ServerContext ) {
        $ServerContext.Stop()
    }

    Get-PSDrive PolarisStaticFileServer* | Remove-PSDrive
}
