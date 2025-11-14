/**
 * @summary
 * Handles database updates after a failed login attempt. It increments the failed attempts counter,
 * locks the account if the threshold is reached, and logs the failed attempt.
 * 
 * @procedure spLoginFailure
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {NVARCHAR(255)} emailAttempt
 *   - Required: Yes
 *   - Description: The email address used in the failed login attempt.
 * @param {VARCHAR(45)} ipAddress
 *   - Required: Yes
 *   - Description: The IP address from which the attempt occurred.
 * @param {NVARCHAR(512)} userAgent
 *   - Required: Yes
 *   - Description: The user agent of the client.
 */
CREATE OR ALTER PROCEDURE [security].[spLoginFailure]
    @emailAttempt NVARCHAR(255),
    @ipAddress VARCHAR(45),
    @userAgent NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUserAccount INT;
    DECLARE @failedAttempts INT;
    DECLARE @lockoutMinutes INT = 15;
    DECLARE @maxFailedAttempts INT = 5;

    SELECT 
        @idUserAccount = [usr].[idUserAccount],
        @failedAttempts = [usr].[failedLoginAttempts]
    FROM [security].[userAccount] [usr]
    WHERE [usr].[email] = @emailAttempt;

    BEGIN TRY
        BEGIN TRAN;

        -- Log the failed attempt
        INSERT INTO [security].[loginAttempt] 
            ([idUserAccount], [emailAttempt], [ipAddress], [userAgent], [wasSuccess])
        VALUES 
            (@idUserAccount, @emailAttempt, @ipAddress, @userAgent, 0);

        -- If the user exists, update their failed attempts counter
        IF @idUserAccount IS NOT NULL
        BEGIN
            SET @failedAttempts = @failedAttempts + 1;

            IF @failedAttempts >= @maxFailedAttempts
            BEGIN
                -- Lock the account
                UPDATE [security].[userAccount]
                SET 
                    [failedLoginAttempts] = @failedAttempts,
                    [lockedUntil] = DATEADD(MINUTE, @lockoutMinutes, GETUTCDATE()),
                    [dateModified] = GETUTCDATE()
                WHERE 
                    [idUserAccount] = @idUserAccount;
            END
            ELSE
            BEGIN
                -- Just increment the counter
                UPDATE [security].[userAccount]
                SET 
                    [failedLoginAttempts] = @failedAttempts,
                    [dateModified] = GETUTCDATE()
                WHERE 
                    [idUserAccount] = @idUserAccount;
            END
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        THROW;
    END CATCH;
END;
GO
