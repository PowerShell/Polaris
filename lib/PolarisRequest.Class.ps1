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

    PolarisRequest ([System.Net.HttpListenerRequest]$RawRequest) {
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
    }
}

