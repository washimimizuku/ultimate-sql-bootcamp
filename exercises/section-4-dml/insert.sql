-- SQL INSERT Examples - Adding new data to tables
-- This file demonstrates various INSERT statement patterns

-- INSERT COMMAND SYNTAX:
-- INSERT INTO <table_name> VALUES (value1, value2, ...);              -- Insert with all values
-- INSERT INTO <table_name> (col1, col2) VALUES (val1, val2);          -- Insert specific columns
-- INSERT INTO <table_name> VALUES (row1), (row2), (row3);             -- Multi-row insert
-- INSERT INTO <table_name> SELECT col1, col2 FROM <other_table>;       -- Insert from query

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create employee table for INSERT examples
CREATE TABLE employee (
    employee_id NUMERIC(3,0) NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Example 1: Basic INSERT with VALUES - All columns in order
INSERT INTO employee VALUES (1, 'John', 'Doe', '1990-01-01', 'US');

-- Example 2: INSERT with explicit column list - Best practice for clarity
INSERT INTO employee (employee_id, first_name, last_name, birthdate, country_code)
VALUES (2, 'Jane', 'Smith', '1985-05-15', 'CA');

-- Example 3: Partial INSERT - Only specified columns, others will be NULL
INSERT INTO employee (employee_id, first_name)
VALUES (3, 'Bob');

-- Verify partial insert - notice NULL values in unspecified columns
SELECT * FROM employee WHERE employee_id = 3;

-- Example 4: Multi-row INSERT - Insert multiple records in one statement
INSERT INTO employee
VALUES
    (4, 'Alice', 'Johnson', '1992-07-20', 'UK'),
    (5, 'Charlie', 'Brown', '1988-12-30', 'AU'),
    (6, 'Randy', 'Caldwell', '1970-01-02', 'FI');

-- Check all inserted records
SELECT * FROM employee;

-- Example 5: INSERT with function - Using RANDOM() for dynamic values
INSERT INTO employee VALUES (RANDOM() * 1000, 'John', 'Doe', '1990-01-01', 'JP');

-- Example 6: INSERT with SELECT - Insert data from a query result
INSERT INTO employee
SELECT RANDOM() * 1000, 'Hirota', 'Shigeru', '1990-01-01', 'JP';

-- Final verification - see all records including those with random IDs
SELECT * FROM employee;

-- Clean up - Remove all objects created in this demo
DROP TABLE employee;
DROP SCHEMA demo_schema;