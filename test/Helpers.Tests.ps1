Describe "Helper functions" {

    BeforeAll {
        
        #  Import module
        Import-Module -Name Polaris

        #  Create test folder
        $GUID = [string][guid]::NewGuid()
        $TestPath = ( New-Item -Path $Env:Temp -Name $GUID -ItemType Directory ).FullName
        
        #  Create test script
        $ScriptPath = "$TestPath\TestScript.ps1"
        $Script = 'Script'
        $Script | Out-File -FilePath $ScriptPath -NoNewline

        #  Start with a clean slate
        Remove-WebRoute
        }

    Context "New-GetRoute" {

        It "Should create GET route" {

            #  Define route
            $Method = "GET"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-GetRoute -Path $Path -ScriptBlock $Scriptblock

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create GET route with Scriptpath" {

            #  Define route
            $Method = 'GET'
            $Path   = "TestScriptBlockRoute$Method"

            #  Create route
            New-GetRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-PostRoute" {

        It "Should create POST route" {

            #  Define route
            $Method = "POST"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PostRoute -Path $Path -ScriptBlock $Scriptblock

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create POST route with Scriptpath" {

            #  Define route
            $Method = 'POST'
            $Path   = "TestScriptBlockRoute$Method"

            #  Create route
            New-PostRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-PutRoute" {

        It "Should create PUT route" {

            #  Define route
            $Method = "PUT"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-PutRoute -Path $Path -ScriptBlock $Scriptblock

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create PUT route with Scriptpath" {

            #  Define route
            $Method = 'PUT'
            $Path   = "TestScriptBlockRoute$Method"

            #  Create route
            New-PutRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    Context "New-DeleteRoute" {

        It "Should create DELETE route" {

            #  Define route
            $Method = "DELETE"
            $Path   = "TestRoute$Method"
            $Scriptblock = [scriptblock]::Create( $Path )

            #  Create route
            New-DeleteRoute -Path $Path -ScriptBlock $Scriptblock
 
            #  Test route
           ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
            }

        It "Should create DELETE route with Scriptpath" {

            #  Define route
            $Method = 'DELETE'
            $Path   = "TestScriptBlockRoute$Method"

            #  Create route
            New-DeleteRoute -Path $Path -ScriptPath $ScriptPath

            #  Test route
            ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Script
            }
        }

    AfterAll {

        #  Clean up test routes
        Remove-WebRoute

        #  Clean up test folder
        Get-ChildItem -Path $TestPath -Recurse | Remove-Item -Recurse -Force
        Remove-Item -Path $TestPath
        }
    }
