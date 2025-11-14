/**
 * @summary
 * Retrieves user account details required for the login process based on the provided email address.
 * 
 * @procedure spUserAccountGetByEmail
 * @schema security
 * @type stored-procedure
 * 
 * @parameters
 * @param {NVARCHAR(255)} email 
 *   - Required: Yes
 *   - Description: The email address of the user to retrieve.
 * 
 * @returns
 * A single result set with the user's account information if found.
 * 
 * @output {UserAccountData, 1, n}
 * @column {INT} idUserAccount
 * @column {NVARCHAR(100)} name
 * @column {NVARCHAR(255)} email
 * @column {NVARCHAR(255)} passwordHash
 * @column {BIT} active
 * @column {DATETIME2} lockedUntil
 * @column {INT} failedLoginAttempts
 */
CREATE OR ALTER PROCEDURE [security].[spUserAccountGetByEmail]
    @email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [usr].[idUserAccount],
        [usr].[name],
        [usr].[email],
        [usr].[passwordHash],
        [usr].[active],
        [usr].[lockedUntil],
        [usr].[failedLoginAttempts]
    FROM
        [security].[userAccount] [usr]
    WHERE
        [usr].[email] = @email;
END;
GO
