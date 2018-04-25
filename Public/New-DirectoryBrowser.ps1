function New-DirectoryBrowser {

    <#
    .SYNOPSIS
        Renders a directory browser in HTML
    .DESCRIPTION
        Creates HTML that can be used as a directory browser
    .PARAMETER RequestedItem
        The directory you would like to generate HTML for
    .PARAMETER HeaderName
        The name you would like displayed at the top of the directory browser
    .PARAMETER DirectoryBrowserPath
        The current path in the directory browser relative to the root of the directory
        browser (not the root of the site).
#>

    param (

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Directory Path')]
        [System.IO.DirectoryInfo]$RequestedItem,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Header Name')]
        [string]$HeaderName = "Polaris Directory Browser",

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory Browser Path')]
        [string]$DirectoryBrowserPath
    )

    Write-Debug "DirectoryBrowserPath: $DirectoryBrowserPath"

    @"
<html>
<head>
<title>$HeaderName</title>
</head>
<body>
<h1>$HeaderName - $DirectoryBrowserPath</h1>
<hr>
$(if ($RequestedItem.FullName.TrimEnd([System.IO.Path]::DirectorySeparatorChar) -ne $RequestedItem.PSDrive.Root) { '<a href="./../">[To Parent Directory]</a><br><br>'})
<table cellpadding="5">
"@
    $Files = ($RequestedItem | Get-ChildItem)
    foreach ($File in $Files) {
        $FileURL = "./" + ($File.PSChildName) -replace "\\", "/"
        if ($File.PSIsContainer) { $FileUrl += "/"; $FileLength = "[dir]" } else { $FileLength = $File.Length }
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