#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module -Name $PSScriptRoot\..\..\Polaris.psd1

Describe "Test webserver use" {

    BeforeAll {

        $IsUnix = $PSVersionTable.Platform -eq "Unix"

        $Port = Get-Random -Minimum 8000 -Maximum 8999

        # Start the app
        $Polaris = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional

    }

    Context "Test starting and stopping of the server" {
        BeforeAll {
            if (-not $IsUnix) {
                Stop-Polaris
                $Polaris = Get-Polaris
                $Polaris.Listener.IsListening | Should Be $false

                $Polaris = Start-Polaris -Port 9998
                $Polaris.Listener.IsListening | Should be $true
            }
        }

        It "Allows a custom logger" {
            $Polaris = Get-Polaris
            $Polaris.Logger = {
                param($Word)
                $Word | Out-File "TestDrive:\test.log" -NoNewline
            }

            $Polaris.Log("Hello")
            Get-Content "TestDrive:\test.log" -Raw | Should be "Hello"
        }
    }
}
