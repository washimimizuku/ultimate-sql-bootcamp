-- =============================================
-- Section 7: Advanced SQL - Python UDF Demonstrations
-- =============================================
-- This file demonstrates using Python UDFs in SQL queries
-- PREREQUISITE: Run python-udfs.py first to register the UDFs
-- Based on Tom Bailey's SQL course, adapted for DuckDB
-- =============================================

-- Setup: Use TPC-H database for examples
-- Note: Database connection is handled by the SQL runner
-- IMPORTANT: Python UDFs must be registered first by running python-udfs.py

-- =============================================
-- 1. BASIC MATHEMATICAL UDF EXAMPLES
-- =============================================

SELECT 'Basic Mathematical UDFs' as section;

-- Compound interest calculations
SELECT 
    'Investment Scenarios' as scenario,
    py_compound_interest(1000, 0.05, 10, 12) as monthly_compounding,
    py_compound_interest(1000, 0.05, 10, 4) as quarterly_compounding,
    py_compound_interest(1000, 0.05, 10, 1) as annual_compounding;

-- Temperature conversions
SELECT 
    'Temperature Conversions' as scenario,
    py_celsius_to_fahrenheit(0) as freezing_f,
    py_celsius_to_fahrenheit(25) as room_temp_f,
    py_celsius_to_fahrenheit(100) as boiling_f;

-- BMI calculations for different profiles
WITH health_profiles AS (
    SELECT profile, weight_kg, height_m FROM VALUES 
        ('Underweight', 50, 1.70),
        ('Normal', 70, 1.75),
        ('Overweight', 85, 1.70),
        ('Obese', 100, 1.65)
    AS t(profile, weight_kg, height_m)
)
SELECT 
    profile,
    weight_kg,
    height_m,
    py_calculate_bmi(weight_kg, height_m) as bmi,
    CASE 
        WHEN py_calculate_bmi(weight_kg, height_m) < 18.5 THEN 'Underweight'
        WHEN py_calculate_bmi(weight_kg, height_m) < 25 THEN 'Normal'
        WHEN py_calculate_bmi(weight_kg, height_m) < 30 THEN 'Overweight'
        ELSE 'Obese'
    END as bmi_category
FROM health_profiles;

-- =============================================
-- 2. STRING PROCESSING UDF EXAMPLES
-- =============================================

SELECT 'String Processing UDFs' as section;

-- Email domain extraction and validation
WITH sample_emails AS (
    SELECT email FROM VALUES 
        ('john.doe@company.com'),
        ('invalid-email'),
        ('jane@university.edu'),
        ('admin@government.gov'),
        ('not.an.email')
    AS t(email)
)
SELECT 
    email,
    py_validate_email(email) as is_valid,
    py_extract_email_domain(email) as domain
FROM sample_emails;

-- Phone number validation
WITH sample_phones AS (
    SELECT phone FROM VALUES 
        ('555-123-4567'),
        ('(555) 123-4567'),
        ('5551234567'),
        ('1-555-123-4567'),
        ('invalid-phone'),
        ('123-456')
    AS t(phone)
)
SELECT 
    phone,
    py_validate_phone(phone) as is_valid_phone
FROM sample_phones;

-- Text cleaning and number extraction
WITH messy_text AS (
    SELECT text FROM VALUES 
        ('  Hello,   World!!!  '),
        ('Price: $19.99 and $25.50'),
        ('Call 555-1234 or visit store #42'),
        ('Order #12345 total: $199.99')
    AS t(text)
)
SELECT 
    text as original,
    py_clean_text(text) as cleaned,
    py_extract_numbers(text) as extracted_numbers
FROM messy_text;

-- =============================================
-- 3. ADVANCED MATHEMATICAL UDF EXAMPLES
-- =============================================

SELECT 'Advanced Mathematical UDFs' as section;

-- Distance calculations between major cities (sample coordinates)
WITH city_coordinates AS (
    SELECT city, lat, lon FROM VALUES 
        ('New York', 40.7128, -74.0060),
        ('Los Angeles', 34.0522, -118.2437),
        ('Chicago', 41.8781, -87.6298),
        ('Houston', 29.7604, -95.3698)
    AS t(city, lat, lon)
)
SELECT 
    a.city as city_a,
    b.city as city_b,
    py_calculate_distance(a.lat, a.lon, b.lat, b.lon) as distance_km
FROM city_coordinates a
CROSS JOIN city_coordinates b
WHERE a.city < b.city  -- Avoid duplicates and self-joins
ORDER BY distance_km DESC;

-- Fibonacci sequence and prime number detection
WITH numbers AS (
    SELECT n FROM generate_series(1, 20) AS t(n)
)
SELECT 
    n,
    py_fibonacci(n) as fibonacci_value,
    py_is_prime(n) as is_prime
