-- =============================================
-- Section 7: Advanced SQL - SQL Macros
-- =============================================
-- This file demonstrates SQL Macro creation and usage in DuckDB
-- Macros are parameterized SQL templates for reusable logic
-- Based on Tom Bailey's SQL course, adapted for DuckDB
-- =============================================

-- Setup: Use TPC-H database for examples
-- Note: Database connection is handled by the SQL runner

-- =============================================
-- 1. UNDERSTANDING SQL MACROS
-- =============================================

-- What are SQL Macros?
-- Macros are parameterized SQL templates that act like functions
-- They are pure SQL (no external dependencies)
-- Parameters are substituted at compile time (fast performance)
-- Perfect for reusable business logic and calculations

SELECT 'Understanding SQL Macros' as section;

-- =============================================
-- 2. BASIC MACRO CREATION
-- =============================================

SELECT 'Basic Macro Creation' as section;

-- Simple calculation macro
CREATE OR REPLACE MACRO calculate_tax(amount, rate := 0.1) AS 
    amount * rate;

-- Test the basic macro
SELECT 
    100 as price,
    calculate_tax(100) as default_tax,
    calculate_tax(100, rate := 0.08) as custom_tax;

-- Macro with multiple parameters
CREATE OR REPLACE MACRO discount_price(original_price, discount_percent) AS 
    original_price * (1 - discount_percent / 100);

-- Test discount macro
SELECT 
    50 as original,
    discount_price(50, 20) as discounted_20_percent,
    discount_price(50, 15) as discounted_15_percent;

-- =============================================
-- 3. MACROS WITH BUSINESS LOGIC
-- =============================================

SELECT 'Business Logic Macros' as section;

-- Customer classification macro
CREATE OR REPLACE MACRO classify_customer(total_spent) AS 
    CASE 
        WHEN total_spent >= 100000 THEN 'VIP'
        WHEN total_spent >= 50000 THEN 'Premium'
        WHEN total_spent >= 10000 THEN 'Standard'
        ELSE 'Basic'
    END;

-- Test customer classification
WITH customer_spending AS (
    SELECT c_custkey, SUM(o_totalprice) as total_spent
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c_custkey
    LIMIT 10
)
SELECT 
    c_custkey,
    total_spent,
    classify_customer(total_spent) as customer_tier
FROM customer_spending
ORDER BY total_spent DESC;

-- Date range macro for business quarters
CREATE OR REPLACE MACRO is_in_quarter(date_col, year_val, quarter_num) AS 
    EXTRACT(YEAR FROM date_col) = year_val 
    AND EXTRACT(QUARTER FROM date_col) = quarter_num;

-- Test quarter macro
SELECT 
    o_orderdate,
    is_in_quarter(o_orderdate, 1995, 1) as q1_1995,
    is_in_quarter(o_orderdate, 1995, 4) as q4_1995
FROM orders 
WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
LIMIT 10;

-- =============================================
-- 4. AGGREGATE AND ANALYTICAL MACROS
-- =============================================

SELECT 'Aggregate and Analytical Macros' as section;

-- Revenue calculation macro
CREATE OR REPLACE MACRO calculate_revenue(quantity, price, discount) AS 
    quantity * price * (1 - discount);

-- Profit margin macro
CREATE OR REPLACE MACRO profit_margin(revenue, cost) AS 
    CASE 
        WHEN revenue > 0 THEN ((revenue - cost) / revenue) * 100
        ELSE 0
    END;

-- Test with lineitem data
SELECT 
    l_orderkey,
    l_linenumber,
    l_quantity,
    l_extendedprice,
    l_discount,
    calculate_revenue(l_quantity, l_extendedprice, l_discount) as calculated_revenue,
    profit_margin(l_extendedprice, l_extendedprice * 0.7) as estimated_margin_percent
FROM lineitem 
LIMIT 10;

