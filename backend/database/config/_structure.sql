/**
 * @schema config
 * Contains system-wide configuration, settings, and utility tables.
 */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'config')
BEGIN
    EXEC('CREATE SCHEMA config');
END
GO

-- FEATURE INTEGRATION POINT
-- Configuration tables will be defined here.
