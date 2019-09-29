---
layout: default
title: Authentication
type: about
---

# Authentication

## about_GettingStarted

# SHORT DESCRIPTION

Authentication is verifying who the consumer of your service or site is. Polaris uses the .Net class [System.Net.HttpListener](https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistener?view=netframework-4.8) under the hood and is thus able to support the following authentication schemes out of the box:

| Authentication Scheme           | Description                                                                                                                                         |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Basic                           | Specifies basic authentication.                                                                                                                     |
| Digest                          | Specifies digest authentication.                                                                                                                    |
| IntegratedWindowsAuthentication | Specifies Windows authentication.                                                                                                                   |
| Negotiate                       | Negotiates with the client to determine the authentication scheme. If both client and server support Kerberos, it is used; otherwise, NTLM is used. |
| NTLM                            | Specifies NTLM authentication.                                                                                                                      |
| Anonymous (Default)             | Specifies anonymous authentication.                                                                                                                 |

These authentication methods are global and are declared when you are creating your Polaris object as follows:

```powershell
# Basic Authentication
Start-Polaris -Auth Basic

# Ntml
Start-Polaris -Auth NTLM
```

User information will be available for use inside your scriptblocks via `$Request.User`:

```powershell
Start-Polaris -Auth Basic

New-PolarisRoute -Method GET -Path "/whoami" -Scriptblock {
  $Response.json(($Request.User | ConvertTo-Json))
}
```

Note that with Basic auth all you get is `$Request.User.Identity.Name` and `$Request.User.Identity.Password`. If you are using Basic authentication in any web application you are going to have to write additional logic to validate that username and password are correct and determine whether or not they are authorized for different parts of your application.

The easiest way to implement authentication is if you are in a Windows environment hosting Polaris from a Windows server and are authenticating with domain joined user accounts. If this is the case authentication and authorization are as simple as:

```powershell
Start-Polaris -Auth Negotiate

# Here we are checking to see if the user is in the administrator group of the PC where Polaris is hosted from
#    Note: This will return false unless you access Polaris from an elevated web browser
New-PolarisRoute -Method Get -Path "/TestAdminGroup" -Scriptblock {
    $Response.Send("User is in Administrators Role:  $($Request.User.IsInRole('Administrators'))")
}

# You can also use IsInRole to test if the user is in any Active Directory security group
New-PolarisRoute -Method Get -Path "/TestADSecurityGroup" -Scriptblock {
    $MyActiveDirectorySecurityGroup = "SecurityGroup1"
    $Response.Send("User is in $MyActiveDirectorySecurityGroup Role:  $($Request.User.IsInRole($MyActiveDirectorySecurityGroup))")
}
```

This is also a very nice experience for end users as on Windows PCs they will not be prompted for credentials unless their PC cannot talk to a domain controller (i.e. off network).

## Additional Authentication Types

Any additional or custom authentication types can be implemented using the `New-PolarisRouteMiddleware`.

# LONG DESCRIPTION

## Basic

Basic authentication strictly validates that a client has passed Polaris a header that looks like this: `Authorization: Basic <Base64Encoded(username:password)>. If the incoming Http request does not have the required headers it will send a response to the client telling them that Basic authentication is required. You can read more about basic authentication on the [Mozilla docs site here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication).

One thing to remember with this authentication scheme though is that it only ensures there is a username and password. Not that the username and password is valid. This leaves it up to you the application developer to validate the username and password.

The most basic implementation of this would be a simple hard coded username and password inside of a Middleware like this:

```powershell
New-PolarisRouteMiddleware -Name "BasicAuthValidation" -Scriptblock {
   if($Request.User.Identity.Name -ne "Username" -or $Request.User.Identity.Password -ne "Password") {
      $Response.StatusCode = 401;
      $Response.Send("Unauthorized")
   }
}
```

Of course in a production environment you might want to use the username and password to query against a table in a database.

## Digest

Digest authentication is an authentication method that can be used to avoid sending the username and password in clear text. With HTTPS being easy and very prevalent this is less of a need for sites who want to use just username and password for authentication.

You can read more about digest authentication in [the official RFC](https://tools.ietf.org/html/rfc2617#section-3)

## Integrated Windows Authentication & Negotiate & NTLM

All three of these authentication methods are very useful for internal web applications that are being accessed by computers or users on the same domain as the computer that is hosting the web application. Typically you will want to use `Negotiate` as that will ensure the best compatibility with any client that is going to be connecting with Polaris.

It will populate `$Request.User` with an IPrincipal that contains all the Active Directory security groups the authenticated user is a member of. You can test their membership of security groups using `$Request.User.IsInRole`. It can also be used to impersonate the user if Polaris is being executed as a service account that has authorization to impersonate authenticated users by `[WindowsIdentity]::RunImpersonated($Request.User.Identity.AccessToken, [action]{ & whoami })`.

Impersonation offers an excellent solution if you are attempting to create a web based file server as access to the files and folders can be managed using standard file and folder permissions and impersonation will ensure that those security rules are honored.

## Custom Authentication

Since this is not supported out of the box and needs to be implemented in a middlware you will need to start Polaris with `Start-Polaris -Auth Anonymous` or leave Auth unspecified and it will default to Anonymous.

Then authentication can be completely implemented using middleware. Here is an example of implementing Basic authentication as a middleware:

```powershell
New-PolarisRouteMiddleware -Name "BasicAuthValidation" -Scriptblock {
    $AuthHeader = $Request.Headers.Get("Authorization")

   if($AuthHeader -eq $Null -or $AuthHeader -notmatch "^Basic") {
       $Response.Headers.Add("WWW-Authenticate", "Basic realm=$Env:Computername")
       $Response.StatusCode = 401
       $Response.Send("Unauthorized. Missing auth header.")
   }

   $DecodedHeader = [system.text.encoding]::UTF8.GetString([system.convert]::FromBase64String(($Request.Headers.Get("Authorization") -split " ")[1]))
   $Username = ($DecodedHeader -split ":")[0]
   $Password = ($DecodedHeader -split ":")[1]

   if($Username -ne "Username" -or $Password -ne "Password") {
      $Response.Headers.Add("WWW-Authenticate", "Basic realm=$Env:Computername")
      $Response.StatusCode = 401;
      $Response.Send("Unauthorized. Incorrect username or password.")
   }
}
```

It is a recommended best practice if you want to store the user's roles and access them throughout the rest of the application to create an IUserPrinciple and assign it to `$Request.User`.
