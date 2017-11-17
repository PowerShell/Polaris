Describe "New-RouteMiddleware" {

    BeforeAll {

        #  Import module
        Import-Module -Name Polaris

        #  Create test folder
        $GUID = [string][guid]::NewGuid()
        $TestPath = ( New-Item -Path $Env:Temp -Name $GUID -ItemType Directory ).FullName
        
        #  Start with a clean slate
        Remove-RouteMiddleware
        }

    It "Should create middleware" {

        #  Define middleware
        $Name   = "TestMiddleware"
        $Scriptblock = [scriptblock]::Create( $Name )

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptBlock $Scriptblock

        #  Test middleware
        ( Get-RouteMiddleware -Name $Name ).Scriptblock | Should Be $Name
        }

    It "Should create middleware with Scriptpath" {

        #  Define middleware
        $Name   = "TestMiddlewareScriptPath"
        $ScriptPath = "$TestPath\$Name.ps1"

        #  Create script file
        $Name | Out-File -FilePath $ScriptPath -NoNewline

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptPath $ScriptPath

        #  Test middleware
        ( Get-RouteMiddleware -Name $Name ).Scriptblock | Should Be $Name
        }

    It "Should throw error if Scriptpath not found" {

        #  Define middleware
        $Name   = "TestScriptPathNotFound"
        $ScriptPath = "$TestPath\DOESNOTEXIST.ps1"

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptPath $ScriptPath
        }

    It "Should throw error if middleware exists" {

        #  Define middleware
        $Name   = "TestExisting"
        $Scriptblock = [scriptblock]::Create( $Name )

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptBlock $Scriptblock

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptBlock $Scriptblock | Should Throw
        }

    It "Should overwrite middleware with Force switch" {

        #  Define middleware
        $Name   = "TestExistingWithForce"
        $NewContent = "NewContent"
        $Scriptblock = [scriptblock]::Create( $NewContent )

        #  Create middleware
        New-RouteMiddleware -Name $Name -ScriptBlock $Scriptblock

        #  Test middleware
        ( Get-RouteMiddleware -Name $Name ).Scriptblock | Should Be $NewContent
        }

    AfterAll {

        #  Clean up test middleware
        Remove-RouteMiddleware

        #  Clean up test folder
        Get-ChildItem -Path $TestPath -Recurse | Remove-Item -Recurse -Force
        Remove-Item -Path $TestPath
        }
    }
