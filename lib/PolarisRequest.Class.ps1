#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

class PolarisRequest {

    [object]$Body
    [string]$BodyString
    [System.Collections.Specialized.NameValueCollection]$Query
    [string[]]$AcceptTypes
    [System.Net.CookieCollection]$Cookies
    [System.Collections.Specialized.NameValueCollection]$Headers
    [string]$Method
    [uri]$Url
    [string]$UserAgent
    [string]$ClientIP
    [System.Net.HttpListenerRequest]$RawRequest
    [PSCustomObject]$Parameters
    [System.Security.Principal.IPrincipal]$User

    PolarisRequest ([System.Net.HttpListenerRequest]$RawRequest, [System.Security.Principal.IPrincipal]$User) {
        $this.RawRequest = $RawRequest
        $this.BodyString = [System.IO.StreamReader]::new($RawRequest.InputStream).ReadToEnd()
        $this.AcceptTypes = $this.RawRequest.AcceptTypes
        $this.Cookies = $this.RawRequest.Cookies
        $this.Headers = $this.RawRequest.Headers
        $this.Method = $this.RawRequest.HttpMethod
        $this.Query = $this.RawRequest.QueryString
        $this.Url = $this.RawRequest.Url
        $this.UserAgent = $this.RawRequest.UserAgent
        $this.ClientIP = $this.RawRequest.RemoteEndPoint.Address
        $this.User = $User
    }
}
