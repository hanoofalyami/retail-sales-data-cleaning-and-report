# retail-sales-data-cleaning-and-report
# Retail Store Sales: Data Cleaning & Power BI Report

End-to-end retail sales analysis for **Veec Store**: data cleaning in SQL Server using a bronze/silver/gold (medallion) architecture, and an interactive Power BI dashboard.

![Dashboard Overview](images/dashboard_overview.png)

## Project Overview

This project takes a raw, messy retail sales dataset and turns it into a clean, analysis-ready model and a dashboard that answers basic business questions: how much are we selling, which categories perform best, and how do customers pay and where do they buy.

**Tools:** SQL Server, Power BI, DAX, GitHub

## Dataset

- **Source:** [Retail Store Sales: Dirty for Data Cleaning (Kaggle)](https://www.kaggle.com/datasets/ahmedmohamed2003/retail-store-sales-dirty-for-data-cleaning)
- **Size:** 12,575 transactions, 11 columns
- **Period:** 2022-01-01 to 2025-01-18
- **Note:** the data is synthetic and contains no personal information.

| Column | Description |
|---|---|
| transaction_id | Unique transaction ID |
| customer_id | Customer ID |
| category | Product category (8 categories) |
| item | Product name |
| price_per_unit | Unit price |
| quantity | Units sold |
| total_spent | Total amount of the transaction |
| payment_method | Cash, Credit Card, Digital Wallet |
| location | Online or In-store |
| transaction_date | Date of the transaction |
| discount_applied | Whether a discount was applied |

## Architecture

```
Raw CSV  ->  bronze (raw as loaded)  ->  silver (cleaned)  ->  gold (reporting view)  ->  Power BI
```

| Layer | Purpose |
|---|---|
| **Bronze** | Raw data loaded as-is, no transformations |
| **Silver** | Cleaned data with correct data types |
| **Gold** | `gold.sales_report` view used directly by Power BI |

## Data Cleaning Steps

Quality checks were run on every column (NULLs, zeros, negatives, spaces, distinct values, date ranges) before loading silver.

- **price_per_unit:** missing prices were recovered with `total_spent / quantity`.
- **item:** missing values replaced with `unknown` (1,213 rows).
- **transaction_date:** converted from text to `DATE` using `TRY_CAST`.
- **Duplicates:** no duplicate `transaction_id` found.
- **Categorical columns** (`category`, `payment_method`, `location`): checked, no inconsistencies.
- **Consistency check:** `total_spent = price_per_unit x quantity` holds for every row that has a value.

**Known data gaps (kept as NULL on purpose):**

- 604 rows have no `quantity` and no `total_spent`. They cannot be recovered because both are missing together.
- 4,199 rows have no `discount_applied` value.

Aggregations (`SUM`, `AVG`) ignore NULLs, so these rows do not distort the results.

## Dashboard

The Overview page includes:

- **KPI cards:** Total Revenue, Transactions, Total Quantity Sold, Average Order Value, each with a month-over-month (MoM) change.
- **Monthly Trend:** revenue by month.
- **Top 5 Revenue by Category:** best-performing categories.
- **Revenue by Payment Method:** donut chart.
- **Revenue by Location:** Online vs In-store.
- **Sales Analysis table:** revenue, quantity and transactions per category.
- **Slicers:** Year, Month Name and Month.
- **Report-level filter:** 2025 is excluded because only 18 days are available.

**Key DAX measures:** Total Revenue, Transactions, Total Quantity Sold, Average Order Value, and MoM % for each KPI.

```DAX
MoM % =
VAR _CM = [Total Revenue]
VAR _PM =
    CALCULATE(
        [Total Revenue],
        DATEADD('Date'[Date], -1, MONTH)
    )
RETURN
    DIVIDE(_CM - _PM, _PM)
```

A dedicated `Date` table (marked as a date table) is used for all time intelligence.

## Key Insights

- Revenue is spread very evenly across the 8 product categories, with no single category dominating.
- Online and In-store revenue are close, with Online slightly ahead.
- The three payment methods each account for roughly a third of revenue.
- Add 2 to 3 more findings from your own exploration of the dashboard.

**Data note:** the dataset ends on 2025-01-18, so 2025 only has 18 days of data. A report-level filter excludes 2025, so the dashboard covers 2022-01-01 to 2024-12-31 (12,362 transactions) and month-over-month changes are not distorted by an incomplete month.

## Repository Structure

```
.
├── data/              # raw and cleaned CSV files
├── sql/
│   ├── 01_ddl_bronze.sql
│   ├── 02_ddl_silver.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_load_silver.sql
│   └── 05_gold_view.sql
├── powerbi/           # .pbix file
├── images/            # dashboard screenshots
└── README.md
```

## How to Run

1. Create the schemas: `CREATE SCHEMA bronze; CREATE SCHEMA silver; CREATE SCHEMA gold;`
2. Run the bronze DDL and load the raw CSV.
3. Run the silver DDL and load script.
4. Create the gold view.
5. Open the `.pbix` file and point the data source to your SQL Server instance.

## Acknowledgments

The bronze/silver/gold (medallion) ETL structure and SQL scripting style follow the [SQL Data Warehouse Project](https://github.com/DataWithBaraa/sql-data-warehouse-project) by Baraa Khatib Salkini (Data With Baraa). The dataset, data-quality checks, cleaning logic, and the Power BI dashboard in this repository are my own work.

## Author

**Hanoof Alyami**
(https://www.linkedin.com/in/hanoof-alyami-2515a1255/)(#) | [GitHub](#)
