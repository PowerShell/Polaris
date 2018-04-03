function New-DirectoryBrowser {

    <#
    .SYNOPSIS
        Renders a directory browser in HTML
    .EXAMPLE
#>

    param (

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Directory Path')]
        [string]$Path,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Header Name')]
        [string]$HeaderName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subfolder Name')]
        [string]$SubfolderName,

        [string]$Root
    )

    @"
<html>
<head>
<title>$($HeaderName)</title>
</head>
<body>
<h1>$($HeaderName) - $($SubfolderName)</h1>
<hr>
"@
    @"
<a href="./../">[To Parent Directory]</a><br><br>
<table cellpadding="5">
"@
    $Files = (Get-ChildItem "$Path")
    foreach ($File in $Files) {
        $FileURL = $RoutePath + ($File.FullName -replace [regex]::Escape($Root), "" ) -replace "\\", "/"
        if (!$File.Length) { $FileLength = "[dir]" } else { $FileLength = $File.Length }
        @"
<tr>
<td align="right">$($File.LastWriteTime)</td>
<td align="right">$($FileLength)</td>
<td align="left"><a href="$($FileURL)">$($File.Name)</a></td>
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