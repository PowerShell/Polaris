#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module -Name $PSScriptRoot\..\..\Polaris.psd1

Describe "Test webserver Auth use" {
    Context "Test starting server with Windows Auth on Linux/Mac" {
        if (($IsMacOS -or $IsLinux)) {
            It "Test Anonymous auth on Mac/Linux" {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                Stop-Polaris
            }
            It "Test Basic auth on Mac/Linux" {
                { Start-Polaris -Auth Basic } | Should not Throw
                Stop-Polaris
            }
            It "Test IntegratedWindowsAuthentication auth on Mac/Linux" {
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should Throw
                Stop-Polaris
            }   
            It "Test Digest auth on Mac/Linux" {
                { Start-Polaris -Auth Digest } | Should Throw
                Stop-Polaris
            }
            It "Test DigeNegotiatest auth on Mac/Linux" {
                { Start-Polaris -Auth Negotiate } | Should Throw
                Stop-Polaris
            }
            It "Test NTLM auth on Mac/Linux" {
                { Start-Polaris -Auth NTLM } | Should Throw
                Stop-Polaris
            }
        }
        else {
            It "Test Anonymous auth on Windows" {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                Stop-Polaris
            }
            It "Test Basic auth on Windows" {
                { Start-Polaris -Auth Basic } | Should not Throw
                Stop-Polaris
            }
            It "Test IntegratedWindowsAuthentication auth on Windows" {
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should not Throw
                Stop-Polaris
            }   
            It "Test Digest auth on Windows" {
                { Start-Polaris -Auth Digest } | Should not Throw
                Stop-Polaris
            }
            It "Test DigeNegotiatest auth on Windows" {
                { Start-Polaris -Auth Negotiate } | Should not Throw
                Stop-Polaris
            }
            It "Test NTLM auth on Windows" {
                { Start-Polaris -Auth NTLM } | Should not Throw
                Stop-Polaris
            }
        }
    }
    
}
