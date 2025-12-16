-- SQL MERGE Examples - Upserting data (INSERT or UPDATE based on conditions)
-- This file demonstrates MERGE statement usage for synchronizing tables
-- MERGE combines INSERT, UPDATE, and DELETE operations in a single statement

-- MERGE COMMAND SYNTAX:
-- MERGE INTO <target_table> AS <alias>                        -- Target table to modify
-- USING <source_table> AS <alias>                             -- Source table with changes
-- ON <join_condition>                                          -- Matching condition
-- WHEN MATCHED THEN UPDATE SET <column> = <value>             -- Update existing rows
-- WHEN NOT MATCHED THEN INSERT (<columns>) VALUES (<values>)  -- Insert new rows
-- WHEN NOT MATCHED BY SOURCE THEN DELETE;                     -- Delete unmatched rows (optional)

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create employee table for MERGE examples
CREATE OR REPLACE TABLE employee (
    employee_id INTEGER NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Insert initial diverse employee data
INSERT INTO employee 
VALUES 
    (1, 'Alice', 'Johnson', '1985-03-15', 'US'),
    (2, 'Carlos', 'Rodriguez', '1990-07-22', 'MX'),
    (3, 'Emma', 'Chen', '1988-11-08', 'CA'),
    (4, 'Raj', 'Patel', '1992-01-30', 'IN'),
    (5, 'Sophie', 'Mueller', '1987-09-12', 'DE'),
    (6, 'Kenji', 'Tanaka', '1991-05-18', 'JP'),
    (7, 'Maria', 'Silva', '1989-12-03', 'BR'),
    (8, 'Ahmed', 'Hassan', '1986-08-25', 'EG'),
    (9, 'Olga', 'Petrov', '1993-04-07', 'RU'),
    (10, 'James', 'O''Connor', '1984-10-14', 'IE');

-- Show initial employee data
SELECT * FROM employee ORDER BY employee_id;

-- Create employee_changes table with same structure as employee
CREATE TABLE employee_changes AS SELECT * FROM employee LIMIT 0;

-- Verify the structure was copied
DESCRIBE employee_changes;

-- Insert changes: updates for existing employees (1,3,5,7) and one new employee (30)
-- This demonstrates both UPDATE and INSERT scenarios for MERGE
INSERT INTO employee_changes 
VALUES 
    (1, 'Alice', 'Johnson-Smith', '1985-03-15', 'CA'),  -- Name and country change
    (3, 'Emma', 'Chen-Wong', '1988-11-08', 'US'),       -- Name and country change
    (5, 'Sophie', 'Mueller-Schmidt', '1987-09-12', 'AT'), -- Name and country change
    (7, 'Maria', 'Silva-Santos', '1989-12-03', 'PT'),   -- Name and country change
    (30, 'Nuno', 'Barreto', '1976-12-03', 'PT');       -- New employee

-- Show the changes to be applied
SELECT * FROM employee_changes ORDER BY employee_id;

-- Example: MERGE statement - Synchronize employee table with changes
-- This will UPDATE existing employees (IDs 1,3,5,7) and INSERT new employee (ID 30)
MERGE INTO employee AS e
USING employee_changes AS ec
ON e.employee_id = ec.employee_id
WHEN MATCHED THEN 
    UPDATE SET first_name = ec.first_name,
               last_name = ec.last_name,
               birthdate = ec.birthdate,
               country_code = ec.country_code
WHEN NOT MATCHED THEN 
    INSERT (employee_id, first_name, last_name, birthdate, country_code)
    VALUES (ec.employee_id, ec.first_name, ec.last_name, ec.birthdate, ec.country_code);

-- Verify the MERGE results
-- Notice: IDs 1,3,5,7 have updated information, ID 30 was inserted, others unchanged
SELECT * FROM employee ORDER BY employee_id;

-- Clean up - Remove all objects created in this demo
DROP TABLE employee;
DROP TABLE employee_changes;
DROP SCHEMA demo_schema;