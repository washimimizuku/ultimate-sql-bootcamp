USE ROLE SYSADMIN;
USE WAREHOUSE XSMALL_WAREHOUSE;
USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1;

-- Result-set A
-- +--------+----------+-------------+
-- | emp_id | emp_name | signup_date |
-- +--------+----------+-------------+
-- | 1      | EMP_1    | 01-01-2024  |
-- | 2      | EMP_2    | 01-01-2024  |
-- +--------+----------+-------------+
-- Result-set B
-- +--------+----------+-------------+
-- | emp_id | emp_name | signup_date |
-- +--------+----------+-------------+
-- | 2      | EMP_2    | 01-01-2024  |
-- | 3      | EMP_3    | 01-01-2024  |
-- +--------+----------+-------------+

-- UNION: Combines unique rows from both result sets
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- UNION ALL: Combines all rows, including duplicates
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION ALL
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- Inconsistent Column Number
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01', 'LDN')
UNION
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- Inconsistent Data Type
SELECT * FROM VALUES ('one', 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

SELECT * FROM VALUES ('1', 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- INTERSECT: Finds common rows between both result sets
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
INTERSECT
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
INTERSECT
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- MINUS / EXCEPT: Returns rows from the first result set that are not in the second
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
MINUS
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
EXCEPT
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01');

-- MULTI SET OPERATORS
SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01')
UNION
SELECT * FROM VALUES (4, 'EMP_4', '2024-01-01'), (4, 'EMP_4', '2024-01-01');

SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION ALL
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01')
INTERSECT
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (4, 'EMP_4', '2024-01-01');

(SELECT * FROM VALUES (1, 'EMP_1', '2024-01-01'), (2, 'EMP_2', '2024-01-01')
UNION ALL
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (3, 'EMP_3', '2024-01-01'))
INTERSECT
SELECT * FROM VALUES (2, 'EMP_2', '2024-01-01'), (4, 'EMP_4', '2024-01-01');

-- Real-world use-case
SELECT C.C_CUSTKEY, C.C_NAME
FROM CUSTOMER AS C
JOIN ORDERS AS O ON C.C_CUSTKEY = O.O_CUSTKEY
WHERE O.O_ORDERPRIORITY = '1-URGENT'
INTERSECT
SELECT C.C_CUSTKEY, C.C_NAME
FROM CUSTOMER AS C
JOIN ORDERS AS O ON C.C_CUSTKEY = O.O_CUSTKEY
WHERE O.O_ORDERPRIORITY = '5-LOW';