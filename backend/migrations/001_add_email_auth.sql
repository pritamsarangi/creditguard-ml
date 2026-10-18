
-- CreditGuard migration 001
-- Target: Microsoft SQL Server
-- Backup your database before applying.

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.users', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.users (
            id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            email VARCHAR(254) NOT NULL,
            is_active BIT NOT NULL
                CONSTRAINT DF_users_is_active DEFAULT 1,
            created_at DATETIME2 NOT NULL
                CONSTRAINT DF_users_created_at
                DEFAULT SYSUTCDATETIME(),

            CONSTRAINT UQ_users_email UNIQUE (email)
        );
    END;

    IF OBJECT_ID('dbo.email_otps', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.email_otps (
            id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            email VARCHAR(254) NOT NULL,
            code_hash VARCHAR(64) NOT NULL,
            expires_at DATETIME2 NOT NULL,
            created_at DATETIME2 NOT NULL
                CONSTRAINT DF_email_otps_created_at
                DEFAULT SYSUTCDATETIME(),
            attempts INT NOT NULL
                CONSTRAINT DF_email_otps_attempts DEFAULT 0,
            consumed_at DATETIME2 NULL,

            CONSTRAINT CK_email_otps_attempts
                CHECK (attempts >= 0)
        );

        CREATE INDEX ix_email_otps_email_created_at
        ON dbo.email_otps(email, created_at);
    END;

    IF COL_LENGTH('dbo.predictions', 'user_id') IS NULL
    BEGIN
        ALTER TABLE dbo.predictions
        ADD user_id INT NULL;
    END;

    IF NOT EXISTS (
        SELECT 1 FROM sys.foreign_keys
        WHERE name = 'FK_predictions_users'
    )
    BEGIN
        ALTER TABLE dbo.predictions
        ADD CONSTRAINT FK_predictions_users
        FOREIGN KEY (user_id)
        REFERENCES dbo.users(id);
    END;

    IF NOT EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE name = 'ix_predictions_user_id'
          AND object_id = OBJECT_ID('dbo.predictions')
    )
    BEGIN
        CREATE INDEX ix_predictions_user_id
        ON dbo.predictions(user_id);
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
