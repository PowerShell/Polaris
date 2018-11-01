---
name: Bug report
about: Create a report to help us improve
---

# Polaris Bug Report

## Description of the bug

---

A clear and concise description of what the bug is.

## Steps to reproduce

Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

You can also just attach a copy of a PowerShell transcript text file using [Start-Transcript](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.host/start-transcript?view=powershell-6) or share a script that can be used to re-create the issue.

## Expected behavior

A clear and concise description of what you expected to happen.

## Verbose output of the script

Set `$VerbosePreference = 'Continue'` and run your script. This will give us additional details from Polaris.

## Additional context

Add any other context about the problem here.

## Version Information

---

Run the following script to send some useful version information in HTML to your clipboard and paste the contents here:

```ps
$Version = [pscustomobject]$PSVersionTable
$Version.PSCompatibleVersions = ($Version.PSCompatibleVersions | foreach { "$($_.Major).$($_.Minor).$($_.Build).$($_.Revision)" }) -join ",  "
(Get-Module Polaris | select Name,Version | ConvertTo-Html -Fragment | Out-String) + ($Version | ConvertTo-Html -Fragment | Out-String) | clip
```
