<#
.SYNOPSIS
    Creates web routes to recursively serve folder contents
.DESCRIPTION
    Creates web routes to recursively serve folder contents. Perfect for static websites.
.PARAMETER RoutePath
    Root route that the folder path will be served to.
    Defaults to "/".
.PARAMETER FolderPath
    Full path and name of the folder to serve.
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

        [Parameter( Mandatory = $True )]
        [string]
        $FolderPath,

        [bool]
        $EnableDirectoryBrowser = $False,
        
        [switch]
        $Force,

        
        $Polaris = $script:Polaris
    )
    
    $ErrorAction = $PSBoundParameters["ErrorAction"]
    If ( -not $ErrorAction ) {
        $ErrorAction = $ErrorActionPreference
    }
    
    CreateNewPolarisIfNeeded
    if ( -not $Polaris) {
        $Polaris = $script:Polaris
    }
    
    if ( -not ( Test-Path -Path $FolderPath ) ) {
        Write-Error -Exception FileNotFoundException -Message "Folder does not exist at path $FolderPath"
    }

    $NewDrive = (New-PSDrive -Name "PolarisStaticFileServer$([guid]::NewGuid().guid)" `
            -PSProvider FileSystem `
            -Root $FolderPath `
            -Scope Global).Name
    
    $ScriptBlock = {
        $Content = ""

        $localPath = ($request.Url.LocalPath -replace $RoutePath, "")
        Write-Debug "Parsed local path: $localPath" 
        try {
            $RequestedItem = Get-Item -LiteralPath "$NewDrive`:$localPath" -Force -ErrorAction Stop
            Write-Debug "Requested Item: $RequestedItem"
             
            $FullPath = $RequestedItem.FullName
            if ($RequestedItem.Attributes -match "Directory") {

                if ($EnableDirectoryBrowser) {
                    $Content = New-DirectoryBrowser -Path $FullPath `
                        -HeaderName "Polaris Static File Server" `
                        -SubfolderName $localPath `
                        -Root "$((get-psdrive $NewDrive).Root)" `
                        -RoutePath $RoutePath

                    $response.ContentType = "text/html"
                    $Response.Send($Content)
                }
                else {
                    throw [System.Management.Automation.ItemNotFoundException]'file not found'
                }
            }
            else {
                $Content = [System.IO.File]::ReadAllBytes($FullPath)
                $response.ContentType = [PolarisResponse]::GetContentType($FullPath)
                $Response.SendBytes($Content)
            }
        }
        catch [System.UnauthorizedAccessException] {
            $response.StatusCode = 401
            $response.ContentType = "text/html"
            $Content = "<h1>401 - Unauthorized</h1>"
            $response.Send($Content)
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            $response.StatusCode = 404
            $response.ContentType = "text/html"
            $Content = "<h1>404 - Page not found $localPath</h1>"
            $response.Send($Content);
        }
        catch {
            Throw $_
        }
    }

    # Inserting variables into scriptblock as hardcoded
    $ScriptBlock = [scriptblock]::Create(
        "`$RoutePath = '$($RoutePath.TrimStart("/"))'`r`n" +
        "`$EnableDirectoryBrowser = `$$EnableDirectoryBrowser`r`n" +
        "`$NewDrive = '$NewDrive'`r`n" +
        $ScriptBlock.ToString())

    New-PolarisRoute -Path $RoutePath -Method GET -ScriptBlock $ScriptBlock -Force:$Force -ErrorAction:$ErrorAction
}
