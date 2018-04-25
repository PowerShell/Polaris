class PolarisResponse {
    [byte[]]$ByteResponse = [byte]0
    [string]$ContentType = "text/plain"
    [System.Net.WebHeaderCollection]$Headers = [System.Net.WebHeaderCollection]::new()
    [int]$StatusCode = 200
    [System.IO.Stream]$StreamResponse

    Send ([string]$stringResponse) {
        $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
    }

    SendBytes ([byte[]]$byteArray) {
        $this.ByteResponse = $byteArray
    }

    Json ([string]$stringResponse) {
        $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
        $this.ContentType = "application/json"
    }

    SetHeader ([string]$headerName, [string]$headerValue) {
        $this.Headers[$headerName] = $headerValue
    }

    SetStatusCode ([int]$StatusCode) {
        $this.StatusCode = $StatusCode
    }

    SetContentType ([string]$ContentType) {
        $this.ContentType = $ContentType
    }
	
    SetStream ([System.IO.Stream]$Stream) {
        $this.StreamResponse = $Stream
    }

    static [string] GetContentType ([string]$Path) {
        return [MimeTypes]::GetMimeType($Path)
    }
}
