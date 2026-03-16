using CLapi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class Method
    {
        public int MethodId { get; set; }
        public string MethodType { get; set; }
    }
}
namespace CLapi.DAL
{
    public class MethodDAL
    {
        private readonly DapperConn _conn;
        public MethodDAL()
        {
            _conn = new DapperConn();
        }

        public List<Method> GetAllMethods()
        {
            var proc = "sp_getAllMethods";
            return _conn.ExecuteMultipleRow<Method>(
                proc,
                null
            );
        }
    }
}