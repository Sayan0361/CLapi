USE [CLapiDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllCollectionsRequestsByUserID]    Script Date: 3/17/2026 2:47:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROC [dbo].[sp_GetAllCollectionsRequestsByUserID] (
	@userId int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (
		SELECT 1 FROM dbo.tbl_Users 
		WHERE userId = @userId
	)
	BEGIN
		SELECT 
			0 AS Success,
			'User not found! Please SignIn to continue' AS Message,
			NULL AS Data;

		RETURN;
	END

	SELECT 
		1 AS Success,
		'Request Data Found' AS Message,
		NULL AS Data;

	SELECT 
		c.collectionId,
		c.collectionName,
		r.reqId,
		r.requestName,
		r.requestURL,
		r.statusCode,
		m.methodType
	FROM tbl_Collections c
	LEFT JOIN tbl_CollectionRequests cr 
		ON c.collectionId = cr.collectionId
	LEFT JOIN tbl_Request r 
		ON cr.reqId = r.reqId
	LEFT JOIN tbl_method m 
		ON r.methodId = m.methodId
	WHERE c.userId = @userId
	ORDER BY c.collectionName ASC;
END
