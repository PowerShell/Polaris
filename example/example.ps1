if(-not (Test-Path -Path ..\Polaris.psd1)) {
    Write-Error -Message "Cannot find Polaris.psd1"
    return
}

# Import Polaris
Import-Module -Name ..\Polaris.psd1

$Hey = "What what!"
# Hello World passing in the Path, Method & ScriptBlock
New-PolarisRoute -Path /helloworld -Method GET -ScriptBlock {
    $response.Send($Hey)
} -Force

# Query Parameters are supported
New-PolarisRoute -Path /hellome -Method GET -ScriptBlock {
    if ($request.Query['name']) {
        $response.Send('Hello ' + $request.Query['name'])
    } else {
        $response.Send('Hello World')
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

# Body Parameters are supported if you use the -UseJsonBodyParserMiddleware
New-PolarisPostRoute -Path /hello -ScriptBlock {
    if ($request.Body.Name) {
        $response.Send('Hello ' + $request.Body.Name);
    } else {
        $response.Send('Hello World');
    }
}

# Pass in script file
New-PolarisRoute -Path /example -Method GET -ScriptPath .\script.ps1

# Also support static serving of a directory
New-PolarisStaticRoute -FolderPath ./static -RoutePath /public -EnableDirectoryBrowser $True

# Start the server
$app = Start-Polaris -Port 8082 -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware -Verbose # all params are optional

while($app.Listener.IsListening){
    Wait-Event Polaris.AsyncHelper.ContextReceived
}

# Stop the server
#Stop-Polaris
