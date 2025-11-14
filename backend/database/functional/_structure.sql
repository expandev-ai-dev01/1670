/**
 * @schema functional
 * Contains tables related to the core business logic and entities of the application.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'functional')
BEGIN
    EXEC('CREATE SCHEMA functional');
END
GO

-- FEATURE INTEGRATION POINT
-- Business entity tables (e.g., products, orders) will be defined here.