FROM numbers
ORDER BY n;

-- Percentile calculations with order data
WITH order_stats AS (
    SELECT 
        AVG(o_totalprice) as mean_price,
        STDDEV(o_totalprice) as std_price
    FROM orders
    WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
)
SELECT 
    o_orderkey,
    o_totalprice,
    py_calculate_percentile(o_totalprice, os.mean_price, os.std_price) as percentile_rank
FROM orders o
CROSS JOIN order_stats os
WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
ORDER BY o_totalprice DESC
LIMIT 10;

-- =============================================
-- 4. DATE AND TIME UDF EXAMPLES
-- =============================================

SELECT 'Date and Time UDFs' as section;

-- Business days calculations
WITH date_ranges AS (
    SELECT start_date, end_date FROM VALUES 
        ('2024-01-01', '2024-01-15'),  -- Includes weekends
        ('2024-01-15', '2024-01-19'),  -- Monday to Friday
        ('2024-01-20', '2024-01-21')   -- Saturday to Sunday
    AS t(start_date, end_date)
)
SELECT 
    start_date,
    end_date,
    py_business_days_between(start_date, end_date) as business_days
FROM date_ranges;

-- Quarter analysis with TPC-H orders
SELECT 
    py_get_quarter_name(o_orderdate::VARCHAR) as quarter,
    COUNT(*) as order_count,
    AVG(o_totalprice) as avg_order_value
FROM orders 
WHERE o_orderdate BETWEEN '1995-01-01' AND '1996-12-31'
GROUP BY py_get_quarter_name(o_orderdate::VARCHAR)
ORDER BY quarter;

-- Days until weekend analysis
WITH sample_dates AS (
    SELECT date_val FROM VALUES 
        ('2024-01-15'),  -- Monday
        ('2024-01-17'),  -- Wednesday  
        ('2024-01-19'),  -- Friday
        ('2024-01-20'),  -- Saturday
        ('2024-01-21')   -- Sunday
    AS t(date_val)
)
SELECT 
    date_val,
    EXTRACT(DOW FROM date_val::DATE) as day_of_week,
    py_days_until_weekend(date_val) as days_to_weekend
FROM sample_dates;

-- =============================================
-- 5. JSON PROCESSING UDF EXAMPLES
-- =============================================

SELECT 'JSON Processing UDFs' as section;

-- JSON parsing and validation
WITH sample_json AS (
    SELECT json_data FROM VALUES 
        ('{"name": "John", "age": 30}'),
        ('{"product": "Widget", "price": 19.99}'),
        ('invalid json'),
        ('{"status": "active", "count": 42}')
    AS t(json_data)
)
SELECT 
    json_data,
    py_validate_json(json_data) as is_valid_json,
    py_parse_json_field(json_data, 'name') as name_field,
    py_parse_json_field(json_data, 'price') as price_field
FROM sample_json;

-- Creating JSON objects from customer data
SELECT 
    c_custkey,
    c_name,
    py_create_json_object('customer_id', c_custkey::VARCHAR, 'name', c_name) as customer_json
FROM customer 
LIMIT 5;

-- =============================================
-- 6. BUSINESS LOGIC UDF EXAMPLES
-- =============================================

SELECT 'Business Logic UDFs' as section;

-- Shipping cost calculations
WITH shipping_scenarios AS (
    SELECT scenario, weight, distance, is_express, customer_tier FROM VALUES 
        ('Standard Customer, Regular', 10.0, 500.0, false, 'Standard'),
        ('Standard Customer, Express', 10.0, 500.0, true, 'Standard'),
        ('Premium Customer, Regular', 10.0, 500.0, false, 'Premium'),
        ('Premium Customer, Express', 10.0, 500.0, true, 'Premium'),
        ('VIP Customer, Express', 10.0, 500.0, true, 'VIP'),
        ('Basic Customer, Heavy Package', 50.0, 1000.0, false, 'Basic')
    AS t(scenario, weight, distance, is_express, customer_tier)
)
SELECT 
    scenario,
    weight,
    distance,
    is_express,
    customer_tier,
    py_calculate_shipping_cost(weight, distance, is_express, customer_tier) as shipping_cost
FROM shipping_scenarios
ORDER BY shipping_cost DESC;

-- Credit risk assessment with customer data
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    -- Simulate payment history score based on account balance
    CASE 
        WHEN c_acctbal > 5000 THEN 90
        WHEN c_acctbal > 0 THEN 75
        WHEN c_acctbal > -1000 THEN 50
        ELSE 25
    END as payment_history_score,
    -- Count orders for this customer
    (SELECT COUNT(*) FROM orders WHERE o_custkey = c.c_custkey) as order_count,
    py_assess_credit_risk(
        c_acctbal, 
        CASE 
            WHEN c_acctbal > 5000 THEN 90
            WHEN c_acctbal > 0 THEN 75
            WHEN c_acctbal > -1000 THEN 50
            ELSE 25
        END,
        (SELECT COUNT(*) FROM orders WHERE o_custkey = c.c_custkey)
    ) as risk_assessment
