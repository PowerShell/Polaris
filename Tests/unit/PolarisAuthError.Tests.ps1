#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module -Name $PSScriptRoot\..\..\Polaris.psd1

Describe "Test Polaris Auth Errors" {
    Context "Test operating specific errors" {
        if ($IsMacOS -or $IsLinux) {
            It "Should not throw an Error with Anonymous auth on Mac/Linux" {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with Basic auth on Mac/Linux" {
                { Start-Polaris -Auth Basic } | Should not Throw
                Stop-Polaris
            }
            It "Should throw an Error with IntegratedWindowsAuthentication auth on Mac/Linux" {
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should Throw
                Stop-Polaris
            }
            It "Should throw an Error with Digest auth on Mac/Linux" {
                { Start-Polaris -Auth Digest } | Should Throw
                Stop-Polaris
            }
            It "Should throw an Error with Negotiate auth on Mac/Linux" {
                { Start-Polaris -Auth Negotiate } | Should Throw
                Stop-Polaris
            }
            It "Should throw an Error with NTLM auth on Mac/Linux" {
                { Start-Polaris -Auth NTLM } | Should Throw
                Stop-Polaris
            }
        }
        else {
            It "Should not throw an Error with Anonymous auth on Windows" {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with Basic auth on Windows" {
                { Start-Polaris -Auth Basic } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with IntegratedWindowsAuthentication auth on Windows" {
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with Digest auth on Windows" {
                { Start-Polaris -Auth Digest } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with Negotiate auth on Windows" {
                { Start-Polaris -Auth Negotiate } | Should not Throw
                Stop-Polaris
            }
            It "Should not throw an Error with NTLM auth on Windows" {
                { Start-Polaris -Auth NTLM } | Should not Throw
                Stop-Polaris
            }
        }
    }
}