-- Statistical macro for coefficient of variation
CREATE OR REPLACE MACRO coefficient_of_variation(std_dev, mean_val) AS 
    CASE 
        WHEN mean_val != 0 THEN (std_dev / ABS(mean_val)) * 100
        ELSE NULL
    END;

-- Test statistical macro
WITH order_stats AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        AVG(o_totalprice) as avg_price,
        STDDEV(o_totalprice) as std_price
    FROM orders 
    WHERE o_orderdate BETWEEN '1995-01-01' AND '1997-12-31'
    GROUP BY EXTRACT(YEAR FROM o_orderdate)
)
SELECT 
    order_year,
    avg_price,
    std_price,
    coefficient_of_variation(std_price, avg_price) as cv_percent
FROM order_stats
ORDER BY order_year;

-- =============================================
-- 5. STRING MANIPULATION MACROS
-- =============================================

SELECT 'String Manipulation Macros' as section;

-- Name formatting macro
CREATE OR REPLACE MACRO format_customer_name(name) AS 
    UPPER(LEFT(name, 1)) || LOWER(SUBSTRING(name, 2));

-- Phone number formatting macro
CREATE OR REPLACE MACRO format_phone(phone) AS 
    '(' || SUBSTRING(phone, 1, 3) || ') ' || 
    SUBSTRING(phone, 4, 3) || '-' || 
    SUBSTRING(phone, 7);

-- Test string macros
SELECT 
    c_name,
    format_customer_name(c_name) as formatted_name,
    c_phone,
    format_phone(REPLACE(c_phone, '-', '')) as formatted_phone
FROM customer 
WHERE LENGTH(REPLACE(c_phone, '-', '')) >= 10
LIMIT 10;

-- Email domain extraction macro
CREATE OR REPLACE MACRO extract_domain(email) AS 
    SUBSTRING(email, POSITION('@' IN email) + 1);

-- Test with sample email data
WITH sample_emails AS (
    SELECT email FROM VALUES 
        ('john.doe@company.com'),
        ('jane.smith@university.edu'),
        ('admin@government.gov'),
        ('support@startup.io')
    AS t(email)
)
SELECT 
    email,
    extract_domain(email) as domain
FROM sample_emails;

-- =============================================
-- 6. CONDITIONAL LOGIC MACROS
-- =============================================

SELECT 'Conditional Logic Macros' as section;

-- Order priority scoring macro
CREATE OR REPLACE MACRO priority_score(priority, ship_date, order_date) AS 
    CASE priority
        WHEN '1-URGENT' THEN 100
        WHEN '2-HIGH' THEN 80
        WHEN '3-MEDIUM' THEN 60
        WHEN '4-NOT SPECIFIED' THEN 40
        WHEN '5-LOW' THEN 20
        ELSE 0
    END + 
    CASE 
        WHEN ship_date - order_date <= 7 THEN 20
        WHEN ship_date - order_date <= 14 THEN 10
        ELSE 0
    END;

-- Test priority scoring
SELECT 
    o_orderkey,
    o_orderpriority,
    o_orderdate,
    o_shippriority,
    priority_score(o_orderpriority, (o_orderdate + INTERVAL '10 days')::DATE, o_orderdate) as calculated_priority
FROM orders 
LIMIT 10;

-- Risk assessment macro
CREATE OR REPLACE MACRO assess_credit_risk(account_balance, days_overdue, order_count) AS 
    CASE 
        WHEN account_balance < 0 AND days_overdue > 90 THEN 'HIGH'
        WHEN account_balance < 1000 AND days_overdue > 30 THEN 'MEDIUM'
        WHEN order_count < 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END;

-- Test risk assessment with sample data
WITH customer_risk_data AS (
    SELECT 
        c_custkey,
        c_acctbal,
        CASE 
            WHEN c_acctbal < 0 THEN ABS(c_acctbal) / 100  -- Simulate days overdue
            ELSE 0
        END as days_overdue,
        (SELECT COUNT(*) FROM orders WHERE o_custkey = c.c_custkey) as order_count
    FROM customer c
    LIMIT 20
)
SELECT 
    c_custkey,
    c_acctbal,
    days_overdue,
    order_count,
    assess_credit_risk(c_acctbal, days_overdue, order_count) as risk_level
