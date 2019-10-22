<#
.SYNOPSIS
    Start Polaris web server.
.DESCRIPTION
    Start Polaris web server.
.PARAMETER Port
    Port number to listen on.
    Defaults to 8080.
.PARAMETER MinRunspaces
    Minimum number of PowerShell runspaces for web server to use.
    Defaults to 1.
.PARAMETER MaxRunspaces
    Maximum number of PowerShell runspaces for web server to use.
    Defaults to 1.
.PARAMETER UseJsonBodyParserMiddleware
    When present, JSONBodyParser middleware will be created, if needed.
.PARAMETER Https
    Determines if you want to use https as the prefix.
.PARAMETER HostName
    Determines the hostname used in the URL prefix.
    Defaults to localhost.
.PARAMETER Auth
    Polaris will use various authentication methods to authenticate requests.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    Start-Polaris
.EXAMPLE
    Start-Polaris -Port 8081 -MinRunspaces 2 -MaxRunspaces 10 -UseJsonBodyParserMiddleware
#>
function Start-Polaris {
    [CmdletBinding()]
    param(
        [Int32]
        $Port = 8080,

        [Int32]
        $MinRunspaces = 1,

        [Int32]
        $MaxRunspaces = 1,

        [switch]
        $UseJsonBodyParserMiddleware = $False,

        [ValidateScript( {
                if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
                    throw "SSL is not supported on Linux and Mac. Please proxy the traffic."
                }
                else {
                    $true
                }
            })]
        [switch]
        $Https = $False,

        [String]
        $HostName = 'localhost',

        [ValidateSet('Anonymous', 'Basic', 'Digest', 'IntegratedWindowsAuthentication', 'Negotiate', 'NTLM')]
        [ValidateScript( {
                if (($IsMacOS -or $IsLinux) -and !($_ -in @( 'Basic', 'Anonymous'))) {
                    throw "Basic and Anonymous Aathentication are the only supported Auth types on Linux and Mac"
                }
                else {
                    $true
                }
            })]
        [String]
        $Auth = 'Anonymous',

        $Polaris = $Script:Polaris
    )

    if ( -not $Polaris) {
        Write-Verbose 'No Polaris found. Creating new.'
        CreateNewPolarisIfNeeded
        $Polaris = $Script:Polaris
    }

    if ( $UseJsonBodyParserMiddleware ) {
        Use-PolarisJsonBodyParserMiddleware -Polaris $Polaris
    }

    Write-Verbose "Starting polaris listening"
    Write-Verbose "   Port: $Port"
    Write-Verbose "   Https.IsPreset: $($Https.IsPresent)"
    Write-Verbose "   Auth: $Auth"
    Write-Verbose "   HostName: $HostName"
    $Polaris.Start( $Port, $Https.IsPresent, $Auth, $HostName)

    return $Polaris
}
