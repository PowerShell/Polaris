#
# Copyright (c) Microsoft. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

class PolarisResponse {
    [byte[]]$ByteResponse = [byte]0
    [string]$ContentType = "text/plain"
    [System.Net.WebHeaderCollection]$Headers = [System.Net.WebHeaderCollection]::new()
    [int]$StatusCode = 200
    [System.IO.Stream]$StreamResponse
    [System.Net.HttpListenerResponse]$RawResponse
    [bool]$Sent = $false

    PolarisResponse ([System.Net.HttpListenerResponse]$RawResponse) {
        $this.RawResponse = $RawResponse
    }

    Send () {
        $this.ByteResponse = [byte[]]::new(0)
        $this.Sent = $true
    }

    Send ([string]$stringResponse) {
        if ([string]::IsNullOrEmpty($stringResponse)) {
            $this.ByteResponse = [byte[]]::new(0)
        }
        else {
            $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
        }
        $this.Sent = $true
    }

    SendBytes ([byte[]]$byteArray) {
        $this.ByteResponse = $byteArray
        $this.Sent = $true
    }

    Json ([string]$stringResponse) {
        if ([string]::IsNullOrEmpty($stringResponse)) {
            $this.ByteResponse = [byte[]]::new(0)
        }
        else {
            $this.ByteResponse = [System.Text.Encoding]::UTF8.GetBytes($stringResponse)
        }
        $this.ContentType = "application/json"
        $this.Sent = $true
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
