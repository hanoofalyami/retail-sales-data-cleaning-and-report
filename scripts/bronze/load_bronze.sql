/*
===============================================================================
Load Script: Load Data into Bronze Layer
===============================================================================
Script Purpose:
    This script loads raw data from the external CSV file
    'retail_store_sales.csv' into the 'bronze.retail_store_sales' table
    using the BULK INSERT command.

    The data is loaded AS-IS, without any cleaning or transformation.
    All columns are stored as NVARCHAR, so dirty values such as 'ERROR',
    'UNKNOWN', and empty cells are preserved for handling in the Silver layer.

Process Steps:
    1. Truncate the bronze table to remove existing data (Full Load).
    2. Load all rows from the CSV file, skipping the header row.

WARNING:
    Running this script will delete all existing data in
    bronze.retail_store_sales before reloading it.
    The file path must be accessible from the SQL Server machine.
===============================================================================
*/

-- Switch to the project database
USE retail_store_ETL;
GO

-- Step 1: Empty the bronze table so the load can be re-run without duplicating rows (Full Load)
TRUNCATE TABLE bronze.retail_store_sales;
GO

-- Step 2: Load the raw CSV file into the bronze table
BULK INSERT bronze.retail_store_sales
FROM 'C:\data\Sales_Retail_project\retail_store_sales.csv'   -- Path is read by the SQL Server machine, not your PC
WITH (
    FIRSTROW        = 2,          -- Skip row 1 because it contains the column headers
    FIELDTERMINATOR = ',',        -- Columns are separated by commas
    ROWTERMINATOR   = '0x0d0a',   -- Rows end with CRLF (Windows line ending)
    TABLOCK                       -- Lock the table during the load for faster performance
);
GO

-- Step 3: Verify the load (expected: 12,575 rows)
SELECT COUNT(*) AS total_rows
FROM bronze.retail_store_sales;
GO
