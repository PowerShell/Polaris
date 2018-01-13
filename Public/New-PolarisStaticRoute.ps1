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
        
        [switch]
        $Force )
    
    $ErrorAction = $PSBoundParameters["ErrorAction"]
    If ( -not $ErrorAction ) {
        $ErrorAction = $ErrorActionPreference
    }
    
    CreateNewPolarisIfNeeded
    
    if ( -not ( Test-Path -Path $FolderPath ) ) {
        ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "Folder does not exist at path $FolderPath"
    }

    $allPaths = Get-ChildItem -Path $FolderPath -Recurse -File | ForEach-Object { $_.FullName }
    $resolvedPath = ( Resolve-Path -Path $FolderPath ).Path

    $RoutePath = $RoutePath.TrimEnd( '/' )

    ForEach ( $Path in $AllPaths ) {
        $StaticPath = "$RoutePath$( $Path.Substring( $ResolvedPath.Length ).Replace( '\' , '/' ) )"
        
        If ( $PSVersionTable.PSEdition -eq "Core" ) {
            $ByteParam = '-AsByteStream'
        }
        Else {
            $ByteParam = '-Encoding Byte'
        }

        $ScriptBlock = [ScriptBlock]::Create( @"
            `$bytes = Get-Content -LiteralPath "$Path" $ByteParam -ReadCount 0
            `$response.SetContentType( ( [PolarisCore.PolarisResponse]::GetContentType( "$Path" ) ) )
            `$response.ByteResponse = `$bytes
"@ )

        New-PolarisRoute -Path $StaticPath -Method GET -ScriptBlock $ScriptBlock -Force:$Force -ErrorAction:$ErrorAction
    }
}
