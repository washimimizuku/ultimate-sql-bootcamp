USE ROLE SYSADMIN;
USE WAREHOUSE XSMALL_WAREHOUSE;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;

-- SEARCH CASE EXPRESSION
-- Customer support level based on their years 
SELECT 
    O_CUSTKEY,
    DATEDIFF(YEAR, MIN_ORDERDATE, CURRENT_DATE()) AS C_YEARS,
    CASE
        WHEN DATEDIFF(YEAR, MIN_ORDERDATE, CURRENT_DATE()) >= 30 THEN 'Gold Customer'
        WHEN DATEDIFF(YEAR, MIN_ORDERDATE, CURRENT_DATE()) >= 20 THEN 'Silver Customer'
        WHEN DATEDIFF(YEAR, MIN_ORDERDATE, CURRENT_DATE()) >= 10 THEN 'Bronze Customer'
        ELSE 'New Customer'
    END AS C_TIER,
    C.*
FROM (
    SELECT 
        O_CUSTKEY,
        MIN(O_ORDERDATE) AS MIN_ORDERDATE 
    FROM ORDERS
    GROUP BY O_CUSTKEY
) O
INNER JOIN CUSTOMER C ON O.O_CUSTKEY = C.C_CUSTKEY;


-- SIMPLE CASE EXPRESSION
-- Convert each order status to its long-form
SELECT 
    O_ORDERSTATUS,
    CASE O_ORDERSTATUS
        WHEN 'F' THEN 'Filled'
        WHEN 'O' THEN 'Open'
        WHEN 'P' THEN 'Paid'
        WHEN 'R' THEN 'Returned'
        WHEN 'A' THEN 'Approved'
        ELSE 'N/A Orderstatus'
    END AS O_ORDERSTATUS_LONG
FROM 
    ORDERS O
INNER JOIN CUSTOMER C ON (O.O_CUSTKEY = C.C_CUSTKEY);

-- (IF)F()
CREATE TABLE DEMO_DB.DEMO_SCHEMA.ORDERS_ENRICHED
AS
SELECT
    O.*,
    IFF(O.O_TOTALPRICE > 100000, 'High Value', 'Low Value') AS VALUE_TAG
FROM
    ORDERS AS O;

SELECT O_ORDERKEY, O_TOTALPRICE, VALUE_TAG FROM DEMO_DB.DEMO_SCHEMA.ORDERS_ENRICHED;

-- COALESCE
SELECT 
    P_PARTKEY, 
    P_NAME, 
    COALESCE(P_COMMENT, 'No comment available.') AS COMMENT
FROM 
    PART;

SELECT 
    P_PARTKEY, 
    P_NAME, 
    COALESCE(P_COMMENT, 
             CONCAT(P_NAME, ' is manufactured by ', P_MFGR, ' and is of brand: ', P_BRAND), 
             CONCAT(P_NAME, ' is manufactured by ', P_MFGR), 'No comment available.'
            ) AS COMMENT
FROM 
    PART;
