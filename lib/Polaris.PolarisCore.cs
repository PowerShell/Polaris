using System;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

namespace Polaris
{
    public class PolarisCore
    {
        public delegate void EventRaised(HttpListenerContext context);
        public event EventRaised myEvent;

        private async Task ListenerLoop(HttpListener web)
        {
            while (true)
            {
                var context = await web.GetContextAsync();
                myEvent(context);
            }
        }

        public void Start(HttpListener web)
        {
            Thread listenerThread = new Thread(async () => { await ListenerLoop(web); });
            listenerThread.Start();
        }
    }
}