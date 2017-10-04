if(-not (Test-Path -Path "..\Polaris.psm1")) {
    Write-Error -Message "Cannot find Polaris.psm1"
    return;
}

# Import Polaris
Import-Module –Name ..\Polaris.psm1

# Hello World passing in the Path, Method & ScriptBlock
New-WebRoute -Path "/helloworld" -Method "GET" -ScriptBlock {
    param($request,$response);
    $response.Send('Hello World');
}

$sbWow = {
    param($request,$response);

    $json = @{
        wow = $true
    }

    # .Json helper function that sets content type
    $response.Json(($json | ConvertTo-Json));
}

# Supports helper functions for Get, Post, Put, Delete
New-PostRoute -Path "/wow" -ScriptBlock $sbWow

# Pass in script file
New-WebRoute -Path "/example" -Method "GET" -ScriptPath .\test.ps1

# Also support static serving of a directory
New-StaticRoute -FolderPath "./static" -RoutePath "/public"

$Port = Get-Random -Minimum 8000 -Maximum 8999

# Start the app
$app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional