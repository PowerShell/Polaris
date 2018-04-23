Describe "Test middleware creation/usage" {

    BeforeAll {
        Import-Module $PSScriptRoot\..\..\Polaris.psd1

        New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
            $Response.Send('Hello World')
        }

        $Port = Get-Random -Minimum 7000 -Maximum 7999

        $app = Start-Polaris -Port $Port -MinRunspaces 1 -MaxRunspaces 5 -UseJsonBodyParserMiddleware # all params are optional


        $JsonBodyParserMiddleware = {
            if ($Request.BodyString -ne $null) {
                $Request.Body = $Request.BodyString | ConvertFrom-Json
            }
        }

        $defaultMiddleware = {
            if ($Request.BodyString -ne $null) {
                $Request.Body = '{"Name":"Manipulated"}' | ConvertFrom-Json
            }
        }
    }

    Context "Test -UseJsonBodyParserMiddleware flag" {
        It "Adds the middleware to the list of middlewares" {
            $filtered = $app.RouteMiddleware | ? { $_.Name -eq "JsonBodyParser" }
            $filtered.Count | Should Be 1
        }
    }
    Context "Test adding a new middleware" {
        It "Adds the middleware to the list of middlewares" {
            (Get-PolarisRouteMiddleware -Name TestMiddleware).Name | Should Be "TestMiddleware"
        }
        BeforeEach {
            $app.RouteMiddleware.Count | Should Be 1
            New-PolarisRouteMiddleware -Name TestMiddleware -Scriptblock $defaultMiddleware
        }
        AfterEach {
            Remove-PolarisRouteMiddleware -Name TestMiddleware
            $app.RouteMiddleware.Count | Should Be 1
        }
    }
    AfterAll {
        Stop-Polaris -ServerContext $app
    }
}
