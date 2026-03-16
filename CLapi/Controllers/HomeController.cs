using CLapi.DAL;
using CLapi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CLapi.Controllers
{
    public class HomeController : Controller
    {
        private readonly MethodDAL methodDAL;

        public HomeController()
        {
            methodDAL = new MethodDAL();
        }

        public ActionResult Index()
        {
            List<Method> methods = methodDAL.GetAllMethods();
            return View(methods);
        }
        // Test your DB connection
        public ContentResult TestDb()
        {
            try
            {
                using (var conn = DbConnectionFactory.Create())
                {
                    conn.Open();
                    return Content("DB Connected Successfully");
                }
            }
            catch (Exception ex)
            {
                return Content(ex.Message);
            }
        }
    }
}