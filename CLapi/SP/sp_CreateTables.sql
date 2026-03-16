CREATE OR ALTER PROCEDURE sp_CreateTables
AS
BEGIN
    SET NOCOUNT ON;

    -- Users table
    CREATE TABLE tbl_Users(
        userId INT PRIMARY KEY IDENTITY(1,1),
        userName VARCHAR(100),
        email VARCHAR(100),
        hashedPassword VARCHAR(MAX),
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    -- HTTP Methods table
    CREATE TABLE tbl_method(
        methodId INT PRIMARY KEY IDENTITY(1,1),
        methodType VARCHAR(100)
    );

    -- Requests table
    CREATE TABLE tbl_Request(
        reqId INT PRIMARY KEY IDENTITY(1,1),
        userId INT,
        methodId INT,
        requestURL VARCHAR(100),
        body VARCHAR(MAX),
        response VARCHAR(MAX),
        statusCode INT,
        FOREIGN KEY (userId) REFERENCES tbl_Users(userId),
        FOREIGN KEY (methodId) REFERENCES tbl_method(methodId)
    );

    -- Collections table
    CREATE TABLE tbl_Collections(
        collectionId INT PRIMARY KEY IDENTITY(1,1),
        collectionName VARCHAR(100),
        userId INT,
        reqId INT,
        FOREIGN KEY (userId) REFERENCES tbl_Users(userId),
        FOREIGN KEY (reqId) REFERENCES tbl_Request(reqId)
    );

    -- Insert default HTTP methods
    INSERT INTO tbl_method (methodType)
    VALUES 
        ('GET'),
        ('POST'),
        ('PUT'),
        ('DELETE');

END;

exec sp_CreateTables;