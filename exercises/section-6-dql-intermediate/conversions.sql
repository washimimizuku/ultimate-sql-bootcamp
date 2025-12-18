-- SQL DATA TYPE CONVERSIONS Examples - Advanced Data Query Language (DQL)
-- This file demonstrates data type conversion and transformation functions
-- Conversions allow changing data types for calculations, formatting, and data integration
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-6-dql-intermediate/conversions.sql
-- ============================================

-- CONVERSION FUNCTION TYPES:
-- - CAST(): Standard SQL type conversion
-- - :: operator: DuckDB shorthand casting syntax
-- - TRY_CAST(): Safe casting with NULL on failure
-- - TO_CHAR(): Format numbers/dates to strings
-- - TO_DATE(): Convert strings to dates
-- - EXTRACT(): Extract date/time components
-- - FORMAT(): Format numbers with patterns

-- COMMON DATA TYPES:
-- - INTEGER, BIGINT, DECIMAL, DOUBLE
-- - VARCHAR, TEXT
-- - DATE, TIMESTAMP, TIME
-- - BOOLEAN

-- ============================================
-- CAST() FUNCTION - STANDARD SQL CONVERSION
-- ============================================

-- Example 1: Convert numeric values to strings for concatenation
-- Create formatted customer identifiers and account information
SELECT 
    c_custkey,
    c_name,
    CAST(c_custkey AS VARCHAR) AS customer_id_string,
    'Customer-' || CAST(c_custkey AS VARCHAR) AS formatted_customer_id,
    CAST(c_acctbal AS VARCHAR) AS balance_string,
    'Balance: $' || CAST(ROUND(c_acctbal, 2) AS VARCHAR) AS formatted_balance
FROM customer
ORDER BY c_custkey
LIMIT 10;

-- Example 2: Convert strings to numbers for mathematical operations
-- Convert part size (stored as string) to integer for calculations
SELECT 
    p_partkey,
    p_name,
    p_size,
    CAST(p_size AS INTEGER) AS size_numeric,
    CAST(p_size AS INTEGER) * 2 AS double_size,
    CASE 
        WHEN CAST(p_size AS INTEGER) > 30 THEN 'Large'
        WHEN CAST(p_size AS INTEGER) > 15 THEN 'Medium'
        ELSE 'Small'
    END AS size_category
FROM part
WHERE p_size IS NOT NULL
ORDER BY CAST(p_size AS INTEGER) DESC
LIMIT 15;

-- Example 3: Convert dates to strings for custom formatting
-- Format order dates for different reporting needs
SELECT 
    o_orderkey,
    o_orderdate,
    CAST(o_orderdate AS VARCHAR) AS date_string,
    CAST(EXTRACT(YEAR FROM o_orderdate) AS VARCHAR) AS order_year,
    CAST(EXTRACT(MONTH FROM o_orderdate) AS VARCHAR) AS order_month,
    'Order placed in ' || CAST(EXTRACT(YEAR FROM o_orderdate) AS VARCHAR) AS year_description
FROM orders
ORDER BY o_orderdate DESC
LIMIT 10;

-- ============================================
-- :: OPERATOR - DUCKDB SHORTHAND CASTING
-- ============================================

-- Example 1: Quick numeric conversions using :: syntax
-- Convert customer keys and balances using shorthand notation
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_custkey::VARCHAR AS customer_string,
    c_acctbal::INTEGER AS balance_rounded,
    (c_acctbal * 1.1)::DECIMAL(10,2) AS balance_with_interest
FROM customer
WHERE c_acctbal > 5000
ORDER BY c_acctbal DESC
LIMIT 12;

-- Example 2: String to numeric conversions for analysis
-- Convert part sizes and perform calculations
SELECT 
    p_partkey,
    p_name,
    p_size,
    p_retailprice,
    p_size::INTEGER AS size_int,
    p_retailprice::INTEGER AS price_rounded,
    (p_size::INTEGER * p_retailprice::INTEGER) AS size_price_product
FROM part
WHERE p_size IS NOT NULL AND p_retailprice IS NOT NULL
ORDER BY size_price_product DESC
LIMIT 15;

-- Example 3: Date conversions and formatting
-- Convert dates to different string formats
SELECT 
    o_orderkey,
    o_orderdate,
    o_orderdate::VARCHAR AS date_as_string,
    EXTRACT(YEAR FROM o_orderdate)::VARCHAR AS year_string,
    ('Year: ' || EXTRACT(YEAR FROM o_orderdate)::VARCHAR) AS formatted_year
