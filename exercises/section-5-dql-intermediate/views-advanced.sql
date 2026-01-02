-- ADVANCED VIEWS Examples - Extended View Concepts
-- This file demonstrates advanced view patterns, materialized views, and view optimization
-- ============================================
-- REQUIRED: This file uses both TPC-H and Star Wars databases
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-5-dql-intermediate/views-advanced.sql
-- ============================================

-- ADVANCED VIEW CONCEPTS:
-- - Updatable views and their limitations
-- - Views with window functions
-- - Recursive views (using CTEs)
-- - Views for data transformation and ETL
-- - Performance considerations with complex views
-- - View dependencies and management

-- ============================================
-- UPDATABLE VIEWS
-- ============================================

-- Example 1: Simple updatable view
-- Views are updatable if they meet certain criteria:
-- - Single table source
-- - No aggregations, DISTINCT, GROUP BY, HAVING
-- - No window functions or set operations
CREATE VIEW customer_contact_info AS
SELECT 
    c_custkey,
    c_name,
    c_address,
    c_phone
FROM customer
WHERE c_custkey <= 100;  -- Limit for safety in examples

-- This view is updatable - we can INSERT, UPDATE, DELETE through it
SELECT * FROM customer_contact_info LIMIT 5;

-- Example of updating through a view (commented out for safety)
-- UPDATE customer_contact_info 
-- SET c_phone = '555-0123' 
-- WHERE c_custkey = 1;

-- Example 2: Non-updatable view (has JOIN)
CREATE VIEW customer_nation_view AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_address,
    n.n_name as nation_name
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey;

-- This view is NOT updatable due to the JOIN
SELECT * FROM customer_nation_view LIMIT 5;

-- ============================================
-- VIEWS WITH WINDOW FUNCTIONS
-- ============================================

-- Example 3: Analytical view with window functions
CREATE VIEW customer_ranking_analysis AS
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_mktsegment,
    n.n_name as nation,
    -- Ranking functions
    ROW_NUMBER() OVER (ORDER BY c_acctbal DESC) as balance_rank,
    RANK() OVER (PARTITION BY c_mktsegment ORDER BY c_acctbal DESC) as segment_rank,
    -- Analytical functions
    AVG(c_acctbal) OVER (PARTITION BY c_mktsegment) as segment_avg_balance,
    c_acctbal - AVG(c_acctbal) OVER (PARTITION BY c_mktsegment) as balance_vs_segment_avg,
    -- Percentile functions
    NTILE(4) OVER (ORDER BY c_acctbal) as balance_quartile
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey;

-- Query the analytical view
SELECT 
    c_name,
    nation,
    c_mktsegment,
    c_acctbal,
    balance_rank,
    segment_rank,
    balance_quartile,
    ROUND(balance_vs_segment_avg, 2) as balance_vs_avg
FROM customer_ranking_analysis
WHERE balance_rank <= 20
ORDER BY balance_rank;

