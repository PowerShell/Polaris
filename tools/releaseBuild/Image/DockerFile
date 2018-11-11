# escape=`
#0.3.6 (no powershell 6)
FROM microsoft/dotnet-framework:4.7.1
LABEL maintainer='PowerShell Team <powershellteam@hotmail.com>'
LABEL description="Build's Polaris"

SHELL ["C:\\windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-command"]

COPY dockerInstall.psm1 containerFiles/dockerInstall.psm1

RUN Import-Module PackageManagement; `
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force; `
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted | Out-Null; `
    Install-Module platyPS -Scope CurrentUser -Force; `
    Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck;

# Copy build script over
COPY buildPolaris.ps1 containerFiles/buildPolaris.ps1

# Uncomment to debug locally
# RUN Import-Module ./containerFiles/dockerInstall.psm1; `
#     Install-ChocolateyPackage -PackageName git -Executable git.exe; `
#     git clone https://github.com/PowerShell/Polaris;

ENTRYPOINT ["C:\\windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-command"]

