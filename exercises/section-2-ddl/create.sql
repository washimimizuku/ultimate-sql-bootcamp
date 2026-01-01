-- SQL CREATE Examples - Creating database objects
-- This file demonstrates various CREATE statement patterns

-- CREATE COMMAND SYNTAX:
-- CREATE SCHEMA <schema_name>;                    -- Create a new schema
-- CREATE TABLE <table_name> (                    -- Create table with columns
--     <column_name> <data_type> [constraints],
--     ...
-- );
-- CREATE TABLE <new_table> AS SELECT ...;        -- Create table from query result

-- Setup: Create and use a demo schema
CREATE SCHEMA demo_schema;
USE demo_schema;

-- Example 1: CREATE TABLE with explicit column definitions
-- This is the most common way to create tables
CREATE TABLE employee (
    employee_id NUMERIC NOT NULL PRIMARY KEY,  -- Primary key constraint
    first_name STRING,                         -- Variable-length string
    last_name STRING,
    birthdate DATE,                            -- Date data type
    country_code STRING
);

-- Examine the table structure we just created
DESCRIBE employee;

-- Example 2: CREATE TABLE AS SELECT (CTAS)
-- Creates a new table based on the result of a SELECT query
-- The new table inherits column names and data types from the SELECT
CREATE TABLE employee_us
AS
SELECT * FROM employee WHERE country_code = 'US';

-- Examine the structure of the table created from SELECT
DESCRIBE employee_us;

-- Cleanup - Remove all objects created in this demo
DROP TABLE employee_us;
DROP TABLE employee;
DROP SCHEMA demo_schema;
