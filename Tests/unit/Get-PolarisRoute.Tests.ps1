Describe "Get-PolarisRoute" {
    BeforeAll {

        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create test route to test against
        New-PolarisRoute -Path '/Test0'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test0'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test1'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test2'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test2'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test3A' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test3B' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test3C' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test4A' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test4B' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test6A' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test6B' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test7'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test7'  -Method PUT  -Scriptblock {}
    }

    It "Should default to get all routes" {
        $ExpectedCount = (Get-Polaris).ScriptblockRoutes.Values.Values.Count
        $Routes = Get-PolarisRoute
        @( $Routes ).Count | Should Be $ExpectedCount
    }

    It "Should respect Path" {
        $Routes = Get-PolarisRoute -Path '/Test2'
        @( $Routes ).Count | Should Be 2
    }

    It "Should respect Method" {
        $Routes = Get-PolarisRoute -Path '/Test3*' -Method PUT
        @( $Routes ).Count | Should Be 2
    }

    It "Should do nothing when no routes match" {
        $Routes = Get-PolarisRoute -Path 'DOESNOTEXIST'
        @( $Routes ).Count | Should Be 0
    }

    It "Should accept multiple values for Path" {
        $Routes = Get-PolarisRoute -Path '/Test4A', '/Test4B'
        @( $Routes ).Count | Should Be 2
    }

    It "Should accept multiple values for Method" {
        $Routes = Get-PolarisRoute -Path '/Test5' -Method GET, POST
        @( $Routes ).Count | Should Be 2
    }

    It "Should accept wildcard values for Path" {
        $Routes = Get-PolarisRoute -Path '/Test6*'
        @( $Routes ).Count | Should Be 2
    }

    It "Should accept wildcard values for Method" {
        $Routes = Get-PolarisRoute -Path '/Test7' -Method 'P*'
        @( $Routes ).Count | Should Be 2
    }

    It "Should accept pipeline input for Path" {
        $Routes = '/Test6A', '/Test6B' | Get-PolarisRoute
        @( $Routes ).Count | Should Be 2
    }

    It "Should accept pipeline property input for Path and Method" {
        $Routes = Get-PolarisRoute -Path '/Test7' | Get-PolarisRoute
        @( $Routes ).Count | Should Be 2
    }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisRoute
    }
}