FROM orders
WHERE o_orderdate >= '1995-01-01'
ORDER BY o_orderdate
LIMIT 10;

-- ============================================
-- TRY_CAST() - SAFE CONVERSION WITH ERROR HANDLING
-- ============================================

-- Example 1: Safe string to number conversion
-- Handle potentially invalid numeric data gracefully
SELECT 
    p_partkey,
    p_name,
    p_comment,
    p_size,
    TRY_CAST(p_size AS INTEGER) AS safe_size_conversion,
    CASE 
        WHEN TRY_CAST(p_size AS INTEGER) IS NULL THEN 'Invalid Size'
        ELSE 'Valid Size'
    END AS size_validation,
    COALESCE(TRY_CAST(p_size AS INTEGER), 0) AS size_with_default
FROM part
ORDER BY p_partkey
LIMIT 20;

-- Example 2: Safe date conversions from strings
-- Create sample data with potentially invalid dates and handle safely
WITH date_samples AS (
    SELECT 
        o_orderkey,
        o_orderdate,
        CAST(o_orderdate AS VARCHAR) AS date_string,
        -- Simulate some invalid date strings
        CASE 
            WHEN o_orderkey % 100 = 0 THEN 'invalid-date'
            ELSE CAST(o_orderdate AS VARCHAR)
        END AS potentially_invalid_date
    FROM orders
    LIMIT 20
)
SELECT 
    o_orderkey,
    date_string,
    potentially_invalid_date,
    TRY_CAST(potentially_invalid_date AS DATE) AS safe_date_conversion,
    CASE 
        WHEN TRY_CAST(potentially_invalid_date AS DATE) IS NULL THEN 'Invalid Date'
        ELSE 'Valid Date'
    END AS date_validation
FROM date_samples;

-- Example 3: Safe numeric conversions with business logic
-- Handle customer account balances that might have invalid formats
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    TRY_CAST(c_acctbal AS INTEGER) AS balance_as_integer,
    TRY_CAST(c_acctbal * 100 AS INTEGER) AS balance_in_cents,
    CASE 
        WHEN TRY_CAST(c_acctbal AS INTEGER) IS NULL THEN 'Invalid Balance'
        WHEN TRY_CAST(c_acctbal AS INTEGER) > 10000 THEN 'High Value Customer'
        WHEN TRY_CAST(c_acctbal AS INTEGER) > 5000 THEN 'Medium Value Customer'
        ELSE 'Standard Customer'
    END AS customer_category
FROM customer
ORDER BY c_acctbal DESC
LIMIT 15;

-- ============================================
-- STRING FORMATTING FUNCTIONS
-- ============================================

-- Example 1: Format numbers as currency strings
-- Create formatted financial reports
SELECT 
    o_orderkey,
    o_custkey,
    o_totalprice,
    '$' || FORMAT('{:.2f}', o_totalprice) AS formatted_price,
    'Order #' || CAST(o_orderkey AS VARCHAR) || ': $' || FORMAT('{:.2f}', o_totalprice) AS order_summary
FROM orders
WHERE o_totalprice > 300000
ORDER BY o_totalprice DESC
LIMIT 10;

-- Example 2: Format dates using STRFTIME
-- Create custom date formats for reporting
SELECT 
    o_orderkey,
    o_orderdate,
    STRFTIME(o_orderdate, '%Y-%m-%d') AS iso_date,
    STRFTIME(o_orderdate, '%B %d, %Y') AS readable_date,
    STRFTIME(o_orderdate, '%Y') || '-Q' || CAST(EXTRACT(QUARTER FROM o_orderdate) AS VARCHAR) AS quarter_format,
    STRFTIME(o_orderdate, '%A, %B %d, %Y') AS full_date
FROM orders
ORDER BY o_orderdate DESC
LIMIT 12;

-- Example 3: Combine formatting with business logic
-- Create formatted customer reports
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_mktsegment,
    'Customer: ' || c_name || ' (ID: ' || CAST(c_custkey AS VARCHAR) || ')' AS customer_header,
    'Balance: $' || FORMAT('{:,.2f}', c_acctbal) AS formatted_balance,
    'Segment: ' || c_mktsegment || ' | Balance: $' || FORMAT('{:,.2f}', c_acctbal) AS customer_summary
