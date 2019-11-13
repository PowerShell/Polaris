#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module -Name $PSScriptRoot\..\..\Polaris.psd1

Describe "Test webserver use" {

    Context "Test starting and stopping of the server" {

        It "Should allow starting and stopping the server" {
            $Port = Get-Random -Minimum 8000 -Maximum 8999
            $Polaris = Start-Polaris -Port $Port
            Stop-Polaris
            $Polaris.Listener.IsListening | Should Be $false

            $Polaris = Start-Polaris -Port $Port
            $Polaris.Listener.IsListening | Should be $true
        }

        It "Should allow running Start-Polaris multiple times without error" {
            $Port = Get-Random -Minimum 8000 -Maximum 8999
            $Polaris = Start-Polaris -Port $Port
            $Polaris.Listener.IsListening | Should Be $true

            $Polaris = Start-Polaris -Port $Port
            $Polaris.Listener.IsListening | Should be $true
        }

        It "Allows a custom logger" {
            $Port = Get-Random -Minimum 8000 -Maximum 8999
            $Polaris = Start-Polaris -Port $Port
            $Polaris.Logger = {
                param($Word)
                $Word | Out-File "TestDrive:\test.log" -NoNewline
            }

            $Polaris.Log("Hello")
            Get-Content "TestDrive:\test.log" -Raw | Should be "Hello"
        }
    }
}
