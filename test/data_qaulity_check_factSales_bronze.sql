/*
=============================================
Quality Check: Bronze crm_sales_details]
=============================================
*/
SELECT [sls_ord_num]
      ,[sls_prd_key]
      ,[sls_cust_id]
	   ,CASE 
			WHEN LEN([sls_ord_dt]) != 8 OR [sls_ord_dt] = 0 THEN NULL
			ELSE CAST(CAST([sls_ord_dt] AS VARCHAR) AS DATE)
		END [sls_ord_dt]
      ,CASE 
			WHEN LEN([sls_ship_dt]) != 8 OR [sls_ship_dt] = 0 THEN NULL
			ELSE CAST(CAST([sls_ship_dt] AS VARCHAR) AS DATE)
		END [sls_ship_dt],
		CASE 
			WHEN LEN([sls_due_dt]) != 8 OR [sls_due_dt] = 0 THEN NULL
			ELSE CAST(CAST([sls_due_dt] AS VARCHAR) AS DATE)
		END [sls_due_dt],
      [sls_sales]
      ,[sls_quantity]
      ,[sls_price]
  FROM [DataWarehouse].[Bronze].[crm_sales_details]
  
  WHERE [sls_cust_id] NOT IN (SELECT sls_cust_id FROM Silver.crm_cust_info)

-- Check for outliers where date is equal to zero.
SELECT 
	 NULLIF(sls_ord_dt,0) AS sls_ord_dt
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_ord_dt <= 0 
OR LEN(sls_ord_dt) != 8
OR sls_ord_dt > 20500101 
OR sls_ord_dt < 19000101

-- Check for outliers where date is equal to zero.
SELECT 
	 NULLIF(sls_ord_dt,0) AS sls_ord_dt
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_ord_dt <= 0 
OR LEN(sls_ord_dt) != 8
OR sls_ord_dt > 20500101 
OR sls_ord_dt < 19000101


SELECT 
	 sls_ord_dt AS sls_ord_dt
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE  LEN(sls_ord_dt) != 8
OR sls_ord_dt > 20500101 
OR sls_ord_dt < 19000101


SELECT 
	 [sls_due_dt] AS [sls_due_dt]
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE  LEN([sls_due_dt]) != 8
OR [sls_due_dt] > 20500101 
OR [sls_due_dt] < 19000101

-- Check for invalid date entry
SELECT *
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE  sls_ord_dt > sls_ship_dt OR sls_ord_dt > sls_due_dt  

-- Check for Negatives, zeros and Nulls in  sales, quantity and price
SELECT sls_sales
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_sales < 0 OR sls_sales =0 OR sls_sales IS NULL

-- Check for Negatives, zeros and Nulls in  sales, quantity and price
SELECT  sls_sales,
		sls_price * sls_quantity AS Sales_over,
		sls_price,
		sls_quantity
FROM [DataWarehouse].[Bronze].[crm_sales_details]
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
OR sls_sales <= 0 OR sls_price <= 0 OR sls_price <=0
ORDER BY 1,2,3 


SELECT  sls_sales,
		sls_price * sls_quantity AS Sales_over,
		sls_price,
		sls_quantity
FROM [DataWarehouse].[Silver].[crm_sales_details]
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_quantity IS NULLL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <= 0 OR sls_price <0
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0
ORDER BY 1,2,3 


SELECT *
FROM Silver.crm_sales_details

USE datawarehouse

-- RULES 
-- If sales is negative, zero or null, derive it using Quantity and Price
-- If Price is zero or null, calcualte it using Sales & Quantity
-- If Price is negative, convert it to a positive value.

USE DATAWAREHOUSE

 -- WHERE [sls_prd_key] IN (SELECT prd_key FROM Silver.crm_prd_info)
 --WHERE [sls_ord_num] != TRIM([sls_ord_num])
