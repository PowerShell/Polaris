---
layout: default
title: About $Request and $Response
type: about
---

# Polaris

## about_Polaris

# SHORT DESCRIPTION

These are two special variables that will be available for use during the scriptblock of any Polaris Route. $Request is used to represent information that was requested from the client. $Response is used to hold information that you would like to send back to the client.

# LONG DESCRIPTION

\$Request is tied to the `[PolarisRequest]` class and \$Response is a `[PolarisResponse]` the information on what properties and methods each class contains are described below

## [PolarisRequest]\$Request

| Property                           | Description                                                                                                                                              |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[object]$Body`                    | By default this is empty but is an `[object]` so it can be used to store any format of data. Useful for middlware parsers such as a json body converter. |
| `[string]$BodyString`              | This is the full body of the request in string format                                                                                                    |
| `[NameValueCollection]$Query`      | Gets the query string included in the request.                                                                                                           |
| `[string[]]$AcceptTypes`           | Gets the MIME types accepted by the client.                                                                                                              |
| `[string]$Method`                  | Gets the HTTP method specified by the client. (i.e. POST, GET, PUT, DELETE, etc.)                                                                        |
| `[uri]$URL`                        | Gets the Uri object requested by the client.                                                                                                             |
| `[string]$UserAgent`               | Gets the user agent presented by the client.                                                                                                             |
| `[string]$ClientIP`                | Gets the IP address of the client making the request.                                                                                                    |
| `[HttpListenerRequest]$RawRequest` | Gets the full raw [HttpListenerRequest](https://docs.microsoft.com/en-us/dotnet/api/system.net.httplistenerrequest?view=netframework-4.8).               |
| `[PSCustomObject]$Parameters`      | Parameters extracted from url patters. See about_routing for more details.                                                                               |
| `[IPrincipal]$User`                | The user making the request. The information stored here will depend on the authentication method set.                                                   |
| `[CookieCollection]$Cookies`       | Gets the cookies sent with the request.                                                                                                                  |
| `[NameValueCollection]$Headers`    | Gets the collection of header name/value pairs sent in the request.                                                                                      |

## [PolarisResponse]\$Response

### Properties

| Property                             | Description                                                                                                                                                                         |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[byte[]]$ByteResponse`              | Gets and sets a byte response to be sent to the client. You may set this directly but you should not run any of the `Send` methods as those methods will overwrite this property.   |
| `[string]$ContentType`               | Gets and sets the content type to be sent to the client.                                                                                                                            |
| `[WebHeaderCollection]$Headers`      | Gets and sets the headers to be sent to the client.                                                                                                                                 |
| `[int]$StatusCode`                   | Gets and sets the status code to be sent to the client.                                                                                                                             |
| `[Stream]$StreamResponse`            | Gets and sets a stream response to be sent to the client. You may set this directly but you should not run any of the `Send` methods as those methods will overwrite this property. |
| `[HttpListenerResponse]$RawResponse` | Gets the HttpListenerResponse for direct access to what will be sent to the client.                                                                                                 |

### Methods

The `[PolarisResponse]` class provides a series of helper methods that can be used to send information to the client a bit easier than accessing the properties directly.

| Method                                                 | Description                                                                                                                                           |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Send()`                                               | Sends an empty response to the client                                                                                                                 |
| `Send([string]$stringResponse)`                        | Sets the value of the \$ByteResponse property to the value of the string passed as the argument. \*Note: You will still have to set the content type. |
| `SendBytes([byte[]]$byteArray)`                        | Sets the value of $ByteResponse to your $ByteArray                                                                                                    |
| `Json([string]$stringResponse`                         | Sets the value of $ByteResponse to the value of the string passed as the argument and sets the $ContentType to `application/json`                     |
| `SetHeader([string]$headerName, [string]$headerValue)` | Sets the value of a header                                                                                                                            |
| `SetStatusCode([int]$StatusCode)`                      | Sets the value of \$StatusCode                                                                                                                        |
| `SetContentType([string]$ContentType)`                 | Sets the MIME type of the response                                                                                                                    |
| `SetStream([Stream]$Stream)`                           | Sets the value of \$ResponseStream                                                                                                                    |
| `GetContentType([string]$Path)`                        | Gets the content type of a file given a filepath.                                                                                                     |

# SEE ALSO

about_Routing