FROM customer c
ORDER BY c_acctbal DESC
LIMIT 15;

-- Customer Lifetime Value calculations
WITH customer_metrics AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        COUNT(o.o_orderkey) as total_orders,
        AVG(o.o_totalprice) as avg_order_value,
        COUNT(o.o_orderkey) / 2.0 as orders_per_year  -- Assuming 2-year data period
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name
    HAVING COUNT(o.o_orderkey) > 0
)
SELECT 
    c_custkey,
    c_name,
    total_orders,
    avg_order_value,
    orders_per_year,
    py_calculate_customer_ltv(avg_order_value, orders_per_year, 3.0, 0.2) as estimated_ltv
FROM customer_metrics
ORDER BY estimated_ltv DESC
LIMIT 10;

-- =============================================
-- 7. ERROR HANDLING AND VALIDATION UDF EXAMPLES
-- =============================================

SELECT 'Error Handling and Validation UDFs' as section;

-- Safe division examples
WITH division_scenarios AS (
    SELECT numerator, denominator FROM VALUES 
        (100.0, 5.0),
        (50.0, 0.0),    -- Division by zero
        (75.0, 3.0),
        (0.0, 10.0),
        (100.0, 0.0)    -- Another division by zero
    AS t(numerator, denominator)
)
SELECT 
    numerator,
    denominator,
    py_safe_divide(numerator, denominator, -1.0) as safe_result,
    -- Compare with regular division (would cause error)
    CASE 
        WHEN denominator = 0 THEN 'ERROR: Division by zero'
        ELSE (numerator / denominator)::VARCHAR
    END as regular_division_result
FROM division_scenarios;

-- Email validation with customer-like data
WITH sample_customer_emails AS (
    SELECT customer_id, email FROM VALUES 
        (1, 'john.doe@company.com'),
        (2, 'invalid.email'),
        (3, 'jane@university.edu'),
        (4, 'admin@'),
        (5, 'user@domain.co.uk'),
        (6, 'not-an-email-at-all')
    AS t(customer_id, email)
)
SELECT 
    customer_id,
    email,
    py_validate_email(email) as is_valid_email,
    CASE 
        WHEN py_validate_email(email) THEN 'Valid'
        ELSE 'Invalid - needs correction'
    END as email_status
FROM sample_customer_emails;

-- Safe number parsing from text
WITH messy_data AS (
    SELECT description, value_text FROM VALUES 
        ('Price with currency', '$19.99'),
        ('Percentage', '15.5%'),
        ('Weight with units', '25.3 kg'),
        ('Invalid number', 'not-a-number'),
        ('Negative value', '-42.7'),
        ('Just text', 'hello world')
    AS t(description, value_text)
)
SELECT 
    description,
    value_text,
    py_parse_number_safe(value_text, 0.0) as parsed_number,
    CASE 
        WHEN py_parse_number_safe(value_text, 0.0) = 0.0 AND value_text != '0' 
        THEN 'Parsing failed - using default'
        ELSE 'Successfully parsed'
    END as parse_status
FROM messy_data;

-- =============================================
-- 8. PERFORMANCE COMPARISON: UDF vs SQL vs MACRO
-- =============================================

SELECT 'Performance Comparison Examples' as section;

-- Compare compound interest calculation methods
WITH investment_data AS (
    SELECT 
        1000.0 as principal,
        0.05 as rate,
        10 as years,
        12 as compounds_per_year
)
SELECT 
    'Compound Interest Comparison' as calculation_type,
    -- Python UDF
    py_compound_interest(principal, rate, years, compounds_per_year) as python_udf_result,
    -- Pure SQL calculation
    principal * POWER(1 + rate / compounds_per_year, compounds_per_year * years) as sql_result,
    -- Could also use SQL Macro (if defined)
    -- calculate_compound_interest(principal, rate, years, compounds_per_year) as macro_result
    'Python UDF allows complex logic, SQL is faster for simple math' as performance_note
FROM investment_data;

-- Distance calculation comparison
SELECT 
    'Distance Calculation Comparison' as calculation_type,
    -- Python UDF (Haversine formula)
    py_calculate_distance(40.7128, -74.0060, 34.0522, -118.2437) as python_haversine_km,
    -- Simplified SQL approximation (less accurate)
    SQRT(
        POWER(40.7128 - 34.0522, 2) + 
        POWER(-74.0060 - (-118.2437), 2)
    ) * 111.0 as sql_approximation_km,
    'Python UDF provides accurate Haversine formula, SQL approximation is faster but less accurate' as accuracy_note;

