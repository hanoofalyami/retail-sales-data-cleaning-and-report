/*
===============================================================================
Load Script: Load Data into Silver Layer
===============================================================================
Script Purpose:
    This script loads data from 'bronze.retail_store_sales' into
    'silver.retail_store_sales' after cleaning and type conversion.

Transformations:
    - Replace missing item with 'unknown'.
    - Derive missing price_per_unit from total_spent / quantity.
    - Convert transaction_date from text to DATE.

Note:
    Rows with missing quantity and total_spent (604 rows) are kept as NULL on purpose.
===============================================================================
*/

/** silver load **/

INSERT INTO silver.retail_store_sales (
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
)
SELECT
    transaction_id,
    customer_id,
    category,
    COALESCE(item, 'unknown') AS item,         -- Replace missing item with 'unknown'
    CASE
        WHEN price_per_unit IS NULL
             AND quantity > 0
             AND total_spent IS NOT NULL
        THEN total_spent / NULLIF(quantity, 0) -- Derive missing price from total_spent / quantity
        ELSE price_per_unit
    END                       AS price_per_unit,
    quantity,
    total_spent,
    payment_method,
    location,
    TRY_CAST(transaction_date AS DATE) AS transaction_date, -- Convert text to DATE safely
    discount_applied
FROM bronze.retail_store_sales;
GO

-- Check the loaded data
SELECT
    *
FROM
    silver.retail_store_sales;
