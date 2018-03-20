﻿Describe "Get-PolarisRouteMiddleware" {

    BeforeAll {
        
        #  Import module
        Import-Module "$PSScriptRoot\..\Polaris.psd1"

        #  Start with a clean slate
        Remove-PolarisRouteMiddleware

        #  Create middleware to test against
        New-PolarisRouteMiddleware -Name 'Test0'  -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test1'  -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test2A' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test2B' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test3A' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test3B' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test3C' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test4A' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test4B' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test5A' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test5B' -ScriptBlock {}
        New-PolarisRouteMiddleware -Name 'Test6'  -ScriptBlock {}
        }

    It "Should default to get all middleware" {
        $ExpectedCount = (Get-Polaris).RouteMiddleware.Count

        $Middleware = Get-PolarisRouteMiddleware
        @( $Middleware ).Count | Should Be $ExpectedCount
        }

    It "Should respect Name" {
        $Middleware = Get-PolarisRouteMiddleware -Name 'Test1'
        @( $Middleware ).Count | Should Be 1
        }

    It "Should do nothing when no middleware match" {
        $Middleware = Get-PolarisRouteMiddleware -Name 'DoesNotExist'
        @( $Middleware ).Count | Should Be 0
        }

    It "Should accept multiple values for Name" {
        $Middleware = Get-PolarisRouteMiddleware -Name 'Test3A', 'Test3B'
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept wildcard values for Name" {
        $Middleware = Get-PolarisRouteMiddleware -Name 'Test4*'
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept pipeline input for Name" {
        $Middleware = 'Test5A', 'Test5B' | Get-PolarisRouteMiddleware
        @( $Middleware ).Count | Should Be 2
        }

    It "Should accept pipeline property input for Name" {
        $Middleware = Get-PolarisRouteMiddleware -Name 'Test4*' | Get-PolarisRouteMiddleware
        @( $Middleware ).Count | Should Be 2
        }

    AfterAll {

        #  Clean up test middleware
        Remove-PolarisRouteMiddleware
        }
    }
