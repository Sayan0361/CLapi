CREATE OR ALTER PROC sp_InsertEnvById
    @variableKey nvarchar(200),
    @variableValue nvarchar(MAX),
    @userId int,
    @collectionId int,
    @scope nvarchar(20)
AS
BEGIN

    -- Validate User
    IF NOT EXISTS (
        SELECT 1 FROM tbl_Users WHERE userId = @userId
    )
    BEGIN
        SELECT 0 AS SUCCESS, 'No such User found!' AS MESSAGE;
        RETURN;
    END

    -- Validate inputs
    IF @variableKey IS NULL OR LTRIM(RTRIM(@variableKey)) = ''
       OR @variableValue IS NULL OR LTRIM(RTRIM(@variableValue)) = ''
    BEGIN
        SELECT 0 AS SUCCESS, 'Variable key or value is missing' AS MESSAGE;
        RETURN;
    END

    -- Validate Scope
    IF @scope IS NULL OR UPPER(LTRIM(RTRIM(@scope))) NOT IN ('GLOBAL', 'LOCAL')
    BEGIN
        SELECT 0 AS SUCCESS, 'Scope must be GLOBAL or LOCAL' AS MESSAGE;
        RETURN;
    END

    -- LOCAL scope requires collectionId
    IF @scope = 'LOCAL' AND (@collectionId IS NULL OR @collectionId = 0)
    BEGIN
        SELECT 0 AS SUCCESS, 'CollectionId is required for LOCAL scope' AS MESSAGE;
        RETURN;
    END

	/**
	-- If Key is already there in global scope, one cannot add the same key in local scope
	IF @scope = 'LOCAL'
	BEGIN
		IF EXISTS (
			SELECT 1 FROM tbl_Environment env
			WHERE env.scope = 'GLOBAL'
			AND env.variableKey = @variableKey
			AND env.userId = @userId
		)
		BEGIN
			SELECT 0 AS SUCCESS, 'Such variable key already exists in Global scope' AS MESSAGE;
			RETURN;
		END
	END

	-- If Key is already there in local scope, one cannot add the same key in global scope
	IF @scope = 'GLOBAL'
	BEGIN
		IF EXISTS (
			SELECT 1 FROM tbl_Environment env
			WHERE env.scope = 'LOCAL'
			AND env.variableKey = @variableKey
			AND env.userId = @userId
			AND env.collectionId = @collectionId
		)
		BEGIN
			SELECT 0 AS SUCCESS, 'Such variable key already exists in Local scope' AS MESSAGE;
			RETURN;
		END
	END
	**/

    -- Normalize collectionId for GLOBAL
    IF @scope = 'GLOBAL'
    BEGIN
        SET @collectionId = NULL;
    END

    -- Check if exists (FIXED)
    IF EXISTS(
        SELECT 1
        FROM tbl_Environment
        WHERE userId = @userId
        AND variableKey = @variableKey
        AND (
            (@collectionId IS NULL AND collectionId IS NULL)
            OR collectionId = @collectionId
        )
    )
    BEGIN
        -- Update (FIXED NULL handling)
        UPDATE tbl_Environment
        SET variableValue = @variableValue,
            scope = @scope
        WHERE userId = @userId
        AND variableKey = @variableKey
        AND (
            (@collectionId IS NULL AND collectionId IS NULL)
            OR collectionId = @collectionId
        );

        SELECT 1 AS SUCCESS, 'Env variable updated' AS MESSAGE;
        RETURN;
    END

    -- Insert
    INSERT INTO tbl_Environment(
        variableKey,
        variableValue,
        userId,
        collectionId,
        scope
    )
    VALUES(
        @variableKey,
        @variableValue,
        @userId,
        @collectionId,
        @scope
    );

    SELECT 1 AS SUCCESS, 'Env created successfully' AS MESSAGE;

END;
