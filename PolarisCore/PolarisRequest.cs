using System;
using System.Collections.Specialized;
using System.IO;
using System.Net;

namespace PolarisCore
{
    public class PolarisRequest
    {
        public string[] AcceptTypes { get { return RawRequest.AcceptTypes; } }
        public object Body { get; set; }
        public string BodyString { get; set; }
        public CookieCollection Cookies { get { return RawRequest.Cookies; } }
        public NameValueCollection Headers { get { return RawRequest.Headers; } }
        public string Method { get { return RawRequest.HttpMethod; } }
        public NameValueCollection Query { get { return RawRequest.QueryString; } }
        public Uri Url { get { return RawRequest.Url; } }
        public string UserAgent { get { return RawRequest.UserAgent; } }

        private HttpListenerRequest RawRequest;

        public PolarisRequest(HttpListenerRequest rawRequest)
        {
            RawRequest = rawRequest;
            BodyString = new StreamReader(rawRequest.InputStream).ReadToEnd();
        }
    }
}