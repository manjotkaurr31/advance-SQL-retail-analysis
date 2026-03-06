-- database exploration
-- 1. List all tables & views and their corresponding types in the current database
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME, 
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_TYPE, TABLE_NAME;

-- 2 List of all implicit and explicit schemas
SELECT
    catalog_name,
    schema_name,
    schema_owner,
    default_character_set_name
FROM information_schema.schemata;

-- 3. List of all views in the current db (expected to return empty table since i didn't create any view)
SELECT
    table_catalog,
    table_schema,
    table_name,
    view_definition,
    check_option,
    is_updatable
FROM information_schema.views;

-- 4. List of all the columns that are being used as keys
SELECT
    constraint_catalog,
    constraint_schema,
    constraint_name,
    table_catalog,
    table_schema,
    table_name,
    column_name,
    ordinal_position
FROM information_schema.key_column_usage;

-- 5. List of check constraints (check the data content before letting it enter the table)
SELECT
    constraint_catalog,
    constraint_schema,
    constraint_name,
    check_clause
FROM information_schema.check_constraints;

-- 6. List of all the columns from explicit tables across the db along with relevant metadata
SELECT
    table_catalog,
    table_schema,
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns;

-- 7. List of all columns that use domains (user defined data types). Expected to return empty table
SELECT
    domain_catalog,
    domain_schema,
    domain_name,
    table_catalog,
    table_schema,
    table_name,
    column_name
FROM information_schema.column_domain_usage;

-- 8. List of all parameters (@parameters used to make generic stored procedures dynamic at run time). Expected to return implicit parameters only.
SELECT
    specific_catalog,
    specific_schema,
    specific_name,
    ordinal_position,
    parameter_mode,
    parameter_name,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale
FROM information_schema.parameters;

/* moving toward table-specific exploration*/

            /*
                - List of all columns in a table
                - List of all constraints
                - type of indexing followed by the table
            */

-- following queries can be applied to all tables of bronze, silver and gold layer
-- List of all columns and corresponding characteristics
SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    ordinal_position
FROM information_schema.columns
WHERE table_schema='bronze'
AND table_name='crm_cust_info'
ORDER BY ordinal_position;
GO
-- List of all sorts of associated constraints
SELECT
    constraint_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema= 'bronze'
AND table_name='crm_cust_info';
GO
-- Type of indexing followed (depends upon presence or absence of constraints)
SELECT
    name,
    type,
    type_desc,
    is_primary_key,
    is_unique,
    is_unique_constraint,
    is_disabled,
    has_filter
FROM sys.indexes
WHERE object_id = OBJECT_ID('bronze.crm_cust_info');

/* moving towards data quality inspection*/

            /*
                -data volume check: counts number of rows to inspect table size & if the load was successful/interrupted
                -missing values/NULLs check: to inspect if data is complete
                -duplicate rows check: to inspect issues during ingestion such as interrupted loading or lack of deduplication in the source data.
                -sanity check: to inspect data makes logical sense such as prices are not negative, dates follow correct order, quantities are non-negative etc.
            */
  
-- bronze layer
-- following checks can be applied to all the tables in bronze layer
-- 1.checkinng volume
SELECT COUNT(*) AS total_rows
FROM bronze.crm_cust_info;

-- 2.checking for missing values. (number of aggregates being equal to row count prove absence of NULLs)
SELECT
    COUNT(*) AS total_rows,
    COUNT(cst_id) AS number_of_cst_id,
    COUNT(cst_key) AS number_of_cst_key,
    COUNT(cst_firstname) AS number_of_firstname
FROM bronze.crm_cust_info;

-- 3.checking for duplicate values (can be checkedd for various columns)
SELECT
    cst_id,
    COUNT(*) AS duplicates
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1;

--4.checking for data validation
-- negative product cost
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost< 0;
GO
-- product end date earlier than start date
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt< prd_start_dt;
GO
-- negative sales amount
SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales <0;
GO
-- invalid quantities
SELECT *
FROM bronze.crm_sales_details
WHERE sls_quantity<=0;
GO
-- negative prices
SELECT *
FROM bronze.crm_sales_details
WHERE sls_price<0;
GO
-- birthdate in the future
SELECT *
FROM bronze.erp_cust_az12
WHERE bdate>GETDATE();
GO

-- silver layer
-- Following checks can be applied to all the tables in silver layer
-- 1.checking volume
SELECT COUNT(*) AS total_rows
FROM silver.crm_cust_info;

-- 2.checking for missing values (expected: number of aggregates equal to row count since data in silver layer is clean)
SELECT
    COUNT(*) AS total_rows,
    COUNT(cst_id) AS non_null_id,
    COUNT(cst_key) AS non_null_key,
    COUNT(cst_firstname) AS non_null_firstname
FROM silver.crm_cust_info;

-- 3.checking for duplicate data (expected: empty table since data in silver layer is clean)
SELECT
    cst_id,
    COUNT(*) AS duplicates
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1;

-- 4.checking for data validation/sanity (expected: empty tables since data in silver layer is clean)
-- negative product cost
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost <0;
GO
-- invalid product date ranges
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt< prd_start_dt;
GO
-- negative sales values
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <0;
-- invalid quantities
SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0;
GO
-- negative prices
SELECT *
FROM silver.crm_sales_details
WHERE sls_price<0;
GO
-- missing or blank country values
SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL OR TRIM(cntry)= '';
GO
-- birthdate in the future
SELECT *
FROM silver.erp_cust_az12
WHERE bdate >GETDATE();
GO
-- missing category or subcategory
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL
   OR subcat IS NULL
   OR TRIM(cat)=''
   OR TRIM(subcat)= '';
GO

-- gold layer
-- following checks can be applied to all the tables in gold layer
-- 1.checking data volume
SELECT COUNT(*) AS total_customers
FROM gold.dim_customers;

-- 2.checking for missing values (expected: empty tables since source layer of gold i.e silver has clean data)
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;
GO
SELECT *
FROM gold.dim_customers
WHERE customer_id IS NULL;
GO
SELECT *
FROM gold.dim_products
WHERE product_id IS NULL;
GO

-- 3. checking sync/consistency between dimension tables and fact tables
-- customers referenced in fact but missing in dimension
SELECT DISTINCT customer_key
FROM gold.fact_sales
WHERE customer_key NOT IN
(
    SELECT customer_key
    FROM gold.dim_customers
);
GO
-- products referenced in fact but missing in dimension
SELECT DISTINCT product_key
FROM gold.fact_sales
WHERE product_key NOT IN
(
    SELECT product_key
    FROM gold.dim_products
);
GO

-- 4. checking data validation/sanity
-- negative sales values
SELECT *
FROM gold.fact_sales
WHERE sales_amount<0;
GO
-- invalid quantities
SELECT *
FROM gold.fact_sales
WHERE quantity<=0;
GO
-- negative prices
SELECT *
FROM gold.fact_sales
WHERE price <0;
GO
-- invalid date sequence
SELECT *
FROM gold.fact_sales
WHERE shipping_date< order_date
   OR due_date<order_date;
GO
-- future birthdates
SELECT *
FROM gold.dim_customers
WHERE birthdate >GETDATE();
GO
-- negative product cost
SELECT *
FROM gold.dim_products
WHERE cost<0;
GO
