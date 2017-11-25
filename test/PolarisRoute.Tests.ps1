$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$defaultScriptBlock = {
    $response.Send("test script");
}
$defaultScriptPath = './test.ps1';
$defaultStaticDirectory = './static';

function RouteExists ($Path, $Method) {
    return $Global:Polaris.ScriptBlockRoutes[$Path.TrimEnd('/').TrimStart('/')][$Method] -ne $null
}

Describe "Test route creation" {
    Context "Using New-PolarisRoute" {
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
                New-PolarisRoute -Path $Path -Method $Method -ScriptPath $ScriptPath
            } else {
                New-PolarisRoute -Path $Path -Method $Method -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method $Method | Should Be $true
        }
    }

    Context "Using New-PolarisGetRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath -ne $null -and $ScriptPath -ne '') {
                New-PolarisGetRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PolarisGetRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'GET' | Should Be $true
        }
    }

    Context "Using New-PolarisPostRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-PolarisPostRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PolarisPostRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'POST' | Should Be $true
        }
    }

    Context "Using New-PolarisPutRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-PolarisPutRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PolarisPutRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'PUT' | Should Be $true
        }
    }

    Context "Using New-PolarisDeleteRoute" {
        It "with -Path '<Path>' -ScriptPath '<ScriptPath>' -ScriptBlock '<ScriptBlock>'" `
            -TestCases @(
            @{ Path = '/test'; ScriptPath = $defaultScriptPath; ScriptBlock = $null }
            @{ Path = '/test'; ScriptPath = $null; ScriptBlock = $defaultScriptBlock }
        ) {
            param ($Path, $ScriptPath, $ScriptBlock)
            if ($ScriptPath) {
                New-PolarisDeleteRoute -Path $Path -ScriptPath $ScriptPath
            } else {
                New-PolarisDeleteRoute -Path $Path -ScriptBlock $ScriptBlock
            }
            RouteExists -Path $Path -Method 'DELETE' | Should Be $true
        }
    }

    Context "Using New-PolarisStaticRoute" {
        It "Will create a route for every file in a directory without the RoutePath param" {

            New-PolarisStaticRoute -FolderPath $defaultStaticDirectory

            RouteExists -Path 'index.html' -Method 'GET' | Should Be $true
            RouteExists -Path 'test.png' -Method 'GET' | Should Be $true
            RouteExists -Path 'test1.png' -Method 'GET' | Should Be $true
        }
        It "Will create a route for every file in a directory with the RoutePath param" {

            New-PolarisStaticRoute -RoutePath '/test' -FolderPath $defaultStaticDirectory

            RouteExists -Path 'test/index.html' -Method 'GET' | Should Be $true
            RouteExists -Path 'test/test.png' -Method 'GET' | Should Be $true
            RouteExists -Path 'test/test1.png' -Method 'GET' | Should Be $true
        }
    }

    Context "Using Get-PolarisRoute and Remove-PolarisRoute" {
        It "Will get the object with the routes" {
            ( Get-PolarisRoute -Path "/test" -Method "GET" ).ScriptBlock |
                Should Be $defaultScriptBlock.ToString()
        }
        It "will remove the routes" {
            Remove-PolarisRoute -Path "/test" -Method "GET"
            (Get-PolarisRoute).Count | Should Be 0
        }
        BeforeEach {
            New-PolarisRoute -Path "/test" -Method "GET" -ScriptBlock $defaultScriptBlock
        }
        AfterEach {
            $Global:Polaris = $null
        }
    }

    AfterEach {
        $Global:Polaris = $null
    }
}