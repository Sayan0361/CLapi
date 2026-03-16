using System;
using System.Data.SqlClient;

namespace CLapi.DAL
{
    public static class DbConnectionFactory
    {
        public static SqlConnection Create()
        {
            var connStr =
                Environment.GetEnvironmentVariable("CLAPI_DB_CONNECTION")
                ?? "Server=.;Database=CLapiDB;Trusted_Connection=True;";

            if (string.IsNullOrEmpty(connStr))
                throw new Exception("Database connection string not found.");

            return new SqlConnection(connStr);
        }
    }
}