/*
======================================================================
DDL Script: Create Gold Views
======================================================================

Script Purpose: 
	This script creates views for the Gold layer in the data warehouse.
	The Gold layer represents the final dimension and fact tables (Star Schema)

	Each view performs transformations and combines data from the Silver layer 
	to produce a clean, enriched and business-ready dataset.

Usage:
	- These views can be queried directly for analytics and reporting
=======================================================================
*/


/*
=======================================================================
  Create dimension gold.Dim_product
=======================================================================
*/
IF OBJECT_ID('gold.Dim_product', 'V') IS NOT NULL 
	DROP VIEW gold.Dim_product;
GO 

CREATE VIEW gold.Dim_product AS
SELECT 
	   ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
	   prd_id AS product_id,
       prd_key AS product_number,
	   prd_nm AS product_name,
	   cat_id AS category_id,
	   ec.cat AS category,
	   ec.subcat subcategory,
	   ec.maintenance,
	   prd_cost AS cost,
	   prd_line AS product_line,
       prd_start_dt AS start_date
       --prd_end_dt
FROM  Silver.crm_prd_info AS pn
LEFT JOIN Silver.erp_px_cat_g1v2 AS ec
ON		pn.cat_id = EC.id
WHERE PN.prd_end_dt IS NULL

/*
=======================================================================
  Create  dimension gold.dim_customers
=======================================================================
*/
  
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL 
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
		ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		ci.cst_marital_status AS marital_status,
		CASE 
			WHEN ci.cst_gndr = 'n/a' THEN ca.gen
			ELSE COALESCE(ci.cst_gndr, 'n/a')
		END gender,
		la.cntry AS country,
		ca.bdate AS birthdate, 
		ci.cst_create_date AS create_date
FROM Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca
ON		ci.cst_key = ca.cid
LEFT JOIN Silver.erp_loc_a101 AS la
ON		ci.cst_key = la.cid

  /*
=======================================================================
  Create facts gold.fact_sales
=======================================================================
*/

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL 
	DROP VIEW gold.fact_sales
GO
CREATE VIEW gold.fact_sales AS
SELECT	sls_ord_num AS Order_Number,
		dp.product_key,
		dc.customer_key,
		sls_ord_dt AS order_date,
		sls_ship_dt AS shipping_date,
		sls_due_dt AS due_date,
		sls_sales AS sales_amount,
		sls_quantity AS quantity,
		sls_price AS price
FROM Silver.crm_sales_details AS cs
LEFT JOIN Gold.dim_customers AS dc
ON	cs.sls_cust_id = dc.customer_id
LEFT JOIN Gold.Dim_product AS dp
ON dp.product_number = cs.sls_prd_key
