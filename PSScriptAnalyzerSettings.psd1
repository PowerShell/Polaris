# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

@{
    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            # (gal -d "*-Object").Name
            Whitelist = @(
                '%',
                '?',
                'compare',
                'diff',
                'foreach',
                'group',
                'measure',
                'select',
                'sort',
                'tee',
                'where'
            )
        }
    }
    Severity = @('Error', 'Warning')
    ExcludeRules = @('PSUseShouldProcessForStateChangingFunctions')
}
