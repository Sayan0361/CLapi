using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using CLapi.Models;
using Dapper;

namespace CLapi.Models
{
    public class CollectionModel
    {
        public int collectionId { get; set; }
        public string collectionName { get; set; }
        public int UserId { get; set; }
        public int reqId { get; set; }
        public string requestName { get; set; }
        public string requestURL { get; set; }
        public int statusCode { get; set; }
        public string methodType { get; set; }
    }

    public class Collection_MessageModel
    {
        public DBResponseModel<string> dbres { get; set; }
        public List<CollectionModel> collections { get; set; }
       
    }
    
}

namespace CLapi.DAL
{
    public class CollectionDAL
    {
        private readonly DapperConn _conn;
        public CollectionDAL()
        {
            _conn = new DapperConn();
        }
        public DBResponseModel<int> addOrEditCollection(string collectionName, int userId, int collectionId = 0)
        {
            var proc = "sp_AddOrEditCollection";

            DynamicParameters parameters = new DynamicParameters();
            parameters.Add("@collectionId", collectionId);
            parameters.Add("@collectionName", collectionName);
            parameters.Add("@userId", userId);

            return _conn.ExecuteSingle<DBResponseModel<int>>(
                proc,
                parameters
            );
        }
        public Collection_MessageModel getDetails(int userId)
        {
            var proc = "sp_GetAllCollectionsRequestsByUserID";
            DynamicParameters param = new DynamicParameters();

            param.Add("userId", userId);
            var result = _conn.ExecuteMultipleResult<DBResponseModel<string>, CollectionModel>(proc, param);
            return new Collection_MessageModel
            {
                dbres = result.Item1 ?? new DBResponseModel<string>(),
                collections = result.Item2

            };
        }
    }
}