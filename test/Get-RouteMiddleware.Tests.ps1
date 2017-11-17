Describe "Get-RouteMiddleware" {

    BeforeAll {
        
        #  Import module
        Import-Module -Name Polaris

        #  Start with a clean slate
        Remove-RouteMiddleware

        #  Create middleware to test against
        New-RouteMiddleware -Name 'Test0'  -ScriptBlock {}
        New-RouteMiddleware -Name 'Test1'  -ScriptBlock {}
        New-RouteMiddleware -Name 'Test2A' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test2B' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test3A' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test3B' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test3C' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test4A' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test4B' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test5A' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test5B' -ScriptBlock {}
        New-RouteMiddleware -Name 'Test6'  -ScriptBlock {}
        }

    It "Should default to get all middleware" {
        $ExpectedCount = $Global:Polaris.RouteMiddleware.Count

        $Middleware = Get-RouteMiddleware
        @( $Middleware ).Count | Should Be $ExpectedCount
        }

    It "Should respect Name" {
        $Middleware = Get-RouteMiddleware -Name 'Test1'
        @( $Middleware ).Count | Should Be 1
        }

    It "Should do nothing when no middleware match" {
        $Middleware = Get-RouteMiddleware -Name 'DoesNotExist'
        @( $Middleware ).Count | Should Be 0
        }

    It "Should accept multiple values for Name" {
        $Middleware = Get-RouteMiddleware -Name 'Test3A', 'Test3B'
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept wildcard values for Name" {
        $Middleware = Get-RouteMiddleware -Name 'Test4*'
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept pipeline input for Name" {
        $Middleware = 'Test5A', 'Test5B' | Get-RouteMiddleware
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept pipeline property input for Name" {
        $Middleware = Get-RouteMiddleware -Name 'Test4*' | Get-RouteMiddleware
        @( $Middleware ).Count | Should Be 2
        }

    AfterAll {

        #  Clean up test middleware
        Remove-RouteMiddleware
        }
    }
