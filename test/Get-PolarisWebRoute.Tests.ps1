Describe "Get-PolarisWebRoute" {
    BeforeAll {

        #  Import module
        Import-Module ..\Polaris.psd1

        #  Start with a clean slate
        Remove-PolarisWebRoute

        #  Create test route to test against
        New-PolarisWebRoute -Path 'Test0'  -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test0'  -Method POST -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test1'  -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test2'  -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test2'  -Method POST -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test3A' -Method PUT  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test3B' -Method PUT  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test3C' -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test4A' -Method PUT  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test4B' -Method PUT  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test5'  -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test5'  -Method POST -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test5'  -Method PUT  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test6A' -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test6B' -Method GET  -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test7'  -Method POST -ScriptBlock {}
        New-PolarisWebRoute -Path 'Test7'  -Method PUT  -ScriptBlock {}
        }

    It "Should default to get all routes" {
        $ExpectedCount = $Global:Polaris.ScriptBlockRoutes.Values.Values.Count
        $Routes = Get-PolarisWebRoute
        @( $Routes ).Count | Should Be $ExpectedCount
        }

    It "Should respect Path" {
        $Routes = Get-PolarisWebRoute -Path 'Test2'
        @( $Routes ).Count | Should Be 2
        }

    It "Should respect Method" {
        $Routes = Get-PolarisWebRoute -Path 'Test3*' -Method PUT
        @( $Routes ).Count | Should Be 2
        }

    It "Should do nothing when no routes match" {
        $Routes = Get-PolarisWebRoute -Path 'DOESNOTEXIST'
        @( $Routes ).Count | Should Be 0
        }

    It "Should accept multiple values for Path" {
        $Routes = Get-PolarisWebRoute -Path 'Test4A', 'Test4B'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept multiple values for Method" {
        $Routes = Get-PolarisWebRoute -Path 'Test5' -Method GET, POST
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept wildcard values for Path" {
        $Routes = Get-PolarisWebRoute -Path 'Test6*'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept wildcard values for Method" {
        $Routes = Get-PolarisWebRoute -Path 'Test7' -Method 'P*'
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept pipeline input for Path" {
        $Routes = 'Test6A', 'Test6B' | Get-PolarisWebRoute
        @( $Routes ).Count | Should Be 2
        }

    It "Should accept pipeline property input for Path and Method" {
        $Routes = Get-PolarisWebRoute -Path 'Test7' | Get-PolarisWebRoute
        @( $Routes ).Count | Should Be 2
        }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisWebRoute
        }
    }
