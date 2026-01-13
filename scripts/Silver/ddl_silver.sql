EXEC Silver.Load_Silver

CREATE OR ALTER PROCEDURE Silver.Load_Silver AS 
BEGIN
	DECLARE @startTime AS DATETIME, @endTime AS DATETIME, @silver_StartTime DATETIME, @silver_EndTime DATETIME
	BEGIN TRY
		SET @silver_StartTime = getdate()
		PRINT '=======================================================';
		PRINT 'Loading the Silver Layer'
		PRINT '=======================================================';

		SET @startTime = GETDATE()
		PRINT '>> Truncating Table: Silver.crm_cust_info'
		TRUNCATE TABLE Silver.crm_cust_info
		PRINT '>> Inserting Data into: Silver.crm_cust_info'

		
		INSERT INTO Silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
				dup.cst_id,
				dup.cst_key,
				TRIM(dup.cst_firstname) AS cst_firstname,
				TRIM(dup.cst_lastname) AS cst_lastname,
				CASE 
					WHEN UPPER(TRIM(dup.cst_marital_status)) = 'S' THEN 'Single'
					WHEN UPPER(TRIM(dup.cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
				END cst_marital_status, -- Normalize marital status values to readable format
				CASE
					WHEN UPPER(TRIM(dup.cst_gndr)) = 'M' THEN 'Male'
					WHEN UPPER(TRIM(dup.cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
				END cst_gndr, -- Normalize gender values to readable format
				dup.cst_create_date
		FROM (
			SELECT *,
					ROW_NUMBER() OVER(PARTITION BY bc.cst_id ORDER BY bc.cst_create_date DESC) AS flag_last
			FROM Bronze.crm_cust_info AS bc
			WHERE bc.cst_id IS NOT NULL
		) AS dup
		WHERE dup.flag_last = 1;

		SET @endTime = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'


		SET @startTime = GETDATE()
		PRINT '>> Truncating Table: Silver.crm_prd_info'
		TRUNCATE TABLE Silver.crm_prd_info
		PRINT '>> Inserting Data into: Silver.crm_prd_info'

		INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost, 
			prd_line,
			prd_start_dt, 
			prd_end_dt
			)
		SELECT [prd_id],
			  REPLACE(SUBSTRING([prd_key],1,5), '-','_') AS cat_id, -- extract category key from product key and and replace hyphen with an underscore. 
			  SUBSTRING([prd_key],7,LEN([prd_key])) AS prd_key, -- extract product key from product key column
			  [prd_nm],
			  ISNULL([prd_cost],0) AS prd_cost, -- Handling Null values. Replace NULLS with Zero
			  CASE UPPER(TRIM([prd_line]))
					WHEN 'R' THEN 'Road'
					WHEN 'M' THEN 'Mountain'
					WHEN 'S' THEN 'Other Sales'
					WHEN 'T' THEN 'Touring'
			  ELSE 'n/a'
			  END AS 'prd_line', -- Map product line codes to descriptive values
			  [prd_start_dt],
			  DATEADD(DAY, -1, LEAD([prd_start_dt]) OVER(PARTITION BY prd_key ORDER BY [prd_start_dt] ASC)) AS [prd_end_dt] -- Calculate end date as one day before the next start date
		FROM [DataWarehouse].[Bronze].[crm_prd_info]
				SET @endTime = GETDATE()
				PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
				PRINT '>>---------------'

		SET @startTime = GETDATE()
		PRINT '>> Truncating Table: Silver.crm_sales_details'
		TRUNCATE TABLE Silver.crm_sales_details
		PRINT '>> Inserting Data into: Silver.crm_sales_details'

		  INSERT INTO Silver.crm_sales_details (
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				sls_ord_dt,
				sls_ship_dt,
				sls_due_dt,
				sls_sales,
				sls_quantity,
				sls_price
				)
		SELECT	sls_ord_num,
				sls_prd_key,
				sls_cust_id,
				CASE WHEN sls_ord_dt = 0 OR LEN(sls_ord_dt) != 8 THEN NULL
					 ELSE CAST(CAST(sls_ord_dt AS VARCHAR) AS DATE)
				END AS sls_ord_dt,
				CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
					 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
				END AS sls_ship_dt,
				CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
					 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
				END AS sls_due_dt,
				CASE 
					WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price) 
					ELSE sls_sales
				END AS sls_sales,
				sls_quantity,
				CASE 
					WHEN sls_price <= 0 OR sls_price IS NULL 
					THEN sls_sales/NULLIF(sls_quantity,0) 
					ELSE sls_price
				END AS sls_price
		FROM [DataWarehouse].[Bronze].[crm_sales_details]
		SET @endTime = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'

		SET @startTime = GETDATE()
		PRINT '>> Inserting Data into: Silver.erp_cust_az12'
		TRUNCATE TABLE Silver.erp_cust_az12
		PRINT '>> Inserting Data into: Silver.erp_cust_az12'

		INSERT INTO Silver.erp_cust_az12 (cid, bdate,gen)
		SELECT
				CASE 
					WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) -- Remove 'NAS' prefix if present
					ELSE cid
				END AS cid,
				CASE 
					 WHEN bdate > GETDATE() THEN NULL -- Set Future birthdates to NULL
					 ELSE bdate
				END AS bdate,
				CASE 
					WHEN UPPER(TRIM(gen))	IN ( 'F', 'Female') THEN 'Female'
					WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
					ELSE 'n/a'
				END AS gen -- Normalize gender values and handle unknown cases
		FROM Bronze.erp_cust_az12
		SET @endTime = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'

		SET @startTime = GETDATE()
		PRINT '>> Inserting Data into: Silver.erp_px_cat_g1v2'
		TRUNCATE TABLE Silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data into: Silver.erp_px_cat_g1v2'
		INSERT INTO Silver.erp_px_cat_g1v2(id, cat, subcat,maintenance)
		SELECT 
			id,
			cat,
			subcat,
			maintenance
		FROM Bronze.erp_px_cat_g1v2
		SET @endTime = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'


		PRINT '>> Inserting Data into: Silver.erp_loc_a101'
		TRUNCATE TABLE Silver.erp_loc_a101
		PRINT '>> Inserting Data into: Silver.erp_loc_a101'
		INSERT INTO Silver.erp_loc_a101(cid,cntry)
		SELECT 
		REPLACE(cid, '-','') AS cid,
				CASE 
					WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
					WHEN TRIM(cntry) ='' OR TRIM(cntry) IS NULL THEN 'n/a'
					WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				ELSE cntry
				END AS cntry_2 -- Normalize and Handle missing or blank country codes
		FROM Bronze.erp_loc_a101
		SET @endTime = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @startTime, @endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'

		SET @silver_EndTime = GETDATE()
		PRINT '>> Silver Layer Load Duration: ' + CAST(DATEDIFF(SECOND, @silver_startTime, @silver_endtime) AS NVARCHAR) + ' Seconds';
		PRINT '>>---------------'
		END TRY
		BEGIN CATCH 
		
		PRINT '============================================'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		END CATCH
END
