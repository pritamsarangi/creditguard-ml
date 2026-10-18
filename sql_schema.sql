IF DB_ID(N'CreditGuard') IS NULL
BEGIN
    CREATE DATABASE CreditGuard;
END
GO

USE CreditGuard;
GO

IF OBJECT_ID(N'dbo.predictions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.predictions (
        id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        model_name NVARCHAR(64) NOT NULL,
        model_version NVARCHAR(32) NOT NULL,
        default_probability FLOAT NOT NULL,
        predicted_default INT NOT NULL,
        risk_band NVARCHAR(16) NOT NULL,
        input_payload NVARCHAR(MAX) NOT NULL,
        factors_json NVARCHAR(MAX) NOT NULL,
        disclaimer NVARCHAR(MAX) NOT NULL
    );
END
GO

USE CreditGuard;
GO

SELECT name
FROM sys.tables;

USE CreditGuard;
GO

SELECT *
FROM predictions
ORDER BY id DESC;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('users', 'email_otps', 'predictions');

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'predictions'
AND COLUMN_NAME = 'user_id';

USE CreditGuard;

SELECT TOP 5
    id,
    email,
    created_at,
    expires_at,
    attempts,
    consumed_at
FROM dbo.email_otps
ORDER BY id DESC;

USE CreditGuard;

SELECT id, email, is_active, created_at
FROM dbo.users;

SELECT TOP 5
    id,
    email,
    attempts,
    consumed_at
FROM dbo.email_otps
ORDER BY id DESC;


USE CreditGuard;

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'auth_sessions';

USE CreditGuard;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'auth_sessions'
ORDER BY ORDINAL_POSITION;

USE CreditGuard;

SELECT TOP 10
    id,
    user_id,
    created_at,
    expires_at,
    revoked_at
FROM dbo.auth_sessions
ORDER BY id DESC;

USE CreditGuard;

SELECT TOP 10
    id,
    user_id,
    model_name,
    risk_band,
    created_at
FROM dbo.predictions
ORDER BY id DESC;