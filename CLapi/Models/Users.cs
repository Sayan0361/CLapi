using CLapi.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace CLapi.Models
{
    public class UsersModel
    {
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string HashedPassword { get; set; }
        public DateTime CreatedAt { get; set; }
        public DbResponse  DbResponse { get; set; }
    }

    public class DbResponse
    {
        public int SUCCESS { get; set; }
        public string MESSAGE { get; set; }
    }
}

namespace CLapi.DAL
{
    public class UsersDAL
    {
        private readonly DapperConn _conn;

        public UsersDAL()
        {
            _conn = new DapperConn();
        }

        public DbResponse SignUp(DynamicParameters param)
        {
            try
            {
                DapperConn conn = new DapperConn();
                return conn.ExecuteSingle<DbResponse>("sp_SignUp", param);
            }
            catch(SqlException ex)
            {
                throw new Exception("Error Message from DB : "+ ex.Message);
            }
        }

        public UsersModel LogIn(DynamicParameters param)
        {
            try
            {
                DapperConn conn = new DapperConn();
                return conn.ExecuteSingle<UsersModel>("sp_LogIn", param);

            }catch(SqlException ex)
            {
                throw new Exception("Error Message from DB : " + ex.Message);
            }
        }
    }
}