/*
===============================================================================
DDL Script: Create Gold View
===============================================================================
*/

IF OBJECT_ID('gold.sales_report', 'V') IS NOT NULL
    DROP VIEW gold.sales_report;
GO

CREATE VIEW gold.sales_report AS
SELECT
    transaction_id,
    customer_id,
    category,
    item,
    price_per_unit,
    quantity,
    total_spent,
    payment_method,
    location,
    transaction_date,
    discount_applied
FROM silver.retail_store_sales;
GO
