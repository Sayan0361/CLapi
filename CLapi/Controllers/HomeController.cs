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
        private readonly CollectionDAL collectionDAL;
        public HomeController()
        {
            methodDAL = new MethodDAL();
            collectionDAL = new CollectionDAL();
        }

        public ActionResult Index()
        {
            CollectionDAL dal = new CollectionDAL();

            var details = dal.getDetails(1);
            return View(details);
        }
        public JsonResult GetMethods()
        {
            var methods = methodDAL.GetAllMethods();
            return Json(new { methods }, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult AddOrEditCollection(int collectionId, string collectionName, int userId)
        {
            var dbResponse = collectionDAL.addOrEditCollection(
                    collectionName,
                    userId,
                    collectionId
                );
            return Json(
                dbResponse,
                JsonRequestBehavior.AllowGet
            );
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