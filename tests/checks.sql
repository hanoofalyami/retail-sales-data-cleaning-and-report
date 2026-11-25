/*
===============================================================================
Data Quality Checks: bronze.retail_store_sales
===============================================================================
Script Purpose:
    This script runs data quality checks on every column of the bronze table
    before loading the Silver layer. It only reads data, nothing is modified.

Checks per column:
    - NULLs and empty values
    - Unwanted spaces
    - Distinct values and distribution
    - Zero / negative values and basic statistics (numeric columns)
    - Invalid or unconvertible values (date column)
===============================================================================
*/

USE retail_store_ETL;
GO


/* ===========================================================================
   1) transaction_id
   =========================================================================== */

-- Duplicates or NULLs (expected: no rows)
SELECT
    transaction_id,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1 OR transaction_id IS NULL;

-- Unwanted spaces (expected: no rows)
SELECT transaction_id
FROM bronze.retail_store_sales
WHERE transaction_id != TRIM(transaction_id);

-- View the numeric part of the ID (after the 4-character prefix)
SELECT
    SUBSTRING(transaction_id, 5, LEN(transaction_id)) AS transaction_id_number
FROM bronze.retail_store_sales;


/* ===========================================================================
   2) customer_id
   =========================================================================== */

-- NULLs (expected: 0)
SELECT COUNT(*) AS null_count
FROM bronze.retail_store_sales
WHERE customer_id IS NULL;

-- Unwanted spaces (expected: no rows)
SELECT *
FROM bronze.retail_store_sales
WHERE customer_id != TRIM(customer_id);

-- Distinct customers
SELECT DISTINCT customer_id
FROM bronze.retail_store_sales
ORDER BY customer_id;

-- Customers with more than one transaction (repeats are expected, not an error)
SELECT
    customer_id,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
GROUP BY customer_id
HAVING COUNT(*) > 1;


/* ===========================================================================
   3) category
   =========================================================================== */

-- Distinct values
SELECT DISTINCT category
FROM bronze.retail_store_sales;

-- NULLs
SELECT category
FROM bronze.retail_store_sales
WHERE category IS NULL;

-- Unwanted spaces
SELECT category
FROM bronze.retail_store_sales
WHERE category != TRIM(category);


/* ===========================================================================
   4) item
   =========================================================================== */

-- Distinct values
SELECT DISTINCT item
FROM bronze.retail_store_sales;

-- NULLs
SELECT item
FROM bronze.retail_store_sales
WHERE item IS NULL;

-- Unwanted spaces
SELECT item
FROM bronze.retail_store_sales
WHERE item != TRIM(item);

-- Empty values
SELECT COUNT(*) AS empty_items
FROM bronze.retail_store_sales
WHERE item = '';

-- NULL item and NULL price: counts and overlap
SELECT
    COUNT(*)                                                                  AS total_rows,
    COUNT(CASE WHEN item IS NULL THEN 1 END)                                  AS null_item,
    COUNT(CASE WHEN price_per_unit IS NULL THEN 1 END)                        AS null_price_per_unit,
    COUNT(CASE WHEN item IS NULL AND price_per_unit IS NULL THEN 1 END)       AS null_both
FROM bronze.retail_store_sales;


/* ===========================================================================
   5) price_per_unit
   =========================================================================== */

-- Rows with NULL price
SELECT *
FROM bronze.retail_store_sales
WHERE price_per_unit IS NULL
ORDER BY transaction_date ASC;

-- Distinct prices
SELECT DISTINCT price_per_unit
FROM bronze.retail_store_sales
ORDER BY price_per_unit;

-- Statistics
SELECT
    MIN(price_per_unit)   AS min_price_per_unit,
    MAX(price_per_unit)   AS max_price_per_unit,
    AVG(price_per_unit)   AS avg_price_per_unit,
    COUNT(price_per_unit) AS count_price_per_unit,
    COUNT(*)              AS total_rows
FROM bronze.retail_store_sales;

