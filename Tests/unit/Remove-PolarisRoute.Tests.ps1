Describe "Remove-PolarisRoute" {

    BeforeAll {
        
        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

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
                $RoutesBefore = Get-PolarisRoute

                If ( $Objects )
                    {
                    $RoutesToDelete = $Objects | Get-PolarisRoute
                    $RoutesExpectedAfter = $RoutesBefore.Count - $RoutesToDelete.Count
                    #  Remove
                    $Objects | Remove-PolarisRoute
                    }
                Else
                    {
                    $RoutesToDelete = @( Get-PolarisRoute -Path $Path -Method $Method )
                    $RoutesExpectedAfter = $RoutesBefore.Count - $RoutesToDelete.Count

                    #  Remove
                    Remove-PolarisRoute -Path $Path -Method $Method
                    }

                #  Get after state
                $DeletedRoutesRemaining = $RoutesToDelete | Get-PolarisRoute
                $TotalRemainingRoutes   = Get-PolarisRoute

                #  Test after state
                $DeletedRoutesRemaining.Count | Should Be 0
                $TotalRemainingRoutes.Count   | Should Be $RoutesExpectedAfter
                }
            }

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create some web routes to test against
        New-PolarisRoute -Path '/Test0'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test0'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test1'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test2'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test2'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test3A' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test3B' -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test3C' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test4A' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test4B' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method POST -Scriptblock {}
        New-PolarisRoute -Path '/Test5'  -Method PUT  -Scriptblock {}
        New-PolarisRoute -Path '/Test6A' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test6B' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test7A' -Method GET  -Scriptblock {}
        New-PolarisRoute -Path '/Test7B' -Method GET  -Scriptblock {}
        }

    It "Should delete route" {
        Test-RemoveRoute -Path '/Test1' -Method 'GET'
        }

    It "Should respect Path" {
        Test-RemoveRoute -Path '/Test2' -Method '*'
        }

    It "Should respect Method" {
        Test-RemoveRoute -Path '/Test3*' -Method 'PUT'
        }

    It "Should do nothing when no routes match" {
        Test-RemoveRoute -Path 'DOESNOTEXIST' -Method 'PUT'
        }

    It "Should accept multiple values for Path" {
        Test-RemoveRoute -Path '/Test4A', '/Test4B' -Method 'GET'
        }

    It "Should accept multiple values for Method" {
        Test-RemoveRoute -Path '/Test5' -Method 'GET', 'POST'
        }

    It "Should accept Path from pipeline" {
        '/Test6A', '/Test6B' | Test-RemoveRoute
        }

    It "Should accept Path and Method from pipeline variables" {
        Get-PolarisRoute -Path '/Test7A', '/Test7B' | Test-RemoveRoute
        }

    AfterAll {

        #  Clean up any test routes
        Remove-PolarisRoute
        }
    }
