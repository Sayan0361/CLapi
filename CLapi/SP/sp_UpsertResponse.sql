USE [CLapiDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_UpsertResponse]    Script Date: 3/26/2026 9:25:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- problems : no idea of requestId -> input requestId
-- when i already have a request called tests and i change the requestURL and/or method and/or requestName ,
-- a newly request called tests (1) is been created. :( WE SHOULD EDIT THE DETAILS

-- If collectionId is changed, therefore delete the existing request from the prev collection
-- and add this edited request to the new collection

ALTER PROC [dbo].[sp_UpsertResponse]
(
    @userId INT,
    @reqId INT = NULL,
    @methodId INT,
    @collectionId INT, 
    @requestName VARCHAR(100) = 'New Request',
    @requestURL NVARCHAR(MAX),
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
            SELECT 0 AS Success, 'User not found' AS Message, NULL AS Data;
            RETURN;
        END

        -- Validate Collection
        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Collections 
            WHERE collectionId = @collectionId AND userId = @userId
        )
        BEGIN
            SELECT 0 AS Success, 'Invalid collection' AS Message, NULL AS Data;
            RETURN;
        END

        BEGIN TRAN;

        -- Edit existing request
        IF @reqId IS NOT NULL
        BEGIN
            -- Update request
            UPDATE dbo.tbl_Request
            SET 
                methodId = @methodId,
                requestName = @requestName,
                requestURL = @requestURL,
                body = @body,
                response = @response,
                statusCode = @statusCode
            WHERE reqId = @reqId
              AND userId = @userId;

            -- If collection change
            IF NOT EXISTS (
                SELECT 1 FROM tbl_CollectionRequests
                WHERE reqId = @reqId AND collectionId = @collectionId
            )
            BEGIN
                -- Remove old mapping
                DELETE FROM tbl_CollectionRequests
                WHERE reqId = @reqId;

                -- Add new mapping
                INSERT INTO tbl_CollectionRequests (collectionId, reqId)
                VALUES (@collectionId, @reqId);
            END
        END

        -- New Request
        ELSE
        BEGIN
            DECLARE @finalName VARCHAR(100) = @requestName;
            DECLARE @counter INT = 1;

            WHILE EXISTS (
                SELECT 1
                FROM tbl_CollectionRequests cr
                JOIN tbl_Request r ON cr.reqId = r.reqId
                WHERE cr.collectionId = @collectionId
                  AND r.requestName = @finalName
            )
            BEGIN
                SET @finalName = @requestName + ' (' + CAST(@counter AS VARCHAR) + ')';
                SET @counter = @counter + 1;
            END

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

            INSERT INTO tbl_CollectionRequests (collectionId, reqId)
            VALUES (@collectionId, @reqId);
        END

        COMMIT;

        SELECT 
            1 AS Success,
            'Success' AS Message,
            @reqId AS Data;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK;

        SELECT 
            0 AS Success,
            ERROR_MESSAGE() AS Message,
            NULL AS Data;

    END CATCH

END