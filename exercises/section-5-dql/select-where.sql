-- SQL SELECT WHERE Examples - Data Query Language (DQL)
-- This file demonstrates WHERE clause usage for filtering data in SELECT statements
-- WHERE clause is essential for conditional data retrieval in SQL

-- WHERE CLAUSE SYNTAX:
-- SELECT <columns> FROM <table> WHERE <condition>;           -- Basic filtering
-- SELECT <columns> FROM <table> WHERE <col> = <value>;       -- Equality comparison
-- SELECT <columns> FROM <table> WHERE <col> > <value>;       -- Numeric comparison
-- SELECT <columns> FROM <table> WHERE <col> LIKE <pattern>;  -- Pattern matching
-- SELECT <columns> FROM <table> WHERE <col> IN (<values>);   -- Multiple value matching
-- SELECT <columns> FROM <table> WHERE <col> IS NULL;        -- NULL value checking
-- SELECT <columns> FROM <table> WHERE <cond1> AND <cond2>;  -- Logical AND
-- SELECT <columns> FROM <table> WHERE <cond1> OR <cond2>;   -- Logical OR
-- SELECT <columns> FROM <table> WHERE NOT <condition>;      -- Logical NOT

-- WHERE clause operators:
-- - Comparison: =, !=, <>, <, >, <=, >=
-- - Logical: AND, OR, NOT
-- - Pattern: LIKE, ILIKE (case-insensitive)
-- - Set: IN, NOT IN
-- - Range: BETWEEN, NOT BETWEEN
-- - NULL: IS NULL, IS NOT NULL

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
-- Basic WHERE Conditions
-- =============================================

-- Example 1: Exact match (case-sensitive)
SELECT * FROM starship 
WHERE starship_class = 'Starfighter';

-- Example 2: Not equal operator
SELECT * FROM starship 
WHERE starship_class != 'starfighter';

-- Example 3: Numeric comparison - greater than
SELECT * FROM starship 
WHERE cost_in_credits > 10000000;

-- Example 4: Numeric comparison - less than
SELECT * FROM starship 
WHERE cost_in_credits < 100000;

-- =============================================
-- Logical Operators (AND, OR, NOT)
-- =============================================

-- Example 5: AND operator - both conditions must be true
SELECT * FROM starship 
WHERE starship_class = 'Starfighter' 
  AND cost_in_credits >= 200000;

-- Example 6: OR operator - either condition can be true
SELECT * FROM starship 
WHERE starship_class = 'Starfighter' 
   OR starship_class = 'starfighter';

-- Example 7: NOT operator - negates the condition
SELECT * FROM starship 
WHERE NOT starship_class = 'Starfighter' 
  AND cost_in_credits >= 100000000;

-- =============================================
-- Complex WHERE Conditions
-- =============================================

-- Example 8: Multiple AND conditions with specific columns
SELECT
    name, 
    model, 
    manufacturer
FROM starship
WHERE cost_in_credits < 1000000
  AND starship_class = 'Starfighter'
  AND hyperdrive_rating >= 1;

-- Example 9: Combining OR and AND with parentheses
SELECT
    name, 
    model, 
    manufacturer
FROM starship
WHERE (starship_class = 'Starfighter' OR starship_class = 'starfighter')
  AND cost_in_credits < 1000000;

-- Example 10: Complex condition with NOT and NULL handling
SELECT
    name, 
    model, 
    manufacturer, 
    starship_class
FROM starship
WHERE NOT (starship_class = 'Starfighter' OR starship_class = 'starfighter')
  AND (cost_in_credits < 1000000 OR cost_in_credits IS NULL);

-- =============================================
-- Pattern Matching and Set Operations
-- =============================================

-- Example 11: LIKE operator for pattern matching
SELECT
    name, 
    model, 
    manufacturer, 
    starship_class, 
    cost_in_credits
FROM starship
WHERE starship_class LIKE '%cruiser%';

-- Example 12: IN operator for multiple values
SELECT
    name, 
    model, 
    manufacturer, 
    starship_class, 
    cost_in_credits
FROM starship
WHERE starship_class IN ('starfighter', 'Starfighter');

-- Example 13: NOT IN operator to exclude multiple values
SELECT
    name, 
    model, 
    manufacturer, 
    starship_class, 
    cost_in_credits
FROM starship
WHERE starship_class NOT IN ('starfighter', 'Starfighter');

-- Cleanup: Remove demo objects
DROP TABLE starship;
DROP SCHEMA demo_schema;
