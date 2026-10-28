-- ============================================
-- FINFLAKE: SNOWFLAKE ENVIRONMENT SETUP
-- Run this FIRST in Snowsight SQL Worksheet
-- ============================================

-- Create the warehouse (compute engine)
CREATE WAREHOUSE IF NOT EXISTS FINANCE_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'Finflake project compute warehouse';

-- Create the database
CREATE DATABASE IF NOT EXISTS FINANCE_PLATFORM
  COMMENT = 'Finance Data Platform - Finflake Project';

-- Create the three-layer schema architecture
USE DATABASE FINANCE_PLATFORM;

CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw ingestion layer - untouched source data';
CREATE SCHEMA IF NOT EXISTS CONFORMED
  COMMENT = 'Conformed layer - cleaned and standardised';
CREATE SCHEMA IF NOT EXISTS CURATED
  COMMENT = 'Curated layer - business-ready reporting data';

-- Access control
CREATE ROLE IF NOT EXISTS FINANCE_ANALYST;
GRANT USAGE ON DATABASE FINANCE_PLATFORM TO ROLE FINANCE_ANALYST;
GRANT USAGE ON WAREHOUSE FINANCE_WH TO ROLE FINANCE_ANALYST;
GRANT ALL ON SCHEMA FINANCE_PLATFORM.RAW TO ROLE FINANCE_ANALYST;
GRANT ALL ON SCHEMA FINANCE_PLATFORM.CONFORMED TO ROLE FINANCE_ANALYST;
GRANT ALL ON SCHEMA FINANCE_PLATFORM.CURATED TO ROLE FINANCE_ANALYST;
GRANT ROLE FINANCE_ANALYST TO USER CURRENT_USER();

-- Verify
SELECT 'Setup complete' AS status,
       CURRENT_DATABASE() AS database_name,
       CURRENT_WAREHOUSE() AS warehouse_name;
