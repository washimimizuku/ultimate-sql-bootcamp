-- SQL SELECT FROM Examples - Data Query Language (DQL)
-- This file demonstrates SELECT FROM statement usage for querying data
-- SELECT FROM is the foundation of data retrieval in SQL

-- SELECT FROM COMMAND SYNTAX:
-- SELECT <columns> FROM <table>;                             -- Basic column selection
-- SELECT * FROM <table>;                                     -- Select all columns
-- SELECT <column> AS <alias> FROM <table>;                  -- Column aliasing
-- SELECT DISTINCT <column> FROM <table>;                    -- Unique values only
-- SELECT * FROM <table> LIMIT <n>;                          -- Limit result rows
-- SELECT * FROM <table> LIMIT <n> OFFSET <m>;               -- Skip and limit rows
-- SELECT * EXCLUDE <column> FROM <table>;                   -- Exclude specific columns

-- SELECT FROM vs other DQL statements:
-- - SELECT FROM retrieves data without modifying it
-- - WHERE clause filters rows based on conditions
-- - ORDER BY sorts results
-- - GROUP BY aggregates data
-- - HAVING filters grouped results

CREATE SCHEMA demo_schema;
USE demo_schema;

-- Load sample data from Star Wars starships CSV file
CREATE TABLE starship AS SELECT * FROM 'data/star-wars/starships.csv';

-- Example 1: Examine table structure
-- DESCRIBE shows column names, types, and constraints
DESCRIBE starship;

-- Example 2: Select single column
-- Returns only the 'name' column for all rows
SELECT name FROM starship;

-- Example 3: Select multiple specific columns
-- Choose only the columns you need for better performance
SELECT name, model, manufacturer FROM starship;

-- Example 4: Select all columns
-- Use * to retrieve all columns (be careful with large tables)
SELECT * FROM starship;

-- Example 5: Exclude specific columns
-- DuckDB's EXCLUDE syntax removes unwanted columns from SELECT *
SELECT * EXCLUDE cost_in_credits FROM starship;

-- Example 6: Column aliasing
-- Use AS to give columns more readable names in results
SELECT 
    name,
    cost_in_credits AS cost,
    starship_class AS class
FROM starship;

-- Example 7: String concatenation and type casting
-- Transform data during selection with functions and operators
SELECT
    'USS ' || name AS name,
    'Star Trek Shipyard' AS manufacturer,
    ROUND(CAST(cost_in_credits AS BIGINT) / 1000) || 'K' AS cost
FROM starship
WHERE cost_in_credits != 'NA';

-- Example 8: Create table from SELECT results
-- SELECT can be used to create new tables with transformed data
CREATE TABLE starship_star_trek AS
SELECT
    'USS ' || name AS name,
    'Star Trek Shipyard' AS manufacturer,
    ROUND(CAST(cost_in_credits AS BIGINT) / 1000) || 'K' AS cost
FROM starship
WHERE cost_in_credits != 'NA';

-- Verify the new table was created with transformed data
SELECT * FROM starship_star_trek;

-- Example 9: DISTINCT for unique values
-- Compare unique manufacturers between original and transformed tables
SELECT DISTINCT manufacturer FROM starship;
SELECT DISTINCT manufacturer FROM starship_star_trek;

-- Example 10: LIMIT for result pagination
-- Limit results to first 10 rows for large datasets
SELECT * FROM starship LIMIT 10;

-- Example 11: LIMIT with OFFSET for pagination
-- Skip first 5 rows, then return next 10 rows
SELECT * FROM starship LIMIT 10 OFFSET 5;

-- Clean up - Remove all objects created in this demo
DROP TABLE starship_star_trek;
DROP TABLE starship;
DROP SCHEMA demo_schema;
