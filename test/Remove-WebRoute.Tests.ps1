Describe "Remove-WebRoute" {

    BeforeAll {
        
        #  Import module
        Import-Module ..\Polaris.psd1

        #  Define test function to reduce redundancy
        function Test-RemoveRoute
            {
            [CmdletBinding()]
            Param (
                [string[]]$Path,
                [string[]]$Method,

                [Parameter( ValueFromPipeline = $True )]
                [object[]]$Object
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
                $RoutesBefore = Get-WebRoute

                If ( $Objects )
                    {
                    $RoutesToDelete = $Objects | Get-WebRoute
                    $RoutesExpectedAfter = $RoutesBefore.Count - $RoutesToDelete.Count
                    #  Remove
                    $Objects | Remove-WebRoute
                    }
                Else
                    {
                    $RoutesToDelete = @( Get-WebRoute -Path $Path -Method $Method )
                    $RoutesExpectedAfter = $RoutesBefore.Count - $RoutesToDelete.Count

                    #  Remove
                    Remove-WebRoute -Path $Path -Method $Method
                    }

                #  Get after state
                $DeletedRoutesRemaining = $RoutesToDelete | Get-WebRoute
                $TotalRemainingRoutes   = Get-WebRoute

                #  Test after state
                $DeletedRoutesRemaining.Count | Should Be 0
                $TotalRemainingRoutes.Count   | Should Be $RoutesExpectedAfter
                }
            }

        #  Start with a clean slate
        Remove-WebRoute

        #  Create some web routes to test against
        New-WebRoute -Path 'Test0'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test0'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test1'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test2'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test2'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test3A' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test3B' -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test3C' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test4A' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test4B' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method POST -ScriptBlock {}
        New-WebRoute -Path 'Test5'  -Method PUT  -ScriptBlock {}
        New-WebRoute -Path 'Test6A' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test6B' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test7A' -Method GET  -ScriptBlock {}
        New-WebRoute -Path 'Test7B' -Method GET  -ScriptBlock {}
        }

    It "Should delete route" {
        Test-RemoveRoute -Path 'Test1' -Method 'GET'
        }

    It "Should respect Path" {
        Test-RemoveRoute -Path 'Test2' -Method '*'
        }

    It "Should respect Method" {
        Test-RemoveRoute -Path 'Test3*' -Method 'PUT'
        }

    It "Should do nothing when no routes match" {
        Test-RemoveRoute -Path 'DOESNOTEXIST' -Method 'PUT'
        }

    It "Should accept multiple values for Path" {
        Test-RemoveRoute -Path 'Test4A', 'Test4B' -Method 'GET'
        }

    It "Should accept multiple values for Method" {
        Test-RemoveRoute -Path 'Test5' -Method 'GET', 'POST'
        }

    It "Should accept Path from pipeline" {
        'Test6A', 'Test6B' | Test-RemoveRoute
        }

    It "Should accept Path and Method from pipeline variables" {
        Get-WebRoute -Path 'Test7A', 'Test7B' | Test-RemoveRoute
        }

    AfterAll {

        #  Clean up any test routes
        Remove-WebRoute
        }
    }
