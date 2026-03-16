using CLapi.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class Request
    {
        public int ReqId { get; set; }
        [Required(ErrorMessage = "UserId is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Invalid UserId")]
        public int UserId { get; set; }
        [Required(ErrorMessage = "Method is required")]
        [Range(1, 4, ErrorMessage = "Invalid MethodId")]
        public int MethodId { get; set; }
        [Required(ErrorMessage = "Request URL is required")]
        [StringLength(100, ErrorMessage = "URL cannot exceed 100 characters")]
        [Url(ErrorMessage = "Invalid URL format")]
        public string RequestURL { get; set; }
        public string Body { get; set; }
        public string Response { get; set; }
        [Range(100, 599, ErrorMessage = "Invalid HTTP Status Code")]
        public int StatusCode { get; set; }
    }
    public class DBResponse<T>
    {
        public int Success { get; set; }
        public string Message { get; set; }
        public T Data { get; set; }
    }
}

namespace CLapi.DAL
{
    public class RequestDAL
    {
        private readonly DapperConn _conn;
        public RequestDAL()
        {
            _conn = new DapperConn();
        }
        public DBResponse<int> SaveResponse(Request request)
        {
            var proc = "sp_UpsertResponse";
            var param = new DynamicParameters();
            param.Add("@UserId", request.UserId);
            param.Add("@MethodId", request.MethodId);
            param.Add("@RequestURL", request.RequestURL);
            param.Add("@Body", request.Body);
            param.Add("@Response", request.Response);
            param.Add("@StatusCode", request.StatusCode);
            return _conn.ExecuteSingle<DBResponse<int>>(
                proc,
                param
            );
        }
    }
}