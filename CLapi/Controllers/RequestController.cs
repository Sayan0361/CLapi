using CLapi.DAL;
using CLapi.Models;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
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
        public JsonResult SaveRequestToCollection(RequestModel request)
        {
            if (!ModelState.IsValid)
            {
                return Json(new DBResponseModel<object>
                {
                    Success = 0,
                    Message = string.Join(", ",
                        ModelState.Values.SelectMany(v => v.Errors)
                                         .Select(e => e.ErrorMessage))
                });
            }

            RequestDAL dal = new RequestDAL();
            var result = dal.SaveRequest(request);

            return Json(result);
        }

        [HttpPost]
        public async Task<JsonResult> SendPostRequest(RequestModel request)
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

            Dictionary<int, string> methodMap = new Dictionary<int, string>
            {
                {1,  "GET"},
                {2, "POST"},
                {3, "PUT"},
                {4,  "DELETE"}
            };

            // Sending Request Here
            using (HttpClient client = new HttpClient())
            {
                if (!methodMap.ContainsKey(request.MethodId))
                {
                    return Json(new { Success = 0, Message = "Invalid Method" });
                }

                var methodString = methodMap[request.MethodId];

                var httpMethod = new HttpMethod(methodString);

                var requestMessage = new HttpRequestMessage(httpMethod, request.RequestURL);

                // Add body only when needed
                if (methodString == "POST" || methodString == "PUT" || methodString == "DELETE")
                {
                    requestMessage.Content = new StringContent(
                        request.Body ?? "",
                        Encoding.UTF8,
                        "application/json"
                    );
                }

                HttpResponseMessage response = await client.SendAsync(requestMessage);

                string result = await response.Content.ReadAsStringAsync();

                return Json(new
                {
                    Success = 1,
                    StatusCode = (int)response.StatusCode,
                    Body = result
                });
            }
        }

        [HttpPost]
        public JsonResult CreateNewCollection(CollectionModel collection)
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

            CollectionDAL collectionDAL = new CollectionDAL();
            var response = collectionDAL.addOrEditCollection(
                collection.collectionName,
                collection.UserId
            );

            return Json(response);
        }

        [HttpPost]
        public JsonResult DeleteCollection(int userId, int collectionId)
        {
            CollectionDAL collectionDAL = new CollectionDAL();
            var response = collectionDAL.deleteCollection(userId,collectionId);
            return Json(response);
        }
    }
}