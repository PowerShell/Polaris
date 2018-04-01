class PolarisResponse {
    [byte[]] $ByteResponse = [byte]0
    [string] $ContentType = "text/plain"
    [System.Net.WebHeaderCollection] $Headers = [System.Net.WebHeaderCollection]::new()
    [int] $StatusCode = 200

    Send([string]$stringResponse) {
        $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
    }

    SendBytes([byte[]] $byteArray) {
        $this.ByteResponse = $byteArray
    }

    Json([string] $stringResponse) {
        $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
        $this.ContentType = "application/json"
    }

    SetHeader([string] $headerName, [string] $headerValue) {
        $this.Headers[$headerName] = $headerValue
    }

    SetStatusCode([int] $statusCode) {
        $this.StatusCode = $statusCode
    }

    SetContentType([string] $contentType) {
        $this.ContentType = $contentType
    }
    
    static [string] GetContentType([string] $path) {
        return [MimeTypes]::GetMimeType($path)
    }
}
