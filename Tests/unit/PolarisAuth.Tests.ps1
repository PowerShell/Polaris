#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module -Name $PSScriptRoot\..\..\Polaris.psd1

Describe "Test webserver Auth use" {
    Context "Test starting server with Windows Auth on Linux/Mac" {
        BeforeAll {
            if (($IsMacOS -or $IsLinux)) {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                { Start-Polaris -Auth Basic } | Should not Throw
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should Throw
                { Start-Polaris -Auth Digest } | Should Throw
                { Start-Polaris -Auth Negotiate } | Should Throw
                { Start-Polaris -Auth NTLM } | Should Throw
            }
            else {
                { Start-Polaris -Auth Anonymous } | Should not Throw
                { Start-Polaris -Auth Basic } | Should not Throw
                { Start-Polaris -Auth IntegratedWindowsAuthentication } | Should not Throw
                { Start-Polaris -Auth Digest } | Should not Throw
                { Start-Polaris -Auth Negotiate } | Should not Throw
                { Start-Polaris -Auth NTLM } | Should not Throw
            }
        }
    }
}
