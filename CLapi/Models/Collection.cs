using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class CollectionModel
    {
        public int CollectionId { get; set; }
        public string CollectionName { get; set; }
        public int UserId { get; set; }
        public int ReqId { get; set; }
    }
}