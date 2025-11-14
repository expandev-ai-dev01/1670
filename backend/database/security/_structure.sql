/**
 * @schema security
 * Contains tables for authentication, authorization, users, roles, and permissions.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
BEGIN
    EXEC('CREATE SCHEMA security');
END
GO

-- FEATURE INTEGRATION POINT
-- User, role, and permission tables will be defined here.
