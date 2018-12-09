#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
    Returns the internal instance of Polaris
.DESCRIPTION
    Returns the instance of the Polaris .NET Standard object
.EXAMPLE
    Get-Polaris
.NOTES
    Should only be used for testing
#>
function Get-Polaris {
    return $Script:Polaris
}
