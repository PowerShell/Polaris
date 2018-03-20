﻿Describe "New-PolarisStaticRoute" {

    BeforeAll {

        #  Import module
        Import-Module "$PSScriptRoot\..\Polaris.psd1"

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create test folders
        $GUID = [string][guid]::NewGuid()
        $TestPath   = ( New-Item -Path 'TestDrive:\' -Name $GUID  -ItemType Directory ).FullName
        $TestFolder = ( New-Item -Path $TestPath     -Name 'Sub1' -ItemType Directory ).FullName

        #  Create test files
        $File1 =  ( New-Item -Path $TestPath   -Name 'File1.txt' -ItemType File ).FullName
        $Null  =    New-Item -Path $TestPath   -Name 'File2.txt' -ItemType File
        $Null  =    New-Item -Path $TestFolder -Name 'File3.txt' -ItemType File
        $Null  =    New-Item -Path $TestFolder -Name 'File4.txt' -ItemType File

        #  Define expected routes
        $Paths = @(
            'BaseRoot/File1.txt'
            'BaseRoot/File2.txt'
            'BaseRoot/Sub1/File3.txt'
            'BaseRoot/Sub1/File4.txt' )

        #  Add content to a file
        $Port = Get-Random -Minimum 3000 -Maximum 4000
        $File1Uri = "http://localhost:$Port/BaseRoot/File1.txt"
        $File1Content = 'File1Content'
        $File1Content | Out-File -FilePath $File1 -Encoding ascii -NoNewline

        ####  Create static routes
        New-PolarisStaticRoute -RoutePath 'BaseRoot' -FolderPath $TestPath

        Start-Polaris -Port $Port
        }


    It "Should create static routes for all files" {

        #  Confirm expected routes created
        $Routes = Get-PolarisRoute -Path $Paths -Method Get
        $Routes.Count | Should Be $Paths.Count

        #  Confirm no other routes created
        $AllRoutes = Get-PolarisRoute
        $AllRoutes.Count | Should Be $Paths.Count
        }

    It "Should create routes that serve files" {

        #  Confirm file can be downloaded
        $Download = Invoke-WebRequest -Uri $File1Uri -TimeoutSec 10 -UseBasicParsing
        $Download.Content | Should be $File1Content
        }

    It "Should throw error if route for file exists" {

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create a route which will conflict with next command
        New-PolarisRoute -Path $Paths[0] -Method GET -ScriptBlock {'Existing script'}

        #  Create static routes
        { New-PolarisStaticRoute -RoutePath 'BaseRoot' -FolderPath $TestPath -ErrorAction Stop } |
            Should Throw
        }

    It "Should overwrite matching route with Force switch" {

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create a route which will conflict with next command
        New-PolarisRoute -Path $Paths[0] -Method GET -ScriptBlock {'Existing script'}

        #  Create static routes
        New-PolarisStaticRoute -RoutePath 'BaseRoot' -FolderPath $TestPath -Force

        #  Confirm expected routes created
        $Routes = Get-PolarisRoute -Path $Paths -Method Get
        $Routes.Count | Should Be 4

        #  Confirm conflicting route was overwritten
        $NewRoute = Get-PolarisRoute $Paths[0] -Method GET
        $NewRoute.ScriptBlock.TrimStart().SubString( 0, 20 ) | Should be '$bytes = Get-Content'
        }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisRoute

        #  Stop Polaris
        Stop-Polaris
        }
    }
