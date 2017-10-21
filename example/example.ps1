if(-not (Test-Path -Path "..\Polaris.psm1")) {
    Write-Error -Message "Cannot find Polaris.psm1"
    return;
}

# Import Polaris
Import-Module –Name ..\Polaris.psm1

# Hello World passing in the Path, Method & ScriptBlock
New-WebRoute -Path "/helloworld" -Method "GET" -ScriptBlock {
    $response.Send('Hello World');
}

# Query Parameters are supported
New-WebRoute -Path "/hellome" -Method "GET" -ScriptBlock {
    if ($request.QueryParameters['name']) {
        $response.Send('Hello ' + $request.QueryParameters['name']);
    } else {
        $response.Send('Hello World');
    }
}

$sbWow = {
    $json = @{
        wow = $true
    }

    # .Json helper function that sets content type
    $response.Json(($json | ConvertTo-Json));
}

# Supports helper functions for Get, Post, Put, Delete
New-PostRoute -Path "/wow" -ScriptBlock $sbWow

# Body Parameters are supported if you use the -UseJsonBodyParserMiddleware
New-PostRoute -Path "/hello" -ScriptBlock {
    if ($request.Body.Name) {
        $response.Send('Hello ' + $request.Body.Name);
    } else {
        $response.Send('Hello World');
    }
}

# Pass in script file
New-WebRoute -Path "/example" -Method "GET" -ScriptPath .\script.ps1

# Also support static serving of a directory
New-StaticRoute -FolderPath "./static" -RoutePath "/public"

# Start the server
$app = Start-Polaris -Port 8082 -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware -Verbose # all params are optional

# Stop the server
#Stop-Polaris