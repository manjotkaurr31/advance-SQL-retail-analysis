-- Activate database
USE DataWarehouseAnalytics;
GO
-- Create Schema
CREATE SCHEMA gold;
GO

/*
    This script creates the physical tables for the Gold Layer (Star Schema).Each dimension uses an IDENTITY(1,1) column to provide a stable Surrogate Key that survives across full-load cycles.
*/

-- 1. Create Dimension: gold.dim_customers
IF OBJECT_ID('gold.dim_customers', 'U') IS NOT NULL
    DROP TABLE gold.dim_customers;
GO
CREATE TABLE gold.dim_customers (
    customer_key      INT IDENTITY(1,1), /* Stable Surrogate Key */
    customer_id       INT NOT NULL, /* Natural Key from Silver */
    customer_number   NVARCHAR(50),
    first_name        NVARCHAR(50),
    last_name         NVARCHAR(50),
    country           NVARCHAR(50),
    marital_status    NVARCHAR(50),
    gender            NVARCHAR(50),
    birthdate         DATE,
    create_date       DATE,
    dwh_create_date   DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT pk_gold_dim_customers PRIMARY KEY (customer_key)
);
GO

-- 2. Create Dimension: gold.dim_products
IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL
    DROP TABLE gold.dim_products;
GO
CREATE TABLE gold.dim_products (
    product_key       INT IDENTITY(1,1), /* Stable Surrogate Key */
    product_id        INT NOT NULL, /* Natural Key from Silver */
    product_number    NVARCHAR(50),
    product_name      NVARCHAR(50),
    category_id       NVARCHAR(50),
    category          NVARCHAR(50),
    subcategory       NVARCHAR(50),
    maintenance       NVARCHAR(50),
    cost              INT,
    product_line      NVARCHAR(50),
    start_date        DATE,
    dwh_create_date   DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT pk_gold_dim_products PRIMARY KEY (product_key)
);
GO

-- 3. Create Fact Table: gold.fact_sales
IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
    DROP TABLE gold.fact_sales;
GO
CREATE TABLE gold.fact_sales (
    order_number      NVARCHAR(50),
    product_key       INT, /* Links to gold.dim_products.product_key */
    customer_key      INT, /* Links to gold.dim_customers.customer_key */
    order_date        DATE, /*first 3 columns making composite key*/
    shipping_date     DATE,
    due_date          DATE,
    sales_amount      INT,
    quantity          INT,
    price             INT,
    dwh_create_date   DATETIME2 DEFAULT GETDATE()
);
GO
/*
    This procedure performs the final transformations to populate the Star Schema. Uses TRUNCATE & INSERT full load loading mechanism.
    - Truncates existing Gold tables.
    - Inserts data from Silver, allowing IDENTITY(1,1) to generate stable keys.
    - Uses ORDER BY on Natural Keys to maintain deterministic key assignment.
    -Exception Handling
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';

        -- 1. Loading gold.dim_customers
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: gold.dim_customers';
        TRUNCATE TABLE gold.dim_customers;
        PRINT '>> Inserting Data Into: gold.dim_customers';
        
        INSERT INTO gold.dim_customers (
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            marital_status,
            gender,
            birthdate,
            create_date
        )
        SELECT
            ci.cst_id,
            ci.cst_key,
            ci.cst_firstname,
            ci.cst_lastname,
            la.cntry,
            ci.cst_marital_status,
            CASE 
                WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
                ELSE COALESCE(ca.gen, 'n/a')
            END AS gender,
            ca.bdate,
            ci.cst_create_date
        FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
        ORDER BY ci.cst_id;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 2. Loading gold.dim_products
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: gold.dim_products';
        TRUNCATE TABLE gold.dim_products;
        PRINT '>> Inserting Data Into: gold.dim_products';

        INSERT INTO gold.dim_products (
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            cost,
            product_line,
            start_date
        )
        SELECT
            pn.prd_id,
            pn.prd_key,
            pn.prd_nm,
            pn.cat_id,
            pc.cat,
            pc.subcat,
            pc.maintenance,
            pn.prd_cost,
            pn.prd_line,
            pn.prd_start_dt
        FROM silver.crm_prd_info pn
        LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
        WHERE pn.prd_end_dt IS NULL /* Only load active products*/
        ORDER BY pn.prd_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- 3. Loading gold.fact_sales
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: gold.fact_sales';
        TRUNCATE TABLE gold.fact_sales;
        PRINT '>> Inserting Data Into: gold.fact_sales';

        INSERT INTO gold.fact_sales (
            order_number,
            product_key,
            customer_key,
            order_date,
            shipping_date,
            due_date,
            sales_amount,
            quantity,
            price
        )
        SELECT
            sd.sls_ord_num,
            pr.product_key,
            cu.customer_key,
            sd.sls_order_dt,
            sd.sls_ship_dt,
            sd.sls_due_dt,
            sd.sls_sales,
            sd.sls_quantity,
            sd.sls_price
        FROM silver.crm_sales_details sd
        LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
        LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';
        PRINT 'Gold Layer Load Completed Successfully';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING GOLD LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
		    PRINT 'Error Message: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		    PRINT 'Error Message: ' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
GO
