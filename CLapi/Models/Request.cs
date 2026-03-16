using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class Request
    {
        public int ReqId { get; set; }
        public int UserId { get; set; }
        public int MethodId { get; set; }
        public string RequestURL { get; set; }
        public string Body { get; set; }
        public string Response { get; set; }
        public int StatusCode { get; set; }
    }
}