FROM customer
WHERE c_acctbal > 8000
ORDER BY c_acctbal DESC
LIMIT 15;

-- ============================================
-- NUMERIC CONVERSIONS AND ROUNDING
-- ============================================

-- Example 1: ROUND() for decimal precision control
-- Round prices and calculate percentages
SELECT 
    p_partkey,
    p_name,
    p_retailprice,
    ROUND(p_retailprice) AS price_rounded,
    ROUND(p_retailprice, 2) AS price_two_decimals,
    ROUND(p_retailprice / 100, 3) AS price_percentage,
    CAST(ROUND(p_retailprice) AS INTEGER) AS price_as_integer
FROM part
WHERE p_retailprice IS NOT NULL
ORDER BY p_retailprice DESC
LIMIT 15;

-- Example 2: TRUNC() for truncating decimals
-- Truncate values without rounding
SELECT 
    o_orderkey,
    o_totalprice,
    ROUND(o_totalprice, 2) AS rounded_price,
    TRUNC(o_totalprice, 2) AS truncated_price,
    TRUNC(o_totalprice) AS truncated_to_integer,
    CAST(TRUNC(o_totalprice) AS INTEGER) AS integer_price
FROM orders
WHERE o_totalprice > 100000
ORDER BY o_totalprice DESC
LIMIT 12;

-- Example 3: Mathematical conversions for business calculations
-- Convert and calculate various financial metrics
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    ROUND(c_acctbal * 0.02, 2) AS monthly_interest,
    CAST(ROUND(c_acctbal / 1000) AS INTEGER) AS balance_in_thousands,
    ROUND(c_acctbal * 1.05, 2) AS balance_with_5_percent_increase
FROM customer
WHERE c_acctbal > 0
ORDER BY c_acctbal DESC
LIMIT 20;

-- ============================================
-- DATE AND TIME CONVERSIONS
-- ============================================

-- Example 1: EXTRACT() for date component extraction
-- Extract various date parts for analysis
SELECT 
    o_orderkey,
    o_orderdate,
    EXTRACT(YEAR FROM o_orderdate) AS order_year,
    EXTRACT(MONTH FROM o_orderdate) AS order_month,
    EXTRACT(DAY FROM o_orderdate) AS order_day,
    EXTRACT(QUARTER FROM o_orderdate) AS order_quarter,
    EXTRACT(DAYOFWEEK FROM o_orderdate) AS day_of_week,
    EXTRACT(DAYOFYEAR FROM o_orderdate) AS day_of_year
FROM orders
ORDER BY o_orderdate DESC
LIMIT 15;

-- Example 2: Date arithmetic and conversions
-- Calculate date differences and create date ranges
SELECT 
    o_orderkey,
    o_orderdate,
    CURRENT_DATE AS today,
    DATEDIFF('day', o_orderdate, CURRENT_DATE) AS days_since_order,
    DATEDIFF('year', o_orderdate, CURRENT_DATE) AS years_since_order,
    DATE_ADD(o_orderdate, INTERVAL 30 DAY) AS estimated_delivery,
    CAST(EXTRACT(YEAR FROM o_orderdate) AS VARCHAR) || '-Q' || CAST(EXTRACT(QUARTER FROM o_orderdate) AS VARCHAR) AS year_quarter
FROM orders
WHERE o_orderdate >= '1995-01-01'
ORDER BY o_orderdate DESC
LIMIT 12;

-- Example 3: Convert timestamps to different formats
-- Format dates for various business reporting needs
SELECT 
    o_orderkey,
    o_orderdate,
    DATE(o_orderdate) AS date_only,
    STRFTIME(o_orderdate, '%Y-%m') AS year_month,
    STRFTIME(o_orderdate, '%Y') AS year_only,
    STRFTIME(o_orderdate, '%m/%d/%Y') AS us_date_format,
    STRFTIME(o_orderdate, '%d/%m/%Y') AS european_date_format
FROM orders
ORDER BY o_orderdate
LIMIT 10;

-- ============================================
-- BOOLEAN CONVERSIONS
-- ============================================

