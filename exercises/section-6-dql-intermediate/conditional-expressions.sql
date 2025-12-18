-- SQL CONDITIONAL EXPRESSIONS Examples - Advanced Data Query Language (DQL)
-- This file demonstrates conditional logic in SQL for dynamic data transformation
-- Conditional expressions allow for if-then-else logic within SQL queries
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-6-dql-intermediate/conditional-expressions.sql
-- ============================================

-- CONDITIONAL EXPRESSION TYPES:
-- - CASE WHEN: Multi-condition logic (searched case)
-- - Simple CASE: Value matching (simple case)
-- - IF(): Two-way conditional (DuckDB specific)
-- - COALESCE(): First non-NULL value
-- - IFNULL(): NULL replacement (two values)
-- - NULLIF(): Convert specific value to NULL

-- SYNTAX OVERVIEW:
-- CASE WHEN condition THEN result [WHEN condition THEN result ...] [ELSE result] END
-- CASE expression WHEN value THEN result [WHEN value THEN result ...] [ELSE result] END
-- IF(condition, true_result, false_result)
-- COALESCE(value1, value2, value3, ...)
-- IFNULL(expression, replacement_value)
-- NULLIF(expression1, expression2)

-- ============================================
-- CASE WHEN EXPRESSIONS (SEARCHED CASE)
-- ============================================

-- Example 1: Customer tier classification based on order history
-- Classify customers into tiers based on their years as customers
SELECT
    o_custkey,
    DATEDIFF('year', min_orderdate, CURRENT_DATE) as customer_years,
    CASE
        WHEN DATEDIFF('year', min_orderdate, CURRENT_DATE) >= 25 THEN 'Diamond Customer'
        WHEN DATEDIFF('year', min_orderdate, CURRENT_DATE) >= 20 THEN 'Platinum Customer'
        WHEN DATEDIFF('year', min_orderdate, CURRENT_DATE) >= 15 THEN 'Gold Customer'
        WHEN DATEDIFF('year', min_orderdate, CURRENT_DATE) >= 10 THEN 'Silver Customer'
        ELSE 'Bronze Customer'
    END AS customer_tier,
    c.c_name,
    c.c_nationkey
FROM (
    SELECT
        o_custkey,
        MIN(o_orderdate) as min_orderdate
    FROM orders
    GROUP BY o_custkey
) o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
ORDER BY customer_years DESC
LIMIT 10;

-- Example 2: Order priority classification with business logic
-- Categorize orders based on total price and priority for processing
SELECT
    o_orderkey,
    o_totalprice,
    o_orderpriority,
    CASE
        WHEN o_totalprice > 300000 AND o_orderpriority IN ('1-URGENT', '2-HIGH') THEN 'VIP Rush'
        WHEN o_totalprice > 200000 THEN 'High Value'
        WHEN o_orderpriority IN ('1-URGENT', '2-HIGH') THEN 'Priority'
        WHEN o_totalprice < 50000 THEN 'Standard'
        ELSE 'Regular'
    END AS processing_category,
    CASE
        WHEN o_totalprice > 300000 THEN 'Same Day'
        WHEN o_orderpriority IN ('1-URGENT', '2-HIGH') THEN '1-2 Days'
        ELSE '3-5 Days'
    END AS estimated_delivery
FROM orders
WHERE o_orderdate >= '1995-01-01'
ORDER BY o_totalprice DESC
LIMIT 15;

-- Example 3: Part size and type analysis with multiple conditions
-- Analyze parts with complex business rules for inventory management
SELECT
    p_partkey,
    p_name,
    p_size,
    p_type,
    p_retailprice,
    CASE
        WHEN p_size > 40 AND p_retailprice > 1500 THEN 'Large Premium'
        WHEN p_size > 40 THEN 'Large Standard'
        WHEN p_size > 20 AND p_retailprice > 1000 THEN 'Medium Premium'
        WHEN p_size > 20 THEN 'Medium Standard'
        WHEN p_retailprice > 500 THEN 'Small Premium'
        ELSE 'Small Standard'
    END AS inventory_category,
    CASE
        WHEN p_type LIKE '%STEEL%' THEN 'Industrial'
        WHEN p_type LIKE '%BRASS%' THEN 'Commercial'
        WHEN p_type LIKE '%COPPER%' THEN 'Electrical'
        ELSE 'General'
    END AS material_category
FROM part
WHERE p_retailprice IS NOT NULL
ORDER BY p_retailprice DESC
LIMIT 20;

-- ============================================
-- SIMPLE CASE EXPRESSIONS (VALUE MATCHING)
-- ============================================

