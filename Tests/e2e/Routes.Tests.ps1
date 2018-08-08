Describe "Polaris Routing (e2e)" {

    BeforeAll {
        
        $Port = Get-Random -Minimum 8000 -Maximum 8999
        $IsUnix = $PSVersionTable.Platform -eq "Unix"

        Start-Job -Scriptblock {
            # Import Polaris
            Import-Module -Name $using:PSScriptRoot\..\..\Polaris.psd1

            $DebugPreference = "Continue"

            New-PolarisRoute -Path "/users/:userId/books/:bookId" -Method "GET" -Scriptblock {
                $Response.Send(($Request.Parameters | ConvertTo-JSON))
            }

            New-PolarisRoute -Path "/flights/:from-:to" -Method "GET" -Scriptblock {
                $Response.Send(($Request.Parameters | ConvertTo-JSON))
            }

            New-PolarisRoute -Path "/flights/:from.:to" -Method "GET" -Scriptblock {
                $Response.Send(($Request.Parameters | ConvertTo-JSON))
            }

            New-PolarisRoute -Path "/user/(?<userId>\d+)" -Method "GET" -Scriptblock {
                $Response.Send(($Request.Parameters | ConvertTo-JSON))
            }

            New-PolarisRoute -Path "/" -Method "GET" -Scriptblock {
                $Response.Send("root")
            }

            New-PolarisRoute -Path "/about" -Method "GET" -Scriptblock {
                $Response.Send("about")
            }

            New-PolarisRoute -Path "/random.text" -Method "GET" -Scriptblock {
                $Response.Send("random.text")
            }

            New-PolarisRoute -Path "/12?34" -Method "GET" -Scriptblock {
                $Response.Send("12?34")
            }

            New-PolarisRoute -Path "/ab+cd" -Method "GET" -Scriptblock {
                $Response.Send("ab+cd")
            }

            New-PolarisRoute -Path "/ef*gh" -Method "GET" -Scriptblock {
                $Response.Send("ef*gh")
            }

            New-PolarisRoute -Path "/ij(kl)?m" -Method "GET" -Scriptblock {
                $Response.Send("ij(kl)?m")
            }

            # Start the app
            $Polaris = Start-Polaris -Port $using:Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional

            # Keeping the job running while the tests are running
            while ($Polaris.Listener.IsListening) {
                Wait-Event callbackeventbridge.callbackcomplete
            }
        }

        # Giving server job time to start up
        Start-Sleep -seconds 8
    }
    
    It "should match and extract named parameters anywhere in the route" {
        $Result = Invoke-RestMethod -Uri "http://localhost:$Port/users/12/books/123" -UseBasicParsing -TimeoutSec 2
        $Result.bookId | Should Be '123'
        $Result.userId | Should Be '12'
    }

    It "should interpret . and - literally" {
        $Result = Invoke-RestMethod -Uri "http://localhost:$Port/flights/LAX-SFO" -UseBasicParsing -TimeoutSec 2
        $Result.from | Should Be 'LAX'
        $Result.to | Should Be 'SFO'

        $Result = Invoke-RestMethod -Uri "http://localhost:$Port/flights/LAX.SFO" -UseBasicParsing -TimeoutSec 2
        $Result.from | Should Be 'LAX'
        $Result.to | Should Be 'SFO'
    }

    It "should allow custom named capture regular expressions" {
        $Result = Invoke-RestMethod -Uri "http://localhost:$Port/user/42" -UseBasicParsing -TimeoutSec 2
        $Result.userId | Should Be '42'
    }

    It "should provide matches with basic strings" {
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'root'

        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/about" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'about'
        
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/random.text" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'random.text'
    }

    It "should provide matches with string patterns" {
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/134" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be '12?34'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/1234" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be '12?34'

        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/abcd" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ab+cd'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/abbcd" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ab+cd'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/abbbcd" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ab+cd'

        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/efgh" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ef*gh'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/efxgh" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ef*gh'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/efRANDOMgh" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ef*gh'

        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/ijm" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ij(kl)?m'
        $Result = Invoke-WebRequest -Uri "http://localhost:$Port/ijklm" -UseBasicParsing -TimeoutSec 2
        $Result.Content | Should Be 'ij(kl)?m'
    }
}