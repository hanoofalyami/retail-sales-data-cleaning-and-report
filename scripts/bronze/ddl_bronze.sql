/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'retail_store_ETL' after checking if it already exists.
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
    within the database: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will drop the entire 'retail_store_ETL' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

-- Switch to the master database, required to create or drop other databases
USE master;
GO

-- Drop and recreate the 'retail_store_ETL' database
-- Check if the database already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'retail_store_ETL')
BEGIN
    -- Disconnect all other users and roll back their open transactions so the drop does not fail
    ALTER DATABASE retail_store_ETL SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    -- Delete the existing database and all its data
    DROP DATABASE retail_store_ETL;
END;
GO

-- Create a fresh 'retail_store_ETL' database
CREATE DATABASE retail_store_ETL;
GO

-- Switch to the new database so the schemas are created inside it
USE retail_store_ETL;
GO

-- Create Schemas (each CREATE SCHEMA must run in its own batch, hence the GO)

-- Bronze: raw data loaded as-is from the source CSV
CREATE SCHEMA bronze;
GO

-- Silver: cleaned data with correct data types
CREATE SCHEMA silver;
GO

-- Gold: reporting views consumed by Power BI
CREATE SCHEMA gold;
GO

-- Verify: should return 3 rows (bronze, silver, gold)
USE retail_store_ETL;
SELECT name
FROM sys.schemas
WHERE name IN ('bronze', 'silver', 'gold');
