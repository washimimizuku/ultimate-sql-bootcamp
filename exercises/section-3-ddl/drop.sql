-- SQL DROP Examples - Removing database objects
-- This file demonstrates how to safely remove database objects
-- WARNING: DROP operations are destructive and cannot be undone!

-- DROP COMMAND SYNTAX:
-- DROP TABLE <table_name>;           -- Remove table and all its data
-- DROP SCHEMA <schema_name>;         -- Remove schema (must be empty)
-- DROP DATABASE <database_name>;     -- Remove database (must be empty)
-- DROP TABLE IF EXISTS <table_name>; -- Remove table only if it exists

-- Setup: Create objects that we will then drop
CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create a sample table
CREATE TABLE employee (
    employee_id NUMERIC NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Verify objects exist before dropping
SHOW TABLES;        -- Should show the employee table
DESCRIBE employee;  -- Show table structure

-- Example 1: DROP TABLE - Remove a table and all its data
-- This permanently deletes the table and all data within it
DROP TABLE employee;

-- Example 2: DROP SCHEMA - Remove a schema
-- Note: Schema must be empty (no tables) before it can be dropped
DROP SCHEMA demo_schema;

-- Verify cleanup was successful
-- This should show no tables since we're back in the main schema
SHOW TABLES;
