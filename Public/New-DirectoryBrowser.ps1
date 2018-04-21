function New-DirectoryBrowser {

    <#
    .SYNOPSIS
        Renders a directory browser in HTML
    .DESCRIPTION
        Creates HTML that can be used as a directory browser
    .PARAMETER FileSystemPath
        The file path of the directory you would like to generate HTML
    .PARAMETER HeaderName
        The name you would like displayed at the top of the directory browser
    .PARAMETER DirectoryBrowserPath
        The current path in the directory browser relative to the root of the directory
        browser (not the root of the site).
    .PARAMETER FileSystemRootFolder
        The root of the directory browser on the file system
    .PARAMETER WebServerPath
        The current path of the directory browser relative to the root of Polaris
#>

    param (

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Directory Path')]
        [string]$FileSystemPath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Header Name')]
        [string]$HeaderName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory Browser Path')]
        [string]$DirectoryBrowserPath,

        [string]$FileSystemRootFolder,

        [string]$WebServerPath
    )

    @"
<html>
<head>
<title>$HeaderName</title>
</head>
<body>
<h1>$HeaderName - $DirectoryBrowserPath</h1>
<hr>
"@
    @"
<a href="./../">[To Parent Directory]</a><br><br>
<table cellpadding="5">
"@
    $Files = (Get-ChildItem "$FileSystemPath")
    foreach ($File in $Files) {
        $FileURL = "/" + $WebServerPath + ($File.FullName -replace [regex]::Escape($FileSystemRootFolder), "" ) -replace "\\", "/"
        if ($File.PSIsContainer) { $FileLength = "[dir]" } else { $FileLength = $File.Length }
        @"
<tr>
<td align="right">$($File.LastWriteTime)</td>
<td align="right">$FileLength</td>
<td align="left"><a href="$FileURL">$($File.Name)</a></td>
</tr>
"@
    }
    @"
</table>
<hr>
</body>
</html>
"@
}