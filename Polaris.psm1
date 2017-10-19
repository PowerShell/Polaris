Add-Type -Path "$PSScriptRoot/PolarisCore/bin/Debug/netstandard2.0/Polaris.dll"
$global:Polaris = $null;

##############################
#.SYNOPSIS
# Adds a new HTTP Route
#
#.DESCRIPTION
# This cmdlet defines an HTTP route that your server will listen for
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER Method
# The HTTP Verb/Method for this request
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-WebRoute -Path "/helloworld" -Method "GET" -ScriptBlock {
#    param($request,$response);
#    $response.Send('Hello World');
# }
#
# New-WebRoute -Path "/helloworld" -Method "GET" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-WebRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Mandatory=$True, Position=1)]
        [string]
        $Method,

        [Parameter(Position=2)]
        [scriptblock]
        $ScriptBlock,

        [Parameter()]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded;
    if ($ScriptPath -ne $null -and $ScriptPath -ne "") {
        if(-Not (Test-Path -Path $ScriptPath)) {
            ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "File does not exist at path $ScriptPath";
        }

        $ScriptBlock = [ScriptBlock]::Create((Get-Content -Path $ScriptPath -Raw));
    }
    $global:Polaris.AddRoute($Path, $Method, $ScriptBlock.ToString());
}

##############################
#.SYNOPSIS
# Defines routes to serve a folder at the "/" endpoint
#
#.DESCRIPTION
# Defines routes to serve a folder at the "/" endpoint. Perfect for static websites.
#
#.PARAMETER RoutePath
# (Optional) Root route that the folder path will be served to. Defaults to "/"
#
#.PARAMETER FolderPath
# Path to the folder you want to serve.
#
#.EXAMPLE
# New-StaticRoute -Path ./public
#
##############################
function New-StaticRoute {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $RoutePath = "/",

        [Parameter(Mandatory=$True, Position=1)]
        [string]
        $FolderPath)
    CreateNewPolarisIfNeeded;
    if(-Not (Test-Path -Path $FolderPath)) {
        ThrowError -ExceptionName FileNotFoundException -ExceptionMessage "Folder does not exist at path $FolderPath";
    }

    $allPaths = Get-ChildItem -Path $FolderPath -Recurse | ForEach-Object { $_.FullName };
    $resolvedPath = (Resolve-Path -Path $FolderPath).Path;


    $allPaths | ForEach-Object {
    $scriptTemplate = @"
param(`$request,`$response);
`$bytes = Get-Content "$_" -Encoding Byte -ReadCount 0
`$response.SetContentType(([PolarisCore.PolarisResponse]::GetContentType("$_")));
`$response.ByteResponse = `$bytes;
"@

        New-GetRoute -Path "$($RoutePath.TrimEnd("/"))$($_.Substring($resolvedPath.Length).Replace('\','/'))" `
            -ScriptBlock ([ScriptBlock]::Create($scriptTemplate));
    }
}

##############################
#.SYNOPSIS
# Starts the web server.
#
#.DESCRIPTION
# Starts the web server.
#
#.PARAMETER Port
# (Optional) The port you want the web server to run on. Defaults to 8080.
#
#.PARAMETER MinRunspaces
# (Optional) The minimum ammount of PowerShell runspaces you'd like to use. Defaults to 1.
#
#.PARAMETER MaxRunspaces
# (Optional) The maximum ammount of PowerShell runspaces you'd like to use. Defaults to 1.
#
#.EXAMPLE
# Start-Polaris
#
# Start-Polaris -Port 8081
#
##############################
function Start-Polaris {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [Int32]
        $Port = 8080,

        [Parameter(Position=1)]
        [Int32]
        $MinRunspaces = 1,

        [Parameter(Position=2)]
        [Int32]
        $MaxRunspaces = 1)
    if ($global:Polaris -eq $null) {
        ThrowError -ExceptionName NoRoutesDefinedException -ExceptionMessage 'You must have at least 1 route defined.'
    }
    #Invoke-Command -AsJob $global:Polaris.Start($Port, $MinRunspaces, $MaxRunspaces);
    #Start-Job -ScriptBlock { param($Polaris); $Polaris.Start(); } -ArgumentList $global:Polaris
    $global:Polaris.Start($Port, $MinRunspaces, $MaxRunspaces);
    return $global:Polaris;
}

##############################
#.SYNOPSIS
# Stops the web server.
#
#.DESCRIPTION
# Stops the web server.
#
#.PARAMETER ServerContext
# (Optional) The server that you wish to stop. Defaults to the global instance.
#
#.EXAMPLE
# Stop-Polaris
#
# Stop-Polaris -ServerContext $app
#
##############################
function Stop-Polaris {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [PolarisCore.Polaris]
        $ServerContext = $global:Polaris)
    $ServerContext.Stop();
}

##############################
# HELPERS
##############################

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "GET"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "GET"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-GetRoute -Path "/helloworld" -ScriptBlock {
#    param($request,$response);
#    $response.Send('Hello World');
# }
#
# New-GetRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Navigating to localhost:8080/helloworld would display the example.
#
##############################
function New-GetRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded;
    New-WebRoute -Path $Path -Method "GET" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath;
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "POST"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "POST"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PostRoute -Path "/helloworld" -ScriptBlock {
#    param($request,$response);
#    $response.Send('Hello World');
# }
#
# New-PostRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a POST request would display the example.
#
##############################
function New-PostRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded;
    New-WebRoute -Path $Path -Method "POST" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath;
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "PUT"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "PUT"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-PutRoute -Path "/helloworld" -ScriptBlock {
#    param($request,$response);
#    $response.Send('Hello World');
# }
#
# New-PutRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a PUT request would display the example.
#
##############################
function New-PutRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded;
    New-WebRoute -Path $Path -Method "PUT" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath;
}

##############################
#.SYNOPSIS
# Adds a new Route with HTTP Method "DELETE"
#
#.DESCRIPTION
# A shorthand version of doing New-WebRoute -Method "DELETE"
#
#.PARAMETER Path
# The HTTP Route/Path/endpoint that you call to trigger this script
#
#.PARAMETER ScriptBlock
# A script block that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.PARAMETER ScriptPath
# A path to a script that will be triggered when this HTTP Route/Path/endpoint has been called
#
#.EXAMPLE
# New-DeleteRoute -Path "/helloworld" -ScriptBlock {
#    param($request,$response);
#    $response.Send('Hello World');
# }
#
# New-DeleteRoute -Path "/helloworld" -ScriptPath ./example.ps1
#
#.NOTES
# Calling to localhost:8080/helloworld with a DELETE request would display the example.
#
##############################
function New-DeleteRoute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]
        $Path,

        [Parameter(Position=1, ParameterSetName = "ScriptBlock")]
        [scriptblock]
        $ScriptBlock,

        [Parameter(ParameterSetName = "ScriptPath")]
        [string]
        $ScriptPath)
    CreateNewPolarisIfNeeded;
    New-WebRoute -Path $Path -Method "DELETE" -ScriptBlock $ScriptBlock -ScriptPath $ScriptPath;
}

##############################
# INTERNAL
##############################
function CreateNewPolarisIfNeeded () {
    if ($global:Polaris -eq $null) {
        [Action[string]]$logger = { param($str) Write-Verbose "$str" }
        $global:Polaris = [PolarisCore.Polaris]::new($logger);
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function `
    New-WebRoute, `
    New-GetRoute, `
    New-PostRoute, `
    New-PutRoute, `
    New-DeleteRoute, `
    Start-Polaris, `
    New-StaticRoute, `
    Stop-Polaris