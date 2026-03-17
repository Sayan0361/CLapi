INSERT INTO tbl_Users (userName, email, hashedPassword)
VALUES 
('Sayan', 'sayan@test.com', 'hashed123'),
('John', 'john@test.com', 'hashed456');

INSERT INTO tbl_Collections (collectionName, userId)
VALUES 
('Auth APIs', 1),
('User APIs', 1),
('Test APIs', 2);

INSERT INTO tbl_Request 
(userId, methodId, requestName, requestURL, body, response, statusCode)
VALUES
-- Auth APIs
(1, 2, 'Login', 'https://api.test.com/login', '{ "user":"test" }', 'OK', 200),
(1, 2, 'Register', 'https://api.test.com/register', '{ "user":"new" }', 'Created', 201),

-- User APIs
(1, 1, 'Get Profile', 'https://api.test.com/profile', NULL, 'OK', 200),

-- Test APIs (user 2)
(2, 1, 'Ping', 'https://api.test.com/ping', NULL, 'Pong', 200);

INSERT INTO tbl_CollectionRequests (collectionId, reqId)
VALUES
-- Auth APIs (collectionId = 1)
(1, 1),
(1, 2),

-- User APIs (collectionId = 2)
(2, 3),

-- Test APIs (collectionId = 3)
(3, 4);