FROM customer_risk_data
ORDER BY c_acctbal;

-- =============================================
-- 7. DATE AND TIME MACROS
-- =============================================

SELECT 'Date and Time Macros' as section;

-- Business days calculation macro
CREATE OR REPLACE MACRO business_days_between(start_date, end_date) AS 
    CASE 
        WHEN end_date >= start_date THEN
            (end_date - start_date) - 
            (2 * ((end_date - start_date) / 7)) -
            CASE WHEN EXTRACT(DOW FROM start_date) = 0 THEN 1 ELSE 0 END -
            CASE WHEN EXTRACT(DOW FROM end_date) = 6 THEN 1 ELSE 0 END
        ELSE 0
    END;

-- Age calculation macro
CREATE OR REPLACE MACRO calculate_age_years(birth_date, reference_date) AS 
    EXTRACT(YEAR FROM reference_date) - EXTRACT(YEAR FROM birth_date) -
    CASE 
        WHEN EXTRACT(MONTH FROM reference_date) < EXTRACT(MONTH FROM birth_date) OR
             (EXTRACT(MONTH FROM reference_date) = EXTRACT(MONTH FROM birth_date) AND 
              EXTRACT(DAY FROM reference_date) < EXTRACT(DAY FROM birth_date))
        THEN 1 
        ELSE 0 
    END;

-- Test date macros
SELECT 
    '2024-01-15'::DATE as start_date,
    '2024-01-25'::DATE as end_date,
    business_days_between('2024-01-15'::DATE, '2024-01-25'::DATE) as business_days,
    calculate_age_years('1990-06-15'::DATE, '2024-01-01'::DATE) as age_in_years;

-- Fiscal year macro (assuming April 1st start)
CREATE OR REPLACE MACRO fiscal_year(date_col) AS 
    CASE 
        WHEN EXTRACT(MONTH FROM date_col) >= 4 THEN EXTRACT(YEAR FROM date_col)
        ELSE EXTRACT(YEAR FROM date_col) - 1
    END;

-- Test fiscal year
SELECT 
    o_orderdate,
    EXTRACT(YEAR FROM o_orderdate) as calendar_year,
    fiscal_year(o_orderdate) as fiscal_year
FROM orders 
WHERE o_orderdate BETWEEN '1995-01-01' AND '1996-12-31'
LIMIT 10;

-- =============================================
-- 8. COMPLEX ANALYTICAL MACROS
-- =============================================

SELECT 'Complex Analytical Macros' as section;

-- Moving average macro (simplified for demonstration)
CREATE OR REPLACE MACRO simple_moving_average(current_value, prev_value1, prev_value2) AS 
    (current_value + prev_value1 + prev_value2) / 3.0;

-- Percentage change macro
CREATE OR REPLACE MACRO percentage_change(new_value, old_value) AS 
    CASE 
        WHEN old_value != 0 THEN ((new_value - old_value) / ABS(old_value)) * 100
        WHEN new_value != 0 THEN 100  -- From 0 to something is 100% increase
        ELSE 0  -- From 0 to 0 is no change
    END;

-- Test analytical macros with order trends
WITH monthly_orders AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as year,
        EXTRACT(MONTH FROM o_orderdate) as month,
        COUNT(*) as order_count,
        SUM(o_totalprice) as total_revenue
    FROM orders 
    WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)
    ORDER BY year, month
),
with_previous AS (
    SELECT *,
        LAG(total_revenue, 1) OVER (ORDER BY year, month) as prev_month_revenue,
        LAG(total_revenue, 2) OVER (ORDER BY year, month) as prev_month2_revenue
    FROM monthly_orders
)
SELECT 
    year,
    month,
    total_revenue,
    prev_month_revenue,
    percentage_change(total_revenue, prev_month_revenue) as month_over_month_change,
    simple_moving_average(total_revenue, prev_month_revenue, prev_month2_revenue) as three_month_avg
