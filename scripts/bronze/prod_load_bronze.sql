/*
=====================================================================================
Stored Procedure: Load raw data from Source > bronze layer
=====================================================================================
Script Purpose: This Stored Procedure loads data into the bronze schema from external CSV files. 
    It performs the following actions;
    -  Truncates the Bronze tables before loading in data
    -  Uses the `BULK INSERT` command to load data from CSV files to bronze tables. 

Parameters: 
    None.
    This Stored procedure accepts no parameters nor return any value.

Usage Example:
    EXEC bronze.load_bronze;
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '======================================================';
		PRINT 'Loading the Bronze Layer';
		PRINT '======================================================';

		PRINT '------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info

		PRINT '>> Inserting Data into Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
				FIRSTROW = 2, -- This skips the CSV file header and starts from the second row. 
				FIELDTERMINATOR = ',', -- This is use as a delimiter to create columns 
				TABLOCK --  This locks the insertions
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info 

		PRINT '>> Inserting Data into Table: bronze.crm_prd_info';
		BULK INSERT  bronze.crm_prd_info
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details
	
		PRINT '>> Inserting Data into Table: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'
		-- Truncate and bulk insert into bronze.erp_cust_az12 
	
		PRINT '------------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12 

		PRINT '>> Inserting Data into Table: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12 
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
				FIRSTROW = 2, 
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101

		PRINT '>> Inserting Data into Table: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2

		PRINT '>> Inserting Data into Table: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2 
		FROM 'C:\Users\PUCHEO\Desktop\Desktop Files\Data Pack\my_projects\SQL Project\Data With Baraa - Data Warehouse Project\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '>>----------------'
	SET @batch_end_time = GETDATE()

	PRINT '===========================================';
	PRINT 'Loading Bronze Layer is completed';
	PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_Start_time, @batch_end_time) AS NVARCHAR) + ' Seconds';
	PRINT '==========================================='
	END TRY 
	BEGIN CATCH 
		PRINT '======================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
	END CATCH 
END 


