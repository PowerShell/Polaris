#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Describe "Hostname Parameter" {

    BeforeAll {

        #Start the server with a function to not repeat code
        function New-PolarisHostTest {
            Param
            (
                [Parameter(Mandatory = $true)]
                $HostName
            )
            Process {
                Start-Job -ArgumentList @($HostName) -Scriptblock {
                    # Import Polaris
                    Import-Module -Name $using:PSScriptRoot\..\..\Polaris.psd1

                    $HostName = $args[0]
                    $DebugPreference = "Continue"

                    New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
                        $Response.Send('Hello World')
                    }

                    # Start the app
                    $Polaris = Start-Polaris -Port 8080 -HostName $HostName

                    # Keeping the job running while the tests are running
                    while ($Polaris.Listener.IsListening) {
                        Wait-Event callbackeventbridge.callbackcomplete
                    }
                }

                # Giving server job time to start up
                Start-Sleep -seconds 8
            }
        }

        function Stop-PolarisHostTest {
            Get-Job | Stop-Job -PassThru | Remove-Job
        }
    }

    Context "Using localhost as hostname" {
        New-PolarisHostTest -hostname "localhost"

        It "test /helloworld route" {
            $Result = Invoke-WebRequest -Uri "http://localhost:8080/helloworld" -UseBasicParsing -TimeoutSec 2
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test GET to /IDontExist route" {
            try {
                Invoke-RestMethod -Uri "http://localhost:8080/IDontExist" -Method POST
            }
            catch {
                $_.Exception.Response.StatusCode.value__ | Should Be 404
            }
        }

        Stop-PolarisHostTest
    }

    Context "Using 127.0.0.1 as hostname" {
        New-PolarisHostTest -hostname "127.0.0.1"

        It "test /helloworld route" {
            $Result = Invoke-WebRequest -Uri "http://127.0.0.1:8080/helloworld" -UseBasicParsing -TimeoutSec 2
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test GET to /IDontExist route" {
            try {
                Invoke-RestMethod -Uri "http://127.0.0.1:8080/IDontExist" -Method POST
            }
            catch {
                $_.Exception.Response.StatusCode.value__ | Should Be 404
            }
        }

        Stop-PolarisHostTest
    }

    Context "Using + as hostname" {
        New-PolarisHostTest -hostname "+"

        It "test /helloworld route" {
            $Result = Invoke-WebRequest -Uri "http://localhost:8080/helloworld" -UseBasicParsing -TimeoutSec 2
            $Result.Content | Should Be 'Hello World'
            $Result.StatusCode | Should Be 200
        }

        It "test GET to /IDontExist route" {
            try {
                Invoke-RestMethod -Uri "http://localhost:8080/IDontExist" -Method POST
            }
            catch {
                $_.Exception.Response.StatusCode.value__ | Should Be 404
            }
        }

        Stop-PolarisHostTest
    }
}
