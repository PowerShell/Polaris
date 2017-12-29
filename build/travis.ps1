Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module Pester
Invoke-Pester -ExcludeTag VersionChecks -EnableExit
