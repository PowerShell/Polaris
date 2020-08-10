# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function CreateNewPolarisIfNeeded () {
    if ( -not $Script:Polaris ) {
        $Script:Polaris = [Polaris]::New(
            [Action[string]] { param($str) Write-Verbose "$str" } )
    }
}
