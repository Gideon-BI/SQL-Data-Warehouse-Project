# 🏗️ Data Warehouse and Analytics Projects 
This project demonstrates a complete end-to-end development of Data Warehouse to Analytics solution for Dasten Retailstore Supermarket. The purpose of this project is to build a central source of truth for the company's operations data and eliminate the tediousness in accessing the right data, the inconsitency and lack of trust in reporting. 

# ✍️ Project Requirements 

### Data Warehouse Objective: 
Build a consolidated, modern and robust Data Warehouse for retail firm with SQL including reporting to enable strategic business decision making

### Specifications and Work flow 
-  **Data Sources:** Import Data from two sources systems - ERP and CRM provided as CSV files.
-  **Data Quality:** Cleanse and resolve data quality issues before analysis. 
-  **Data Integration:** Comnine both sources into a single user-friendly, data model designed for analytical purposes.
-  **Scope:** Focus on the latest dataset only; Historization is not required.
-  **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytical teams.

### BI and Reporting Analytics Objective
Develop a SQL analytics solution to give deep insight into;

-  **Customer Behaviour**
-  **Product Performance**
-  **Sales Trend**

## 🏛️ Data Warehouse Architecture 

<p align="center">
  <img src="[https://raw.githubusercontent.com/username/image-assets/main/project1/dashboard.png](https://github.com/Gideon-BI/SQL-Data-Warehouse-Project/blob/main/assets/Data%20Warehouse%20Diagram%20.drawio.pdf)" width="600" alt="Data Warehouse Architecture">
</p>

## General Principles 
-  **Naming Conventions** Use snake_case with lower case letters and underscore to seperate words.
-  **Language** Use English for all names.
-  **Avoid reserves words:** Do not use SQL reserves for naming objects. 

# Table Naming Conventions
## Bronze Rules 
-  All name must start with the source system name and table names must march their original names without renaming
-  **`<sourcesystem>_<entity>`**
      -  `<sourcesystem>_<entity>`: Name of thesource system (e.g., `crm`, `erp`).
      -  `<entity>` : Exact table name from the source system.
      -  Example `crm_customer_info` → Customer information from the CRM system.
  
## Silver Rules 
-  All name must start with the source system name and table names must march their original names without renaming
-  **`<sourcesystem>_<entity>`**
      -  `<sourcesystem>_<entity>`: Name of thesource system (e.g., `crm`, `erp`).
      -  `<entity>` : Exact table name from the source system.
      -  Example `crm_customer_info` → Customer information from the CRM system.
   
## Gold Rules 
-  All names must use meaningful, business-aligned names for tables, starting with the category prefix
-  **`<category>_<entity>`**
      - `<category>`: Describes the role of the table, such as `dim` (dimension) or `fact` (fact table)
      - `<entity>`: Descriptive name of the table, aligned with the business domain (e.g customers, products, sales)
      -  Examples: 
            -  `dim_customers` → Dimension table for customer data. 
            -  `fact_sales` → Fact Table containing sales transactions.

  #### Glossary of Category Patterns

  | Pattern | Meaning | Examples | 
  | --------  | ------- | -------- |
  | `dim_` | Dimension table | `dim_customer`, `dim_product` |
  | `fact_` | Fact table | `fact_sales` |
  | `agg_` | Aggregated_table | `agg_customers`, `agg_sales_monthly` |


## Column Naming Conventions

### Surrogate Keys
All primary keys in dimension tables must use the `suffix _key`.

-  `<table_name>_key`
-  `<table_name>`: Refers to the name of the table or entity the key belongs to.
-  `_key`: A suffix indicating that this column is a surrogate key.

**Example:** `customer_key` → Surrogate key in the `dim_customers` table.

### Technical Columns

All technical columns must start with the prefix `dwh_`, followed by a descriptive name indicating the column’s purpose.

-  `dwh_<column_name>`
-  `dwh:` Prefix exclusively for system-generated metadata.
-  `<column_name>`: Descriptive name indicating the column’s purpose.

**Example:**  `dwh_load_date` → System-generated column used to store the date when the record was loaded.

### Stored Procedure

All stored procedures used for loading data must follow the naming pattern: `load_<layer>`.

- **`<layer>:`** Represents the layer being loaded, such as `bronze`, `silver`, or `gold`.

**Example:**

- `load_bronze` → Stored procedure for loading data into the Bronze layer.

- `load_silver` → Stored procedure for loading data into the Silver layer.
  
