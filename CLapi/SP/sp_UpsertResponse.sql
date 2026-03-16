CREATE OR ALTER PROC sp_UpsertResponse
(
    @userId INT,
    @methodId INT,
    @requestURL VARCHAR(100),
    @body VARCHAR(MAX),
    @response VARCHAR(MAX),
    @statusCode INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @reqId INT;

        SELECT @reqId = reqId
        FROM dbo.tbl_Request
        WHERE 
            userId = @userId
        AND methodId = @methodId
        AND requestURL = @requestURL
        AND body = @body;

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
                requestURL,
                body,
                response,
                statusCode
            )
            VALUES
            (
                @userId,
                @methodId,
                @requestURL,
                @body,
                @response,
                @statusCode
            );

            SET @reqId = SCOPE_IDENTITY();
        END

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
GO