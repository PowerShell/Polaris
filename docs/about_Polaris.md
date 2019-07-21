---
layout: default
title: About Polaris
type: about
---

# Polaris

## about_Polaris

# SHORT DESCRIPTION

A cross-platform, minimalist web framework for PowerShell.

# LONG DESCRIPTION

Polaris can be used by web developers and system administrators alike to build web applications and APIs quickly and with very little code.

## Light Weight

One of the best things about Polaris is how light it is. The entire framework is less than 1 MB to download. It leverages the .NET `HttpListener` class which is shipped with current versions of .NET Core and .NET Framework.

## Cross Platform

Polaris can be run on Windows or Linux or Mac. As long as you can install PowerShell, you can run Polaris.

# EXAMPLES

A quick example of an API is the below command which will start Polaris listening on http://localhost:8080 for a GET request to the /helloworld path.

```powershell
Install-Module Polaris
New-PolarisGetRoute -Path "/helloworld" -Scriptblock {
    $Response.Send('Hello World!')
}

Start-Polaris
```

I can get a response from the server by either opening a browser to http://localhost:8080/helloworld or running the following PowerShell command:

**Command**

```powershell
PS> Invoke-RestMethod -Method GET -Uri http://localhost:8080/helloworld
```

**Output**

```
Hello World!

PS>
```

# TROUBLESHOOTING NOTE

Any issues you find please file a bug on to https://github.com/PowerShell/Polaris/issues

# SEE ALSO

about_Routing
