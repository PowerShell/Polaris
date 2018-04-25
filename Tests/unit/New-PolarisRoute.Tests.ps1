Describe "New-PolarisRoute" {

    BeforeAll {

        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        #  Start with a clean slate
        Remove-PolarisRoute
    }

    It "Should create GET route" {

        #  Define route
        $Method = 'GET'
        $Path = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock
        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }
    
    ## Fix for bug n°108 - Creating route with a lowercase 'get'

    It "Should create route with lower case parameters" {

        New-PolarisRoute -Path /108 -Method get -Scriptblock {

            $line = "<h1>this is H1</h1>"
            $response.SetContentType("text/html");  
            $response.send($line)
        } -force

        (Get-PolarisRoute -Path 108).Method | should be 'GET'
    }
    
    It "Should create POST route" {

        #  Define route
        $Method = 'POST'
        $Path = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock
        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }

    It "Should create PUT route" {

        #  Define route
        $Method = 'PUT'
        $Path = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock
        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }

    It "Should create DELETE route" {

        #  Define route
        $Method = 'DELETE'
        $Path = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock
        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }

    It "Should create route with Scriptpath" {

        #  Define route
        $Method = 'GET'
        $Path = "TestScriptblockRoute$Method"
        $ScriptPath = "TestDrive:\$Path.ps1"

        $Path | Out-File -FilePath $ScriptPath -NoNewline

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -ScriptPath $ScriptPath
        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }

    It "Should throw error if Scriptpath not found" {

        #  Define route
        $Method = 'GET'
        $Path = "TestScriptblockRoute$Method"
        $ScriptPath = "TestDrive:\DOESNOTEXIST.ps1"

        #  Create route
        { New-PolarisRoute -Path $Path -Method $Method -ScriptPath $ScriptPath -ErrorAction Stop } |
            Should Throw
    }

    It "Should create route with matching Path but new Method" {

        #  Define route
        $Method = 'GET'
        $Path = "TestNewMethod$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock

        #  Define route
        $Method = 'POST'
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock

        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
    }

    It "Should throw error if route for Path and Method exists" {

        #  Define route
        $Method = 'GET'
        $Path = "TestExisting"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock

        #  Create route
        { New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock -ErrorAction Stop } |
            Should Throw
    }

    It "Should overwrite route with matching Path and Method with Force switch" {

        #  (Using existing route from previous test.)

        #  Define route
        $Method = 'GET'
        $Path = "TestExisting"
        $NewContent = "NewContent"
        $Scriptblock = [scriptblock]::Create( $NewContent )

        #  Create route
        New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock -Force

        
        #  Test route
        ( Get-PolarisRoute -Path $Path -Method $Method ).Scriptblock | Should Be $NewContent
    }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisRoute
    }
}
