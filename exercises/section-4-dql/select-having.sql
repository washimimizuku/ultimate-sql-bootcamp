-- SQL HAVING Clause Examples - Data Query Language (DQL)
-- This file demonstrates the HAVING clause for filtering grouped results
-- HAVING filters groups after GROUP BY, while WHERE filters rows before grouping

-- HAVING CLAUSE FUNDAMENTALS:
-- Purpose: Filter groups based on aggregate conditions
-- Syntax: SELECT ... FROM ... WHERE ... GROUP BY ... HAVING ... ORDER BY ...
-- Key difference: WHERE filters rows, HAVING filters groups
-- Usage: Can only reference columns in GROUP BY or aggregate functions

-- Common HAVING patterns:
-- - COUNT(*) > n (groups with more than n rows)
-- - AVG(column) > value (groups with average above threshold)
-- - SUM(column) BETWEEN x AND y (groups with totals in range)
-- - MAX(column) IS NOT NULL (groups with non-null maximum)

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
-- Basic HAVING Examples
-- =============================================

-- Example 1: Starship classes with more than 1 ship
SELECT 
    starship_class, 
    COUNT(*) AS ship_count
FROM starship 
GROUP BY starship_class 
HAVING COUNT(*) > 1
ORDER BY ship_count DESC;

-- Example 2: Classes with average cargo capacity below 10,000
SELECT 
    starship_class, 
    AVG(cargo_capacity) AS avg_cargo,
    COUNT(*) AS ship_count
FROM starship 
WHERE cargo_capacity IS NOT NULL
GROUP BY starship_class 
HAVING AVG(cargo_capacity) < 10000
ORDER BY avg_cargo DESC;

-- Example 3: Expensive ship classes (average cost > 100,000)
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship 
WHERE cost_in_credits IS NOT NULL
GROUP BY starship_class 
HAVING AVG(cost_in_credits) > 100000
ORDER BY avg_cost DESC;

-- =============================================
-- Advanced HAVING Examples
-- =============================================

-- Example 4: Multiple HAVING conditions
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost,
    MIN(cost_in_credits) AS min_cost,
    MAX(cost_in_credits) AS max_cost
FROM starship 
WHERE cost_in_credits IS NOT NULL
GROUP BY starship_class
HAVING COUNT(*) > 1 AND AVG(cost_in_credits) > 50000
ORDER BY avg_cost DESC;

-- Example 5: HAVING with range conditions
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    AVG(length) AS avg_length
FROM starship 
WHERE length IS NOT NULL
GROUP BY starship_class
HAVING AVG(length) BETWEEN 10 AND 100
ORDER BY avg_length;

-- Example 6: HAVING with string aggregates
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    STRING_AGG(name, ', ') AS ship_names
FROM starship
GROUP BY starship_class
HAVING COUNT(*) >= 2
ORDER BY ship_count DESC;

-- =============================================
-- WHERE vs HAVING Comparison
-- =============================================

-- Example 7: WHERE filters rows before grouping
SELECT 
    starship_class,
    COUNT(*) AS expensive_ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship 
WHERE cost_in_credits > 1000000  -- Filter individual ships first
GROUP BY starship_class
ORDER BY expensive_ship_count DESC;

-- Example 8: HAVING filters groups after aggregation
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship 
WHERE cost_in_credits IS NOT NULL
GROUP BY starship_class
HAVING AVG(cost_in_credits) > 1000000  -- Filter groups by average
ORDER BY avg_cost DESC;

-- Example 9: Combined WHERE and HAVING
SELECT 
    starship_class,
    COUNT(*) AS large_ship_count,
    AVG(cost_in_credits) AS avg_cost
FROM starship 
WHERE length > 50  -- Filter: only large ships
GROUP BY starship_class
HAVING COUNT(*) > 1  -- Filter: classes with multiple large ships
ORDER BY avg_cost DESC;

-- Cleanup: Remove demo objects
DROP TABLE starship;
DROP SCHEMA demo_schema;