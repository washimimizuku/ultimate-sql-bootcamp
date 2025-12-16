-- SQL Aggregate Functions Examples - Data Query Language (DQL)
-- This file demonstrates aggregate function usage for data summarization and analysis
-- Aggregate functions operate on groups of rows and return a single result per group

-- AGGREGATE FUNCTION CATEGORIES:
-- Basic Aggregates:
--   COUNT() - count rows, SUM() - total values, AVG() - average value
--   MIN() - minimum value, MAX() - maximum value
-- Statistical:
--   STDDEV() - standard deviation, VARIANCE() - variance
--   MEDIAN() - middle value, MODE() - most frequent value
-- String Aggregates:
--   STRING_AGG() - concatenate strings, ARRAY_AGG() - collect into array
-- Advanced:
--   COUNT(DISTINCT) - count unique values, GROUPING() - grouping indicator
--   PERCENTILE_CONT() - continuous percentile, PERCENTILE_DISC() - discrete percentile

-- Aggregate functions vs other functions:
-- - Aggregate: Return one value per group (many:1 relationship)
-- - Scalar: Return one value per input row (1:1 relationship)
-- - Window: Return one value per row but consider multiple rows
-- - Table: Return multiple rows and columns

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
-- Basic Aggregate Functions
-- =============================================

-- Example 1: Sum all starship costs
SELECT SUM(cost_in_credits) AS total_cost
FROM starship;

-- Example 2: Sum costs for specific starship class
SELECT SUM(cost_in_credits) AS starfighter_total_cost
FROM starship 
WHERE starship_class = 'Starfighter';

-- Example 3: Count total number of starships
SELECT COUNT(*) AS total_starships
FROM starship;

-- Example 4: Count starships of specific class
SELECT COUNT(*) AS starfighter_count
FROM starship 
WHERE starship_class = 'Starfighter';

-- Example 5: Count non-null values in a column
SELECT COUNT(cost_in_credits) AS ships_with_known_cost
FROM starship;

-- Example 6: Count distinct values
SELECT COUNT(DISTINCT starship_class) AS unique_ship_classes
FROM starship;

-- Example 7: Find maximum cost
SELECT MAX(cost_in_credits) AS most_expensive_ship
FROM starship;

-- Example 8: Find minimum cost
SELECT MIN(cost_in_credits) AS least_expensive_ship
FROM starship;

-- Example 9: Calculate average cost
SELECT AVG(cost_in_credits) AS average_cost
FROM starship;

-- =============================================
-- Statistical Aggregate Functions
-- =============================================

-- Example 10: Standard deviation of costs
SELECT STDDEV(cost_in_credits) AS cost_std_deviation
FROM starship;

-- Example 11: Variance of costs
SELECT VARIANCE(cost_in_credits) AS cost_variance
FROM starship;

-- Example 12: Median length
SELECT MEDIAN(length) AS median_length
FROM starship;

-- =============================================
-- String and Array Aggregates
-- =============================================

-- Example 13: Concatenate all starship names
SELECT STRING_AGG(name, ', ') AS all_ship_names
FROM starship
LIMIT 1;

-- Example 14: Collect starship classes into array
SELECT ARRAY_AGG(DISTINCT starship_class) AS ship_classes_array
FROM starship;

-- =============================================
-- Multiple Aggregates in One Query
-- =============================================

-- Example 15: Comprehensive statistics
SELECT 
    COUNT(*) AS total_ships,
    COUNT(cost_in_credits) AS ships_with_cost,
    SUM(cost_in_credits) AS total_cost,
    AVG(cost_in_credits) AS average_cost,
    MIN(cost_in_credits) AS min_cost,
    MAX(cost_in_credits) AS max_cost,
    STDDEV(cost_in_credits) AS cost_std_dev
FROM starship;

-- Example 16: Statistics by starship class
SELECT 
    starship_class,
    COUNT(*) AS ship_count,
    AVG(cost_in_credits) AS avg_cost,
    MIN(length) AS min_length,
    MAX(length) AS max_length
FROM starship
GROUP BY starship_class
ORDER BY ship_count DESC;

-- Example 17: Aggregates with filtering
SELECT 
    COUNT(*) AS expensive_ships,
    AVG(length) AS avg_length_expensive
FROM starship
WHERE cost_in_credits > 1000000;

-- =============================================
-- Advanced Aggregate Examples
-- =============================================

-- Example 18: Percentile calculations
SELECT 
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY cost_in_credits) AS cost_25th_percentile,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cost_in_credits) AS cost_median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cost_in_credits) AS cost_75th_percentile
FROM starship
WHERE cost_in_credits IS NOT NULL;

-- Example 19: Conditional aggregation
SELECT 
    SUM(CASE WHEN starship_class = 'Starfighter' THEN 1 ELSE 0 END) AS starfighter_count,
    SUM(CASE WHEN cost_in_credits > 100000000 THEN 1 ELSE 0 END) AS expensive_ship_count,
    AVG(CASE WHEN length > 100 THEN length ELSE NULL END) AS avg_length_large_ships
FROM starship;

-- Cleanup: Remove demo objects
DROP TABLE starship;
DROP SCHEMA demo_schema;