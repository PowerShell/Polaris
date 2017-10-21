if(-not (Test-Path -Path ..\Polaris.psm1)) {
    Write-Error -Message "Cannot find Polaris.psm1"
    return;
}

# Import Polaris
Import-Module -Name ..\Polaris.psm1

# Hello World passing in the Path, Method & ScriptBlock
New-WebRoute -Path /helloworld -Method GET -ScriptBlock {
    $Response.Send('Hello World');
}

# Hello World passing in the Path, Method & ScriptBlock
New-WebRoute -Path /hellome -Method GET -ScriptBlock {
    if ($Request.Query['name']) {
        $Response.Send('Hello ' + $Request.Query['name']);
    } else {
        $Response.Send('Hello World');
    }
}

$sbWow = {
    $json = @{
        wow = $true
    }

    # .Json helper function that sets content type
    $Response.Json(($json | ConvertTo-Json));
}

# Supports helper functions for Get, Post, Put, Delete
New-PostRoute -Path /wow -ScriptBlock $sbWow

# Pass in script file
New-WebRoute -Path /example -Method GET -ScriptPath .\test.ps1

# Also support static serving of a directory
New-StaticRoute -FolderPath ./static -RoutePath /public

$Port = Get-Random -Minimum 8000 -Maximum 8999

# Start the app
$app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 # all params are optional