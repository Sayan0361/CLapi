using CLapi.DAL;
using CLapi.Models;
using Dapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;

namespace CLapi.Controllers
{
    public class AuthController : Controller
    {
        // GET: Auth/SignUp
        [HttpGet]
        public ActionResult SignUp()
        {
            return View();
        }

        [HttpPost]
        public JsonResult SignUp(UsersModel model)
        {
            if(model == null)
            {
                return Json(
                    new
                    {
                        Success = false,
                        StatusCode = 400,
                        Message = "Fields missing",
                        Data = new { },
                        Error = "",
                    }
                );
            }

            DynamicParameters param = new DynamicParameters();

            string PasswordHash = BCrypt.Net.BCrypt.HashPassword(model.HashedPassword);

            param.Add("@userName", model.UserName);
            param.Add("@email", model.Email);
            param.Add("@hashedPassword", PasswordHash);

            UsersDAL user = new UsersDAL();
            try
            {
                var result = user.SignUp(param);

                if(result.SUCCESS == 1)
                {
                    return Json(
                        new
                        {
                            success = true,
                            StatusCode = 201,
                            Message = result.MESSAGE.ToString(),
                            Data = new { },
                            Error = "",
                        }
                    );
                }
                else
                {
                    return Json(
                        new
                        {
                            success = false,
                            StatusCode = 409,
                            Message = result.MESSAGE.ToString(),
                            Data = new { },
                            Error = "",
                        }
                    );
                }

                
            }
            catch(Exception ex)
            {
                return Json(
                   new
                   {
                       success = false,
                       StatusCode = 500,
                       Message = ex.Message,
                       Data = new { },
                       Error = "",
                   }
               );
            }

        }

        [HttpGet]
        public ActionResult LogIn()
        {
            return View();
        }

        [HttpPost]
        public JsonResult LogIn(UsersModel model)
        {
            if (model == null)
            {
                return Json(new
                {
                    success = false,
                    statusCode = 400,
                    message = "Fields missing",
                    data = new { },
                    error = ""
                });
            }

            DynamicParameters param = new DynamicParameters();
            param.Add("@email", model.Email);

            UsersDAL user = new UsersDAL();

            try
            {
                var result = user.LogIn(param);

                // Email not found
                if (result.DbResponse.SUCCESS == 0)
                {
                    return Json(new
                    {
                        success = false,
                        statusCode = 404,
                        message = result.DbResponse.MESSAGE,
                        data = new { },
                        error = ""
                    });
                }

                bool isValid = BCrypt.Net.BCrypt.Verify(
                    model.HashedPassword,              // plain password from user
                    result.HashedPassword             // hash from DB
                );

                if (!isValid)
                {
                    return Json(new
                    {
                        success = false,
                        statusCode = 401,
                        message = "Invalid password",
                        data = new { },
                        error = ""
                    });
                }

                // Success
                return Json(new
                {
                    success = true,
                    statusCode = 200,
                    message = "Login successful",
                    data = new
                    {
                        UserId = result.UserId,
                        UserName = result.UserName,
                        Email = result.Email,
                        CreatedAt = result.CreatedAt
                    },
                    error = ""
                });
            }
            catch (Exception)
            {
                return Json(new
                {
                    success = false,
                    statusCode = 500,
                    message = "Something went wrong",
                    data = new { },
                    error = "Internal server error"
                });
            }
        }
    }
}