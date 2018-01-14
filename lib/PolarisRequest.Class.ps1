class PolarisRequest {
    
    [object] $Body
    [string] $BodyString

    hidden [System.Net.HttpListenerRequest] $RawRequest

    PolarisRequest([System.Net.HttpListenerRequest] $rawRequest) {
        $this.RawRequest = $rawRequest
        $this.BodyString = [System.IO.StreamReader]::new($rawRequest.InputStream).ReadToEnd()
        $this | Add-Member -MemberType ScriptProperty -Name AcceptTypes -Value `
        {
            # Get
            return $this.RawRequest.AcceptTypes; 
        }

        $this | Add-Member -MemberType ScriptProperty -Name Cookies -Value `
        {
            # Get
            return $this.RawRequest.Cookies
        }

        $this | Add-Member -MemberType ScriptProperty -Name Headers -Value `
        { 
            # Get 
            return $this.RawRequest.Headers 
        }

        $this | Add-Member -MemberType ScriptProperty -Name Method -Value `
        {
            # Get
            return $this.RawRequest.HttpMethod
        }

        $this | Add-Member -MemberType ScriptProperty -Name Query -Value `
        {
            # Get
            return [System.Collections.Specialized.NameValueCollection]($this.RawRequest.QueryString)
        }

        $this | Add-Member -MemberType ScriptProperty -Name Url -Value `
        {
            # Get
            return $this.RawRequest.Url
        }

        $this | Add-Member -MemberType ScriptProperty -Name UserAgent -Value `
        {
            # Get
            return $this.RawRequest.UserAgent
        }
    }
}

