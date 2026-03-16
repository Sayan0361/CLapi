using CLapi.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CLapi.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }
        // Test your DB connection
        public ContentResult TestDb()
        {
            using (var conn = DbConnectionFactory.Create())
            {
                conn.Open();
                return Content("DB Connected Successfully");
            }
        }
    }
}