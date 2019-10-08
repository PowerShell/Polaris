#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Import-Module $PSScriptRoot\..\..\Polaris.psd1

InModuleScope Polaris {
    Describe "[PolarisRoute]::ConvertPathToRegex" {

        It "should match and extract named parameters anywhere in the route" {
            $RegEx = [PolarisRoute]::ConvertPathToRegex("/users/:userId/books/:bookId")
            "/users/34/books/8989" -cmatch $RegEx | Should Be $true
            $Matches.userId | Should Be 34
            $Matches.bookId | Should Be 8989
        }

        It "should interpret . and - literally" {
            $RegEx = [PolarisRoute]::ConvertPathToRegex("/flights/:from-:to")
            "/flights/LAX-SFO" -cmatch $RegEx | Should Be $true
            $Matches.from | Should Be "LAX"
            $Matches.to | Should Be "SFO"

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/flights/:from.:to")
            "/flights/LAX.SFO" -cmatch $RegEx | Should Be $true
            $Matches.from | Should Be "LAX"
            $Matches.to | Should Be "SFO"
        }

        It "should allow custom named capture regular expressions" {
            $RegEx = [PolarisRoute]::ConvertPathToRegex("/user/(?<userId>\d+)")
            "/user/42" -cmatch $RegEx | Should Be $true
            $Matches.userId | Should Be 42
        }

        It "should provide matches with basic strings" {
            $RegEx = [PolarisRoute]::ConvertPathToRegex("/")
            "/" -cmatch $RegEx | Should Be $true

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/about")
            "/about" -cmatch $RegEx | Should Be $true

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/random.text")
            "/random.text" -cmatch $RegEx | Should Be $true
        }

        It "should provide matches with string patterns" {
            $RegEx = [PolarisRoute]::ConvertPathToRegex("/ab?cd")
            "/acd" -cmatch $RegEx | Should Be $true
            "/abcd" -cmatch $RegEx | Should Be $true

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/ab+cd")
            "/abcd" -cmatch $RegEx | Should Be $true
            "/abbcd" -cmatch $RegEx | Should Be $true
            "/abbbcd" -cmatch $RegEx | Should Be $true

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/ab*cd")
            "/abcd" -cmatch $RegEx | Should Be $true
            "/abxcd" -cmatch $RegEx | Should Be $true
            "/abRANDOMcd" -cmatch $RegEx | Should Be $true

            $RegEx = [PolarisRoute]::ConvertPathToRegex("/ab(cd)?e")
            "/abe" -cmatch $RegEx | Should Be $true
            "/abcde" -cmatch $RegEx | Should Be $true
        }
    }
}
