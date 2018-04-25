Describe "Remove-PolarisRouteMiddleware" {

    BeforeAll {

        #  Import Module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

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
                $MiddlewareBefore   = Get-PolarisRouteMiddleware

                If ( $Objects )
                    {
                    $MiddlewareToDelete = $Objects | Get-PolarisRouteMiddleware
                    $MiddlewareExpectedAfter = $MiddlewareBefore.Count - $MiddlewareToDelete.Count

                    #  Remove
                    $Objects | Remove-PolarisRouteMiddleware
                    }
                Else
                    {
                    $MiddlewareToDelete = @( Get-PolarisRouteMiddleware -Name $Name )
                    $MiddlewareExpectedAfter = $MiddlewareBefore.Count - $MiddlewareToDelete.Count

                    #  Remove
                    Remove-PolarisRouteMiddleware -Name $Name
                    }

                #  Get after state
                $DeletedMiddlewareRemaining = $MiddlewareToDelete | Get-PolarisRouteMiddleware
                $TotalRemainingMiddleware   = Get-PolarisRouteMiddleware

                #  Test after state
                $DeletedMiddlewareRemaining.Count | Should Be 0
                $TotalRemainingMiddleware.Count   | Should Be $MiddlewareExpectedAfter
                }
            }

        #  Start with a clean slate
        Remove-PolarisRouteMiddleware

        #  Create middleware to test against
        New-PolarisRouteMiddleware -Name '/Test0'  -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test1'  -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test2A' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test2B' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test3A' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test3B' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test3C' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test4A' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test4B' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test5A' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test5B' -Scriptblock {}
        New-PolarisRouteMiddleware -Name '/Test6'  -Scriptblock {}
        }

    It "Should delete middleware" {
        
        Test-RemoveMiddleware -Name '/Test1'
        }

    It "Should do nothing when no middleware match" {
        
        Test-RemoveMiddleware -Name 'DoesNotExist'
        }

    It "Should accept multiple values for Name" {

        Test-RemoveMiddleware -Name '/Test2A', '/Test2B'
        }

    It "Should accept wildcard values for Name" {

        Test-RemoveMiddleware -Name '/Test3*'
        }

    It "Should accept Name from pipeline" {

        '/Test4A', '/Test4B' | Test-RemoveMiddleware
        }

    It "Should accept Name from pipeline variables" {

        Get-PolarisRouteMiddleware -Name '/Test5*' | Test-RemoveMiddleware
        }

    It "Should delete all middleware if no Name parameter" {

        #  Remove
        Remove-PolarisRouteMiddleware

        #  Get after state
        $TotalRemainingMiddleware = Get-PolarisRouteMiddleware

        #  Test after state
        $TotalRemainingMiddleware.Count | Should Be 0
        }

    AfterAll {

        #  Clean up test middleware
        Remove-PolarisRouteMiddleware
        }
    }
