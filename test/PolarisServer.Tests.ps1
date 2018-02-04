$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

$IsUnix = $PSVersionTable.Platform -eq "Unix"

Describe "Test webserver use" {
    Context "Test different route responses" {
        It "test /helloworld route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /helloworld route with query params that do nothing" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?test=true&another=one"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }


        It "test /header route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/header"
            $result.Content | Should Be 'Header test'
            $result.StatusCode | Should Be 200
            $result.Headers['Location'] | Should be 'http://www.contoso.com/'
        }
        It "test /helloworld route with log query param" {
            $expectedText = `
"
[PSHOST]This is Write-Host
[Tag0]This is Write-Information

Hello World"

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?PolarisLogs=true"
            $result.Content -replace "`r" | Should Be ($expectedText -replace "`r")
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route with query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome?name=PowerShell"
            $result.Content | Should Be 'Hello PowerShell'
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route without query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome"
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /wow route" {
            $result = Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method POST
            $result.wow | Should Be $true
        }

        It "test /example route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/example"
            $result.Content | Should Be 'test file'
            $result.StatusCode | Should Be 200
        }

        It "test /public/index.html static route" {
            $expectedHtml = `
'<div>hello world</div>

<img src="test.png" alt="yay" />
<img src="test.png" alt="yay" />
<img src="test1.png" alt="yay" />'

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/public/index.html"
            $result.Content | Should Be $expectedHtml
            $result.StatusCode | Should Be 200
        }

        It "test /error route that returns 500" {
            { Invoke-WebRequest -Uri "http://localhost:$Port/error" } | Should Throw
        }

        AfterAll {
            Stop-Polaris
        }
    }

    Context "Test starting and stopping of the server" {
        BeforeAll {
            if (-not $IsUnix) {
                Stop-Polaris
                Start-Polaris -Port 9998
    
                $result = Invoke-WebRequest -Uri "http://localhost:9998/helloworld"
                $result.StatusCode | Should Be 200
            }
        }

        It "Can properly shut down the server" {
            Stop-Polaris

            { Invoke-WebRequest -Uri "http://localhost:9998/helloworld" } | Should Throw
        } -Skip:$IsUnix
    }
}
