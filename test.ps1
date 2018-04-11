$PowerShell = [powershell]::Create()

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:8085/");

$Powershell = [powershell]::create()
$PowerShell
$listener.Start();

function New-ScriptBlockCallback {
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [scriptblock]$Callback
    )
<#
    .SYNOPSIS
        Allows running ScriptBlocks via .NET async callbacks.
 
    .DESCRIPTION
        Allows running ScriptBlocks via .NET async callbacks. Internally this is
        managed by converting .NET async callbacks into .NET events. This enables
        PowerShell 2.0 to run ScriptBlocks indirectly through Register-ObjectEvent.         
 
    .PARAMETER Callback
        Specify a ScriptBlock to be executed in response to the callback.
        Because the ScriptBlock is executed by the eventing subsystem, it only has
        access to global scope. Any additional arguments to this function will be
        passed as event MessageData.
         
    .EXAMPLE
        You wish to run a scriptblock in reponse to a callback. Here is the .NET
        method signature:
         
        void Bar(AsyncCallback handler, int blah)
         
        ps> [foo]::bar((New-ScriptBlockCallback { ... }), 42)                        
 
    .OUTPUTS
        A System.AsyncCallback delegate.
#>
    # is this type already defined?    
    if (-not ("CallbackEventBridge" -as [type])) {
        Add-Type @"
            using System;
             
            public sealed class CallbackEventBridge
            {
                public event AsyncCallback CallbackComplete = delegate { };
                private Action callback;
 
                private CallbackEventBridge(Action callback) {
                    this.callback = callback;
                }
 
                private void CallbackInternal(IAsyncResult result)
                {
                    Object[] result = this.callback(result)
                    CallbackComplete(result);
                }
 
                public AsyncCallback Callback
                {
                    get { return new AsyncCallback(CallbackInternal); }
                }
 
                public static CallbackEventBridge Create(Action callback)
                {

                    return new CallbackEventBridge(Action callback);
                }
            }
"@
    }
    $bridge = [callbackeventbridge]::create($callback)
    Register-ObjectEvent -input $bridge -EventName callbackcomplete -action {$args} -messagedata $args > $null
    $bridge.callback
}

 $listener.BeginGetContext((New-ScriptBlockCallback -callback {
         param(
             [System.IAsyncResult] $result
         )

         $listener = $result.AsyncState
         [System.Net.HttpListenerContext]$Context = $listener.EndGetContext($result)
         $response = $Context.Response

         Write-Host "Hello World!"
         $buffer = [System.Text.Encoding]::UTF8.GetBytes("Hello World!")
         $response.ContentLength64 = $buffer.Length
         $output = $response.OutputStream
         $output.Write($buffer, 0, $buffer.Length)
         $output.Close()
     }), $listener)

