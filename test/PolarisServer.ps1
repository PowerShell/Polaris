
if(-not (Test-Path -Path ..\Polaris.psm1)) {
    Write-Error -Message "Cannot find Polaris.psm1"
    return
}

# Import Polaris
Import-Module -Name ..\Polaris.psm1

# Hello World passing in the Path, Method & ScriptBlock
New-PolarisRoute -Path /helloworld -Method GET -ScriptBlock {
    Write-Host "This is Write-Host"
    Write-Information "This is Write-Information" -Tags Tag0
    $Response.Send('Hello World')
}

# Hello World passing in the Path, Method & ScriptBlock
New-PolarisRoute -Path /hellome -Method GET -ScriptBlock {
    if ($Request.Query['name']) {
        $Response.Send('Hello ' + $Request.Query['name'])
    } else {
        $Response.Send('Hello World')
    }
}

$sbWow = {
    $json = @{
        wow = $true
    }

    # .Json helper function that sets content type
    $response.Json(($json | ConvertTo-Json))
}

# Supports helper functions for Get, Post, Put, Delete
New-PolarisPostRoute -Path /wow -ScriptBlock $sbWow

# Pass in script file
New-PolarisRoute -Path /example -Method GET -ScriptPath .\test.ps1

# Also support static serving of a directory
New-PolarisStaticRoute -FolderPath ./static -RoutePath /public

New-PolarisPostRoute -Path /error -ScriptBlock {
    $params = @{}
    Write-Host "asdf"
    $request.body.psobject.properties | ForEach-Object { $params[$_.Name] = $_.Value }
    $response.Send("this should not show up in response")
}

# Support Headers
New-PolarisRoute -Path /header -Method "GET" -ScriptBlock {
    $response.SetHeader('Location','http://www.contoso.com/');
    $response.Send("Header test");
}

$Port = Get-Random -Minimum 8000 -Maximum 8999

# Start the app
$app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional
