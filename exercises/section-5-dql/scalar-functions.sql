-- SQL Scalar Functions Examples - Data Query Language (DQL)
-- This file demonstrates scalar function usage for data transformation and calculation
-- Scalar functions operate on individual values and return a single result per row

-- SCALAR FUNCTION CATEGORIES:
-- Mathematical: 
--   ABS() - absolute value, CEIL() - round up, FLOOR() - round down
--   POWER() - exponentiation, SQRT() - square root, ROUND() - round to decimals
--   MOD() - remainder after division
-- String: 
--   CONCAT() - join strings, LENGTH() - string length, UPPER() - to uppercase
--   LOWER() - to lowercase, SUBSTRING() - extract part of string, TRIM() - remove whitespace
-- Date/Time: 
--   YEAR() - extract year, MONTH() - extract month, DAY() - extract day
--   QUARTER() - extract quarter, DAYNAME() - day name, MONTHNAME() - month name
-- Conversion: 
--   CAST() - change data type, COALESCE() - first non-null value
--   NULLIF() - return NULL if values equal
-- Conditional: 
--   CASE WHEN - conditional logic, GREATEST() - maximum value
--   LEAST() - minimum value
-- System: 
--   RANDOM() - random number, USER() - current user, VERSION() - database version

-- Scalar functions vs other functions:
-- - Scalar: Return one value per input row (1:1 relationship)
-- - Aggregate: Return one value per group (many:1 relationship)
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
-- Mathematical Functions
-- =============================================

-- Example 1: Generate random number (0 to 1)
SELECT RANDOM() AS random_value;

-- Example 2: Absolute value of a negative number
SELECT ABS(-645) AS absolute_value;

-- Example 3: Absolute value applied to table column
SELECT 
    name,
    cost_in_credits,
    ABS(cost_in_credits) AS absolute_cost
FROM starship
WHERE cost_in_credits IS NOT NULL;

-- Example 4: Ceiling function (round up to nearest integer)
SELECT CEIL(3.14) AS ceiling_value;

-- Example 5: Floor function (round down to nearest integer)
SELECT FLOOR(3.14) AS floor_value;

-- Example 6: Power function (exponentiation)
SELECT POWER(2, 3) AS power_result;

-- Example 7: Square root function
SELECT SQRT(9) AS square_root;

-- Example 8: Round function with decimal places
SELECT ROUND(3.14159, 2) AS rounded_value;

-- Example 9: Modulo function (remainder after division)
SELECT MOD(10, 3) AS modulo_result;

-- =============================================
-- String Functions
-- =============================================

-- Example 10: Concatenate literal strings
SELECT CONCAT('Nuno', ' ', 'Barreto') AS full_name;

-- Example 11: Concatenate table columns
SELECT 
    name,
    model,
    CONCAT(name, ' - ', model) AS ship_description
FROM starship
LIMIT 5;

-- Example 12: String length function
SELECT 
    name,
    LENGTH(name) AS name_length
FROM starship
LIMIT 5;

-- Example 13: Convert to uppercase
SELECT 
    starship_class,
    UPPER(starship_class) AS class_upper
FROM starship
LIMIT 5;

-- Example 14: Convert to lowercase
SELECT 
    starship_class,
    LOWER(starship_class) AS class_lower
FROM starship
LIMIT 5;

-- Example 15: Extract substring
SELECT 
    name,
    SUBSTRING(name, 1, 5) AS name_prefix
FROM starship
LIMIT 5;

-- Example 16: Trim whitespace
SELECT TRIM('  Hello World  ') AS trimmed_string;

-- =============================================
-- Date and Time Functions
-- =============================================

-- Example 17: Extract year from date
SELECT YEAR(DATE('2023-01-01')) AS year_value;

-- Example 18: Extract quarter from date
SELECT QUARTER(DATE('2023-07-01')) AS quarter_value;

-- Example 19: Extract month from date
SELECT MONTH(DATE('2023-04-01')) AS month_value;

-- Example 20: Extract day from date
SELECT DAY(DATE('2023-01-01')) AS day_value;

-- Example 21: Get day name from date
SELECT DAYNAME(DATE('2023-01-01')) AS day_name;

-- Example 22: Get month name from date
SELECT MONTHNAME(DATE('2023-01-01')) AS month_name;

-- =============================================
-- Conversion Functions
-- =============================================

-- Example 23: Type casting
SELECT 
    name,
    CAST(length AS INTEGER) AS length_int
FROM starship
WHERE length IS NOT NULL
LIMIT 5;

-- Example 24: COALESCE - return first non-null value
SELECT 
    name,
    COALESCE(cost_in_credits, 0) AS cost_with_default
FROM starship
LIMIT 5;

-- Example 25: NULLIF - return NULL if values are equal
SELECT 
    name,
    NULLIF(passengers, 0) AS passengers_null_if_zero
FROM starship
LIMIT 5;

-- =============================================
-- Conditional Functions
-- =============================================

-- Example 26: CASE WHEN statement
SELECT 
    name,
    cost_in_credits,
    CASE 
        WHEN cost_in_credits > 100000000 THEN 'Expensive'
        WHEN cost_in_credits > 1000000 THEN 'Moderate'
        WHEN cost_in_credits IS NOT NULL THEN 'Affordable'
        ELSE 'Unknown'
    END AS price_category
FROM starship
LIMIT 10;

-- Example 27: GREATEST function (maximum of values)
SELECT 
    name,
    GREATEST(crew, passengers, 0) AS max_occupancy
FROM starship
WHERE crew IS NOT NULL OR passengers IS NOT NULL
LIMIT 5;

-- Example 28: LEAST function (minimum of values)
SELECT 
    name,
    LEAST(crew, passengers, 1000) AS min_occupancy
FROM starship
WHERE crew IS NOT NULL AND passengers IS NOT NULL
LIMIT 5;

-- =============================================
-- System Functions
-- =============================================

-- Example 29: Get current user
SELECT USER() AS db_user;

-- Example 30: Get database version
SELECT VERSION() AS database_version;

-- =============================================
-- Combined Function Examples
-- =============================================

-- Example 31: Multiple functions in one query
SELECT 
    name,
    UPPER(starship_class) AS class_upper,
    ROUND(length, 1) AS rounded_length,
    COALESCE(cost_in_credits, 0) AS cost_with_default,
    CASE 
        WHEN length > 1000 THEN 'Large'
        WHEN length > 100 THEN 'Medium'
        ELSE 'Small'
    END AS size_category
FROM starship
WHERE length IS NOT NULL
LIMIT 10;

-- Cleanup: Remove demo objects
DROP TABLE starship;
DROP SCHEMA demo_schema;