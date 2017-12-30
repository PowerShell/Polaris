Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module Pester
pushd test
Invoke-Pester -ExcludeTag VersionChecks -EnableExit
popd
