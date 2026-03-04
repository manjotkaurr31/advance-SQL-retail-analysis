--Activate database
USE DataWarehouseAnalytics;
GO
-- Create Schema bronze
CREATE SCHEMA bronze;
GO
  
/* This script creates tables in the 'bronze' layer schema after dropping existing tables if they already exist. It defines the DDL structure of 'bronze' tables */

/*Customer Information*/
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO
  
/*Product Informaiton*/
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

/*Sales Details*/
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

/* erp_loc_a101 */
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

/* erp_cust_az12 */
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

/* erp_px_cat_g1v2 */
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO
  
/*
Stored Procedure: Load Bronze Layer
    This stored procedure loads data into the 'bronze' schema from external CSV files. It uses TRUNCATE & INSERT : FULL LOAD loading mechanism. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.
    - Calculates individual table load times and cumulative batch load time.
    - Exception Handling.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN /*stored procedure begins*/
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; /*variables to calculate time*/
	BEGIN TRY /*try block begins*/
		SET @batch_start_time = GETDATE(); /*cumulative batch load time starts*/
		PRINT '================================================';
		PRINT 'Starting Loading Bronze Layer';
		PRINT '================================================';
/*
loading CRM tables
*/
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

    PRINT '>> **********************************************';
		SET @start_time = GETDATE(); /*table no.1 load time starts*/
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info; 
		PRINT '>> Inserting Data Into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info /*table no.1*/
		FROM 'datasets\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.1 load time ends*/
		PRINT '>> Load Duration bronze.crm_cust_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 1*/
		PRINT '>> **********************************************';

    PRINT '>> **********************************************';
    SET @start_time = GETDATE();  /*table no.2 load time starts*/
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting Data Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info /*table no.2*/
		FROM 'datasets\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.2 load time ends*/
		PRINT '>> Load Duration bronze.crm_prd_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 2*/
		PRINT '>> **********************************************';

    PRINT '>> **********************************************';
    SET @start_time = GETDATE();  /*table no.3 load time starts*/
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting Data Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details /*table no.3*/
		FROM 'datasets\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.3 load time ends*/
		PRINT '>> Load Duration bronze.crm_sales_details: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 3*/
		PRINT '>> **********************************************';
/*
loading ERP tables
*/
		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

    PRINT '>> **********************************************';
		SET @start_time = GETDATE();  /*table no.4 load time starts*/
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101 /*table no.4*/
		FROM 'datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.4 load time ends*/
		PRINT '>> Load Duration bronze.erp_loc_a101: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 4*/
		PRINT '>> **********************************************';

    PRINT '>> **********************************************';
		SET @start_time = GETDATE();  /*table no.5 load time starts*/
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12 /*table no.5*/
		FROM 'datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.5 load time ends*/
		PRINT '>> Load Duration bronze.erp_cust_az12: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 5*/
		PRINT '>> **********************************************';

    PRINT '>> **********************************************';
		SET @start_time = GETDATE();  /*table no.6 load time starts*/
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2 /*table no.6*/
		FROM 'datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE(); /*table no.6 load time ends*/
		PRINT '>> Load Duration bronze.erp_px_cat_g1v2: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'; /*calculate total load time for table no. 6*/
		PRINT '>> **********************************************';

		SET @batch_end_time = GETDATE(); /*cumulative batch load time starts*/
		PRINT '==========================================';
		PRINT 'Finished Loading Bronze Layer';
    PRINT 'Total Bronze Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'; /*calculate cumulative batch load time*/
		PRINT '==========================================';
	END TRY /*try block ends*/
   
	BEGIN CATCH /*catch block begins*/
		PRINT '==========================================';
		PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(10));
		PRINT '==========================================';
	END CATCH /*catch block ends*/
END /*stored procedure ends*/
