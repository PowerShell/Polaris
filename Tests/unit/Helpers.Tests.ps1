Describe "Helper functions" {

    BeforeAll {
        
        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        #  Create test script
        $ScriptPath = 'TestDrive:\TestScript.ps1'
        $Script = 'Script'
        $Script | Out-File -FilePath $ScriptPath -NoNewline

        #  Start with a clean slate
        Remove-PolarisRoute
        }

    Context "New-PolarisGetRoute" {

        It "Should create GET route" {

            #  Define route
            $Method = "GET"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PolarisGetRoute -Path $Path -Scriptblock $Scriptblock

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create GET route with Scriptpath" {

            #  Define route
            $Method = 'GET'
            $Path   = "TestScriptblockRoute$Method"

            #  Create route
            New-PolarisGetRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-PolarisPostRoute" {

        It "Should create POST route" {

            #  Define route
            $Method = "POST"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PolarisPostRoute -Path $Path -Scriptblock $Scriptblock

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create POST route with Scriptpath" {

            #  Define route
            $Method = 'POST'
            $Path   = "TestScriptblockRoute$Method"

            #  Create route
            New-PolarisPostRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-PolarisPutRoute" {

        It "Should create PUT route" {

            #  Define route
            $Method = "PUT"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PolarisPutRoute -Path $Path -Scriptblock $Scriptblock

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create PUT route with Scriptpath" {

            #  Define route
            $Method = 'PUT'
            $Path   = "TestScriptblockRoute$Method"

            #  Create route
            New-PolarisPutRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-PolarisDeleteRoute" {

        It "Should create DELETE route" {

            #  Define route
            $Method = "DELETE"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PolarisDeleteRoute -Path $Path -Scriptblock $Scriptblock
 
            #  Test route
           ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create DELETE route with Scriptpath" {

            #  Define route
            $Method = 'DELETE'
            $Path   = "TestScriptblockRoute$Method"

            #  Create route
            New-PolarisDeleteRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisRoute
        }
    }
