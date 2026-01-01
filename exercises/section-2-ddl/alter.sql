-- SQL ALTER Examples - Modifying existing database objects
-- This file demonstrates various ALTER TABLE operations

-- ALTER COMMAND SYNTAX:
-- ALTER TABLE <table_name> ADD COLUMN <column_name> <data_type>;     -- Add new column
-- ALTER TABLE <table_name> DROP COLUMN <column_name>;               -- Remove column
-- ALTER TABLE <table_name> ALTER <column_name> SET DATA TYPE <type>; -- Change data type
-- ALTER TABLE <table_name> RENAME TO <new_table_name>;              -- Rename table

-- Setup: Create schema and table for ALTER examples
CREATE SCHEMA demo_schema;
USE demo_schema;

-- Create initial table structure
CREATE TABLE employee (
    employee_id NUMERIC NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

-- Show initial table structure
DESCRIBE employee;

-- Example 1: ADD COLUMN - Add a new column to existing table
ALTER TABLE employee ADD COLUMN address STRING;
DESCRIBE employee; -- Notice the new address column

-- Example 2: DROP COLUMN - Remove a column from the table
ALTER TABLE employee DROP COLUMN address;
DESCRIBE employee; -- Address column is now gone

-- Example 3: ALTER COLUMN DATA TYPE - Change the data type of existing column
-- Note: This changes country_code from STRING to DECIMAL
ALTER TABLE employee ALTER country_code SET DATA TYPE DECIMAL(10,0);
DESCRIBE employee; -- Notice country_code is now DECIMAL instead of STRING

-- Cleanup - Remove all objects created in this demo
DROP TABLE employee;
DROP SCHEMA demo_schema;
