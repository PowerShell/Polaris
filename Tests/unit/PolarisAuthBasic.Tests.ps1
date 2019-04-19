#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Describe "Polaris Authentication" {

    BeforeAll {
        Start-Job -Scriptblock {
            Import-Module $using:PSScriptRoot\..\..\Polaris.psd1

            New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
                $Response.Send('Hello World')
            }

            $Polaris = Start-Polaris -Auth Basic

            New-PolarisRoute -Method GET -Path '/' -Force -Scriptblock {
                $ResponseJson = @{
                    Username = $Request.User.identity.Name
                    Password = $Request.User.identity.Password
                } | ConvertTo-Json

                $Response.SetContentType("application/json")
                $Response.Send($ResponseJson)
            }

            # Keeping the job running while the tests are running
            while ($Polaris.Listener.IsListening) {
                Wait-Event callbackeventbridge.callbackcomplete
            }
        }

        # Give the Polaris Server time to start up in the job
        Start-Sleep -Seconds 5
    }

    It 'Authenticates and passes on Basic authentication credentials, -Username <Username> -Password <Pass>' -TestCases @(
        @{ Username = 'blah'; Pass = 'hellothere'}
        @{ Username = 'username'; Pass = 'username'}
        @{ Username = 'jeremym'; Pass = 'asdasdf@2232!!*%#23'}
        @{ Username = '!'; Pass = '@'}
        @{ Username = 'reallong'; Pass = 'a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!'}
    ) {
        param ($Username, $Pass)

        $BasicAuth = $Username + ":" + $Pass
        $Base64BasicAuth = [convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(($BasicAuth)))

        $Headers = @{}
        $Headers["Authorization"] = "Basic $Base64BasicAuth"

        $Result = Invoke-RestMethod -Uri "http://localhost:8080" -Method Get -UseBasicParsing -Headers $Headers

        $UsernameAndPasswordMatch = $False

        if ($Result.Username -eq $Username -and $Result.Password -eq $Pass) {
            $UsernameAndPasswordMatch = $True
        }
        Write-Debug "UsernameAndPasswordMatch: $UsernameAndPasswordMatch"
        $UsernameAndPasswordMatch | Should -Be $True
    }

    AfterAll {
        Get-Job | Stop-Job | Remove-Job
    }
}
