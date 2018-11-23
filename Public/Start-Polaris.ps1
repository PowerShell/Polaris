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
    Polaris listens on Https. This only works on Windows.
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

        [switch]
        $Https = $False,

        [ValidateSet('Anonymous', 'Basic', 'Digest', 'IntegratedWindowsAuthentication', 'Negotiate', 'NTLM')]
        [ValidateScript( {
                if ( $IsWindows -ne $False -and ($_ -ne 'Basic' -or $_ -ne 'Anonymous')) {
                    throw "Basic and Annoynymous Aathentication are the only supported Auth types on Linux and Mac"
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
        CreateNewPolarisIfNeeded
        $Polaris = $Script:Polaris
    }

    if ( $UseJsonBodyParserMiddleware ) {
        Use-PolarisJsonBodyParserMiddleware -Polaris $Polaris
    }

    $Polaris.Start( $Port, $Https.IsPresent, $Auth)

    return $Polaris
}
