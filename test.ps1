<##
 # Visiting /helloworld should print "123" in the browser
 #>




$Server = @{
    Port = 8080
    MaxThreadCount = 1000
    Debug = $true
    Routes = @(
        @{
            Path    = '/helloworld'
            Method  = 'GET'
            Handler = {
                Param($Request, $Response)
                $Response.Body = "1"
            }
        },
        @{
            Path    = 'he(l+)o'
            Method  = 'GET'
            Handler = {
                Param($Response, $Matches)
                $Response.Body += "2"
            }
        },
        @{
            Path    = '*'
            Method  = 'GET'
            Handler = {
                Param($Response)
                $Response.Body += "3"
            }
        }
    )
}




$ErrorActionPreference = "Stop"
Start-Job {
    Import-Module "$PSScriptRoot\Polaris" -Force
    Start-PolarisServer $using:Server
}

