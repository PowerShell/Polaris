Install-Module Pester
$res = Invoke-Pester -Path ..\test -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru;
(New-Object System.Net.WebClient).UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path .\TestsResults.xml));
if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed."}