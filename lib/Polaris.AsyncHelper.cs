using System;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

namespace Polaris
{
    public class AsyncHelper
    {
        public delegate void EventRaised(HttpListenerContext context);
        public event EventRaised myEvent;
        public HttpListener Listener;

        public AsyncHelper(){
            this.Listener = new HttpListener();
        }

        private async Task ListenerLoop()
        {
            try {
                 this.Listener.Start();
            } 
            catch (Exception e) {
                throw e;
            }
           
            while (true)
            {
                try{
                    var context = await this.Listener.GetContextAsync();
                    myEvent(context);
                } 
                catch (Exception e) {
                    throw e;
                }
            }
        }

        public void Start()
        {
            try{
                Thread listenerThread = new Thread(async () => { await ListenerLoop(); });
                listenerThread.Start();
            }
            catch (Exception e) {
                throw e;
            }
            
        }
    }
}