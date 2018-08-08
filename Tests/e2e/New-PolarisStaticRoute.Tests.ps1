Describe "New-PolarisStaticRoute (E2E)" {

    BeforeAll {

        #  Create test folders
        $GUID = [string][guid]::NewGuid()
        $TestPath = ( New-Item -Path 'TestDrive:\' -Name $GUID  -ItemType Directory ).FullName
        $TestFolder = ( New-Item -Path $TestPath     -Name 'Sub1' -ItemType Directory ).FullName
        $RootPath = "BaseRoot"

        #  Create test files
        $File1 = ( New-Item -Path $TestPath   -Name 'File1.txt' -ItemType File ).FullName
        $Null = New-Item -Path $TestPath   -Name 'File2.txt' -ItemType File
        $Null = New-Item -Path $TestFolder -Name 'File3.txt' -ItemType File
        $Null = New-Item -Path $TestFolder -Name 'File4.txt' -ItemType File

        #  Define expected routes
        $Paths = @(
            "$RootPath/File1.txt"
            "$RootPath/File2.txt"
            "$RootPath/Sub1/File3.txt"
            "$RootPath/Sub1/File4.txt" )

        #  Add content to a file
        $Port = Get-Random -Minimum 3000 -Maximum 4000
        $File1Uri = "http://localhost:$Port/$RootPath/File1.txt"
        $File1Content = 'File1Content'
        $File1Content | Out-File -FilePath $File1 -Encoding ascii -NoNewline

        

        Start-Job -Scriptblock {

            #  Import module
            Import-Module $using:PSScriptRoot\..\..\Polaris.psd1

            #  Start with a clean slate
            Remove-PolarisRoute

            ####  Create static routes
            New-PolarisStaticRoute -RoutePath $using:RootPath -FolderPath $using:TestPath
            Write-Output "RootPath: $using:RootPath  --- FolderPath: $using:TestPath"

            ####  Create a static route at the root
            New-PolarisStaticRoute -RoutePath "/" -FolderPath $using:TestPath -EnableDirectoryBrowser $true

            $Polaris = Start-Polaris -Port $using:Port

            # Keeping the job running while the tests are running
            while ($Polaris.Listener.IsListening) {
                Wait-Event callbackeventbridge.callbackcomplete
            }
        }

        # Giving server job time to start up
        Start-Sleep -seconds 5
    }

    It "Should create routes that serve files" {

        #  Confirm file can be downloaded
        $Download = Invoke-WebRequest -Uri $File1Uri -UseBasicParsing
        $Download.Content | Should be $File1Content
    }

    It "Should create routes that serve files when / is used as the base" {

        #  Confirm file can be downloaded
        $Download = Invoke-WebRequest -Uri "http://localhost:$Port/File1.txt" -UseBasicParsing
        $Download.Content | Should be $File1Content
    }

    It "Should serve a directory browser when enabled" {

        #  Confirm file can be downloaded
        $Download = Invoke-WebRequest -Uri "http://localhost:$Port/" -UseBasicParsing
        $Download.Content | Should BeLike "*Polaris Static File Server*"
    }

    AfterAll {

        #  Clean up test routes
        Get-Job | Stop-Job | Remove-Job
    }
}
