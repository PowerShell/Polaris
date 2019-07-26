$ErrorActionPreference = 'Stop'

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null

# Needed for build and docs gen eventually...
Install-Module PlatyPS -Scope CurrentUser -Force
Install-Module Pester -Scope CurrentUser -Force

Push-Location (Join-Path $PSScriptRoot '..')
./build.ps1 -Test -Package
Pop-Location
