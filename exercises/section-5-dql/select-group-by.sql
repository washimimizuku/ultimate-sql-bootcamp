-- SQL SELECT GROUP BY Examples - Data Query Language (DQL)
-- This file demonstrates GROUP BY clause usage for data aggregation and grouping
-- GROUP BY is essential for creating summary reports and analyzing data by categories

-- GROUP BY CLAUSE SYNTAX:
-- SELECT <columns>, <aggregate_functions> FROM <table> GROUP BY <columns>;
-- SELECT <columns>, <aggregate_functions> FROM <table> GROUP BY 1, 2;  -- By position
-- SELECT <columns>, <aggregate_functions> FROM <table> GROUP BY ROLLUP(<columns>);
-- SELECT <columns>, <aggregate_functions> FROM <table> GROUP BY CUBE(<columns>);
-- SELECT <columns>, <aggregate_functions> FROM <table> GROUP BY GROUPING SETS(...);

-- GROUP BY features:
-- - Groups rows with same values in specified columns
-- - Enables aggregate functions to work on each group
-- - Must include all non-aggregate SELECT columns in GROUP BY
-- - Can group by column names or positions (1, 2, 3...)
-- - ROLLUP: Creates subtotals and grand totals
-- - CUBE: Creates all possible combinations of groupings
-- - GROUPING SETS: Specify custom grouping combinations

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
-- Basic GROUP BY Examples
-- =============================================

-- Example 1: Simple grouping by starship class
SELECT 
    starship_class, 
    COUNT(name) AS starship_count 
FROM starship 
GROUP BY starship_class 
ORDER BY starship_count DESC;

-- Example 2: Multiple aggregates with grouping
SELECT
    starship_class,
    COUNT(name) AS starship_count,
    MAX(cost_in_credits) AS max_cost,
    MIN(cost_in_credits) AS min_cost,
    AVG(cost_in_credits) AS avg_cost,
    SUM(cost_in_credits) AS sum_cost
FROM starship
GROUP BY starship_class
ORDER BY starship_count DESC;

-- Example 3: Filtering before grouping (WHERE clause)
SELECT
    starship_class,
    COUNT(*) AS expensive_ships,
    AVG(cost_in_credits) AS avg_cost
FROM starship
WHERE cost_in_credits > 1000000
GROUP BY starship_class
ORDER BY expensive_ships DESC;

-- =============================================
-- Multiple Column Grouping
-- =============================================

-- Example 4: Group by multiple columns
SELECT
    starship_class,
    crew,
    COUNT(name) AS starship_count,
    MAX(cost_in_credits) AS max_cost,
    MIN(cost_in_credits) AS min_cost,
    AVG(cost_in_credits) AS avg_cost,
    SUM(cost_in_credits) AS sum_cost
FROM starship
GROUP BY starship_class, crew
ORDER BY starship_count DESC, crew DESC;

-- Example 5: Group by column positions (alternative syntax)
SELECT
    starship_class,
    crew,
    COUNT(name) AS starship_count,
    MAX(cost_in_credits) AS max_cost,
    MIN(cost_in_credits) AS min_cost,
    AVG(cost_in_credits) AS avg_cost,
    SUM(cost_in_credits) AS sum_cost
FROM starship
GROUP BY 1, 2  -- Group by first and second columns
ORDER BY 3 DESC, 2 DESC;  -- Order by third and second columns

-- =============================================
-- Advanced Grouping with ROLLUP
-- =============================================

-- Example 6: ROLLUP for subtotals and grand totals
SELECT
    starship_class,
    crew,
    SUM(cost_in_credits) AS sum_cost,
    COUNT(*) AS ship_count
FROM starship
GROUP BY ROLLUP(starship_class, crew)
ORDER BY starship_class NULLS LAST, crew NULLS LAST;

-- Example 7: CUBE for all possible grouping combinations
SELECT
    starship_class,
    CASE 
        WHEN length > 100 THEN 'Large'
        WHEN length > 20 THEN 'Medium' 
        ELSE 'Small'
    END AS size_category,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship
WHERE length IS NOT NULL
GROUP BY CUBE(starship_class, 
              CASE 
                  WHEN length > 100 THEN 'Large'
                  WHEN length > 20 THEN 'Medium' 
                  ELSE 'Small'
              END)
ORDER BY starship_class NULLS LAST, size_category NULLS LAST;

-- Example 8: GROUPING SETS for custom grouping combinations
SELECT
    starship_class,
    manufacturer,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship
GROUP BY GROUPING SETS (
    (starship_class),           -- Group by class only
    (manufacturer),             -- Group by manufacturer only
    (starship_class, manufacturer), -- Group by both
    ()                          -- Grand total
)
ORDER BY starship_class NULLS LAST, manufacturer NULLS LAST;

-- =============================================
-- GROUP BY with Conditional Logic
-- =============================================

-- Example 9: Conditional aggregation within groups
SELECT
    starship_class,
    COUNT(*) AS total_ships,
    SUM(CASE WHEN cost_in_credits > 100000000 THEN 1 ELSE 0 END) AS expensive_ships,
    SUM(CASE WHEN crew = 1 THEN 1 ELSE 0 END) AS single_pilot_ships,
    AVG(CASE WHEN length > 50 THEN length ELSE NULL END) AS avg_length_large_ships
FROM starship
GROUP BY starship_class
ORDER BY total_ships DESC;

-- Cleanup: Remove demo objects
DROP TABLE starship;
DROP SCHEMA demo_schema;