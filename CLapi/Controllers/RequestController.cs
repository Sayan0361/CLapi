using CLapi.DAL;
using CLapi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CLapi.Controllers
{
    public class RequestController : Controller
    {
        // GET: Request
        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public JsonResult SaveRequest(RequestModel request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values
                    .SelectMany(v => v.Errors)
                    .Select(e => e.ErrorMessage)
                    .ToList();

                return Json(new
                {
                    Success = 0,
                    Message = string.Join(", ", errors)
                });
            }

            RequestDAL dal = new RequestDAL();
            var result = dal.SaveResponse(request);

            return Json(result);
        }
    }
}