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
CREATE TABLE starship AS SELECT * FROM 'data/star-wars/starships.csv';

-- Examine the automatically created table structure
DESCRIBE starship;

-- Show sample data loaded from CSV
SELECT * FROM starship LIMIT 5;

-- Example 2: COPY FROM into existing table
-- First, clear the existing data
TRUNCATE starship;

-- Verify table is empty
SELECT COUNT(*) as row_count FROM starship;

-- Use COPY FROM to reload data into existing table structure
-- This is useful when you want to control the table schema first
COPY starship FROM 'data/star-wars/starships.csv' (FORMAT CSV, HEADER, DELIMITER ',');

-- Verify data was loaded successfully
SELECT COUNT(*) as total_starships FROM starship;

-- Show sample of loaded data
SELECT * FROM starship LIMIT 10;

-- Example 3: Query file directly without creating table
-- DuckDB allows querying files directly for exploration
SELECT COUNT(*) as direct_count 
FROM 'data/star-wars/starships.csv';

-- Example 4: Loading Parquet files
-- DuckDB natively supports Parquet format with automatic schema detection
-- Parquet files are columnar and often more efficient than CSV
CREATE TABLE passenger AS SELECT * FROM 'data/titanic/titanic.parquet';

-- Examine the Parquet-based table structure
DESCRIBE passenger;

-- Show sample passenger data from Parquet file
SELECT * FROM passenger LIMIT 5;

-- Example 5: Loading multiple related CSV files
-- Load Star Wars characters data
CREATE TABLE character AS SELECT * FROM 'data/star-wars/characters.csv';
SELECT * FROM character LIMIT 3;

-- Load Star Wars planets data
CREATE TABLE planet AS SELECT * FROM 'data/star-wars/planets.csv';
SELECT * FROM planet LIMIT 3;

-- Load Star Wars species data
CREATE TABLE species AS SELECT * FROM 'data/star-wars/species.csv';
SELECT * FROM species LIMIT 3;

-- Load Star Wars vehicles data
CREATE TABLE vehicle AS SELECT * FROM 'data/star-wars/vehicles.csv';
SELECT * FROM vehicle LIMIT 3;

-- Example 6: Query across multiple loaded tables
-- Show total counts from all Star Wars datasets
SELECT 
    (SELECT COUNT(*) FROM character) as characters,
    (SELECT COUNT(*) FROM planet) as planets,
    (SELECT COUNT(*) FROM species) as species,
    (SELECT COUNT(*) FROM starship) as starships,
    (SELECT COUNT(*) FROM vehicle) as vehicles;

-- Clean up - Remove all objects created in this demo
DROP TABLE passenger;
DROP TABLE starship;
DROP TABLE character;
DROP TABLE planet;
DROP TABLE species;
DROP TABLE vehicle;
DROP SCHEMA demo_schema;