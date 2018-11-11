#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

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
        $ServerContext = $Script:Polaris
    )

    if ( $ServerContext ) {
        $ServerContext.Stop()
    }

    Get-PSDrive PolarisStaticFileServer* | Remove-PSDrive
}