-- Example 1: Order status translation to full descriptions
-- Convert abbreviated order status codes to readable descriptions
SELECT
    o_orderkey,
    o_orderstatus,
    CASE o_orderstatus
        WHEN 'F' THEN 'Filled'
        WHEN 'O' THEN 'Open'
        WHEN 'P' THEN 'Partial'
        ELSE 'Unknown Status'
    END AS status_description,
    o_totalprice,
    o_orderdate
FROM orders
ORDER BY o_orderdate DESC
LIMIT 10;

-- Example 2: Nation region mapping for reporting
-- Map nation keys to region names for business reporting
SELECT
    n_nationkey,
    n_name,
    CASE n_regionkey
        WHEN 0 THEN 'Africa'
        WHEN 1 THEN 'America'
        WHEN 2 THEN 'Asia'
        WHEN 3 THEN 'Europe'
        WHEN 4 THEN 'Middle East'
        ELSE 'Unknown Region'
    END AS region_name,
    COUNT(*) as customer_count
FROM nation n
INNER JOIN customer c ON n.n_nationkey = c.c_nationkey
GROUP BY n_nationkey, n_name, n_regionkey
ORDER BY customer_count DESC;

-- Example 3: Part container type standardization
-- Standardize container descriptions for shipping logistics
SELECT
    p_partkey,
    p_name,
    p_container,
    CASE p_container
        WHEN 'SM CASE' THEN 'Small Case'
        WHEN 'SM BOX' THEN 'Small Box'
        WHEN 'SM PACK' THEN 'Small Package'
        WHEN 'SM PKG' THEN 'Small Package'
        WHEN 'MED BAG' THEN 'Medium Bag'
        WHEN 'MED BOX' THEN 'Medium Box'
        WHEN 'MED PKG' THEN 'Medium Package'
        WHEN 'MED PACK' THEN 'Medium Package'
        WHEN 'LG CASE' THEN 'Large Case'
        WHEN 'LG BOX' THEN 'Large Box'
        WHEN 'LG PACK' THEN 'Large Package'
        WHEN 'LG PKG' THEN 'Large Package'
        ELSE 'Standard Container'
    END AS container_description
FROM part
WHERE p_container IS NOT NULL
ORDER BY p_container
LIMIT 15;

-- ============================================
-- IF() FUNCTION (DUCKDB SPECIFIC)
-- ============================================

-- Example 1: High-value order flagging for sales team
-- Create temporary table with value classification for analysis
CREATE TEMPORARY TABLE orders_classified AS
SELECT
    o_orderkey,
    o_custkey,
    o_totalprice,
    o_orderdate,
    IF(o_totalprice > 200000, 'High Value', 'Standard Value') AS value_category,
    IF(o_orderpriority IN ('1-URGENT', '2-HIGH'), 'Priority', 'Regular') AS priority_flag
FROM orders;

-- Query the classified orders
SELECT 
    value_category,
    priority_flag,
    COUNT(*) as order_count,
    AVG(o_totalprice) as avg_order_value,
    SUM(o_totalprice) as total_value
FROM orders_classified
GROUP BY value_category, priority_flag
ORDER BY total_value DESC;

-- Example 2: Supplier performance evaluation
-- Evaluate suppliers based on part pricing competitiveness
SELECT
    s_suppkey,
    s_name,
    s_nationkey,
    COUNT(ps_partkey) as parts_supplied,
    AVG(ps_supplycost) as avg_supply_cost,
    IF(AVG(ps_supplycost) < 500, 'Cost Effective', 'Premium Supplier') AS cost_category,
    IF(COUNT(ps_partkey) > 100, 'High Volume', 'Low Volume') AS volume_category
FROM supplier s
INNER JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s_suppkey, s_name, s_nationkey
HAVING COUNT(ps_partkey) > 50
ORDER BY avg_supply_cost;

-- Example 3: Customer market segment analysis
-- Analyze customer segments with conditional logic
SELECT
    c_custkey,
    c_name,
    c_mktsegment,
    c_acctbal,
    IF(c_acctbal > 5000, 'High Credit', 'Standard Credit') AS credit_rating,
    IF(c_mktsegment = 'BUILDING', 'Construction Industry', 'Other Industry') AS industry_type,
    n.n_name as nation
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE c_acctbal > 0
ORDER BY c_acctbal DESC
LIMIT 20;

-- Clean up temporary table
DROP TABLE orders_classified;

-- ============================================
-- COALESCE() FUNCTION
-- ============================================

-- Example 1: Part comment handling with fallback descriptions
-- Provide meaningful descriptions when comments are missing
SELECT
    p_partkey,
    p_name,
    p_mfgr,
    p_brand,
    p_type,
    COALESCE(
        p_comment,
        CONCAT(p_name, ' - ', p_brand, ' ', p_type),
        CONCAT(p_brand, ' part manufactured by ', p_mfgr),
        'No description available'
    ) AS part_description
FROM part
ORDER BY p_partkey
LIMIT 15;

