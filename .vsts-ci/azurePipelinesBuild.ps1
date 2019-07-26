$ErrorActionPreference = 'Stop'

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null
if ($IsWindows -or $PSVersionTable.PSVersion.Major -lt 6) {
    # Just in case, let's get the latest PowerShellGet.
    Get-Module PowerShellGet,PackageManagement | Remove-Module -Force -Verbose
    powershell -Command { Install-Module -Name PowerShellGet -MinimumVersion 1.6 -Force -Confirm:$false -Verbose }
    powershell -Command { Install-Module -Name PackageManagement -MinimumVersion 1.1.7.0 -Force -Confirm:$false -Verbose }
    Import-Module -Name PowerShellGet -MinimumVersion 1.6 -Force
    Import-Module -Name PackageManagement -MinimumVersion 1.1.7.0 -Force
}

# Needed for build and docs gen eventually...
Install-Module PlatyPS -RequiredVersion 0.9.0 -Scope CurrentUser

Push-Location $PSScriptRoot/..
./build.ps1 -Test -Package
