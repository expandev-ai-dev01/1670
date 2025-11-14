/**
 * @summary
 * Handles database updates after a successful login. It resets the failed login attempts counter,
 * logs the successful attempt, and creates a new user session.
 * 
 * @procedure spLoginSuccess
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {INT} idUserAccount 
 *   - Required: Yes
 *   - Description: The ID of the user who logged in successfully.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address from which the login occurred.
 * @param {NVARCHAR(512)} userAgent
 *   - Required: Yes
 *   - Description: The user agent of the client.
 * @param {NVARCHAR(1024)} token
 *   - Required: Yes
 *   - Description: The JWT generated for the session.
 * @param {DATETIME2} expiresAt
 *   - Required: Yes
 *   - Description: The expiration timestamp of the token.
 */
CREATE OR ALTER PROCEDURE [security].[spLoginSuccess]
    @idUserAccount INT,
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(512),
    @token NVARCHAR(1024),
    @expiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Reset failed login attempts and unlock account if it was locked
        UPDATE [security].[userAccount]
        SET 
            [failedLoginAttempts] = 0,
            [lockedUntil] = NULL,
            [dateModified] = GETUTCDATE()
        WHERE 
            [idUserAccount] = @idUserAccount;

        -- Log the successful attempt
        INSERT INTO [security].[loginAttempt] 
            ([idUserAccount], [emailAttempt], [ipAddress], [userAgent], [wasSuccess])
        SELECT 
            @idUserAccount, 
            [usr].[email], 
            @ipAddress, 
            @userAgent, 
            1
        FROM [security].[userAccount] [usr]
        WHERE [usr].[idUserAccount] = @idUserAccount;

        -- Create a new session record
        INSERT INTO [security].[userSession]
            ([idUserAccount], [token], [ipAddress], [userAgent], [expiresAt])
        VALUES
            (@idUserAccount, @token, @ipAddress, @userAgent, @expiresAt);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO
