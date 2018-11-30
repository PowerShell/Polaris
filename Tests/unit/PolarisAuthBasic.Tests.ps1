#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

Describe "Test Polaris Basic Auth" {
    
    BeforeAll {
        Start-Job -Scriptblock {
            Import-Module $using:PSScriptRoot\..\..\Polaris.psd1

            New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
                $Response.Send('Hello World')
            }

            $Polaris = Start-Polaris -MinRunspaces 1 -MaxRunspaces 5 -Auth Basic

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
    

    Context "Test Basic Auth provider" {
        function Test-BasicAuth {
            
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingUserNameAndPassWordParams", "")]
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
            param ($Username, $Password)
            
            It ("Username {0} and Password {1} should match request" -f $Username, $Password) {
                $EncryptedPass = $Password | ConvertTo-SecureString -asPlainText -Force
                $Credential = New-Object System.Management.Automation.PSCredential($Username, $EncryptedPass)                

                $Result = Invoke-RestMethod -Uri "http://localhost:8080" -Method Get -UseBasicParsing -Credential $Credential
                $Result.Username | Should Be $Username
                $Result.Password | Should Be $Password
            }
        }

        $testCases = @(
            @{ Username = 'blah'; Password = 'hellothere'}
            @{ Username = 'username'; Password = 'username'}
            @{ Username = 'jeremym'; Password = 'asdasdf@2232!!*%#23'}
            @{ Username = '!'; Password = '@'}
            @{ Username = 'reallong'; Password = 'a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!a!'}
        )

        foreach ($testCase in $testCases) {
            Test-BasicAuth @testCase
        }        
    }                   
    AfterAll {
        Get-Job | Stop-Job | Remove-Job
    }
}
