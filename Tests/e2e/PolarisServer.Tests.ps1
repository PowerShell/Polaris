#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Describe "Test webserver use (E2E)" {

    BeforeAll {

        $Port = Get-Random -Minimum 8000 -Maximum 8999
        $IsUnix = $PSVersionTable.Platform -eq "Unix"

        Start-Job -Scriptblock {
            # Import Polaris
            Import-Module -Name $using:PSScriptRoot\..\..\Polaris.psd1

            # Support Headers
            New-PolarisRoute -Path /header -Method "GET" -Scriptblock {
                $Response.SetHeader('Location', 'http://www.contoso.com/')
                $Response.Send("Header test")
            }

            # Support Path Parameters
            New-PolarisGetRoute -Path "/hello/:Name" -ScriptBlock {
                $Response.Send("Hello $($Request.Parameters.Name)")
            }

            # Hello World passing in the Path, Method & Scriptblock
            New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
                Write-Host "This is Write-Host"
                Write-Information "This is Write-Information" -Tags Tag0
                $Response.Send('Hello World')
            }

            # Hello World passing in the Path, Method & Scriptblock
            New-PolarisRoute -Path /hellome -Method GET -Scriptblock {
                if ($Request.Query['name']) {
                    $Response.Send('Hello ' + $Request.Query['name'])
                }
                else {
                    $Response.Send('Hello World')
                }
            }

            $sbWow = {
                $json = @{
                    wow = $true
                }

                # .Json helper function that sets content type
                $Response.Json(($json | ConvertTo-Json))
            }

            # Supports helper functions for Get, Post, Put, Delete
            New-PolarisPostRoute -Path /wow -Scriptblock $sbWow

            # Pass in script file
            New-PolarisRoute -Path /example -Method GET -ScriptPath $using:PSScriptRoot\..\resources\test.ps1

            # Support static serving of a directory
            New-PolarisStaticRoute -FolderPath $using:PSScriptRoot/../resources/static -RoutePath /public

            New-PolarisGetRoute -Path /error -Scriptblock {
                $params = @{ }
                Write-Host "asdf"
                throw "Error"
                $Response.Send("this should not show up in response")
            }

            # Support sending empty response

            New-PolarisGetRoute -path /empty -Scriptblock {
                $Response.StatusCode = 204
                $Response.Send()
            }

            New-PolarisGetRoute -path /empty-string -Scriptblock {
                $Response.StatusCode = 204
                $Response.Send('')
            }

            # Start the app
            $Polaris = Start-Polaris -Port $using:Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional

            # Keeping the job running while the tests are running
            while ($Polaris.Listener.IsListening) {
                Wait-Event callbackeventbridge.callbackcomplete
            }

        }

        # Giving server job time to start up
        Start-Sleep -seconds 5
    }

    Context "Test different route responses" {
        It "test /helloworld route" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld" -UseBasicParsing -TimeoutSec 2
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test /helloworld route with query params that do nothing" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?test=true&another=one" -UseBasicParsing
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test /header router" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/header" -UseBasicParsing
            $Result.Content | Should Be 'Header test'
            $Result.StatusCode | Should Be 200
            $Result.Headers['Location'] | Should be 'http://www.contoso.com/'
        }
        It "test /helloworld route with log query param" {
            $expectedText = `
                "
[PSHOST]This is Write-Host
[Tag0]This is Write-Information

Hello World"

            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld?PolarisLogs=true" -UseBasicParsing
            $Result.Content -replace "`r" | Should Be ($expectedText -replace "`r")
            $Result.StatusCode | Should Be 200
        }

        It "test /hellome route with query param" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome?name=PowerShell" -UseBasicParsing
            $Result.Content | Should Be 'Hello PowerShell'
            $Result.StatusCode | Should Be 200
        }

        It "test /hello/:Name route with name as path parameter" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/hello/Testing" -UseBasicParsing
            $Result.Content | Should Be 'Hello Testing'
            $Result.StatusCode | Should Be 200
        }

        It "test /hellomenew should respond 404" {
            { $Result = Invoke-RestMethod -Uri "http://localhost:$Port/hellomenew?name=PowerShell" -UseBasicParsing } | Should Throw
        }

        It "test /hellome/new should respond 404" {
            { $Result = Invoke-RestMethod -Uri "http://localhost:$Port/hellome/new?name=PowerShell" -UseBasicParsing } | Should Throw
        }

        It "test /hellome route without query param" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/hellome" -UseBasicParsing
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test /wow route" {
            $Result = Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method POST
            $Result.wow | Should Be $true
        }

        It "test GET to /wow route" {
            try {
                Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method GET
            }
            catch {
                $_.Exception.Response.StatusCode.value__ | Should Be 405
            }
        }

        It "test GET to /IDontExist route" {
            try {
                Invoke-RestMethod -Uri "http://localhost:$Port/IDontExist" -Method POST
            }
            catch {
                $_.Exception.Response.StatusCode.value__ | Should Be 404
            }
        }

        It "test /example route" {
            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/example" -UseBasicParsing
            $Result.Content | Should Be 'test file'
            $Result.StatusCode | Should Be 200
        }

        It "test /public/index.html static route" {
            $expectedHtml = Get-Content -Raw "$PSScriptRoot/../resources/static/index.html"

            $Result = Invoke-WebRequest -Uri "http://localhost:$Port/public/index.html" -UseBasicParsing
            $Result.Content | Should Be $expectedHtml
            $Result.StatusCode | Should Be 200
        }

        It "test /error route that returns 500" {
            { Invoke-WebRequest -Uri "http://localhost:$Port/error" -UseBasicParsing } | Should Throw
        }

        It "test POST to /error route that returns 500" {
            { Invoke-WebRequest -Uri "http://localhost:$Port/error" -UseBasicParsing } | Should Throw
        }

        It "should have an error response matching the thrown server error" {
            { Invoke-WebRequest -Uri "http://localhost:$Port/error" -UseBasicParsing }
            ($Error[0].ErrorDetails.Message -split "`n").Count | Should Be 5
        }

        It "should return an empty response" {
            [Microsoft.PowerShell.Commands.WebResponseObject]$Response = Invoke-WebRequest -Uri "http://localhost:$Port/empty" -UseBasicParsing
            $Response.Content.length | Should Be 0
            $Response.Headers.Keys -contains "Content-Type" | Should Be $False

            $Response = Invoke-WebRequest -Uri "http://localhost:$Port/empty-string" -UseBasicParsing
            $Response.Content.length | Should Be 0
            $Response.Headers.Keys -contains "Content-Type" | Should Be $False
        }

        AfterAll {
            Get-Job | Stop-Job | Remove-Job
        }
    }
}
