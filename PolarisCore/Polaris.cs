using System;
using System.Collections.Generic;
using System.Net;
using System.Management.Automation;
using System.Threading;
using System.Management.Automation.Runspaces;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System.IO;
using System.Security.Principal;

namespace PolarisCore
{
    public class Polaris
    {
        public Action<string> Logger {get; set;}
        public int Port {get; set;}

        // path => method => script block
        public Dictionary<string, Dictionary<string, string>> ScriptBlockRoutes
            = new Dictionary<string, Dictionary<string, string>>();

        HttpListener Listener;

        RunspacePool PowerShellPool;

        bool StopServer = false;

        public Polaris(Action<string> logger)
        {
            Logger = logger;
        }

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
            Log("App listening on Port: " + port + "!");
        }

        public void Stop()
        {
            StopServer = true;
            Log("Server Stopped.");
        }

        public HttpListener InitListener(int port)
        {
            Port = port;

            HttpListener listener = new HttpListener();

            // If user is on a non-windows system or windows as administrator
            if (Environment.OSVersion.Platform != PlatformID.Win32NT ||
                (Environment.OSVersion.Platform == PlatformID.Win32NT &&
                (new WindowsPrincipal(WindowsIdentity.GetCurrent())).IsInRole(WindowsBuiltInRole.Administrator)))
            {
                listener.Prefixes.Add("http://+:" + Port + "/");
            } else
            {
                listener.Prefixes.Add("http://localhost:" + Port + "/");
            }

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

                Log("request came in: " + rawRequest.HttpMethod + " " + rawRequest.RawUrl);

                PolarisRequest request = new PolarisRequest(rawRequest);
                PolarisResponse response = new PolarisResponse();

                string route = rawRequest.Url.AbsolutePath.TrimEnd('/').TrimStart('/');
                PowerShell PowerShellInstance = PowerShell.Create();
                PowerShellInstance.RunspacePool = PowerShellPool;
                try
                {
                    // this script has a sleep in it to simulate a long running script
                    PowerShellInstance.AddScript(ScriptBlockRoutes[route][rawRequest.HttpMethod]);
                    PowerShellInstance.AddParameter(nameof(request), request);
                    PowerShellInstance.AddParameter(nameof(response), response);

                    var res = PowerShellInstance.BeginInvoke<PSObject>(new PSDataCollection<PSObject>(), new PSInvocationSettings(), (result) => {
                        if (PowerShellInstance.InvocationStateInfo.State == PSInvocationState.Failed)
                        {
                            Log(PowerShellInstance.InvocationStateInfo.Reason.ToString());
                            response.Send(PowerShellInstance.InvocationStateInfo.Reason.ToString());
                            response.SetStatusCode(500);
                        }
                        Send(rawResponse, response);
                        PowerShellInstance.Dispose();
                    }, null);
                }
                catch(Exception e)
                {
                    if(e is KeyNotFoundException)
                    {
                        Send(rawResponse, System.Text.Encoding.UTF8.GetBytes("Not Found"), 404, "text/plain; charset=UTF-8");
                        Log("404 Not Found");
                    }
                    else
                    {
                        Log(e.Message);
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

        private void Log(string logString)
        {
            try
            {
                Logger(logString);
            } catch(PSInvalidOperationException e)
            {
                // ignore
            }
        }
    }
}
