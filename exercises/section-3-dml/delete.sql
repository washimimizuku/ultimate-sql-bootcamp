-- SQL DELETE Examples - Removing data from tables
-- This file demonstrates various DELETE statement patterns
-- WARNING: DELETE operations are destructive and cannot be undone!

-- DELETE COMMAND SYNTAX:
-- DELETE FROM <table_name>;                                    -- Delete all rows (dangerous!)
-- DELETE FROM <table_name> WHERE <condition>;                 -- Delete specific rows
-- DELETE FROM <table_name> WHERE <column> IN (val1, val2);    -- Delete multiple matching rows
-- DELETE FROM <table_name> USING <other_table>                -- Delete with JOIN
--   WHERE <table_name>.<col> = <other_table>.<col>;

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create employee table for DELETE examples
CREATE OR REPLACE TABLE employee (
    employee_id INTEGER NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Insert sample data for deletion examples
INSERT INTO employee
VALUES
    (1, 'Alice', 'Johnson', '1992-07-20', 'UK'),
    (2, 'Charlie', 'Brown', '1988-12-30', 'AU'),
    (3, 'Randy', 'Caldwell', '1970-01-02', 'FI');

-- Show initial data
SELECT * FROM employee ORDER BY employee_id;

-- Example 1: DELETE all rows - Use with extreme caution!
-- This removes ALL data from the table but keeps the table structure
DELETE FROM employee;

-- Verify table is empty but still exists
SELECT * FROM employee;

-- Add more data for conditional DELETE examples
INSERT INTO employee
VALUES
    (4, 'Alice', 'Johnson', '1992-07-20', 'UK'),
    (5, 'Charlie', 'Brown', '1988-12-30', 'AU'),
    (6, 'Randy', 'Caldwell', '1970-01-02', 'FI'),
    (7, 'Bob', 'Smith', '1985-03-15', 'US'),
    (8, 'Emma', 'Wilson', '1990-11-08', 'CA'),
    (9, 'Test', 'User', '1980-01-01', 'FI');

-- Show data before conditional deletions
SELECT * FROM employee ORDER BY employee_id;

-- Example 2: DELETE with WHERE condition - Remove specific employee
-- This is the most common and safe way to delete records
DELETE FROM employee
WHERE employee_id = 6;

-- Example 3: DELETE with multiple conditions - Remove employees from Finland
DELETE FROM employee
WHERE country_code = 'FI';

-- Verify the conditional deletions
SELECT * FROM employee ORDER BY employee_id;

-- Example 4: DELETE with JOIN using USING clause
-- Create a table of employees to be removed for GDPR compliance
CREATE OR REPLACE TABLE gdpr_employee (
    employee_id INTEGER NOT NULL PRIMARY KEY
);

INSERT INTO gdpr_employee
VALUES
    (4),
    (5);

-- Show employees marked for deletion
SELECT * FROM gdpr_employee;

-- DELETE using JOIN - Remove employees listed in gdpr_employee table
DELETE FROM employee
USING gdpr_employee
WHERE employee.employee_id = gdpr_employee.employee_id;

-- Verify final results
SELECT * FROM employee ORDER BY employee_id;

-- Clean up - Remove all objects created in this demo
DROP TABLE employee;
DROP TABLE gdpr_employee;
DROP SCHEMA demo_schema;