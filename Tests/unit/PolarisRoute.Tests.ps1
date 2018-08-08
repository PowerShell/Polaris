Describe "Test route creation" {
    BeforeAll {
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        $defaultScriptblock = {
            $Response.Send("test script")
        }
        $defaultScriptPath = "$PSScriptRoot/../resources/test.ps1"
        $defaultStaticDirectory = "$PSScriptRoot/../resources/static"

        function RouteExists ($Path, $Method) {
            [string]$SanitizedPath = $Path.TrimEnd('/')

            if ( [string]::IsNullOrEmpty($SanitizedPath) ) { $SanitizedPath = "/" }

            return $null -ne (Get-Polaris).ScriptblockRoutes[$SanitizedPath][$Method] 
        }
    }
    Context "Using New-PolarisRoute" {
        It "with -Path '<Path>' -Method '<Method>' -ScriptPath '<ScriptPath>' -Scriptblock '<Scriptblock>'" `
            -TestCases @(
            @{ Path = '/test'; Method = 'GET'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
            @{ Path = '/test'; Method = 'POST'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
            @{ Path = '/test'; Method = 'PUT'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
            @{ Path = '/test'; Method = 'DELETE'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
            @{ Path = '/test'; Method = 'GET'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; Method = 'POST'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; Method = 'PUT'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; Method = 'DELETE'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
        ) {
            param ($Path, $Method, $ScriptPath, $Scriptblock)
            if ($ScriptPath) {
                New-PolarisRoute -Path $Path -Method $Method -ScriptPath $ScriptPath
            }
            else {
                New-PolarisRoute -Path $Path -Method $Method -Scriptblock $Scriptblock
            }
            RouteExists -Path $Path -Method $Method | Should Be $true
        }
    }

    Context "Using New-PolarisGetRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -Scriptblock '<Scriptblock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
        ) {
            param ($Path, $ScriptPath, $Scriptblock)
            if ($ScriptPath -ne $null -and $ScriptPath -ne '') {
                New-PolarisGetRoute -Path $Path -ScriptPath $ScriptPath
            }
            else {
                New-PolarisGetRoute -Path $Path -Scriptblock $Scriptblock
            }
            RouteExists -Path $Path -Method 'GET' | Should Be $true
        }
    }

    Context "Using New-PolarisPostRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -Scriptblock '<Scriptblock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
        ) {
            param ($Path, $ScriptPath, $Scriptblock)
            if ($ScriptPath) {
                New-PolarisPostRoute -Path $Path -ScriptPath $ScriptPath
            }
            else {
                New-PolarisPostRoute -Path $Path -Scriptblock $Scriptblock
            }
            RouteExists -Path $Path -Method 'POST' | Should Be $true
        }
    }

    Context "Using New-PolarisPutRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -Scriptblock '<Scriptblock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
        ) {
            param ($Path, $ScriptPath, $Scriptblock)
            if ($ScriptPath) {
                New-PolarisPutRoute -Path $Path -ScriptPath $ScriptPath
            }
            else {
                New-PolarisPutRoute -Path $Path -Scriptblock $Scriptblock
            }
            RouteExists -Path $Path -Method 'PUT' | Should Be $true
        }
    }

    Context "Using New-PolarisDeleteRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -Scriptblock '<Scriptblock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; Scriptblock = $null }
            @{ Path = '/test'; ScriptPath = $null; Scriptblock = $defaultScriptblock }
        ) {
            param ($Path, $ScriptPath, $Scriptblock)
            if ($ScriptPath) {
                New-PolarisDeleteRoute -Path $Path -ScriptPath $ScriptPath
            }
            else {
                New-PolarisDeleteRoute -Path $Path -Scriptblock $Scriptblock
            }
            RouteExists -Path $Path -Method 'DELETE' | Should Be $true
        }
    }

    Context "Using New-PolarisStaticRoute" {
        It "Will create a route for every file in a directory without the RoutePath param" {

            New-PolarisStaticRoute -FolderPath $defaultStaticDirectory

            RouteExists -Path "/:FilePath?" -Method 'GET' | Should Be $true
        }
        It "Will create a route for every file in a directory with the RoutePath param" {

            New-PolarisStaticRoute -RoutePath '/test' -FolderPath $defaultStaticDirectory

            RouteExists -Path '/test/:FilePath?' -Method 'GET' | Should Be $true
        }
    }

    Context "Using Get-PolarisRoute and Remove-PolarisRoute" {
        It "Will get the object with the routes" {
            ( Get-PolarisRoute -Path "/test" -Method "GET" ).Scriptblock |
                Should Be $defaultScriptblock.ToString()
        }
        It "will remove the routes" {
            Remove-PolarisRoute -Path "/test" -Method "GET"
            (Get-PolarisRoute).Count | Should Be 0
        }
        BeforeEach {
            New-PolarisRoute -Path "/test" -Method "GET" -Scriptblock $defaultScriptblock
        }
        AfterEach {
            Clear-Polaris
        }
    }

    AfterEach {
        Clear-Polaris
    }
}
