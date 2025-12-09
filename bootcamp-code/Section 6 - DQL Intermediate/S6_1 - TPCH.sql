USE ROLE SYSADMIN;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;
USE WAREHOUSE XSMALL_WAREHOUSE;

-- Customer Table: 150 Thousand Rows
SELECT 
    * 
FROM
    CUSTOMER;
    
-- Lineitem Table: 6 Million Rows
SELECT 
    * 
FROM
    LINEITEM;

-- Orders Table: 1.5 Million Rows
SELECT 
    * 
FROM
    ORDERS;

