using System;
using System.Collections.Generic;
using System.Net;
using System.Management.Automation;
using System.Threading;
using System.Management.Automation.Runspaces;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System.IO;

namespace PolarisCore
{
    public class Polaris
    {
        public int Port {get; set;}

        // path => method => script block
        public Dictionary<string, Dictionary<string, string>> ScriptBlockRoutes
            = new Dictionary<string, Dictionary<string, string>>();

        HttpListener Listener;

        RunspacePool PowerShellPool;

        bool StopServer = false;

        public void AddRoute(string path, string method, string scriptBlock)
        {
            if (scriptBlock == null)
            {
                throw new ArgumentNullException(nameof(scriptBlock));
            }

            string sanitizedPath = path.TrimEnd('/').TrimStart('/');

            if(!ScriptBlockRoutes.ContainsKey(sanitizedPath))
            {
                ScriptBlockRoutes[sanitizedPath] = new Dictionary<string, string>();
            }
            ScriptBlockRoutes[sanitizedPath][method] = scriptBlock;
        }

        public void Start(int port = 3000, int minRunspaces = 1, int maxRunspaces = 1)
        {
            StopServer = false;

            PowerShellPool = RunspaceFactory.CreateRunspacePool(minRunspaces, maxRunspaces);
            PowerShellPool.Open();
            Listener = InitListener(port);

            Thread listenerThread = new Thread(async () => { await ListenerLoop(); });
            listenerThread.Start();

            // Loop until worker thread activates.
            while (!listenerThread.IsAlive);
            Console.WriteLine("App listening on Port: " + port + "!");
        }

        public void Stop()
        {
            StopServer = true;
            Console.WriteLine("Server Stopped.");
        }

        public HttpListener InitListener(int port)
        {
            Port = port;
            var prefix = "http://localhost:" + Port + "/";
            HttpListener listener = new HttpListener();
            listener.Prefixes.Add(prefix);

            listener.Start();
            return listener;
        }

        public async Task ListenerLoop()
        {
            while(!StopServer)
            {
                var context = await Listener.GetContextAsync();

                if(StopServer)
                {
                    break;
                }

                HttpListenerRequest rawRequest = context.Request;
                HttpListenerResponse rawResponse = context.Response;

                Console.WriteLine("request came in: " + rawRequest.HttpMethod + " " + rawRequest.RawUrl);

                PolarisRequest request = new PolarisRequest();
                PolarisResponse response = new PolarisResponse();

                string route = rawRequest.RawUrl.TrimEnd('/').TrimStart('/');
                PowerShell PowerShellInstance = PowerShell.Create();
                PowerShellInstance.RunspacePool = PowerShellPool;
                try
                {
                    // this script has a sleep in it to simulate a long running script
                    PowerShellInstance.AddScript(ScriptBlockRoutes[route][rawRequest.HttpMethod]);
                    PowerShellInstance.AddParameter(nameof(request), request);
                    PowerShellInstance.AddParameter(nameof(response), response);

                    var res = PowerShellInstance.BeginInvoke<PSObject>(new PSDataCollection<PSObject>(), new PSInvocationSettings(), (result) => {
                        Console.WriteLine(PowerShellInstance.InvocationStateInfo.State);
                        Console.WriteLine(PowerShellInstance.InvocationStateInfo.Reason);

                        Send(rawResponse, response);
                        PowerShellInstance.Dispose();
                    }, null);
                }
                catch(Exception e)
                {
                    if(e is KeyNotFoundException)
                    {
                        Send(rawResponse, System.Text.Encoding.UTF8.GetBytes("Not Found"), 404, "text/plain; charset=UTF-8");
                        Console.WriteLine("404 Not Found");
                    }
                    else
                    {
                        Console.WriteLine(e.Message);
                        throw e;
                    }
                }
            }

            Listener.Close();
            PowerShellPool.Dispose();
        }

        private static void Send(HttpListenerResponse rawResponse, PolarisResponse response)
        {
            Send(rawResponse, response.ByteResponse, response.StatusCode, response.ContentType);
        }

        private static void Send(HttpListenerResponse rawResponse, byte[] byteResponse, int statusCode, string contentType)
        {
            rawResponse.StatusCode = statusCode;
            rawResponse.ContentType = contentType;
            rawResponse.ContentLength64 = byteResponse.Length;
            rawResponse.OutputStream.Write(byteResponse, 0, byteResponse.Length);
            rawResponse.OutputStream.Close();
        }
    }
}
