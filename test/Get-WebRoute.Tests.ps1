Describe "Get-WebRoute" {
    BeforeAll {

        #  Import module
        Import-Module -Name Polaris

        #  Start with a clean slate
        Remove-WebRoute

        #  Create test route to test against
        New-WebRoute -Path 'Test0'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test0'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test1'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test2'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test2'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test3A' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test3B' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test3C' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test4A' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test4B' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test6A' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test6B' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test7'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test7'  -Method PUT  -ScriptBlock {}
        }

    It "Should default to get all routes" {
        $ExpectedCount = $Global:Polaris.ScriptBlockRoutes.Values.Values.Count
        $Routes = Get-WebRoute
        @( $Routes ).Count | Should Be $ExpectedCount
        }

    It "Should respect Path" {
        $Routes = Get-WebRoute -Path 'Test2'
        @( $Routes ).Count | Should Be 2
        }

    It "Should respect Method" {
        $Routes = Get-WebRoute -Path 'Test3*' -Method PUT
        @( $Routes ).Count | Should Be 2
        }

    It "Should do nothing when no routes match" {
        $Routes = Get-WebRoute -Path 'DOESNOTEXIST'
        @( $Routes ).Count | Should Be 0
        }

    It "Should accept multiple values for Path" {
        $Routes = Get-WebRoute -Path 'Test4A', 'Test4B'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept multiple values for Method" {
        $Routes = Get-WebRoute -Path 'Test5' -Method GET, POST
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept wildcard values for Path" {
        $Routes = Get-WebRoute -Path 'Test6*'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept wildcard values for Method" {
        $Routes = Get-WebRoute -Path 'Test7' -Method 'P*'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept pipeline input for Path" {
        $Routes = 'Test6A', 'Test6B' | Get-WebRoute
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept pipeline property input for Path and Method" {
        $Routes = Get-WebRoute -Path 'Test7' | Get-WebRoute
        @( $Routes ).Count | Should Be 2
        }

    AfterAll {

        #  Clean up test routes
        Remove-WebRoute
        }
    }
