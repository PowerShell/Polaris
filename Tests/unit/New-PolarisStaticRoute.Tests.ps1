Describe "New-PolarisStaticRoute" {

    BeforeAll {

        #  Import module
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        #  Start with a clean slate
        Remove-PolarisRoute

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

        ####  Create static routes
        New-PolarisStaticRoute -RoutePath $RootPath -FolderPath $TestPath

        Start-Polaris -Port $Port
    }


    It "Should create static route for folder" {

        #  Confirm expected routes created
        $Routes = @()
        $Routes += Get-PolarisRoute -Path "$RootPath/:FilePath?" -Method Get
        $Routes.Count | Should Be 1

        #  Confirm no other routes created
        $AllRoutes = @()
        $AllRoutes += Get-PolarisRoute
        $AllRoutes.Count | Should Be 1
    }

    It "Should throw error if route for file exists" {

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create a route which will conflict with next command
        New-PolarisRoute -Path "$RootPath/:FilePath?" -Method GET -Scriptblock {'Existing script'}

        #  Create static routes
        { New-PolarisStaticRoute -RoutePath "$RootPath" -FolderPath $TestPath -ErrorAction Stop } |
            Should Throw
    }

    It "Should trim only the leading / from route path" {

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create a static route with many / in the path
        New-PolarisStaticRoute -RoutePath "/foo/foo/foo" -FolderPath $TestPath

        #  Verify generated scriptblock has the correct string
        $Routes = Get-PolarisRoute
        $Routes[0].Scriptblock | Should BeLike "*'foo/foo/foo'*"
        
    }

    It "Should overwrite matching route with Force switch" {

        #  Start with a clean slate
        Remove-PolarisRoute

        #  Create a route which will conflict with next command
        New-PolarisRoute -Path "$RootPath/:FilePath" -Method GET -Scriptblock {'Existing script'}

        #  Create static routes
        New-PolarisStaticRoute -RoutePath "$RootPath" -FolderPath $TestPath -Force

        #  Confirm expected routes created
        $Routes = @()
        $Routes += Get-PolarisRoute -Path "$RootPath/:FilePath" -Method Get
        $Routes.Count | Should Be 1

        #  Confirm conflicting route was overwritten
        $NewRoute = Get-PolarisRoute "$RootPath/:FilePath?" -Method GET
        $NewRoute.Scriptblock.toString().TrimStart().SubString( 0, 20 ) | Should be "`$RoutePath = 'BaseRo"
    }

    AfterAll {

        #  Clean up test routes
        Remove-PolarisRoute

        #  Stop Polaris
        Stop-Polaris -ServerContext (Get-Polaris)
    }
}
