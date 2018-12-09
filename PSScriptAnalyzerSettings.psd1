#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

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
