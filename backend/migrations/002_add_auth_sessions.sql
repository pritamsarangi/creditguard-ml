
USE CreditGuard;
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('dbo.auth_sessions', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.auth_sessions (
            id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,

            user_id INT NOT NULL,

            token_hash VARCHAR(64) NOT NULL,

            created_at DATETIME2 NOT NULL
                CONSTRAINT DF_auth_sessions_created_at
                DEFAULT SYSUTCDATETIME(),

            expires_at DATETIME2 NOT NULL,

            revoked_at DATETIME2 NULL,

            CONSTRAINT FK_auth_sessions_users
                FOREIGN KEY (user_id)
                REFERENCES dbo.users(id),

            CONSTRAINT UQ_auth_sessions_token_hash
                UNIQUE (token_hash)
        );

        CREATE INDEX ix_auth_sessions_user_id
        ON dbo.auth_sessions(user_id);
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
