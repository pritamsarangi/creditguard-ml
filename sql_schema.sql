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