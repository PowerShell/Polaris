# Polaris

A cross-platform, minimalist web framework for [PowerShell 6](https://github.com/powershell/powershell).

```PowerShell
Import-Module –Name .\Polaris.psm1

New-GetRoute -Path "/helloworld" -ScriptBlock {
    param($request,$response);
    $response.Send('Hello World!');
}

Start-Polaris
```

#### _NOTE: This is an experiment from the PowerShell team and this should not be used in any production system yet._

## Getting Started

1. Clone or download the zip of the repo
1. Open [PowerShell 6](https://github.com/powershell/powershell)
1. run `cd Polaris/PolarisCore`
1. run `dotnet restore`
1. run `dotnet build`
1. run `cd ..`

At this point, you can now run `Import-Module ./Polaris.psm1` to start using Polaris! Checkout [the wiki](https://github.com/PowerShell/Polaris/wiki) for more usage!

You can also run all the Pester tests by running `Invoke-Pester` in the `test` directory. You may need the [fork of Pester that supports PowerShell 6](https://github.com/powershell/psl-pester).

_Installation from the PowerShell Gallery coming soon!_

## Feedback

This project is an experiment that has the possibility to grow into something great. We can't do that without great feedback from you.

If you have an idea or find a bug, join the descussions in the issues or create a new issue.

## Limitations

* Currently, this only works in PowerShell 6. Support for older versions of PowerShell is on the roadmap
* There's no support for route parameters or query parameters that you would expect from projects like ASP.NET or Express however, we have a few ideas in mind on how to add this ability
* All script executions happen in a sandboxed runspace which means common parameters can not be shared between routes