-- Can the missing price be derived? price = total_spent / quantity
SELECT
    quantity,
    total_spent,
    total_spent / NULLIF(quantity, 0) AS calculated_price
FROM bronze.retail_store_sales
WHERE price_per_unit IS NULL;


/* ===========================================================================
   6) quantity
   =========================================================================== */

-- NULLs
SELECT COUNT(*) AS null_count
FROM bronze.retail_store_sales
WHERE quantity IS NULL;

-- Zero values
SELECT COUNT(*) AS zero_count
FROM bronze.retail_store_sales
WHERE quantity = 0;

-- Negative values
SELECT COUNT(*) AS negative_count
FROM bronze.retail_store_sales
WHERE quantity < 0;

-- Statistics
SELECT
    MIN(quantity)   AS min_quantity,
    MAX(quantity)   AS max_quantity,
    AVG(quantity)   AS avg_quantity,
    COUNT(quantity) AS count_quantity,
    COUNT(*)        AS total_rows
FROM bronze.retail_store_sales;


/* ===========================================================================
   7) total_spent
   =========================================================================== */

-- NULLs
SELECT COUNT(*) AS null_count
FROM bronze.retail_store_sales
WHERE total_spent IS NULL;

-- Zero values
SELECT COUNT(*) AS zero_count
FROM bronze.retail_store_sales
WHERE total_spent = 0;

-- Negative values
SELECT COUNT(*) AS negative_count
FROM bronze.retail_store_sales
WHERE total_spent < 0;

-- Statistics
SELECT
    MIN(total_spent)   AS min_total_spent,
    MAX(total_spent)   AS max_total_spent,
    AVG(total_spent)   AS avg_total_spent,
    COUNT(total_spent) AS count_total_spent,
    COUNT(*)           AS total_rows
FROM bronze.retail_store_sales;

-- Distribution
SELECT
    total_spent,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
GROUP BY total_spent
ORDER BY total_spent;


/* ===========================================================================
   8) payment_method
   =========================================================================== */

-- Distinct values
SELECT DISTINCT payment_method
FROM bronze.retail_store_sales;

-- NULLs
SELECT COUNT(*) AS null_count
FROM bronze.retail_store_sales
WHERE payment_method IS NULL;

-- Unwanted spaces
SELECT payment_method
FROM bronze.retail_store_sales
WHERE payment_method != TRIM(payment_method);

-- Distribution
SELECT
    payment_method,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
GROUP BY payment_method
ORDER BY cnt DESC;


/* ===========================================================================
   9) location
   =========================================================================== */

-- Distinct values
SELECT DISTINCT location
FROM bronze.retail_store_sales;

-- NULLs
SELECT COUNT(*) AS null_count
FROM bronze.retail_store_sales
WHERE location IS NULL;

-- Unwanted spaces
SELECT location
FROM bronze.retail_store_sales
WHERE location != TRIM(location);

-- Distribution
SELECT
    location,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
GROUP BY location
ORDER BY cnt DESC;


/* ===========================================================================
   10) transaction_date
   =========================================================================== */

-- NULL, empty or placeholder values
SELECT COUNT(*) AS bad_values
FROM bronze.retail_store_sales
WHERE transaction_date IS NULL
   OR TRIM(transaction_date) = ''
   OR UPPER(TRIM(transaction_date)) IN ('ERROR', 'UNKNOWN', 'N/A', 'NULL');

-- Values that cannot be converted to DATE (excluding NULL and empty)
SELECT
    transaction_date,
    COUNT(*) AS cnt
FROM bronze.retail_store_sales
WHERE TRY_CAST(transaction_date AS DATE) IS NULL
  AND NULLIF(TRIM(transaction_date), '') IS NOT NULL
GROUP BY transaction_date
ORDER BY cnt DESC;

-- Unwanted spaces
SELECT transaction_date
FROM bronze.retail_store_sales
WHERE transaction_date != TRIM(transaction_date);
GO
