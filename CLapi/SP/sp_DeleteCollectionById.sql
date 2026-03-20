USE [CLapiDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteCollectionById]    Script Date: 3/20/2026 10:16:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER   PROCEDURE [dbo].[sp_DeleteCollectionById]
(
    @userId INT,
    @collectionId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
		
		IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_CollectionRequests
            WHERE collectionId = @collectionId
        )
        BEGIN
            SELECT
                0 AS Success,
                'Such Collection does not exists' AS Message,
                NULL AS Data;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Users
            WHERE userId = @userId
        )
        BEGIN
            SELECT
                0 AS Success,
                'Unauthorised Access! User Not Found' AS Message,
                NULL AS Data;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Collections
            WHERE userId = @userId AND collectionId = @collectionId
        )
        BEGIN 
            SELECT
                0 AS Success,
                'Unauthorised Access! You are not allowed to delete this collection' AS Message,
                NULL AS Data;
            RETURN;
        END
        
		BEGIN TRAN;
			-- Delete Mapping First  
			DELETE FROM dbo.tbl_CollectionRequests
			WHERE collectionId = @collectionId;

			DELETE FROM dbo.tbl_Collections
			WHERE collectionId = @collectionId;

			SELECT
				1 AS Success,
				'Collection Deleted Successfully' AS Message,
				NULL AS Data;
		COMMIT; 

    END TRY
    BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK;

        SELECT
            0 AS Success,
            ERROR_MESSAGE() AS Message,
            NULL AS Data;
    END CATCH

END