/**
 * @schema subscription
 * Contains tables for managing accounts, subscriptions, and multi-tenancy.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'subscription')
BEGIN
    EXEC('CREATE SCHEMA subscription');
END
GO

-- FEATURE INTEGRATION POINT
-- Account and subscription plan tables will be defined here.
