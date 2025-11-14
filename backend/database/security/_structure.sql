/**
 * @schema security
 * Contains tables for authentication, authorization, users, roles, and permissions.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

/**
 * @table userAccount Stores user account information, including credentials and status.
 * @multitenancy false
 * @softDelete false
 * @alias usr
 */
CREATE TABLE [security].[userAccount] (
  [idUserAccount] INTEGER IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [email] NVARCHAR(255) NOT NULL,
  [passwordHash] NVARCHAR(255) NOT NULL,
  [active] BIT NOT NULL,
  [lockedUntil] DATETIME2 NULL,
  [failedLoginAttempts] INTEGER NOT NULL,
  [dateCreated] DATETIME2 NOT NULL,
  [dateModified] DATETIME2 NOT NULL
);
GO

/**
 * @table userSession Manages active user sessions and their tokens.
 * @multitenancy false
 * @softDelete false
 * @alias uss
 */
CREATE TABLE [security].[userSession] (
    [idUserSession] INTEGER IDENTITY(1, 1) NOT NULL,
    [idUserAccount] INTEGER NOT NULL,
    [token] NVARCHAR(1024) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(512) NOT NULL,
    [expiresAt] DATETIME2 NOT NULL,
    [dateCreated] DATETIME2 NOT NULL
);
GO

/**
 * @table loginAttempt Logs all login attempts for security and auditing.
 * @multitenancy false
 * @softDelete false
 * @alias lga
 */
CREATE TABLE [security].[loginAttempt] (
    [idLoginAttempt] BIGINT IDENTITY(1, 1) NOT NULL,
    [idUserAccount] INTEGER NULL,
    [emailAttempt] NVARCHAR(255) NOT NULL,
    [ipAddress] VARCHAR(45) NOT NULL,
    [userAgent] NVARCHAR(512) NOT NULL,
    [wasSuccess] BIT NOT NULL,
    [dateAttempted] DATETIME2 NOT NULL
);
GO

-- Constraints for userAccount
/**
 * @primaryKey pkUserAccount
 * @keyType Object
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [pkUserAccount] PRIMARY KEY CLUSTERED ([idUserAccount]);
GO

/**
 * @index uqUserAccount_Email Ensures email addresses are unique for active accounts.
 * @type Search
 * @unique true
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqUserAccount_Email]
ON [security].[userAccount]([email]);
GO

/**
 * @default dfUserAccount_Active Sets the default value for the active column to true.
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_Active] DEFAULT (1) FOR [active];
GO

/**
 * @default dfUserAccount_FailedLoginAttempts Sets the default value for failed login attempts to 0.
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_FailedLoginAttempts] DEFAULT (0) FOR [failedLoginAttempts];
GO

/**
 * @default dfUserAccount_DateCreated Sets the default creation date to the current UTC time.
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

/**
 * @default dfUserAccount_DateModified Sets the default modification date to the current UTC time.
 */
ALTER TABLE [security].[userAccount]
ADD CONSTRAINT [dfUserAccount_DateModified] DEFAULT (GETUTCDATE()) FOR [dateModified];
GO

-- Constraints for userSession
/**
 * @primaryKey pkUserSession
 * @keyType Object
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [pkUserSession] PRIMARY KEY CLUSTERED ([idUserSession]);
GO

/**
 * @foreignKey fkUserSession_UserAccount Links the session to a user account.
 * @target security.userAccount
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [fkUserSession_UserAccount] FOREIGN KEY ([idUserAccount])
REFERENCES [security].[userAccount]([idUserAccount]);
GO

/**
 * @default dfUserSession_DateCreated Sets the default creation date to the current UTC time.
 */
ALTER TABLE [security].[userSession]
ADD CONSTRAINT [dfUserSession_DateCreated] DEFAULT (GETUTCDATE()) FOR [dateCreated];
GO

-- Constraints for loginAttempt
/**
 * @primaryKey pkLoginAttempt
 * @keyType Object
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [pkLoginAttempt] PRIMARY KEY CLUSTERED ([idLoginAttempt]);
GO

/**
 * @foreignKey fkLoginAttempt_UserAccount Links the login attempt to a user account if it exists.
 * @target security.userAccount
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [fkLoginAttempt_UserAccount] FOREIGN KEY ([idUserAccount])
REFERENCES [security].[userAccount]([idUserAccount]);
GO

/**
 * @default dfLoginAttempt_DateAttempted Sets the default attempt date to the current UTC time.
 */
ALTER TABLE [security].[loginAttempt]
ADD CONSTRAINT [dfLoginAttempt_DateAttempted] DEFAULT (GETUTCDATE()) FOR [dateAttempted];
GO
