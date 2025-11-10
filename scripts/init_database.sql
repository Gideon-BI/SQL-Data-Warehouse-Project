/*
==================================================
CREATE Database and Schemas 
==================================================
Script Purpose:
	This script creates a new database named 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver', and 'gold'.

WARNING:
	Running this script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permanently deleted. Proceed with caution and
	ensure you have proper backups before running this scripts.
*/

USE master
GO
-- CREATE DATABASE 

-- Drop and create the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
	ALTER Database DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
	DROP Database DataWarehouse;
END;

GO
-- CREATE Datawarehouse Database 
CREATE DATABASE DataWarehouse 

USE DataWarehouse 
GO
-- CREATE distinct SCHEMAs for each of the layers. 
CREATE SCHEMA Bronze 
GO

CREATE SCHEMA Silver 
GO

CREATE SCHEMA Gold 
