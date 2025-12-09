USE ROLE SYSADMIN;
USE WAREHOUSE XSMALL_WAREHOUSE;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;

-- Simple explain command
EXPLAIN
SELECT 
    * 
FROM 
    lineitem;

-- Full table scan
EXPLAIN
SELECT 
    *
FROM 
    lineitem
WHERE 
    l_shipdate = '1995-01-01';

-- Cartesian join between the "lineitem" and "orders" tables
EXPLAIN
SELECT
    l.*,
    o.*
FROM
    tpch_sf1.lineitem l,
    tpch_sf1.orders o;