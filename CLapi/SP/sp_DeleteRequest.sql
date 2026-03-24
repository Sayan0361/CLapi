CREATE OR ALTER PROC sp_DeleteRequest
(
    @userId INT,
    @reqId INT,
    @collectionId INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate ownership
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.tbl_Request
            WHERE userId = @userId 
              AND reqId = @reqId
        )
        BEGIN 
            SELECT 
                0 AS Success,
                'Unauthorised Access! You cannot delete this request' AS Message,
                NULL AS Data;
            RETURN;
        END

        BEGIN TRAN;

        -- If collectionId is provided → remove only mapping
        IF @collectionId IS NOT NULL
        BEGIN
            DELETE FROM dbo.tbl_CollectionRequests
            WHERE reqId = @reqId
              AND collectionId = @collectionId;
        END
        ELSE
        BEGIN
            -- Remove from all collections
            DELETE FROM dbo.tbl_CollectionRequests
            WHERE reqId = @reqId;
        END

        -- Check if request still belongs to any collection
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.tbl_CollectionRequests
            WHERE reqId = @reqId
        )
        BEGIN
            -- Delete request
            DELETE FROM dbo.tbl_Request
            WHERE reqId = @reqId;
        END

        COMMIT;

        SELECT 
            1 AS Success,
            'Request deleted successfully' AS Message,
            NULL AS Data;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0 ROLLBACK;

        SELECT 
            0 AS Success,
            ERROR_MESSAGE() AS Message,
            NULL AS Data;

    END CATCH

END
GO