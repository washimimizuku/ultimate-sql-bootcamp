-- SQL TRUNCATE Examples - Quickly removing all data from tables
-- This file demonstrates TRUNCATE statement usage and differences from DELETE
-- WARNING: TRUNCATE operations are destructive and cannot be undone!

-- TRUNCATE COMMAND SYNTAX:
-- TRUNCATE TABLE <table_name>;                    -- Remove all rows quickly
-- TRUNCATE <table_name>;                          -- Short form (TABLE keyword optional)

-- TRUNCATE vs DELETE differences:
-- - TRUNCATE is faster for large tables (no row-by-row processing)
-- - TRUNCATE cannot use WHERE clause (removes ALL rows)
-- - TRUNCATE resets auto-increment counters
-- - TRUNCATE uses less transaction log space
-- - DELETE can be rolled back more easily

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create employee table for TRUNCATE examples
CREATE OR REPLACE TABLE employee (
    employee_id INTEGER NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Insert diverse sample data
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

-- Show initial data before truncation
SELECT * FROM employee ORDER BY employee_id;

-- Example: TRUNCATE TABLE - Remove all rows quickly
-- This is much faster than DELETE FROM employee for large tables
-- The table structure remains intact, only data is removed
TRUNCATE TABLE employee;

-- Verify table is empty but structure remains
SELECT * FROM employee;
SELECT COUNT(*) as row_count FROM employee;

-- Show that table structure is still intact
DESCRIBE employee;

-- Clean up - Remove all objects created in this demo
DROP TABLE employee;
DROP SCHEMA demo_schema;