FROM with_previous
WHERE prev_month2_revenue IS NOT NULL;

-- =============================================
-- 9. MACRO COMPOSITION AND NESTING
-- =============================================

SELECT 'Macro Composition and Nesting' as section;

-- Base macros for composition
CREATE OR REPLACE MACRO net_amount(gross, tax_rate) AS 
    gross / (1 + tax_rate);

CREATE OR REPLACE MACRO apply_discount(amount, discount_rate) AS 
    amount * (1 - discount_rate);

-- Composite macro using other macros
CREATE OR REPLACE MACRO final_price(gross_price, tax_rate, discount_rate) AS 
    apply_discount(net_amount(gross_price, tax_rate), discount_rate);

-- Test macro composition
SELECT 
    1000 as gross_price,
    net_amount(1000, 0.1) as net_price,
    apply_discount(909.09, 0.15) as discounted_net,
    final_price(1000, 0.1, 0.15) as final_calculated_price;

-- Complex business rule macro
CREATE OR REPLACE MACRO shipping_cost(weight, distance, is_express, customer_tier) AS 
    CASE customer_tier
        WHEN 'VIP' THEN 0  -- Free shipping for VIP
        WHEN 'Premium' THEN 
            CASE WHEN is_express THEN weight * 0.5 + distance * 0.1
                 ELSE weight * 0.3 + distance * 0.05
            END * 0.5  -- 50% discount
        ELSE 
            CASE WHEN is_express THEN weight * 0.5 + distance * 0.1
                 ELSE weight * 0.3 + distance * 0.05
            END
    END;

-- Test complex shipping calculation
WITH shipping_scenarios AS (
    SELECT scenario, weight, distance, is_express, customer_tier FROM VALUES 
        ('Standard Customer, Regular', 10, 500, false, 'Standard'),
        ('Standard Customer, Express', 10, 500, true, 'Standard'),
        ('Premium Customer, Regular', 10, 500, false, 'Premium'),
        ('VIP Customer, Express', 10, 500, true, 'VIP')
    AS t(scenario, weight, distance, is_express, customer_tier)
)
SELECT 
    scenario,
    weight,
    distance,
    is_express,
    customer_tier,
    shipping_cost(weight, distance, is_express, customer_tier) as calculated_shipping_cost
FROM shipping_scenarios;

-- =============================================
-- 10. MACRO MANAGEMENT AND BEST PRACTICES
-- =============================================

SELECT 'Macro Management and Best Practices' as section;

-- List all user-defined macros
SELECT 
    function_name,
    function_type,
    description,
    parameters,
    return_type
FROM duckdb_functions() 
WHERE function_type = 'macro'
ORDER BY function_name;

-- Macro with documentation (using comments)
CREATE OR REPLACE MACRO calculate_compound_interest(
    principal,      -- Initial investment amount
    annual_rate,    -- Annual interest rate (as decimal, e.g., 0.05 for 5%)
    years,          -- Number of years
    compounds_per_year  -- Compounding frequency (default: monthly)
) AS 
    principal * POWER(1 + annual_rate / compounds_per_year, compounds_per_year * years);

-- Test documented macro
SELECT 
    1000 as principal,
    calculate_compound_interest(1000, 0.05, 10, 12) as monthly_compounding,
    calculate_compound_interest(1000, 0.05, 10, 1) as annual_compounding,
    calculate_compound_interest(1000, 0.05, 10, 365) as daily_compounding;

-- =============================================
-- 11. PERFORMANCE CONSIDERATIONS
-- =============================================

SELECT 'Performance Considerations' as section;

