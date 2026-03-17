CREATE OR ALTER PROC sp_SignUp
	@userName VARCHAR(100),
    @email VARCHAR(100),
	@hashedPassword VARCHAR(MAX)
AS
BEGIN
	-- Check if user already exists
	IF EXISTS (
		SELECT 1
		FROM dbo.tbl_Users
		where email = @email
	)

	BEGIN
		SELECT 0 AS SUCCESS, 'Email already exists' AS MESSAGE;
	END

	INSERT INTO dbo.tbl_Users (userName, email, hashedPassword)
    VALUES (@userName, @email, @hashedPassword);

    SELECT 1 AS SUCCESS, 'User created successfully' AS Message;
END;

exec sp_SignUp
	@userName = 'TestUser',
    @email = 'testCantLogIn@gmail.com',
	@hashedPassword = 'logInNotPossible';