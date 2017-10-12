# Polaris

A cross-platform, minimalist web framework for [PowerShell 6](https://github.com/powershell/powershell).

## Disclaimer

Polaris is currently an **unsupported, experimental, proof-of-concept**. There is no current plan to turn it into a supported Microsoft product.

That being said, we do plan on continuing to experiment within this repository for the forseeable future.

## Example

```PowerShell
Import-Module –Name .\Polaris.psm1

New-GetRoute -Path "/helloworld" -ScriptBlock {
    param($request,$response);
    $response.Send('Hello World!');
}

Start-Polaris
```


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

## Roadmap

We have a few paths we are interested in taking. We hope the community helps direct us.

* Expanding on the current implementation using HttpListener to deliver features you'd expect from projects ASP.NET or Expressjs (route parameters, query parameters, middleware etc)

* Investigating the use of [Kestrel](https://github.com/aspnet/KestrelHttpServer)/[ASP.NET Routing](https://github.com/aspnet/routing) instead of HttpListener

* Support for Windows PowerShell (5.x and lower)

* Creating a routing domain-specific language (DSL) for isolating and running script blocks as routes. Drawing inspiration from [Pester](https://github.com/pester/Pester/).

## Feedback

This project is an experiment that has the possibility to grow into something great.
We can't do that without great feedback from you.

If you have an idea or find a bug, join the discussions in the issues or create a new issue.

## Limitations

* Currently, this only works in PowerShell 6. Support for older versions of PowerShell is on the roadmap
* There's no support for route parameters or query parameters that you would expect from projects like ASP.NET or Express however, we have a few ideas in mind on how to add this ability
* All script executions happen in a sandboxed runspace which means common parameters can not be shared between routes

## License

Polaris is licensed under the MIT License.

## Maintainers

* [Tyler Leonhardt](https://github.com/tylerl0706) - [@TylerLeonhardt](https://twitter.com/TylerLeonhardt)

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct][conduct-code].
For more information see the [Code of Conduct FAQ][conduct-FAQ] or contact [opencode@microsoft.com][conduct-email] with any additional questions or comments.

[conduct-code]: http://opensource.microsoft.com/codeofconduct/
[conduct-FAQ]: http://opensource.microsoft.com/codeofconduct/faq/
[conduct-email]: mailto:opencode@microsoft.com
