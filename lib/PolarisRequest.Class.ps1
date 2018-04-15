class PolarisRequest {
    
    [object] $Body
    [string] $BodyString
    [System.Collections.Specialized.NameValueCollection] $Query
    [string[]] $AcceptTypes
    [System.Net.CookieCollection] $Cookies
    [System.Collections.Specialized.NameValueCollection] $Headers
    [string] $Method
    [uri] $Url
    [string] $UserAgent

   [System.Net.HttpListenerRequest] $RawRequest

    PolarisRequest([System.Net.HttpListenerRequest] $rawRequest) {
        $this.RawRequest = $rawRequest
        $this.BodyString = [System.IO.StreamReader]::new($rawRequest.InputStream).ReadToEnd()
        $this.AcceptTypes = $this.RawRequest.AcceptTypes
        $this.Cookies = $this.RawRequest.Cookies
        $this.Headers = $this.RawRequest.Headers 
        $this.Method = $this.RawRequest.HttpMethod
        $this.Query = $this.RawRequest.QueryString
        $this.Url = $this.RawRequest.Url
        $this.UserAgent = $this.RawRequest.UserAgent
    }
}