-- =============================================
-- 9. REAL-WORLD BUSINESS SCENARIOS
-- =============================================

SELECT 'Real-World Business Scenarios' as section;

-- E-commerce order processing with multiple UDFs
WITH enhanced_orders AS (
    SELECT 
        o.o_orderkey,
        o.o_custkey,
        o.o_orderdate,
        o.o_totalprice,
        c.c_name,
        c.c_acctbal,
        -- Simulate shipping details
        (o.o_totalprice / 100.0) as estimated_weight,
        500.0 as estimated_distance,
        (o.o_orderpriority IN ('1-URGENT', '2-HIGH')) as is_express,
        CASE 
            WHEN c.c_acctbal > 5000 THEN 'VIP'
            WHEN c.c_acctbal > 1000 THEN 'Premium'
            ELSE 'Standard'
        END as customer_tier
    FROM orders o
    JOIN customer c ON o.o_custkey = c.c_custkey
    WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-03-31'
    LIMIT 20
)
SELECT 
    o_orderkey,
    c_name,
    o_totalprice,
    customer_tier,
    is_express,
    py_calculate_shipping_cost(estimated_weight, estimated_distance, is_express, customer_tier) as shipping_cost,
    py_assess_credit_risk(c_acctbal, 75, 5) as credit_risk,
    py_get_quarter_name(o_orderdate::VARCHAR) as order_quarter,
    -- Total cost including shipping
    o_totalprice + py_calculate_shipping_cost(estimated_weight, estimated_distance, is_express, customer_tier) as total_with_shipping
FROM enhanced_orders
ORDER BY total_with_shipping DESC;

-- Customer analytics dashboard data
WITH customer_analytics AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_acctbal,
        COUNT(o.o_orderkey) as total_orders,
        COALESCE(AVG(o.o_totalprice), 0) as avg_order_value,
        COALESCE(SUM(o.o_totalprice), 0) as total_spent,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_acctbal
)
SELECT 
    c_custkey,
    c_name,
    total_orders,
    avg_order_value,
    total_spent,
    -- Calculate customer lifetime value
    py_calculate_customer_ltv(avg_order_value, 2.0, 3.0, 0.25) as estimated_ltv,
    -- Assess credit risk
    py_assess_credit_risk(c_acctbal, 80, total_orders) as credit_risk,
    -- Business days between first and last order
    CASE 
        WHEN first_order_date IS NOT NULL AND last_order_date IS NOT NULL 
        THEN py_business_days_between(first_order_date::VARCHAR, last_order_date::VARCHAR)
        ELSE 0
    END as customer_lifespan_days,
    -- Customer tier based on spending
    CASE 
        WHEN total_spent > 100000 THEN 'VIP'
        WHEN total_spent > 50000 THEN 'Premium'
        WHEN total_spent > 10000 THEN 'Standard'
        ELSE 'Basic'
    END as spending_tier
FROM customer_analytics
WHERE total_orders > 0
ORDER BY estimated_ltv DESC
LIMIT 15;

-- =============================================
-- SUMMARY AND BEST PRACTICES
-- =============================================

/*
Python UDF Summary and Best Practices:

1. WHEN TO USE PYTHON UDFs:
   - Complex algorithms not easily expressed in SQL
   - Need external Python libraries (pandas, numpy, etc.)
   - Advanced statistical or mathematical functions
   - Text processing with regex or NLP
   - JSON/XML parsing and manipulation
   - Integration with existing Python code

2. PERFORMANCE CONSIDERATIONS:
   - Python UDFs have overhead compared to native SQL
   - Use vectorized (Arrow) UDFs for better performance on large datasets
   - Consider SQL Macros for simple calculations
   - Cache UDF results when possible

3. ERROR HANDLING:
   - Always include try/catch blocks in UDF code
   - Provide sensible default values
   - Validate input parameters
   - Use null_handling='special' when needed

4. BEST PRACTICES:
   - Keep UDFs focused and single-purpose
   - Document function parameters and return types
   - Test UDFs thoroughly with edge cases
   - Consider type annotations for better performance
   - Use appropriate DuckDB types for parameters and returns

5. MAINTENANCE:
   - UDFs need to be re-registered each session
   - Consider creating setup scripts for production use
   - Version control your UDF definitions
   - Monitor UDF performance in production queries

Key takeaways:
- Python UDFs extend SQL with powerful programming capabilities
- They bridge the gap between SQL and complex business logic
- Use them judiciously - not every calculation needs a UDF
- Combine with SQL Macros and native functions for optimal performance
- Essential for advanced analytics and data science workflows
*/

SELECT 'Python UDF Demonstrations Complete' as summary;