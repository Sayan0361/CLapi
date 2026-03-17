ALTER PROC [dbo].[sp_UpsertResponse]
(
    @userId INT,
    @methodId INT,
    @collectionId INT, 
    @requestName VARCHAR(100) = 'Untitled',
    @requestURL VARCHAR(100),
    @body VARCHAR(MAX),
    @response VARCHAR(MAX),
    @statusCode INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate User
        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Users WHERE userId = @userId
        )
        BEGIN
            SELECT 0, 'User not found. Please signup and login.', NULL;
            RETURN;
        END

        -- Validate Collection
        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Collections 
            WHERE collectionId = @collectionId AND userId = @userId
        )
        BEGIN
            SELECT 0, 'Invalid collection.', NULL;
            RETURN;
        END

        -- HANDLE DUPLICATE NAME IN COLLECTION
        DECLARE @finalName VARCHAR(100) = @requestName;
        DECLARE @counter INT = 1;

        WHILE EXISTS (
            SELECT 1
            FROM tbl_CollectionRequests cr
            JOIN tbl_Request r ON cr.reqId = r.reqId
            WHERE cr.collectionId = @collectionId
              AND r.methodId = @methodId
              AND r.requestName = @finalName
        )
        BEGIN
            SET @finalName = @requestName + ' (' + CAST(@counter AS VARCHAR) + ')';
            SET @counter = @counter + 1;
        END

        -- UPSERT LOGIC
        DECLARE @reqId INT;

        SELECT @reqId = reqId
        FROM dbo.tbl_Request
        WHERE 
            userId = @userId
            AND methodId = @methodId
            AND requestURL = @requestURL
            AND ISNULL(body, '') = ISNULL(@body, '');

        IF @reqId IS NOT NULL
        BEGIN
            UPDATE dbo.tbl_Request
            SET 
                response = @response,
                statusCode = @statusCode
            WHERE reqId = @reqId;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.tbl_Request
            (
                userId,
                methodId,
                requestName,
                requestURL,
                body,
                response,
                statusCode
            )
            VALUES
            (
                @userId,
                @methodId,
                @finalName, 
                @requestURL,
                @body,
                @response,
                @statusCode
            );

            SET @reqId = SCOPE_IDENTITY();

            -- MAP TO COLLECTION
            INSERT INTO tbl_CollectionRequests (collectionId, reqId)
            VALUES (@collectionId, @reqId);
        END


        --  SUCCESS RESPONSE
        SELECT 
            1 AS Success,
            'Success' AS Message,
            @reqId AS Data;

    END TRY
    BEGIN CATCH

        SELECT 
            0 AS Success,
            ERROR_MESSAGE() AS Message,
            NULL AS Data;

    END CATCH

END