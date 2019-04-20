#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

<#
.SYNOPSIS
    Creates web routes to recursively serve folder contents
.DESCRIPTION
    Creates web routes to recursively serve folder contents. Perfect for static websites.
    Also if a default file (for example index.html) is detected, A route pointing to the
    value of the parameter "Routepath" will be created.
.PARAMETER RoutePath
    Root route that the folder path will be served to.
    Defaults to "/".
.PARAMETER FolderPath
    Full path and name of the folder to serve.
.PARAMETER EnableDirectoryBrowser
    Enables the directory browser when the user requests a folder
.PARAMETER ServeDefaultFile
    Polaris will look for a default file matching one of the file names specified in the
    StandardHTMLFiles parameter and, if found, will serve that file when no specific file is requested
.PARAMETER StandardHTMLFiles
    List of file names that Polaris will look for when ServeDefaultFile is $True
.PARAMETER Force
    Use -Force to overwrite existing web route(s) for the same paths.
.PARAMETER Polaris
    A Polaris object
    Defaults to the script scoped Polaris
.EXAMPLE
    New-PolarisStaticRoute -RoutePath 'public' -Path D:\FolderShares\public
    Creates web routes for GET method for each file recursively within D:\FolderShares\public
    at relative path /public, for example, http://localhost:8080/public/File1.html
.EXAMPLE
    Get-PolarisRoute -Path 'public/*' -Method GET | Remove-PolarisRoute
    New-PolarisStaticRoute -RoutePath 'public' -Path D:\FolderShares\public
    Updates website web routes. (Deletes all existing web routes and creates new web routes
    for all existing folder content.)
.NOTES
    Folders are not browsable. New files are not added dynamically.
#>
function New-PolarisStaticRoute {
    [CmdletBinding()]
    param(
        [string]
        $RoutePath = "/",

        [string]
        $FolderPath = "./",

        [bool]
        $EnableDirectoryBrowser = $True,

        [switch]
        $Force,

        [string[]]
        $StandardHTMLFiles = @("index.html", "index.htm", "default.html", "default.htm"),

        [bool]
        $ServeDefaultFile = $True,

        $Polaris = $Script:Polaris
    )

    $ErrorAction = $PSBoundParameters["ErrorAction"]
    If ( -not $ErrorAction ) {
        $ErrorAction = $ErrorActionPreference
    }

    CreateNewPolarisIfNeeded
    if ( -not $Polaris) {
        $Polaris = $Script:Polaris
    }

    if ( -not ( Test-Path -Path $FolderPath ) ) {
        Write-Error -Exception FileNotFoundException -Message "Folder does not exist at path $FolderPath"
    }

    $NewDrive = (New-PSDrive -Name "PolarisStaticFileServer$([guid]::NewGuid().guid)" `
            -PSProvider FileSystem `
            -Root $FolderPath `
            -Scope Global).Name

    $Scriptblock = {
        $Content = ""

        $LocalPath = $Request.Parameters.FilePath
        if (-not $LocalPath -and $ServeDefaultFile) {
            foreach ($FileName in $StandardHTMLFiles) {
                $FilePath = Join-Path "$($NewDrive):" -ChildPath "$FileName"
                if (Test-Path -Path $FilePath) {
                    $LocalPath = $FileName
                    break
                }
            }
        }
        Write-Debug "Parsed local path: $LocalPath"
        try {

            $RequestedItem = Get-Item -LiteralPath "$NewDrive`:$LocalPath" -Force -ErrorAction Stop

            Write-Debug "Requested Item: $RequestedItem"

            if ($RequestedItem.PSIsContainer) {

                if ($EnableDirectoryBrowser) {
                    $Content = New-DirectoryBrowser -RequestedItem $RequestedItem `
                        -HeaderName "Polaris Static File Server" `
                        -DirectoryBrowserPath $LocalPath `

                    $Response.ContentType = "text/html"
                    $Response.Send($Content)
                }
                else {
                    throw [System.Management.Automation.ItemNotFoundException]'file not found'
                }
            }
            else {
                $Response.SetStream(
                    [System.IO.File]::OpenRead($RequestedItem.FullName)
                )
                $Response.ContentType = [PolarisResponse]::GetContentType($RequestedItem.FullName)
            }
        }
        catch [System.UnauthorizedAccessException] {
            $Response.StatusCode = 401
            $Response.ContentType = "text/html"
            $Content = "<h1>401 - Unauthorized</h1>"
            $Response.Send($Content)
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            $Response.StatusCode = 404
            $Response.ContentType = "text/html"
            $Content = "<h1>404 - Page not found $LocalPath</h1>"
            $Response.Send($Content)
        }
        catch {
            Throw $_
        }
    }

    $Parameters = "`$RoutePath = '$($RoutePath.TrimStart("/"))'`r`n" +
    "`$NewDrive = '$NewDrive'`r`n"

    if ($EnableDirectoryBrowser) {
        $Parameters += "`$EnableDirectoryBrowser = `$$EnableDirectoryBrowser`r`n"
    }
    if ($ServeDefaultFile) {
        $Parameters += "`$ServeDefaultFile = `$$ServeDefaultFile`r`n"
        $Parameters += "`$StandardHTMLFiles = @('$( $StandardHTMLFiles -join "','" )')`r`n"
    }



    # Inserting variables into scriptblock as hardcoded
    $Scriptblock = [scriptblock]::Create(
        $Parameters +
        $Scriptblock.ToString())


    $PolarisPath = "$RoutePath/:FilePath?" -replace "//", "/"
    New-PolarisRoute -Path $PolarisPath -Method GET -Scriptblock $Scriptblock -Force:$Force -ErrorAction:$ErrorAction
}
