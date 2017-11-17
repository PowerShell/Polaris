Describe "New-WebRoute" {

    BeforeAll {

        #  Import module
        Import-Module -Name Polaris

        #  Create 
        $GUID = [string][guid]::NewGuid()
        $TestPath = ( New-Item -Path $Env:Temp -Name $GUID -ItemType Directory ).FullName
        
        #  Start with a clean slate
        Remove-WebRoute
        }

    It "Should create GET route" {

        #  Define route
        $Method = 'GET'
        $Path   = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock
        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should create POST route" {

        #  Define route
        $Method = 'POST'
        $Path   = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock
        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should create PUT route" {

        #  Define route
        $Method = 'PUT'
        $Path   = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock
        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should create DELETE route" {

        #  Define route
        $Method = 'DELETE'
        $Path   = "TestRoute$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock
        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should create route with Scriptpath" {

        #  Define route
        $Method = 'GET'
        $Path   = "TestScriptBlockRoute$Method"
        $ScriptPath = "$TestPath\$Path.ps1"

        $Path | Out-File -FilePath $ScriptPath -NoNewline

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptPath $ScriptPath
        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should throw error if Scriptpath not found" {

        #  Define route
        $Method = 'GET'
        $Path   = "TestScriptBlockRoute$Method"
        $ScriptPath = "$TestPath\DOESNOTEXIST.ps1"

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptPath $ScriptPath | Should Throw
        }

    It "Should create route with matching Path but new Method" {

        #  Define route
        $Method = 'GET'
        $Path   = "TestNewMethod$Method"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock

        #  Define route
        $Method = 'POST'
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock

        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $Path
        }

    It "Should throw error if route for Path and Method exists" {

        #  Define route
        $Method = 'GET'
        $Path   = "TestExisting"
        $Scriptblock = [scriptblock]::Create( $Path )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock | Should Throw
        }

    It "Should overwrite route with matching Path and Method with Force switch" {

        #  (Using existing route from previous test.)

        #  Define route
        $Method = 'GET'
        $Path   = "TestExisting"
        $NewContent = "NewContent"
        $Scriptblock = [scriptblock]::Create( $NewContent )

        #  Create route
        New-WebRoute -Path $Path -Method $Method -ScriptBlock $Scriptblock -Force

        
        #  Test route
        ( Get-WebRoute -Path $Path -Method $Method ).Scriptblock | Should Be $NewContent
        }

    AfterAll {

        #  Clean up test routes
        Remove-WebRoute

        #  Clean up test files
        Get-ChildItem -Path $TestPath -Recurse | Remove-Item -Recurse -Force
        Remove-Item -Path $TestPath
        }
    }
