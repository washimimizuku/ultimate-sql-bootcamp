-- SQL SELECT ORDER BY Examples - Data Query Language (DQL)
-- This file demonstrates ORDER BY clause usage for sorting query results
-- ORDER BY clause is essential for controlling the sequence of returned data

-- ORDER BY CLAUSE SYNTAX:
-- SELECT <columns> FROM <table> ORDER BY <column>;          -- Basic sorting
-- SELECT <columns> FROM <table> ORDER BY <column> ASC;     -- Ascending order (default)
-- SELECT <columns> FROM <table> ORDER BY <column> DESC;    -- Descending order
-- SELECT <columns> FROM <table> ORDER BY <col1>, <col2>;   -- Multiple column sorting
-- SELECT <columns> FROM <table> ORDER BY 1, 2;            -- Sort by column position
-- SELECT <columns> FROM <table> ORDER BY <col> NULLS FIRST; -- NULL handling
-- SELECT <columns> FROM <table> ORDER BY <col> NULLS LAST;  -- NULL handling

-- ORDER BY features:
-- - ASC: Ascending order (A-Z, 0-9, oldest to newest)
-- - DESC: Descending order (Z-A, 9-0, newest to oldest)
-- - NULLS FIRST: NULL values appear at the beginning
-- - NULLS LAST: NULL values appear at the end
-- - Multiple columns: Sort by first column, then by second, etc.
-- - Column positions: Use numbers instead of column names

-- Setup: Create demo schema and load starship data
CREATE SCHEMA demo_schema;
USE demo_schema;

-- Load starship data from CSV file
CREATE TABLE starship AS SELECT * FROM 'data/star-wars/starships.csv';

-- Convert string columns to appropriate numeric types
-- Handle 'NA' values by converting them to NULL
ALTER TABLE starship ALTER cost_in_credits TYPE BIGINT 
    USING NULLIF(cost_in_credits, 'NA')::BIGINT;
    
ALTER TABLE starship ALTER length TYPE DECIMAL 
    USING NULLIF(REPLACE(length, ',', ''), 'NA')::DECIMAL;
    
ALTER TABLE starship ALTER max_atmosphering_speed TYPE INTEGER 
    USING NULLIF(NULLIF(REGEXP_REPLACE(max_atmosphering_speed, '[^0-9]', '', 'g'), ''), 'NA')::INTEGER;
    
ALTER TABLE starship ALTER crew TYPE INTEGER 
    USING NULLIF(crew, 'NA')::INTEGER;
    
ALTER TABLE starship ALTER passengers TYPE INTEGER 
    USING NULLIF(passengers, 'NA')::INTEGER;
    
ALTER TABLE starship ALTER cargo_capacity TYPE BIGINT 
    USING NULLIF(cargo_capacity, 'NA')::BIGINT;
    
ALTER TABLE starship ALTER hyperdrive_rating TYPE DECIMAL 
    USING NULLIF(hyperdrive_rating, 'NA')::DECIMAL;
    
ALTER TABLE starship ALTER MGLT TYPE INTEGER 
    USING NULLIF(MGLT, 'NA')::INTEGER;

-- View table structure after type conversions
DESCRIBE starship;

-- =============================================
-- Basic ORDER BY Examples
-- =============================================

-- Example 1: Sort by column name (alphabetical order)
SELECT 
    name, 
    model
FROM starship
WHERE cost_in_credits > 1000000
ORDER BY name;

-- Example 2: Sort by column position (first column)
SELECT 
    name, 
    model
FROM starship
WHERE cost_in_credits > 1000000
ORDER BY 1;

-- Example 3: Sort by numeric column (default ascending)
SELECT 
    name, 
    model, 
    cost_in_credits
FROM starship
WHERE cost_in_credits > 1000000
ORDER BY cost_in_credits;

-- =============================================
-- Explicit Sort Direction
-- =============================================

-- Example 4: Explicit ascending order (same as default)
SELECT 
    name, 
    model, 
    cost_in_credits
FROM starship
WHERE cost_in_credits > 1000000
ORDER BY cost_in_credits ASC;

-- Example 5: Descending order (highest to lowest)
SELECT 
    name, 
    model, 
    cost_in_credits
FROM starship
WHERE cost_in_credits > 1000000
ORDER BY cost_in_credits DESC;

-- =============================================
-- ORDER BY with LIMIT
-- =============================================

-- Example 6: Top 10 most expensive starships
SELECT 
    name, 
    model, 
    cost_in_credits
FROM starship
ORDER BY cost_in_credits DESC
LIMIT 10;

-- Example 7: Top 10 least expensive starships
SELECT 
    name, 
    model, 
    cost_in_credits
FROM starship
ORDER BY cost_in_credits ASC
LIMIT 10;

-- =============================================
-- NULL Value Handling
-- =============================================

-- Example 8: Show unique costs (default NULL handling)
SELECT DISTINCT cost_in_credits
FROM starship
ORDER BY cost_in_credits;

-- Example 9: NULL values first in sort order
SELECT DISTINCT cost_in_credits
FROM starship
ORDER BY cost_in_credits NULLS FIRST;

-- Example 10: NULL values last in sort order
SELECT DISTINCT cost_in_credits
FROM starship
ORDER BY cost_in_credits NULLS LAST;

-- Cleanup: Remove demo objects
DROP TABLE IF EXISTS starship;
DROP SCHEMA IF EXISTS demo_schema;