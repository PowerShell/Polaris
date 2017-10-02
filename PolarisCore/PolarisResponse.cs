using System;
using System.Collections.Generic;
using System.IO;

namespace PolarisCore
{
    public class PolarisResponse
    {
        public byte[] ByteResponse { get; set; }
        public string ContentType { get; set; }
        public Dictionary<string, string> Headers { get; set; }
        public int StatusCode { get; set; } = 200;

        public void Send(string stringResponse) => ByteResponse = System.Text.Encoding.UTF8.GetBytes(stringResponse);

        public void SendBytes(byte[] byteArray) => ByteResponse = byteArray;

        public void Json(string stringResponse) {
            ByteResponse = System.Text.Encoding.UTF8.GetBytes(stringResponse);
            ContentType = "application/json";
        }

        public void SetHeader(string headerName, string headerValue) => Headers[headerName] = headerValue;

        public void SetStatusCode(int statusCode) => StatusCode = statusCode;

        public void SetContentType(string contentType) => ContentType = contentType;
    
        public static string GetContentType(string path)
        {
            string extension = Path.GetExtension(path);
            switch (extension)
            {
                case ".avi":  return "video/x-msvideo";
                case ".css":  return "text/css";
                case ".doc":  return "application/msword";
                case ".gif":  return "image/gif";
                case ".htm":
                case ".html": return "text/html";
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".js":   return "application/javascript";
                case ".json": return "application/json";
                case ".mp3":  return "audio/mpeg";
                case ".png":  return "image/png";
                case ".pdf":  return "application/pdf";
                case ".ppt":  return "application/vnd.ms-powerpoint";
                case ".zip":  return "application/zip";
                case ".txt":  return "text/plain";
                default:      return "application/octet-stream";
            }
        }
    }
}