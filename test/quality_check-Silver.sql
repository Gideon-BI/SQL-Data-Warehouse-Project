-- DATA QUALITY CHECK FOR Silver.crm_cust_info

SELECT * 
FROM Bronze.crm_cust_info
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
	bc.cst_id,
	COUNT(*)
FROM Silver.crm_cust_info AS bc
GROUP BY cst_id
HAVING COUNT(*) > 1 OR 	bc.cst_id IS NULL



-- Check for unwanted spaces
-- Expectation: No Results
SELECT bc.cst_firstname
FROM Silver.crm_cust_info as bc
WHERE bc.cst_firstname != TRIM(bc.cst_firstname)

SELECT bc.cst_lastname
FROM Bronze.crm_cust_info as bc
WHERE bc.cst_lastname != TRIM(bc.cst_lastname)

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM Silver.crm_cust_info

USE DataWarehouse

--- DATA QUALITY CHECK FOR Silver.crm_prd_info
SELECT * 
FROM Bronze.crm_cust_info
-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT 
	prd_id,
	COUNT(*)
FROM Silver.crm_prd_info 
GROUP BY prd_id
HAVING COUNT(*) > 1 OR 	prd_id IS NULL

USE DataWarehouse

-- Check for unwanted spaces
-- Expectation: No Results
SELECT prd_nm
FROM Silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm)

SELECT prd_line
FROM Silver.crm_prd_info  as bc
WHERE prd_line != TRIM(prd_line)

--Check for NULLS or Negative Numbers
-- Expectation: No results
SELECT prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM Silver.crm_prd_info

SELECT * 
FROM Silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt
SELECT * 
FROM Silver.crm_prd_info 

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM Silver.crm_cust_info
