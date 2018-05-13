# Polaris

[![Join the chat at https://gitter.im/PowerShellPolaris/Lobby](https://badges.gitter.im/PowerShellPolaris/Lobby.svg)](https://gitter.im/PowerShellPolaris/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build status](https://ci.appveyor.com/api/projects/status/0ak497mbjn6dibxw/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/polaris/branch/master)

A cross-platform, minimalist web framework for [PowerShell](https://github.com/powershell/powershell).

## Disclaimer

Polaris is currently an **unsupported, experimental, proof-of-concept**. There is no current plan to turn it into a supported Microsoft product.

That being said, we do plan on continuing to experiment within this repository for the forseeable future.

## Example

```PowerShell
New-PolarisGetRoute -Path "/helloworld" -Scriptblock {
    $Response.Send('Hello World!');
}

Start-Polaris
```

### Why yet another web framework for PowerShell?

There have been a great list of [other](https://github.com/StartAutomating/Pipeworks) [micro](https://github.com/toenuff/flancy) [web](https://github.com/Jaykul/NancyPS/) [frameworks](https://github.com/toenuff/PshOdata) [written](https://github.com/straightdave/presley) [over](https://github.com/cofonseca/WebListener) [the](https://github.com/DataBooster/PS-WebApi) [years](https://github.com/ChristopherGLewis/PowerShellWebServers) (Thanks @jaykul for the list!).

Polaris' differentiation is that it is cross-platform and uses the .NET HttpListener class.

## Getting Started

### Prereqs

* [PowerShell](https://github.com/powershell/powershell)

### Steps

1.  Clone or download the zip of the repo
1.  Open [PowerShell](https://github.com/powershell/powershell)

At this point, you can now run `Import-Module ./Polaris.psd1` to start using Polaris! Checkout [the wiki](https://github.com/PowerShell/Polaris/wiki) for more usage!

You can also run all the Pester tests by running `Invoke-Pester` in the `test` directory. You may need the [fork of Pester that supports PowerShell](https://github.com/powershell/psl-pester).

_Installation from the PowerShell Gallery coming soon!_

## Documentation

Check out the [docs folder](https://github.com/PowerShell/Polaris/tree/master/docs) for the API reference.

## Roadmap

We have a few paths we are interested in taking. We hope the community helps direct us.

* Expanding on the current implementation using HttpListener to deliver features you'd expect from projects ASP.NET or Expressjs (route parameters, query parameters, middleware, auth etc)

* Investigating the use of [Kestrel](https://github.com/aspnet/KestrelHttpServer)/[ASP.NET Routing](https://github.com/aspnet/routing) instead of HttpListener

* Creating a routing domain-specific language (DSL) for isolating and running script blocks as routes. Drawing inspiration from [Pester](https://github.com/pester/Pester/).

## Feedback

This project is an experiment that has the possibility to grow into something great.
We can't do that without great feedback from you.

If you have an idea or find a bug, join the discussions in the issues or create a new issue.

## License

Polaris is licensed under the MIT License.

## Maintainers

* [Tyler Leonhardt](https://github.com/tylerl0706) - [@TylerLeonhardt](https://twitter.com/TylerLeonhardt)
* [Micah Rairdon](https://github.com/tiberriver256) - [@tiberriver256](https://twitter.com/tiberriver256)

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct][conduct-code].
For more information see the [Code of Conduct FAQ][conduct-faq] or contact [opencode@microsoft.com][conduct-email] with any additional questions or comments.

[conduct-code]: http://opensource.microsoft.com/codeofconduct/
[conduct-faq]: http://opensource.microsoft.com/codeofconduct/faq/
[conduct-email]: mailto:opencode@microsoft.com
