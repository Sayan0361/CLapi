USE [CLapiDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateTables]    Script Date: 3/17/2026 12:01:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_CreateTables]
AS
BEGIN
    SET NOCOUNT ON;


    -- DROP TABLES (child → parent)
    IF OBJECT_ID('tbl_CollectionRequests', 'U') IS NOT NULL
        DROP TABLE tbl_CollectionRequests;

    IF OBJECT_ID('tbl_Collections', 'U') IS NOT NULL
        DROP TABLE tbl_Collections;

    IF OBJECT_ID('tbl_Request', 'U') IS NOT NULL
        DROP TABLE tbl_Request;

    IF OBJECT_ID('tbl_method', 'U') IS NOT NULL
        DROP TABLE tbl_method;

    IF OBJECT_ID('tbl_Users', 'U') IS NOT NULL
        DROP TABLE tbl_Users;

   -- CREATE TABLES

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
        requestName VARCHAR(100),
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

        FOREIGN KEY (userId) REFERENCES tbl_Users(userId)
    );

    -- Mapping table
    CREATE TABLE tbl_CollectionRequests(
        id INT PRIMARY KEY IDENTITY(1,1),
        collectionId INT,
        reqId INT,

        FOREIGN KEY (collectionId) REFERENCES tbl_Collections(collectionId),
        FOREIGN KEY (reqId) REFERENCES tbl_Request(reqId),

        CONSTRAINT UQ_Collection_Request UNIQUE (collectionId, reqId)
    );

    --  Seed Data
    INSERT INTO tbl_method (methodType)
    VALUES 
        ('GET'),
        ('POST'),
        ('PUT'),
        ('DELETE');

END;