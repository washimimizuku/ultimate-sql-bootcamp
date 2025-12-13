-- SQL Anatomy Example - Understanding basic SQL structure
-- This demonstrates the fundamental components of a SELECT statement

-- SELECT COMMAND SYNTAX:
-- SELECT <column1>, <column2>, <expression>  -- Specify columns to retrieve
-- FROM <table_name>                         -- Specify source table
-- WHERE <condition>;                        -- Filter rows (optional)

-- SELECT clause: Specifies which columns to retrieve
-- - c_name: Customer name column
-- - c_address: Customer address column  
-- - c_nationkey + 1: Expression that adds 1 to the nation key
SELECT
    c_name,
    c_address,
    c_nationkey + 1
-- FROM clause: Specifies the source table
FROM
    customer
-- WHERE clause: Filters rows based on conditions
-- Only returns customers where nation key equals 5
WHERE
    c_nationkey = 5;