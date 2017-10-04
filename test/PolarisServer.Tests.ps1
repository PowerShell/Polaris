$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Test webserver use" {
    It "test /helloworld route" {
        $result = Invoke-WebRequest -Uri "http://localhost:$Port/helloworld"
        $result.Content | Should Be 'Hello World'
    }

    It "test /wow route" {
        $result = Invoke-RestMethod -Uri "http://localhost:$Port/wow" -Method POST
        $result.wow | Should Be $true
    }

    It "test /example route" {
        $result = Invoke-WebRequest -Uri "http://localhost:$Port/example"
        $result.Content | Should Be 'test file'
    }

    It "test /example route" {
        $expectedHtml = `
'<div>hello world</div>

<img src="test.png" alt="yay" />
<img src="test.png" alt="yay" />
<img src="test1.png" alt="yay" />'

        $result = Invoke-WebRequest -Uri "http://localhost:$Port/public/index.html"
        $result.Content | Should Be $expectedHtml
    }
}