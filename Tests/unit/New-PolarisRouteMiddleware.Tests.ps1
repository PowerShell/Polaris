Describe "New-PolarisRouteMiddleware" {

    BeforeAll {

        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        #  Start with a clean slate
        Remove-PolarisRouteMiddleware
    }

    It "Should create middleware" {

        #  Define middleware
        $Name = "TestMiddleware"
        $Scriptblock = [scriptblock]::Create( $Name )

        #  Create middleware
        New-PolarisRouteMiddleware -Name $Name -Scriptblock $Scriptblock

        #  Test middleware
        ( Get-PolarisRouteMiddleware -Name $Name ).Scriptblock | Should Be $Name
    }

    It "Should create middleware with Scriptpath" {

        #  Define middleware
        $Name = "TestMiddlewareScriptPath"
        $ScriptPath = "TestDrive:\$Name.ps1"

        #  Create script file
        $Name | Out-File -FilePath $ScriptPath -NoNewline

        #  Create middleware
        New-PolarisRouteMiddleware -Name $Name -ScriptPath $ScriptPath

        #  Test middleware
        ( Get-PolarisRouteMiddleware -Name $Name ).Scriptblock | Should Be $Name
    }

    It "Should throw error if Scriptpath not found" {

        #  Define middleware
        $Name = "TestScriptPathNotFound"
        $ScriptPath = "TestDrive:\DOESNOTEXIST.ps1"

        #  Create middleware
        { New-PolarisRouteMiddleware -Name $Name -ScriptPath $ScriptPath -ErrorAction Stop } |
            Should Throw
    }

    It "Should throw error if middleware exists" {

        #  Define middleware
        $Name = "TestExisting"
        $Scriptblock = [scriptblock]::Create( $Name )

        #  Create middleware
        New-PolarisRouteMiddleware -Name $Name -Scriptblock $Scriptblock

        #  Create middleware
        { New-PolarisRouteMiddleware -Name $Name -Scriptblock $Scriptblock -ErrorAction Stop } |
            Should Throw
    }

    It "Should overwrite middleware with Force switch" {

        #  Define middleware
        $Name = "TestExistingWithForce"
        $NewContent = "NewContent"
        $Scriptblock = [scriptblock]::Create( $NewContent )

        #  Create middleware
        New-PolarisRouteMiddleware -Name $Name -Scriptblock $Scriptblock

        #  Test middleware
        ( Get-PolarisRouteMiddleware -Name $Name ).Scriptblock | Should Be $NewContent
    }

    AfterAll {

        #  Clean up test middleware
        Remove-PolarisRouteMiddleware
    }
}
