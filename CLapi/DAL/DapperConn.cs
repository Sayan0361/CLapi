using Dapper;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;

namespace CLapi.DAL
{
    public class DapperConn
    {
        // RETURN NO VALUE.
        public void ExecuteWithoutReturn(string procName, DynamicParameters param = null)
        {
            using (var conn = DbConnectionFactory.Create())
            {
                conn.Execute(procName, param, commandType: CommandType.StoredProcedure);
            }
        }

        // RETURN SINGLE ROW.
        public T ExecuteSingleRow<T>(string procName, DynamicParameters param = null)
        {
            using (var conn = DbConnectionFactory.Create())
            {
                return conn.QueryFirstOrDefault<T>(procName, param, commandType: CommandType.StoredProcedure);
            }
        }

        // RETURN MULTIPLE ROWS
        public List<T> ExecuteMultipleRow<T>(string procName, DynamicParameters param)
        {
            using (var conn = DbConnectionFactory.Create())
            {
                return conn.Query<T>(procName, param, commandType: CommandType.StoredProcedure).ToList();
            }
        }

        // RETURN SINGLE VALUE
        public T ExecuteSingle<T>(string procName, DynamicParameters param)
        {
            using (var conn = DbConnectionFactory.Create())
            {
                return conn.QueryFirstOrDefault<T>(
                    procName,
                    param,
                    commandType: CommandType.StoredProcedure
                );
            }
        }
       
        // for collection details : expect dbResponse and a table of multiple rows
        public (T1, List<T2>) ExecuteMultipleResult<T1, T2>(
                    string procName,
                    DynamicParameters param
               )
        {
            using (var conn = DbConnectionFactory.Create())
            {
                using (var multi = conn.QueryMultiple(procName, param, commandType: CommandType.StoredProcedure))
                {
                    var dbResponse = multi.Read<T1>().FirstOrDefault();
                    var collectionDetails = multi.Read<T2>().ToList();

                    return (dbResponse, collectionDetails);
                }
            }
        }

    }
}