-- Example 4: Time-series analysis view
CREATE VIEW order_trend_analysis AS
SELECT 
    o_orderdate,
    COUNT(*) as daily_orders,
    SUM(o_totalprice) as daily_revenue,
    -- Moving averages
    AVG(COUNT(*)) OVER (
        ORDER BY o_orderdate 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as orders_7day_avg,
    AVG(SUM(o_totalprice)) OVER (
        ORDER BY o_orderdate 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as revenue_7day_avg,
    -- Growth calculations
    LAG(SUM(o_totalprice), 1) OVER (ORDER BY o_orderdate) as prev_day_revenue,
    SUM(o_totalprice) - LAG(SUM(o_totalprice), 1) OVER (ORDER BY o_orderdate) as revenue_change
FROM orders
GROUP BY o_orderdate;

-- Query trend analysis
SELECT 
    o_orderdate,
    daily_orders,
    daily_revenue,
    ROUND(orders_7day_avg, 1) as avg_orders_7d,
    ROUND(revenue_7day_avg, 0) as avg_revenue_7d,
    ROUND(revenue_change, 0) as revenue_change
FROM order_trend_analysis
WHERE o_orderdate >= '1995-01-01' AND o_orderdate <= '1995-01-31'
ORDER BY o_orderdate;

-- ============================================
-- VIEWS FOR DATA TRANSFORMATION (ETL PATTERNS)
-- ============================================

-- Example 5: Data cleansing and standardization view
CREATE VIEW customer_standardized AS
SELECT 
    c_custkey,
    UPPER(TRIM(c_name)) as customer_name_clean,
    TRIM(c_address) as address_clean,
    -- Standardize phone format
    CASE 
        WHEN LENGTH(c_phone) = 15 THEN c_phone
        ELSE 'INVALID: ' || c_phone
    END as phone_standardized,
    -- Categorize account balance
    CASE 
        WHEN c_acctbal < 0 THEN 'NEGATIVE'
        WHEN c_acctbal = 0 THEN 'ZERO'
        WHEN c_acctbal < 1000 THEN 'LOW'
        WHEN c_acctbal < 5000 THEN 'MEDIUM'
        WHEN c_acctbal < 9000 THEN 'HIGH'
        ELSE 'PREMIUM'
    END as balance_category,
    -- Standardize market segment
    UPPER(TRIM(c_mktsegment)) as market_segment_clean,
    c_nationkey,
    c_acctbal
FROM customer;

-- Query standardized data
SELECT 
    balance_category,
    market_segment_clean,
    COUNT(*) as customer_count,
    AVG(c_acctbal) as avg_balance,
    MIN(c_acctbal) as min_balance,
    MAX(c_acctbal) as max_balance
FROM customer_standardized
GROUP BY balance_category, market_segment_clean
ORDER BY balance_category, market_segment_clean;

-- Example 6: Dimensional modeling view (Star Schema pattern)
CREATE VIEW fact_order_summary AS
SELECT 
    -- Fact measures
    l.l_orderkey,
    l.l_linenumber,
    l.l_quantity,
    l.l_extendedprice,
    l.l_discount,
    l.l_tax,
    l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax) as net_amount,
    
    -- Dimension keys
    o.o_custkey as customer_key,
    l.l_partkey as product_key,
    l.l_suppkey as supplier_key,
    
    -- Time dimensions
    o.o_orderdate,
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    EXTRACT(MONTH FROM o.o_orderdate) as order_month,
    EXTRACT(QUARTER FROM o.o_orderdate) as order_quarter,
    EXTRACT(DAYOFWEEK FROM o.o_orderdate) as order_day_of_week,
    
    -- Additional attributes
    o.o_orderstatus,
    o.o_orderpriority,
    l.l_shipmode,
    l.l_returnflag
FROM lineitem l
JOIN orders o ON l.l_orderkey = o.o_orderkey;

-- Query the fact table view
SELECT 
    order_year,
    order_quarter,
    COUNT(*) as total_line_items,
    SUM(l_quantity) as total_quantity,
    SUM(net_amount) as total_revenue,
    AVG(net_amount) as avg_line_value
FROM fact_order_summary
WHERE order_year = 1995
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;

-- ============================================
-- RECURSIVE VIEWS (Using CTEs)
-- ============================================

-- Example 7: Hierarchical data view
-- Note: This creates a mock hierarchy for demonstration
CREATE VIEW region_hierarchy AS
WITH RECURSIVE hierarchy AS (
    -- Base case: regions (top level)
    SELECT 
        r_regionkey as id,
        r_name as name,
        'REGION' as level_type,
        0 as level_depth,
        r_name as path,
        r_regionkey as root_region
    FROM region
    
    UNION ALL
    
    -- Recursive case: nations under regions
    SELECT 
        n.n_nationkey as id,
        n.n_name as name,
        'NATION' as level_type,
        h.level_depth + 1 as level_depth,
        h.path || ' > ' || n.n_name as path,
        h.root_region
    FROM nation n
    JOIN hierarchy h ON n.n_regionkey = h.id AND h.level_type = 'REGION'
)
SELECT * FROM hierarchy;

-- Query the hierarchical view
SELECT 
    level_type,
    level_depth,
    name,
    path
FROM region_hierarchy
ORDER BY root_region, level_depth, name;

-- ============================================
-- VIEW PERFORMANCE OPTIMIZATION
-- ============================================

-- Example 8: Performance comparison - Simple vs Complex views
-- Simple view (fast)
CREATE VIEW orders_simple AS
SELECT 
    o_orderkey,
    o_custkey,
    o_totalprice,
    o_orderdate
FROM orders
WHERE o_orderdate >= '1995-01-01';

-- Complex view (slower due to multiple joins and aggregations)
CREATE VIEW orders_complex AS
SELECT 
    o.o_orderkey,
    o.o_custkey,
    c.c_name,
    n.n_name as nation,
    r.r_name as region,
    o.o_totalprice,
    o.o_orderdate,
    COUNT(l.l_linenumber) as line_item_count,
    SUM(l.l_quantity) as total_quantity,
    AVG(l.l_extendedprice) as avg_line_price
FROM orders o
JOIN customer c ON o.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
LEFT JOIN lineitem l ON o.o_orderkey = l.l_orderkey
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY o.o_orderkey, o.o_custkey, c.c_name, n.n_name, r.r_name, o.o_totalprice, o.o_orderdate;

-- Compare performance (use EXPLAIN ANALYZE in practice)
EXPLAIN SELECT COUNT(*) FROM orders_simple;
EXPLAIN SELECT COUNT(*) FROM orders_complex;

-- ============================================
-- VIEW DEPENDENCY MANAGEMENT
-- ============================================

-- Example 9: View dependencies
-- Create a base view
CREATE VIEW customer_base AS
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    c_mktsegment,
    c_nationkey
FROM customer;

-- Create a dependent view
CREATE VIEW customer_enriched AS
SELECT 
    cb.*,
    n.n_name as nation_name,
    r.r_name as region_name
FROM customer_base cb
JOIN nation n ON cb.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey;

-- Create another dependent view
CREATE VIEW customer_analytics AS
SELECT 
    ce.region_name,
    ce.c_mktsegment,
    COUNT(*) as customer_count,
    AVG(ce.c_acctbal) as avg_balance,
    SUM(ce.c_acctbal) as total_balance
FROM customer_enriched ce
GROUP BY ce.region_name, ce.c_mktsegment;

-- Query the final analytical view
SELECT * FROM customer_analytics
ORDER BY total_balance DESC;

-- Show view dependencies (DuckDB specific)
SELECT 
    table_name,
    view_definition
FROM information_schema.views
WHERE table_name IN ('customer_base', 'customer_enriched', 'customer_analytics')
ORDER BY table_name;

-- ============================================
-- CLEANUP
-- ============================================

-- Drop views in reverse dependency order
DROP VIEW IF EXISTS customer_analytics;
DROP VIEW IF EXISTS customer_enriched;
DROP VIEW IF EXISTS customer_base;
DROP VIEW IF EXISTS orders_complex;
DROP VIEW IF EXISTS orders_simple;
DROP VIEW IF EXISTS region_hierarchy;
DROP VIEW IF EXISTS fact_order_summary;
DROP VIEW IF EXISTS customer_standardized;
DROP VIEW IF EXISTS order_trend_analysis;
DROP VIEW IF EXISTS customer_ranking_analysis;
DROP VIEW IF EXISTS customer_nation_view;
DROP VIEW IF EXISTS customer_contact_info;

-- ============================================
-- ADVANCED VIEW BEST PRACTICES
-- ============================================

-- 1. PERFORMANCE CONSIDERATIONS:
--    - Complex views with multiple JOINs can be slow
--    - Consider breaking complex views into simpler, layered views
--    - Use EXPLAIN to analyze view query plans
--    - Be aware that views are re-executed on each query

-- 2. MAINTAINABILITY:
--    - Document view purpose and business logic
--    - Use consistent naming conventions
--    - Manage view dependencies carefully
--    - Version control view definitions

-- 3. SECURITY AND ACCESS CONTROL:
--    - Use views to limit access to sensitive columns
--    - Create role-specific views for different user groups
--    - Avoid exposing raw table structures to end users

-- 4. DATA QUALITY:
--    - Use views for data standardization and cleansing
--    - Implement business rules consistently through views
--    - Create validation views to check data quality

-- 5. ANALYTICAL PATTERNS:
--    - Use views for common analytical calculations
--    - Create dimensional views for reporting
--    - Implement slowly changing dimension logic in views