-- SQL COPY FROM Examples - Loading data from external files
-- This file demonstrates COPY FROM statement usage for bulk data loading
-- COPY FROM is efficient for loading large datasets from CSV, JSON, and other formats

-- COPY FROM COMMAND SYNTAX:
-- COPY <table_name> FROM '<file_path>';                       -- Basic file import
-- COPY <table_name> FROM '<file_path>' (DELIMITER ',');       -- Specify delimiter
-- COPY <table_name> FROM '<file_path>' (HEADER);              -- Skip header row
-- COPY <table_name> FROM '<file_path>' (FORMAT CSV);          -- Specify format
-- CREATE TABLE <name> AS SELECT * FROM '<file_path>';         -- Create table from file

-- COPY FROM vs INSERT differences:
-- - COPY FROM is much faster for large datasets
-- - COPY FROM can read directly from files (CSV, JSON, Parquet)
-- - COPY FROM handles data type inference automatically
-- - INSERT allows more control over individual values

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Example 1: CREATE TABLE AS SELECT from file
-- This automatically creates table structure based on CSV file
-- DuckDB infers column names from header and data types from content
CREATE TABLE movie AS SELECT * FROM 'exercises/section-4-dml/imdb_movies.csv';

-- Examine the automatically created table structure
DESCRIBE movie;

-- Show sample data loaded from CSV
SELECT * FROM movie LIMIT 5;

-- Example 2: COPY FROM into existing table
-- First, clear the existing data
TRUNCATE movie;

-- Verify table is empty
SELECT COUNT(*) as row_count FROM movie;

-- Use COPY FROM to reload data into existing table structure
-- This is useful when you want to control the table schema first
COPY movie FROM 'exercises/section-4-dml/imdb_movies.csv' (FORMAT CSV, HEADER, DELIMITER ',');

-- Verify data was loaded successfully
SELECT COUNT(*) as total_movies FROM movie;

-- Show sample of loaded data
SELECT * FROM movie LIMIT 10;

-- Example 3: Query file directly without creating table
-- DuckDB allows querying files directly for exploration
SELECT COUNT(*) as direct_count 
FROM 'exercises/section-4-dml/imdb_movies.csv';

-- Clean up - Remove all objects created in this demo
DROP TABLE movie;
DROP SCHEMA demo_schema;