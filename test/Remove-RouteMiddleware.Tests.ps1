Describe "Remove-RouteMiddleware" {

    BeforeAll {

        #  Import Module
        Import-Module "$PSScriptRoot\..\Polaris.psd1"

        #  Define test function to reduce redundancy
        function Test-RemoveMiddleware
            {
            [CmdletBinding()]
            param (
                [string[]]
                $Name,

                [Parameter( ValueFromPipeline = $True,
                            ValueFromPipelineByPropertyName = $True )]
                [object[]]
                $Object
                )

            begin
                {
                $Objects = @()
                }

            process
                {
                $Objects += $Object
                }

            End
                {
                #  Get before state
                $MiddlewareBefore   = Get-RouteMiddleware

                If ( $Objects )
                    {
                    $MiddlewareToDelete = $Objects | Get-RouteMiddleware
                    $MiddlewareExpectedAfter = $MiddlewareBefore.Count - $MiddlewareToDelete.Count

                    #  Remove
                    $Objects | Remove-RouteMiddleware
                    }
                Else
                    {
                    $MiddlewareToDelete = @( Get-RouteMiddleware -Name $Name )
                    $MiddlewareExpectedAfter = $MiddlewareBefore.Count - $MiddlewareToDelete.Count

                    #  Remove
                    Remove-RouteMiddleware -Name $Name
                    }

                #  Get after state
                $DeletedMiddlewareRemaining = $MiddlewareToDelete | Get-RouteMiddleware
                $TotalRemainingMiddleware   = Get-RouteMiddleware

                #  Test after state
                $DeletedMiddlewareRemaining.Count | Should Be 0
                $TotalRemainingMiddleware.Count   | Should Be $MiddlewareExpectedAfter
                }
            }

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

    It "Should delete middleware" {
        
        Test-RemoveMiddleware -Name 'Test1'
        }

    It "Should do nothing when no middleware match" {
        
        Test-RemoveMiddleware -Name 'DoesNotExist'
        }

    It "Should accept multiple values for Name" {

        Test-RemoveMiddleware -Name 'Test2A', 'Test2B'
        }

    It "Should accept wildcard values for Name" {

        Test-RemoveMiddleware -Name 'Test3*'
        }

    It "Should accept Name from pipeline" {

        'Test4A', 'Test4B' | Test-RemoveMiddleware
        }

    It "Should accept Name from pipeline variables" {

        Get-RouteMiddleware -Name 'Test5*' | Test-RemoveMiddleware
        }

    It "Should delete all middleware if no Name parameter" {

        #  Remove
        Remove-RouteMiddleware

        #  Get after state
        $TotalRemainingMiddleware = Get-RouteMiddleware

        #  Test after state
        $TotalRemainingMiddleware.Count | Should Be 0
        }

    AfterAll {

        #  Clean up test middleware
        Remove-RouteMiddleware
        }
    }
