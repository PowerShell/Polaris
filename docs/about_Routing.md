---
layout: default
title: About Routing
type: about
---

# Routing

## about_Routing

#  SHORT DESCRIPTION

**Routing** refers to determining how an application responds to a client request to a particular endpoint, which is a URI (or path) and a specific HTTP request method (GET, POST, and so on).

Polaris routes are declared using the `New-PolarisRoute` cmdlet as follows:

```pwsh
New-PolarisRoute -Path "/" -Method GET -Scriptblock { $Response.Send("Hello World!") }
```

This means that when a request is made to the root (`/`) of your site using the HTTP method GET Polaris will respond with `Hello World`.

You can also use a slightly shortened alternative syntax as follows:

```pwsh
New-PolarisGetRoute -Path "/" -Scriptblock { $Response.Send("Hello World!") }
```

If you wanted to respond to a POST instead of a GET you would simply change the method:

```pwsh
New-PolarisRoute -Path "/" -Method POST -Scriptblock { $Response.Send("Hello World!") }
```

You can also use parameters in the path as follows:

```pwsh
New-PolarisRoute -Path "/hello/:firstname/:lastname" -Method GET -Scriptblock { $Response.Send("Hello $($Request.Parameters.firstname) $($Request.Parameters.lastname)!") }
```

An HTTP request using the GET method to the following uri `/hello/Bobby/Dylan` would result in a response of `Hello Bobby Dylan!`.

# LONG DESCRIPTION

## Examples of basic simple route matching

This route path will match requests to the root route, /.
```ps
New-PolarisRoute -Path "/" -ScriptBlock {
   $Response.Send('root')
}
```

This route path will match requests to /about.
```ps
New-PolarisRoute -Path "/about" -ScriptBlock {
   $Response.Send('about')
}
```

This route path will match requests to /random.txt.
```ps
New-PolarisRoute -Path "/random.txt" -ScriptBlock {
   $Response.Send('random.txt')
}
```

## Here are some examples of route paths based on string patterns.

This route path will match acd and abcd.
```ps
New-PolarisRoute -Path "/ab?cd" -ScriptBlock {
   $Response.Send('ab?cd')
}
```

This route path will match abcd, abbcd, abbbcd, and so on.
```ps
New-PolarisRoute -Path "/ab+cd" -ScriptBlock {
   $Response.Send('/ab+cd')
}
```

This route path will match abcd, abxcd, abRANDOMcd, ab123cd, and so on.
```ps
New-PolarisRoute -Path "/ab*cd" -ScriptBlock {
   $Response.Send('/ab*cd')
}
```

This route path will match /abe and /abcde.
```ps
New-PolarisRoute -Path "/ab(cd)?e" -ScriptBlock {
   $Response.Send('/ab(cd)?e')
}
```

## Examples of route paths based on regular expressions:

This route path will match anything with an “a” in it.
```ps
New-PolarisRoute -Path [RegEx]::New("a") -ScriptBlock {
   $Response.Send('a')
}
```

This route path will match butterfly and dragonfly, but not butterflyman, dragonflyman, and so on.
```ps
New-PolarisRoute -Path [RegEx]::New(".*fly$") -ScriptBlock {
   $Response.Send('.*fly$')
}
```

## Route parameters
Route parameters are named URL segments that are used to capture the values specified at their position in the URL. The captured values are populated in the req.params object, with the name of the route parameter specified in the path as their respective keys.

```
Route path: /users/:userId/books/:bookId
Request URL: http://localhost:3000/users/34/books/8989
$Request.parameters: { "userId": "34", "bookId": "8989" }
```

To define routes with route parameters, simply specify the route parameters in the path of the route as shown below.

```ps
New-PolarisRoute -Path "/users/:userId/books/:bookId" -ScriptBlock {
   $Response.Send($Request.Parameters)
}
```

The name of route parameters must be made up of “word characters” ([A-Za-z0-9_]).

Since the hyphen (-) and the dot (.) are interpreted literally, they can be used along with route parameters for useful purposes.

```
Route path: /flights/:from-:to
Request URL: http://localhost:3000/flights/LAX-SFO
$Request.Parameters: { "from": "LAX", "to": "SFO" }
```

```
Route path: /plantae/:genus.:species
Request URL: http://localhost:3000/plantae/Prunus.persica
$Request.Parameters: { "genus": "Prunus", "species": "persica" }
```

## Advanced Cases for Routing

In the case where the above does not suit your needs you also have the option to declare routes using .Net Regular Expressions. The value of $Matches from the regular expression will be available in $Request.Parameters so any named capture groups will flow directly through.

```
Route path: [RegEx]::("^/plantae/(?<genus>.+)\.(?<species>.+)$")
Request URL: http://localhost:3000/plantae/Prunus.persica
$Request.Parameters: { "genus": "Prunus", "species": "persica" }
```

## How things work under the hood

New-PolarisRoute creates a new instance of the class [PolarisRoute] and sets the value of Path, Method and Scriptblock using the values you pass as arguments. The PolarisRoute class has logic that will determine whether the Path passed was a string of a Regular Expression.

If it is a string there is a simple conversion run that converts the path string into a regular expression. For example `/home` will get converted into `^/home$` and `/plantae/:genus.:species` will get converted into `^/plantae/(?<genus>.+)\.(?<species>.+)$`.

Each PolarisRoute is stored in an array and when an incoming request is received Polaris will iterate through the array of routes to determine if the method and URI of the request match any of the PolarisRoutes. If it finds a match it will set $Request.Parameters to the value of $Matches cast to a [pscustomobject] and will execute the corresponding ScriptBlock.

# TROUBLESHOOTING NOTE

If you're not sure why a route you've made isn't executing. It may be helpful to review the regular expression yourself and play with the value of your path until you find one that works for you.

You can do that by manually inspecting the array of routes stored on Polaris.

```pwsh
> $Polaris = Get-Polaris
> $Polaris.Routes
```

```
Path         Regex                Method Scriptblock
----         -----                ------ -----------
/hello/:name ^/hello/(?<name>.+)$ GET     $Response.Send("Hello $($Parameters.Name)")
```

You can modify the value of Path directly and the value of Regex will update to match. You can then simply test it via:

```pwsh
> "/hello/bobby" -match $Polaris.Routes[0].Regex

$true
```

You can also inspect what the parameters will look like via:

```pwsh
> "/hello/bobby" -match $Polaris.Routes[0].Regex
$true
> [pscustomobject]$Matches

name  0
----  -
bobby /hello/bobby
```