-- Example 2: Customer contact information consolidation
-- Create comprehensive contact info with multiple fallback options
SELECT
    c_custkey,
    c_name,
    c_address,
    c_phone,
    c_comment,
    COALESCE(
        NULLIF(TRIM(c_comment), ''),
        CONCAT('Customer in ', n.n_name, ' - Phone: ', c_phone),
        CONCAT('Customer in ', n.n_name),
        'Contact information incomplete'
    ) AS contact_summary
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
ORDER BY c_custkey
LIMIT 10;

-- Example 3: Supplier information with business context
-- Build comprehensive supplier profiles with fallback information
SELECT
    s_suppkey,
    s_name,
    s_address,
    s_phone,
    s_comment,
    n.n_name as nation,
    COALESCE(
        NULLIF(TRIM(s_comment), ''),
        CONCAT(s_name, ' operates in ', n.n_name, ' region'),
        CONCAT('Supplier based in ', n.n_name),
        s_name,
        'Supplier information not available'
    ) AS supplier_profile
FROM supplier s
INNER JOIN nation n ON s.s_nationkey = n.n_nationkey
ORDER BY s_suppkey
LIMIT 12;

-- ============================================
-- IFNULL() FUNCTION
-- ============================================

-- Example 1: Customer comment standardization
-- Handle missing customer comments with default messaging
SELECT 
    c_custkey,
    c_name,
    c_mktsegment,
    c_comment,
    IFNULL(c_comment, 'No customer notes available') as standardized_comment,
    IFNULL(LENGTH(c_comment), 0) as comment_length
FROM customer
ORDER BY c_custkey
LIMIT 10;

-- Example 2: Order aggregation with safe NULL handling
-- Prevent NULL issues in customer order summaries
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_mktsegment,
    IFNULL(COUNT(o.o_orderkey), 0) as total_orders,
    IFNULL(SUM(o.o_totalprice), 0.00) as total_spent,
    IFNULL(AVG(o.o_totalprice), 0.00) as avg_order_value,
    IFNULL(MAX(o.o_orderdate), '1900-01-01') as last_order_date
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
ORDER BY total_spent DESC
LIMIT 15;

-- Example 3: Part pricing analysis with default values
-- Ensure consistent pricing data for business analysis
SELECT 
    p_partkey,
    p_name,
    p_type,
    p_retailprice,
    IFNULL(p_retailprice, 0.00) as price_for_analysis,
    CASE 
        WHEN p_retailprice IS NULL THEN 'Price Not Set'
        WHEN p_retailprice > 1500 THEN 'Premium'
        WHEN p_retailprice > 800 THEN 'Mid-Range'
        ELSE 'Economy'
    END as price_tier,
    IFNULL(p_comment, 'No specifications available') as specifications
FROM part
WHERE p_retailprice IS NULL OR p_retailprice > 1200
ORDER BY price_for_analysis DESC
LIMIT 20;

-- ============================================
-- NULLIF() FUNCTION
-- ============================================

-- Example 1: Clean empty string comments by converting to NULL
-- Convert empty or placeholder comments to NULL for cleaner data
SELECT
    p_partkey,
    p_name,
    p_comment,
    NULLIF(p_comment, '') AS cleaned_comment,
    NULLIF(p_comment, 'No comment available.') AS meaningful_comment,
    CASE 
        WHEN NULLIF(p_comment, '') IS NULL THEN 'No Comment'
        ELSE 'Has Comment'
    END AS comment_status
FROM part
ORDER BY p_partkey
LIMIT 15;

-- Example 2: Handle default phone numbers in supplier data
-- Convert placeholder phone numbers to NULL for data quality
SELECT
    s_suppkey,
    s_name,
    s_phone,
    NULLIF(s_phone, '000-000-0000') AS valid_phone,
    NULLIF(s_phone, 'N/A') AS cleaned_phone,
    CASE 
        WHEN NULLIF(s_phone, '000-000-0000') IS NULL THEN 'Phone Missing'
        ELSE 'Phone Available'
    END AS contact_status
FROM supplier
ORDER BY s_suppkey
LIMIT 10;

-- Example 3: Customer account balance data cleaning
-- Convert zero balances to NULL for specific business analysis
SELECT
    c_custkey,
    c_name,
    c_acctbal,
    NULLIF(c_acctbal, 0.00) AS non_zero_balance,
    CASE 
        WHEN NULLIF(c_acctbal, 0.00) IS NULL THEN 'Zero Balance'
        WHEN c_acctbal > 0 THEN 'Positive Balance'
        ELSE 'Negative Balance'
    END AS balance_category,
    COALESCE(NULLIF(c_acctbal, 0.00), -999.99) AS balance_for_analysis
FROM customer
WHERE c_acctbal <= 100 OR c_acctbal = 0
ORDER BY c_acctbal
LIMIT 15;