/*
Macro Performance Tips:

1. COMPILE-TIME SUBSTITUTION:
   - Macros are expanded at compile time, not runtime
   - No function call overhead
   - Parameters are directly substituted into SQL

2. OPTIMIZATION:
   - DuckDB optimizer can optimize macro expressions
   - Use simple expressions when possible
   - Avoid overly complex nested macros

3. MEMORY USAGE:
   - Macros don't consume runtime memory
   - Large macro definitions are stored in catalog
   - Consider breaking very complex macros into smaller ones

4. DEBUGGING:
   - Use EXPLAIN to see expanded macro SQL
   - Test macros with simple inputs first
   - Document macro parameters and expected behavior
*/

-- Example: Simple vs Complex macro performance
CREATE OR REPLACE MACRO simple_calc(x, y) AS x + y;

CREATE OR REPLACE MACRO complex_calc(x, y) AS 
    CASE 
        WHEN x > 0 AND y > 0 THEN 
            SQRT(x * x + y * y) * 
            (1 + SIN(x) * COS(y)) * 
            LOG(ABS(x) + ABS(y) + 1)
        ELSE 0 
    END;

-- Performance test (simple operations are faster)
SELECT 
    simple_calc(10, 20) as simple_result,
    complex_calc(10, 20) as complex_result;

-- =============================================
-- 12. REAL-WORLD MACRO EXAMPLES
-- =============================================

SELECT 'Real-World Macro Examples' as section;

-- Customer Lifetime Value calculation
CREATE OR REPLACE MACRO customer_ltv(
    avg_order_value,
    purchase_frequency_per_year,
    customer_lifespan_years,
    profit_margin
) AS 
    avg_order_value * purchase_frequency_per_year * customer_lifespan_years * profit_margin;

-- Inventory turnover ratio
CREATE OR REPLACE MACRO inventory_turnover(cost_of_goods_sold, avg_inventory) AS 
    CASE 
        WHEN avg_inventory > 0 THEN cost_of_goods_sold / avg_inventory
        ELSE NULL
    END;

-- A/B test statistical significance (simplified)
CREATE OR REPLACE MACRO ab_test_significance(
    conversions_a, visitors_a,
    conversions_b, visitors_b
) AS 
    CASE 
        WHEN visitors_a > 0 AND visitors_b > 0 THEN
            ABS((conversions_a::FLOAT / visitors_a) - (conversions_b::FLOAT / visitors_b)) > 0.02
        ELSE false
    END;

-- Test real-world macros
SELECT 
    customer_ltv(150, 4, 3, 0.25) as ltv_estimate,
    inventory_turnover(500000, 100000) as turnover_ratio,
    ab_test_significance(120, 1000, 140, 1000) as is_significant;

-- =============================================
-- 13. CLEANUP AND MACRO REMOVAL
-- =============================================

-- Drop specific macros (uncomment to use)
-- DROP MACRO IF EXISTS calculate_tax;
-- DROP MACRO IF EXISTS discount_price;

-- Note: Macros persist in the database session
-- They are automatically cleaned up when connection closes

-- =============================================
-- SUMMARY
-- =============================================

/*
This file covered:

1. Understanding SQL Macros - parameterized SQL templates
2. Basic macro creation with default parameters
3. Business logic macros for customer classification
4. Aggregate and analytical macros for calculations
5. String manipulation macros for formatting
6. Conditional logic macros for complex rules
7. Date and time macros for temporal calculations
8. Complex analytical macros for business metrics
9. Macro composition and nesting techniques
10. Macro management and best practices
11. Performance considerations and optimization
12. Real-world macro examples for business use cases
13. Cleanup and macro lifecycle management

Key takeaways:
- Macros are pure SQL templates with compile-time substitution
- Perfect for reusable business logic and calculations
- No external dependencies, excellent performance
- Support default parameters and complex expressions
- Can be composed and nested for sophisticated logic
- Essential tool for maintaining consistent business rules across queries
*/

SELECT 'SQL Macros Tutorial Complete' as summary;