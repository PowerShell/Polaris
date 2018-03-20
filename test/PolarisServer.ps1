# Import Polaris
Import-Module -Name "$PSScriptRoot\..\Polaris.psd1"

# Support Headers
New-PolarisRoute -Path /header -Method "GET" -ScriptBlock {
    $response.SetHeader('Location','http://www.contoso.com/');
    $response.Send("Header test");
} -Force

# Hello World passing in the Path, Method & ScriptBlock
New-PolarisRoute -Path /helloworld -Method GET -ScriptBlock {
    Write-Host "This is Write-Host"
    Write-Information "This is Write-Information" -Tags Tag0
    $Response.Send('Hello World')
} -Force

# Hello World passing in the Path, Method & ScriptBlock
New-PolarisRoute -Path /hellome -Method GET -ScriptBlock {
    if ($Request.Query['name']) {
        $Response.Send('Hello ' + $Request.Query['name'])
    } else {
        $Response.Send('Hello World')
    }
} -Force

$sbWow = {
    $json = @{
        wow = $true
    }

    # .Json helper function that sets content type
    $response.Json(($json | ConvertTo-Json))
}

# Supports helper functions for Get, Post, Put, Delete
New-PolarisPostRoute -Path /wow -ScriptBlock $sbWow -Force

# Pass in script file
New-PolarisRoute -Path /example -Method GET -ScriptPath "$PSScriptRoot\test.ps1" -Force

# Also support static serving of a directory
New-PolarisStaticRoute -FolderPath "$PSScriptRoot/static" -RoutePath /public -Force

New-PolarisPostRoute -Path /error -ScriptBlock {
    $params = @{}
    Write-Host "asdf"
    $request.body.psobject.properties | ForEach-Object { $params[$_.Name] = $_.Value }
    $response.Send("this should not show up in response")
} -Force

# Support Headers
New-PolarisRoute -Path /header -Method "GET" -ScriptBlock {
    $response.SetHeader('Location','http://www.contoso.com/')
    $response.Send("Header test")
} -Force

$Port = Get-Random -Minimum 8000 -Maximum 8999

# Start the app
$app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional
