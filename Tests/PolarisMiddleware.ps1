Import-Module $PSScriptRoot\..\Polaris.psd1

New-PolarisRoute -Path /helloworld -Method GET -ScriptBlock {
    $Response.Send('Hello World')
}

$Port = Get-Random -Minimum 7000 -Maximum 7999

$app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware # all params are optional
