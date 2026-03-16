using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.Configuration;

namespace CLapi.DAL
{
    public static class DbConnectionFactory
    {
        public static SqlConnection Create()
        {
            var connStr = ConfigurationManager.ConnectionStrings["DB"]?.ConnectionString;

            if (string.IsNullOrEmpty(connStr))
            {
                var localConfig = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "web.local.config");

                if (File.Exists(localConfig))
                {
                    var map = new ExeConfigurationFileMap { ExeConfigFilename = localConfig };
                    var config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

                    connStr = config.ConnectionStrings.ConnectionStrings["DB"]?.ConnectionString;
                }
            }

            if (string.IsNullOrEmpty(connStr))
                throw new Exception("Database connection string not found.");

            return new SqlConnection(connStr);
        }
    }
}