. "$PSScriptRoot\PolarisMiddleware.ps1"

$JsonBodyParserMiddlerware = {
    if ($Request.BodyString -ne $null) {
        $Request.Body = $Request.BodyString | ConvertFrom-Json
    }
}

$defaultMiddleware = {
    if ($Request.BodyString -ne $null) {
        $Request.Body = '{"Name":"Manipulated"}' | ConvertFrom-Json
    }
}

Describe "Test middleware creation/usage" {
    Context "Test -UseJsonBodyParserMiddleware flag" {
        It "Adds the middleware to the list of middlewares" {
            $filtered = $app.RouteMiddleware | ? { $_.Name -eq "JsonBodyParser" }
            $filtered.Count | Should Be 1
        }
        It "Can use the body parameters in route scripts" {
            New-PolarisPostRoute -Path "/hello" -ScriptBlock {
                if ($request.Body.Name) {
                    $response.Send('Hello ' + $request.Body.Name);
                } else {
                    $response.Send('Hello World');
                }
            }

            $body = @{ Name = 'Atlas' } | ConvertTo-Json
            (Invoke-RestMethod -Uri "http://localhost:$Port/hello" -Method POST -Body $body) | Should Be 'Hello Atlas';
        }
    }
    Context "Test adding a new middleware" {
        It "Adds the middleware to the list of middlewares" {
            (Get-PolarisRouteMiddleware -Name TestMiddleware).Name | Should Be "TestMiddleware"
        }
        It "Manipulates the Request before the Route script gets it" {
            $body = @{ Name = 'Atlas' } | ConvertTo-Json
            (Invoke-RestMethod -Uri "http://localhost:$Port/hello" -Method POST -Body $body) | Should Be 'Hello Manipulated';
        }
        BeforeEach {
            $app.RouteMiddleware.Count | Should Be 1;
            New-PolarisRouteMiddleware -Name TestMiddleware -ScriptBlock $defaultMiddleware
        }
        AfterEach {
            Remove-PolarisRouteMiddleware -Name TestMiddleware
            $app.RouteMiddleware.Count | Should Be 1;
        }
    }
    AfterAll {
        Stop-Polaris
    }
}