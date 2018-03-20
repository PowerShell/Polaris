#Requires -Modules @{ModuleName="InvokeBuild";ModuleVersion="3.7.1"}

$script:IsCIBuild = $env:APPVEYOR -ne $null
$script:IsUnix = $PSVersionTable.PSEdition -and $PSVersionTable.PSEdition -eq "Core" -and !$IsWindows

if ($PSVersionTable.PSEdition -ne "Core") {
    Add-Type -Assembly System.IO.Compression.FileSystem
}

task SetupDotNet {

    $requiredSdkVersion = "2.0.0"

    $dotnetPath = "$PSScriptRoot/.dotnet"
    $dotnetExePath = if ($script:IsUnix) { "$dotnetPath/dotnet" } else { "$dotnetPath/dotnet.exe" }
    $originalDotNetExePath = $dotnetExePath

    if (!(Test-Path $dotnetExePath)) {
        $installedDotnet = Get-Command dotnet -ErrorAction Ignore
        if ($installedDotnet) {
            $dotnetExePath = $installedDotnet.Source
        }
        else {
            $dotnetExePath = $null
        }
    }

    # Make sure the dotnet we found is the right version
    if ($dotnetExePath -and (& $dotnetExePath --version) -eq $requiredSdkVersion) {
        $script:dotnetExe = $dotnetExePath
    }
    else {
        # Clear the path so that we invoke installation
        $script:dotnetExe = $null
    }

    if ($script:dotnetExe -eq $null) {

        Write-Host "`n### Installing .NET CLI $requiredSdkVersion...`n" -ForegroundColor Green

        # The install script is platform-specific
        $installScriptExt = if ($script:IsUnix) { "sh" } else { "ps1" }

        # Download the official installation script and run it
        $installScriptPath = "$([System.IO.Path]::GetTempPath())dotnet-install.$installScriptExt"
        Invoke-WebRequest "https://raw.githubusercontent.com/dotnet/cli/master/scripts/obtain/dotnet-install.$installScriptExt" -OutFile $installScriptPath -UseBasicParsing
        $env:DOTNET_INSTALL_DIR = "$PSScriptRoot/.dotnet"

        if (!$script:IsUnix) {
            & $installScriptPath -Version $requiredSdkVersion -InstallDir "$env:DOTNET_INSTALL_DIR"
        }
        else {
            & /bin/bash $installScriptPath -Version $requiredSdkVersion -InstallDir "$env:DOTNET_INSTALL_DIR"
            $env:PATH = $dotnetExeDir + [System.IO.Path]::PathSeparator + $env:PATH
        }

        Write-Host "`n### Installation complete." -ForegroundColor Green
        $script:dotnetExe = $originalDotnetExePath
    }

    # This variable is used internally by 'dotnet' to know where it's installed
    $script:dotnetExe = Resolve-Path $script:dotnetExe
    if (!$env:DOTNET_INSTALL_DIR)
    {
        $dotnetExeDir = [System.IO.Path]::GetDirectoryName($script:dotnetExe)
        $env:PATH = $dotnetExeDir + [System.IO.Path]::PathSeparator + $env:PATH
        $env:DOTNET_INSTALL_DIR = $dotnetExeDir
    }

    Write-Host "`n### Using dotnet v$requiredSDKVersion at path $script:dotnetExe`n" -ForegroundColor Green
}

function NeedsRestore($rootPath) {
    # This checks to see if the number of folders under a given
    # path (like "src" or "test") is greater than the number of
    # obj\project.assets.json files found under that path, implying
    # that those folders have not yet been restored.
    $projectAssets = (Get-ChildItem "$rootPath\*\obj\project.assets.json")
    return ($projectAssets -eq $null) -or ((Get-ChildItem $rootPath).Length -gt $projectAssets.Length)
}

task Restore -If { "Restore" -in $BuildTask -or (NeedsRestore(".\PolarisCore")) } SetupDotNet, {
    exec { & $script:dotnetExe restore .\PolarisCore\Polaris.csproj }
}

task Clean Restore, {
    exec { & $script:dotnetExe clean .\PolarisCore\Polaris.csproj }
}

task Build Restore, {
    if (!$script:IsUnix) {
        exec { & $script:dotnetExe build .\PolarisCore\Polaris.csproj -f net451 }
        Write-Host "" # Newline
    }

    exec { & $script:dotnetExe build .\PolarisCore\Polaris.csproj -f netstandard2.0 }
}

task Test Build, {
    Push-Location "$PSScriptRoot\test"
    $res = Invoke-Pester -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru;
    if ($env:APPVEYOR) {
        (New-Object System.Net.WebClient).UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml));
    }
    if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}
    Pop-Location
}

# The default task is to run the entire CI build
task . Clean, Build, Test
