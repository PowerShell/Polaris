Describe "Test middleware creation/usage (E2E)" {

    BeforeAll {

        $Port = Get-Random -Minimum 7000 -Maximum 7999

        Start-Job -Scriptblock {
            Import-Module $using:PSScriptRoot\..\..\Polaris.psd1

            New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
                $Response.Send('Hello World')
            }

            $Polaris = Start-Polaris -Port $using:Port -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware
            
            $defaultMiddleware = {
                if ($Request.BodyString -ne $null) {
                    $Request.Body | Add-Member -Name NewProperty -Value "Manipulated" -MemberType NoteProperty
                }
            }

            New-PolarisRouteMiddleware -Name TestMiddleware -Scriptblock $defaultMiddleware

            New-PolarisPostRoute -Path "/hello" -Scriptblock {
                if ($Request.Body.Name) {
                    $Response.Send('Hello ' + $Request.Body.Name)
                }
                else {
                    $Response.Send('Hello World')
                }
            }

            New-PolarisPostRoute -Path "/NewProperty" -Scriptblock {
                if ($Request.Body.NewProperty) {
                    $Response.Send('Hello ' + $Request.Body.NewProperty)
                }
                else {
                    $Response.Send('Hello World')
                }
            }

            # Keeping the job running while the tests are running
            while ($Polaris.Listener.IsListening) {
                Wait-Event callbackeventbridge.callbackcomplete
            }
        }

        # Give the Polaris Server time to start up in the job
        Start-Sleep -Seconds 5
    }

    Context "Test -UseJsonBodyParserMiddleware flag" {
        It "Can use the body parameters in route scripts" {
            $body = @{ Name = 'Atlas' } | ConvertTo-Json
            (Invoke-RestMethod -Uri "http://localhost:$Port/hello" -Method POST -Body $body) | Should Be 'Hello Atlas'
        }
    }
    Context "Test adding a new middleware" {
        It "Manipulates the Request before the Route script gets it" {
            $body = @{ Name = 'Atlas' } | ConvertTo-Json
            (Invoke-RestMethod -Uri "http://localhost:$Port/NewProperty" -Method POST -Body $body) | Should Be 'Hello Manipulated'
        }
    }
    AfterAll {
        # Cleanup test job
        Get-Job | Stop-Job | Remove-Job
    }
}