-- Example 1: Convert conditions to boolean values
-- Create boolean flags for business logic
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_acctbal > 5000 AS is_high_value,
    CAST(c_acctbal > 5000 AS INTEGER) AS high_value_flag,
    CASE WHEN c_acctbal > 5000 THEN 1 ELSE 0 END AS high_value_numeric,
    CAST(c_acctbal < 0 AS VARCHAR) AS has_negative_balance_string
FROM customer
ORDER BY c_acctbal DESC
LIMIT 15;

-- Example 2: Boolean logic with conversions
-- Complex boolean expressions for customer segmentation
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_mktsegment,
    (c_acctbal > 8000 AND c_mktsegment = 'BUILDING') AS is_premium_building,
    CAST((c_acctbal > 5000 OR c_mktsegment = 'AUTOMOBILE') AS INTEGER) AS priority_customer_flag,
    CASE 
        WHEN c_acctbal > 8000 THEN 'TRUE'
        ELSE 'FALSE'
    END AS high_balance_string
FROM customer
ORDER BY c_acctbal DESC
LIMIT 20;

-- Example 3: Convert boolean results for reporting
-- Create readable boolean outputs for business reports
SELECT 
    o_orderkey,
    o_totalprice,
    o_orderpriority,
    o_totalprice > 200000 AS is_large_order,
    CASE WHEN o_totalprice > 200000 THEN 'Yes' ELSE 'No' END AS large_order_text,
    CAST(o_orderpriority IN ('1-URGENT', '2-HIGH') AS VARCHAR) AS is_priority_string,
    IF(o_totalprice > 200000 AND o_orderpriority IN ('1-URGENT', '2-HIGH'), 'VIP Order', 'Standard Order') AS order_classification
FROM orders
ORDER BY o_totalprice DESC
LIMIT 15;

-- ============================================
-- COMPLEX CONVERSION SCENARIOS
-- ============================================

-- Example 1: Multi-step conversions for data integration
-- Prepare data for external systems with specific format requirements
SELECT 
    c_custkey,
    c_name,
    c_phone,
    c_acctbal,
    -- Format for external system integration
    'CUST_' || LPAD(CAST(c_custkey AS VARCHAR), 8, '0') AS external_customer_id,
    UPPER(REPLACE(c_name, ' ', '_')) AS system_customer_name,
    CAST(ROUND(c_acctbal * 100) AS INTEGER) AS balance_in_cents,
    CASE 
        WHEN c_acctbal > 10000 THEN '1'
        WHEN c_acctbal > 5000 THEN '2'
        WHEN c_acctbal > 1000 THEN '3'
        ELSE '4'
    END AS customer_tier_code
FROM customer
ORDER BY c_custkey
LIMIT 10;

-- Example 2: Data quality conversions
-- Clean and standardize data with multiple conversion steps
SELECT 
    p_partkey,
    p_name,
    p_size,
    p_retailprice,
    -- Clean and convert size data
    COALESCE(TRY_CAST(p_size AS INTEGER), 0) AS clean_size,
    -- Standardize price format
    COALESCE(ROUND(TRY_CAST(p_retailprice AS DECIMAL(10,2)), 2), 0.00) AS clean_price,
    -- Create standardized part code
    'PART_' || CAST(p_partkey AS VARCHAR) || '_SIZE_' || COALESCE(CAST(TRY_CAST(p_size AS INTEGER) AS VARCHAR), 'UNK') AS part_code
FROM part
ORDER BY p_partkey
LIMIT 15;

-- Example 3: Business intelligence conversions
-- Convert raw data into business-friendly formats for reporting
SELECT 
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    c.c_name,
    -- Create business-friendly formats
    'Order #' || CAST(o.o_orderkey AS VARCHAR) AS order_number,
    STRFTIME(o.o_orderdate, '%B %Y') AS order_month_year,
    '$' || FORMAT('{:,.2f}', o.o_totalprice) AS formatted_total,
    CASE 
        WHEN o.o_totalprice > 300000 THEN 'Tier 1 - Premium'
        WHEN o.o_totalprice > 200000 THEN 'Tier 2 - High Value'
        WHEN o.o_totalprice > 100000 THEN 'Tier 3 - Standard'
        ELSE 'Tier 4 - Basic'
    END AS order_tier,
    -- Calculate business metrics
    CAST(ROUND(o.o_totalprice / 1000, 1) AS VARCHAR) || 'K' AS total_in_thousands
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
WHERE o.o_totalprice > 150000
ORDER BY o.o_totalprice DESC
LIMIT 20;