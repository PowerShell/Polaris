#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

function CreateNewPolarisIfNeeded () {
    if ( -not $Script:Polaris ) {
        $Script:Polaris = [Polaris]::New(
            [Action[string]] { param($str) Write-Verbose "$str" } )
    }
}
