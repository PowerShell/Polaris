using System;
using System.Collections.Specialized;
using System.Net;

namespace PolarisCore
{
    public class PolarisRequest
    {
        public NameValueCollection QueryParameters;

        public PolarisRequest(HttpListenerRequest rawRequest)
        {
            QueryParameters = rawRequest.QueryString;
        }
    }
}