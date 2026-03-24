using CLapi.Models;
using Dapper;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class RequestModel
    {
        public int ReqId { get; set; }

        [Required(ErrorMessage = "UserId is required")]
        [Range(1, int.MaxValue, ErrorMessage = "Invalid UserId")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Method is required")]
        [Range(1, 4, ErrorMessage = "Invalid MethodId")]
        public int MethodId { get; set; } = 1;

        
        [Range(1, int.MaxValue, ErrorMessage = "Invalid CollectionId")]
        public int CollectionId { get; set; }

        [StringLength(100, ErrorMessage = "Request name too long")]
        public string RequestName { get; set; } = "Untitled";

        [Required(ErrorMessage = "Request URL is required")]
        //[Url(ErrorMessage = "Invalid URL format")]
        public string RequestURL { get; set; }

        public string Body { get; set; }

        [JsonIgnore]
        public string Response { get; set; }

        [Range(100, 599, ErrorMessage = "Invalid HTTP Status Code")]
        public int? StatusCode { get; set; }

        public string GetRequestName()
        {
            return string.IsNullOrWhiteSpace(RequestName) ? "New Request" : RequestName;
        }

        public bool IsValidJson()
        {
            if (string.IsNullOrWhiteSpace(Body)) return true;
            try
            {
                JsonConvert.DeserializeObject(Body);
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
    public class DBResponseModel<T>
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
        public DBResponseModel<int> SaveRequest(RequestModel request)
        {
            var proc = "sp_UpsertResponse";
            var param = new DynamicParameters();

            param.Add("@UserId", request.UserId);
            param.Add("@MethodId", request.MethodId);

            param.Add("@CollectionId", request.CollectionId);
            param.Add("@RequestName", request.GetRequestName());

            param.Add("@RequestURL", request.RequestURL);
            param.Add("@Body", request.Body);
            param.Add("@Response", request.Response);
            param.Add("@StatusCode", request.StatusCode);

            return _conn.ExecuteSingle<DBResponseModel<int>>(
                proc,
                param
            );
        }

        public DBResponseModel<int> DeleteRequest(int userId, int reqId, int collectionId)
        {
            var proc = "sp_DeleteRequest";
            var param = new DynamicParameters();
            param.Add("@userId", userId);
            param.Add("@reqId", reqId);
            param.Add("@collectionId", collectionId);

            return _conn.ExecuteSingle<DBResponseModel<int>>(
                proc,
                param
            );
        }
    }
}