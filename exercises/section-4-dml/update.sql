-- SQL UPDATE Examples - Modifying existing data in tables
-- This file demonstrates various UPDATE statement patterns

-- UPDATE COMMAND SYNTAX:
-- UPDATE <table_name> SET <column> = <value> WHERE <condition>;        -- Basic update
-- UPDATE <table_name> SET col1 = val1, col2 = val2 WHERE <condition>; -- Multi-column update
-- UPDATE <table_name> SET <column> = <value> FROM <other_table>        -- Update with JOIN
--   WHERE <table_name>.<col> = <other_table>.<col>;

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create employee table for UPDATE examples
CREATE TABLE employee (
    employee_id NUMERIC(3,0) NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Insert sample data with one employee having an unusual ID
INSERT INTO EMPLOYEE 
VALUES 
    (1, 'Prakash', 'Das', '1987-01-02', 'IN'),
    (2, 'Madiha', 'Bradford', '1975-10-02', 'GB'),
    (3, 'James', 'Lines', '1999-09-20', 'GB'),
    (4, 'Amar', 'Krishnan', '2002-01-02', 'IN'), 
    (5, 'Inaaya', 'Andrews', '2001-01-02', 'US'), 
    (653, 'Randy', 'Caldwell', '1970-01-02', 'FI');

-- Example 1: Simple UPDATE - Fix the unusual employee ID
UPDATE employee
SET employee_id = 6 
WHERE employee_id = 653;

-- Verify the change
SELECT *
FROM employee
ORDER BY employee_id;

-- Example 2: Multiple single-column UPDATEs - Convert to 3-letter country codes
UPDATE employee
SET country_code = 'IND' 
WHERE country_code = 'IN';

UPDATE employee
SET country_code = 'FIN'
WHERE country_code = 'FI';

UPDATE employee
SET country_code = 'GBR'
WHERE country_code = 'GB';

UPDATE employee
SET country_code = 'USA'
WHERE country_code = 'US';

-- Check results after country code updates
SELECT *
FROM employee
ORDER BY employee_id;

-- Example 3: UPDATE with JOIN - Using a lookup table
-- Create a reference table for country codes
CREATE TABLE iso_country_code (
    country_code_alpha2 STRING(2),
    country_code_alpha3 STRING(3), 
    country_name STRING
);

-- Populate the lookup table
INSERT INTO iso_country_code
VALUES
    ('IN', 'IND', 'India'),
    ('FI', 'FIN', 'Finland'),
    ('GB', 'GBR', 'United Kingdom'),
    ('US', 'USA', 'United States of America');

-- UPDATE using JOIN - Convert 3-letter codes back to 2-letter codes
UPDATE employee
SET country_code = iso_country_code.country_code_alpha2
FROM iso_country_code
WHERE employee.country_code = iso_country_code.country_code_alpha3;

-- Verify the conversion to 2-letter codes
SELECT *
FROM employee
ORDER BY employee_id;

-- UPDATE using JOIN again - Convert back to 3-letter codes
UPDATE employee
SET country_code = iso_country_code.country_code_alpha3
FROM iso_country_code
WHERE employee.country_code = iso_country_code.country_code_alpha2;

-- Final verification
SELECT *
FROM employee
ORDER BY employee_id;

-- Clean up - Remove all objects created in this demo
DROP TABLE employee;
DROP TABLE iso_country_code;
DROP SCHEMA demo_schema;
