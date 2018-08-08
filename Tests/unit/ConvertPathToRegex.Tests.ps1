Import-Module $PSScriptRoot\..\..\Polaris.psd1

InModuleScope Polaris {
    Describe "[Polaris]::ConvertPathToRegex" {
    
        It "should match and extract named parameters anywhere in the route" {
            $RegEx = [Polaris]::ConvertPathToRegex("/users/:userId/books/:bookId")
            "/users/34/books/8989" -cmatch $RegEx | Should Be $true
            $Matches.userId | Should Be 34
            $Matches.bookId | Should Be 8989
        }

        It "should interpret . and - literally" {
            $RegEx = [Polaris]::ConvertPathToRegex("/flights/:from-:to")
            "/flights/LAX-SFO" -cmatch $RegEx | Should Be $true
            $Matches.from | Should Be "LAX"
            $Matches.to | Should Be "SFO"

            $RegEx = [Polaris]::ConvertPathToRegex("/flights/:from.:to")
            "/flights/LAX.SFO" -cmatch $RegEx | Should Be $true
            $Matches.from | Should Be "LAX"
            $Matches.to | Should Be "SFO"
        }

        It "should allow custom named capture regular expressions" {
            $RegEx = [Polaris]::ConvertPathToRegex("/user/(?<userId>\d+)")
            "/user/42" -cmatch $RegEx | Should Be $true
            $Matches.userId | Should Be 42
        }

        It "should provide matches with basic strings" {
            $RegEx = [Polaris]::ConvertPathToRegex("/")
            "/" -cmatch $RegEx | Should Be $true

            $RegEx = [Polaris]::ConvertPathToRegex("/about")
            "/about" -cmatch $RegEx | Should Be $true

            $RegEx = [Polaris]::ConvertPathToRegex("/random.text")
            "/random.text" -cmatch $RegEx | Should Be $true
        }

        It "should provide matches with string patterns" {
            $RegEx = [Polaris]::ConvertPathToRegex("/ab?cd")
            "/acd" -cmatch $RegEx | Should Be $true
            "/abcd" -cmatch $RegEx | Should Be $true

            $RegEx = [Polaris]::ConvertPathToRegex("/ab+cd")
            "/abcd" -cmatch $RegEx | Should Be $true
            "/abbcd" -cmatch $RegEx | Should Be $true
            "/abbbcd" -cmatch $RegEx | Should Be $true

            $RegEx = [Polaris]::ConvertPathToRegex("/ab*cd")
            "/abcd" -cmatch $RegEx | Should Be $true
            "/abxcd" -cmatch $RegEx | Should Be $true
            "/abRANDOMcd" -cmatch $RegEx | Should Be $true

            $RegEx = [Polaris]::ConvertPathToRegex("/ab(cd)?e")
            "/abe" -cmatch $RegEx | Should Be $true
            "/abcde" -cmatch $RegEx | Should Be $true
        }
    }
}