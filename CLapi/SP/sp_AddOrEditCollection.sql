USE [CLapiDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_AddOrEditCollection]    Script Date: 3/17/2026 5:23:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER  PROC [dbo].[sp_AddOrEditCollection]
(
    @collectionId INT = 0,
    @collectionName VARCHAR(100),
    @userId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validate User
        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_Users
            WHERE userId = @userId
        )
        BEGIN
            SELECT 
                0 AS Success,
                'User Not Found! Please login to continue' AS Message,
                NULL AS Data;
            RETURN;
        END

        -- Validate Name
        IF (@collectionName IS NULL OR LTRIM(RTRIM(@collectionName)) = '')
        BEGIN
            SELECT 
                0 AS Success,
                'Collection name cannot be empty' AS Message,
                NULL AS Data;
            RETURN;
        END

        DECLARE @finalName VARCHAR(100) = @collectionName;
        DECLARE @counter INT = 1;

        DECLARE @newId INT;

        -- EDIT FLOW
        IF (@collectionId > 0)
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM tbl_Collections
                WHERE collectionId = @collectionId AND userId = @userId
            )
            BEGIN
                SELECT 
                    0 AS Success,
                    'Collection not found' AS Message,
                    NULL AS Data;
                RETURN;
            END

            -- AUTO-RENAME LOOP (exclude self)
            WHILE EXISTS (
                SELECT 1 
                FROM tbl_Collections
                WHERE collectionName = @finalName
                AND userId = @userId
                AND collectionId <> @collectionId
            )
            BEGIN
                SET @finalName = @collectionName + ' (' + CAST(@counter AS VARCHAR) + ')';
                SET @counter = @counter + 1;
            END

            UPDATE tbl_Collections
            SET collectionName = @finalName
            WHERE collectionId = @collectionId;

            SET @newId = @collectionId;
        END

        -- ADD FLOW
        ELSE
        BEGIN
            -- AUTO-RENAME LOOP
            WHILE EXISTS (
                SELECT 1 
                FROM tbl_Collections
                WHERE collectionName = @finalName
                AND userId = @userId
            )
            BEGIN
                SET @finalName = @collectionName + ' (' + CAST(@counter AS VARCHAR) + ')';
                SET @counter = @counter + 1;
            END

            INSERT INTO tbl_Collections (collectionName, userId)
            VALUES (@finalName, @userId);

            SET @newId = SCOPE_IDENTITY();
        END

        -- SUCCESS
        SELECT 
            1 AS Success,
            'Collection saved successfully' AS Message,
            @newId AS Data;

    END TRY
    BEGIN CATCH
        SELECT 
            0 AS Success,
            ERROR_MESSAGE() AS Message,
            NULL AS Data;
    END CATCH

END