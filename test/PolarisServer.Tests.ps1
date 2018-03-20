. "$PSScriptRoot\PolarisServer.ps1"

Describe "Test webserver use" {
    Context "Test different route responses" {
        It "test /helloworld route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld" -UseBasicParsing
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /helloworld route with query params that do nothing" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?test=true&another=one" -UseBasicParsing
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /header route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/header" -UseBasicParsing
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

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?PolarisLogs=true" -UseBasicParsing
            $result.Content -replace "`r" | Should Be ($expectedText -replace "`r")
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route with query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome?name=PowerShell" -UseBasicParsing
            $result.Content | Should Be 'Hello PowerShell'
            $result.StatusCode | Should Be 200
        }

        It "test /hellome route without query param" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome" -UseBasicParsing
            $result.Content | Should Be 'Hello World'
            $result.StatusCode | Should Be 200
        }

        It "test /wow route" {
            $result = Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method POST -UseBasicParsing
            $result.wow | Should Be $true
        }

        It "test /example route" {
            $result = Invoke-WebRequest -Uri "http://localhost:$Port/example" -UseBasicParsing
            $result.Content | Should Be 'test file'
            $result.StatusCode | Should Be 200
        }

        It "test /public/index.html static route" {
            $expectedHtml = `
'<div>hello world</div>

<img src="test.png" alt="yay" />
<img src="test.png" alt="yay" />
<img src="test1.png" alt="yay" />'

            $result = Invoke-WebRequest -Uri "http://localhost:$Port/public/index.html" -UseBasicParsing
            $result.Content | Should Be $expectedHtml
            $result.StatusCode | Should Be 200
        }

        It "test /error route that returns 500" {
            { Invoke-WebRequest -Uri "http://localhost:$Port/error" -UseBasicParsing } | Should Throw
        }

        AfterAll {
            Stop-Polaris
        }
    }

    Context "Test starting and stopping of the server" {
        BeforeAll {
            if ($IsWindows -or $IsWindows -eq $null) {
                Stop-Polaris
                Start-Polaris -Port 9998
    
                $result = Invoke-WebRequest -Uri "http://localhost:9998/helloworld" -UseBasicParsing
                $result.StatusCode | Should Be 200
            }
        }

        It "Can properly shut down the server" {
            Stop-Polaris

            { Invoke-WebRequest -Uri "http://localhost:9998/helloworld" -UseBasicParsing } | Should Throw
        }
    }
}
