/**
	If user is on global scope, 
		-> Get all env variables which have global scope only

	If user is on local scope,
		-> Get all the local variables and global variables
		-> If local variable = global variable, show local variable only and not global variable
**/

CREATE OR ALTER PROC sp_GetEnvDetails
    @userId INT,
    @collectionId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validate User
    IF NOT EXISTS (SELECT 1 FROM dbo.tbl_Users WHERE userId = @userId)
    BEGIN
        SELECT 0 AS Success, 'User not found' AS Message, NULL AS Data;
        RETURN;
    END

    -- 2. Fetch Data
    IF @collectionId IS NOT NULL  -- FIX: Changed from <> NULL
    BEGIN 
        -- Return LOCAL (with Global shadowing) for a specific collection
        SELECT 
            variableKey, 
            variableValue, 
            scope, 
            collectionId
        FROM tbl_Environment
        WHERE userId = @userId 
          AND collectionId = @collectionId 
          AND scope = 'LOCAL'

        UNION ALL

        SELECT 
            g.variableKey, 
            g.variableValue, 
            g.scope, 
            g.collectionId
        FROM tbl_Environment g
        WHERE g.userId = @userId 
          AND g.scope = 'GLOBAL'
          AND NOT EXISTS (
              SELECT 1 
              FROM tbl_Environment l
              WHERE l.userId = @userId 
                AND l.collectionId = @collectionId 
                AND l.variableKey = g.variableKey
                AND l.scope = 'LOCAL'
          );
    END
    ELSE
    BEGIN
        -- FIX: If no collection is provided, just show the User's GLOBAL variables
        SELECT 
            variableKey, 
            variableValue, 
            scope, 
            collectionId
        FROM tbl_Environment 
        WHERE userId = @userId 
          AND scope = 'GLOBAL';
    END
END