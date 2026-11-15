/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.
      Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.retail_store_sales', 'U') IS NOT NULL
    DROP TABLE silver.retail_store_sales;
GO

CREATE TABLE silver.retail_store_sales (
    transaction_id    NVARCHAR(50),
    customer_id       NVARCHAR(50),
    category          NVARCHAR(100),
    item              NVARCHAR(100),
    price_per_unit    DECIMAL(18,2),
    quantity          DECIMAL(10,2),
    total_spent       DECIMAL(12,2),
    payment_method    NVARCHAR(50),
    location          NVARCHAR(50),
    transaction_date  DATE,
    discount_applied  NVARCHAR(50),
    dwh_create_date   DATETIME2 DEFAULT GETDATE()
);
GO
