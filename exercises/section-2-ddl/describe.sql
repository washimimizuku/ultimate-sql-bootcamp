-- SQL DESCRIBE Examples - Examining table structure
-- This file demonstrates how to inspect table definitions

-- DESCRIBE COMMAND SYNTAX:
-- DESCRIBE TABLE <table_name>;       -- Show detailed table structure
-- DESC <table_name>;                 -- Short form of DESCRIBE
-- DESCRIBE SCHEMA <schema_name>;     -- Show schema information

-- Setup: Create schema and table for DESCRIBE examples
CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create a sample table with various data types and constraints
CREATE TABLE employee (
    employee_id NUMERIC NOT NULL PRIMARY KEY,  -- Primary key constraint
    first_name STRING,                         -- Variable-length string
    last_name STRING,
    birthdate DATE,                            -- Date data type
    country_code STRING
);

-- Example: DESCRIBE TABLE - Show detailed table structure
-- This displays column names, data types, nullability, and constraints
-- Very useful for understanding existing table schemas
DESCRIBE TABLE employee;

-- Cleanup - Remove all objects created in this demo
DROP TABLE employee;
DROP SCHEMA demo_schema;
