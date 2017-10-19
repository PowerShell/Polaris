$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$defaultScriptBlock = {
    param($request, $response)
    $response.Send("test script");
}
$defaultScriptPath = './test.ps1';
$defaultStaticDirectory = './static';

function RouteExists ($Path, $Method) {
    return $Global:Polaris.ScriptBlockRoutes[$Path.TrimEnd('/').TrimStart('/')][$Method] -ne $null
}

Describe "Test route creation" {
    Context "Using New-WebRoute" {
        It "with -Path '<Path>' -Method '<Method>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; Method = 'GET'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
            @{ Path = '/test'; Method = 'POST'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
            @{ Path = '/test'; Method = 'PUT'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
            @{ Path = '/test'; Method = 'DELETE'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
            @{ Path = '/test'; Method = 'GET'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; Method = 'POST'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; Method = 'PUT'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; Method = 'DELETE'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
        ) {
            param ($Path, $Method, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-WebRoute -Path $Path -Method $Method -ScriptPath $ScriptPath
            } else {
                New-WebRoute -Path $Path -Method $Method -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method $Method | Should Be $true
        }
    }

    Context "Using New-GetRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath -ne $null -and $ScriptPath -ne '') {
                New-GetRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-GetRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'GET' | Should Be $true
        }
    }

    Context "Using New-PostRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-PostRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PostRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'POST' | Should Be $true
        }
    }

    Context "Using New-PutRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-PutRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PutRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'PUT' | Should Be $true
        }
    }

    Context "Using New-DeleteRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-DeleteRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-DeleteRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'DELETE' | Should Be $true
        }
    }

    Context "Using New-StaticRoute" {
        It "Will create a route for every file in a directory without the RoutePath param" {

            New-StaticRoute -FolderPath $defaultStaticDirectory

            RouteExists -Path 'index.html' -Method 'GET' | Should Be $true
            RouteExists -Path 'test.png' -Method 'GET' | Should Be $true
            RouteExists -Path 'test1.png' -Method 'GET' | Should Be $true
        }
        It "Will create a route for every file in a directory with the RoutePath param" {

            New-StaticRoute -RoutePath '/test' -FolderPath $defaultStaticDirectory

            RouteExists -Path 'test/index.html' -Method 'GET' | Should Be $true
            RouteExists -Path 'test/test.png' -Method 'GET' | Should Be $true
            RouteExists -Path 'test/test1.png' -Method 'GET' | Should Be $true
        }
    }

    AfterEach {
        $Global:Polaris = $null
    }
}