-- DATA WAREHOUSING PATTERNS - Real-World Scenarios
-- This file demonstrates dimensional modeling, star schema, and data warehousing concepts
-- using the TPC-H database as a realistic business scenario
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-9-real-world-scenarios/data-warehousing-patterns.sql
-- ============================================

-- DATA WAREHOUSING CONCEPTS:
-- - Dimensional Modeling: Organizing data into facts and dimensions
-- - Star Schema: Central fact table surrounded by dimension tables
-- - Fact Tables: Contain measurable business metrics (sales, quantities, amounts)
-- - Dimension Tables: Contain descriptive attributes (who, what, when, where)
-- - Slowly Changing Dimensions (SCD): Handling changes in dimension data over time
-- - Data Marts: Subject-specific subsets of the data warehouse

-- BUSINESS CONTEXT:
-- The TPC-H database represents a wholesale supplier business with:
-- - Customers placing orders for parts from suppliers
-- - Geographic hierarchy (regions > nations)
-- - Time-based transactions with dates
-- - This is a perfect example of dimensional modeling in practice

-- ============================================
-- UNDERSTANDING THE EXISTING STAR SCHEMA
-- ============================================

-- The TPC-H database already follows dimensional modeling principles
-- Let's analyze the existing structure:

-- Example 1: Identify Fact vs Dimension Tables
SELECT 'Table Analysis' as analysis_type;

-- FACT TABLES (contain measures/metrics):
-- - ORDERS: Contains order totals, dates (business transactions)
-- - LINEITEM: Contains quantities, prices, discounts (transaction details)

-- DIMENSION TABLES (contain attributes):
-- - CUSTOMER: Who is buying (customer attributes)
-- - PART: What is being sold (product attributes)  
-- - SUPPLIER: Who is supplying (supplier attributes)
-- - NATION: Where (geographic attributes)
-- - REGION: Where (geographic hierarchy)

-- Let's examine the relationships:
SELECT 
    'ORDERS (Fact Table)' as table_type,
    COUNT(*) as record_count,
    'Contains: order totals, dates, status' as contains
FROM orders

UNION ALL

SELECT 
    'LINEITEM (Fact Table)' as table_type,
    COUNT(*) as record_count,
    'Contains: quantities, prices, discounts' as contains
FROM lineitem

UNION ALL

SELECT 
    'CUSTOMER (Dimension)' as table_type,
    COUNT(*) as record_count,
    'Contains: customer attributes, segments' as contains
FROM customer

UNION ALL

SELECT 
    'PART (Dimension)' as table_type,
    COUNT(*) as record_count,
    'Contains: product attributes, categories' as contains
FROM part

UNION ALL

SELECT 
    'SUPPLIER (Dimension)' as table_type,
    COUNT(*) as record_count,
    'Contains: supplier attributes, locations' as contains
FROM supplier;

-- ============================================
-- STAR SCHEMA ANALYSIS
-- ============================================

-- Example 2: Classic Star Schema Query
-- Business Question: "What are our sales by customer segment and region?"
-- This demonstrates the star schema in action

SELECT 
    r.r_name as region,
    c.c_mktsegment as customer_segment,
    COUNT(DISTINCT c.c_custkey) as unique_customers,
    COUNT(o.o_orderkey) as total_orders,
    SUM(o.o_totalprice) as total_revenue,
    AVG(o.o_totalprice) as avg_order_value,
    SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as revenue_per_customer
FROM orders o                                    -- FACT TABLE (center of star)
INNER JOIN customer c ON o.o_custkey = c.c_custkey    -- DIMENSION: Customer
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey -- DIMENSION: Nation  
INNER JOIN region r ON n.n_regionkey = r.r_regionkey -- DIMENSION: Region
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY r.r_name, c.c_mktsegment
ORDER BY total_revenue DESC;

-- Example 3: Multi-Dimensional Analysis
-- Business Question: "Product performance by supplier nation and time period"
-- This shows how dimensions can be combined for deep analysis

SELECT 
    sn.n_name as supplier_nation,
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    EXTRACT(QUARTER FROM o.o_orderdate) as order_quarter,
    p.p_type as product_type,
    COUNT(DISTINCT l.l_orderkey) as orders_with_product,
    SUM(l.l_quantity) as total_quantity_sold,
    SUM(l.l_extendedprice) as total_revenue,
    AVG(l.l_extendedprice / l.l_quantity) as avg_unit_price
FROM lineitem l                                        -- FACT TABLE
INNER JOIN orders o ON l.l_orderkey = o.o_orderkey    -- Time dimension
INNER JOIN part p ON l.l_partkey = p.p_partkey       -- Product dimension
INNER JOIN supplier s ON l.l_suppkey = s.s_suppkey   -- Supplier dimension
INNER JOIN nation sn ON s.s_nationkey = sn.n_nationkey -- Geographic dimension
WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
  AND p.p_type LIKE '%STEEL%'  -- Focus on steel products
GROUP BY sn.n_name, EXTRACT(YEAR FROM o.o_orderdate), 
         EXTRACT(QUARTER FROM o.o_orderdate), p.p_type
HAVING SUM(l.l_extendedprice) > 50000  -- Only significant revenue
ORDER BY supplier_nation, order_year, order_quarter, total_revenue DESC;

-- ============================================
-- CREATING DATA MART VIEWS
-- ============================================

-- Example 4: Sales Data Mart
-- Create a focused view for sales analysis team
CREATE VIEW sales_data_mart AS
SELECT 
    -- Time Dimensions
    o.o_orderdate,
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    EXTRACT(MONTH FROM o.o_orderdate) as order_month,
    EXTRACT(QUARTER FROM o.o_orderdate) as order_quarter,
    EXTRACT(DAYOFWEEK FROM o.o_orderdate) as order_day_of_week,
    
    -- Customer Dimensions
    c.c_custkey as customer_key,
    c.c_name as customer_name,
    c.c_mktsegment as customer_segment,
    cn.n_name as customer_nation,
    cr.r_name as customer_region,
    
    -- Order Dimensions
    o.o_orderkey as order_key,
    o.o_orderstatus as order_status,
    o.o_orderpriority as order_priority,
    
    -- Measures (Facts)
    o.o_totalprice as order_total,
    1 as order_count  -- For counting orders
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation cn ON c.c_nationkey = cn.n_nationkey
INNER JOIN region cr ON cn.n_regionkey = cr.r_regionkey;

-- Test the sales data mart
SELECT 
    customer_region,
    order_year,
    SUM(order_count) as total_orders,
    SUM(order_total) as total_revenue,
    AVG(order_total) as avg_order_value
FROM sales_data_mart
WHERE order_year = 1995
GROUP BY customer_region, order_year
ORDER BY total_revenue DESC;

-- Example 5: Product Performance Data Mart
-- Create a focused view for product management team
CREATE VIEW product_data_mart AS
SELECT 
    -- Product Dimensions
    p.p_partkey as product_key,
    p.p_name as product_name,
    p.p_mfgr as manufacturer,
    p.p_brand as brand,
    p.p_type as product_type,
    p.p_size as product_size,
    p.p_container as container_type,
    
    -- Supplier Dimensions
    s.s_suppkey as supplier_key,
    s.s_name as supplier_name,
    sn.n_name as supplier_nation,
    sr.r_name as supplier_region,
    
    -- Time Dimensions
    o.o_orderdate,
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    EXTRACT(MONTH FROM o.o_orderdate) as order_month,
    
    -- Measures (Facts)
    l.l_quantity as quantity_sold,
    l.l_extendedprice as line_revenue,
    l.l_discount as discount_amount,
    l.l_extendedprice * (1 - l.l_discount) as net_revenue,
    p.p_retailprice as retail_price,
    1 as line_item_count
FROM lineitem l
INNER JOIN part p ON l.l_partkey = p.p_partkey
INNER JOIN supplier s ON l.l_suppkey = s.s_suppkey
INNER JOIN nation sn ON s.s_nationkey = sn.n_nationkey
INNER JOIN region sr ON sn.n_regionkey = sr.r_regionkey
INNER JOIN orders o ON l.l_orderkey = o.o_orderkey;

-- Test the product data mart
SELECT 
    manufacturer,
    brand,
    SUM(quantity_sold) as total_quantity,
    SUM(net_revenue) as total_revenue,
    COUNT(DISTINCT product_key) as unique_products,
    AVG(retail_price) as avg_retail_price
FROM product_data_mart
WHERE order_year = 1995
GROUP BY manufacturer, brand
HAVING SUM(net_revenue) > 100000
ORDER BY total_revenue DESC
LIMIT 15;

-- ============================================
-- SLOWLY CHANGING DIMENSIONS (SCD)
-- ============================================

-- Example 6: SCD Type 1 - Overwrite (Most Common)
-- Scenario: Customer changes address, we only keep current address
-- This is what most systems do by default

-- Simulate a customer address change
SELECT 'SCD Type 1 Example - Current State' as example_type;
SELECT c_custkey, c_name, c_address, c_phone 
FROM customer 
WHERE c_custkey = 1;

-- In a real system, this would be an UPDATE:
-- UPDATE customer SET c_address = 'New Address 123' WHERE c_custkey = 1;
-- Result: Historical address is lost, only current address remains

-- Example 7: SCD Type 2 - Add New Record (Historical Tracking)
-- Scenario: We want to track customer segment changes over time
-- Create a historical customer dimension table

CREATE TABLE customer_history AS
SELECT 
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment,
    '1995-01-01'::DATE as effective_date,
    '9999-12-31'::DATE as end_date,
    TRUE as is_current,
    1 as version_number
FROM customer
WHERE c_custkey <= 10;  -- Sample for demonstration

-- Simulate a customer segment change (SCD Type 2)
-- Customer 1 changes from current segment to 'PREMIUM'
INSERT INTO customer_history
SELECT 
    c_custkey,
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    'PREMIUM' as c_mktsegment,  -- New segment
    c_comment,
    '1995-06-01'::DATE as effective_date,  -- Change date
    '9999-12-31'::DATE as end_date,
    TRUE as is_current,
    2 as version_number  -- New version
FROM customer
WHERE c_custkey = 1;

-- Update the old record to close it
UPDATE customer_history 
SET end_date = '1995-05-31'::DATE, is_current = FALSE
WHERE c_custkey = 1 AND version_number = 1;

-- Query historical changes
SELECT 
    c_custkey,
    c_name,
    c_mktsegment,
    effective_date,
    end_date,
    is_current,
    version_number
FROM customer_history
WHERE c_custkey = 1
ORDER BY effective_date;

-- Example 8: Point-in-Time Analysis using SCD Type 2
-- Business Question: "What was our customer segmentation on a specific date?"
SELECT 
    c_mktsegment,
    COUNT(*) as customer_count
FROM customer_history
WHERE '1995-03-15'::DATE BETWEEN effective_date AND end_date  -- Point in time
GROUP BY c_mktsegment
ORDER BY customer_count DESC;

-- ============================================
-- DIMENSIONAL HIERARCHY NAVIGATION
-- ============================================

-- Example 9: Geographic Hierarchy Drill-Down
-- Business Question: "Sales performance from region down to nation level"

-- Level 1: Regional Summary
SELECT 
    r.r_name as region,
    COUNT(DISTINCT c.c_custkey) as customers,
    COUNT(o.o_orderkey) as orders,
    SUM(o.o_totalprice) as revenue
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY r.r_name
ORDER BY revenue DESC;

-- Level 2: Drill-down to Nation within Region
SELECT 
    r.r_name as region,
    n.n_name as nation,
    COUNT(DISTINCT c.c_custkey) as customers,
    COUNT(o.o_orderkey) as orders,
    SUM(o.o_totalprice) as revenue,
    -- Calculate percentage of region total
    ROUND(SUM(o.o_totalprice) * 100.0 / SUM(SUM(o.o_totalprice)) OVER (PARTITION BY r.r_name), 2) as pct_of_region
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY r.r_name, n.n_name
ORDER BY r.r_name, revenue DESC;

-- ============================================
-- FACT TABLE GRANULARITY EXAMPLES
-- ============================================

-- Example 10: Different Levels of Aggregation
-- Show how the same data can be viewed at different granularities

-- Daily Granularity (Most Detailed)
SELECT 'Daily Granularity' as level;
SELECT 
    o.o_orderdate,
    COUNT(o.o_orderkey) as orders,
    SUM(o.o_totalprice) as revenue
FROM orders o
WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-01-07'
GROUP BY o.o_orderdate
ORDER BY o.o_orderdate;

-- Weekly Granularity
SELECT 'Weekly Granularity' as level;
SELECT 
    EXTRACT(YEAR FROM o.o_orderdate) as year,
    EXTRACT(WEEK FROM o.o_orderdate) as week,
    COUNT(o.o_orderkey) as orders,
    SUM(o.o_totalprice) as revenue
FROM orders o
WHERE o.o_orderdate BETWEEN '1995-01-01' AND '1995-01-31'
GROUP BY EXTRACT(YEAR FROM o.o_orderdate), EXTRACT(WEEK FROM o.o_orderdate)
ORDER BY year, week;

-- Monthly Granularity (Summary Level)
SELECT 'Monthly Granularity' as level;
SELECT 
    EXTRACT(YEAR FROM o.o_orderdate) as year,
    EXTRACT(MONTH FROM o.o_orderdate) as month,
    COUNT(o.o_orderkey) as orders,
    SUM(o.o_totalprice) as revenue
FROM orders o
WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1995
GROUP BY EXTRACT(YEAR FROM o.o_orderdate), EXTRACT(MONTH FROM o.o_orderdate)
ORDER BY year, month;

-- ============================================
-- CONFORMED DIMENSIONS
-- ============================================

-- Example 11: Shared Dimensions Across Facts
-- Both ORDERS and LINEITEM share the same customer dimension
-- This ensures consistent reporting across different fact tables

-- Customer analysis from Orders perspective (order-level facts)
WITH customer_orders AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_order_value
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
-- Customer analysis from LineItem perspective (line-level facts)
customer_lineitems AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(l.l_linenumber) as total_line_items,
        SUM(l.l_extendedprice) as total_line_value
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
)
-- Combine both perspectives using the conformed customer dimension
SELECT 
    co.c_name,
    co.c_mktsegment,
    co.total_orders,
    co.total_order_value,
    cl.total_line_items,
    cl.total_line_value,
    ROUND(cl.total_line_items::DECIMAL / co.total_orders, 2) as avg_lines_per_order,
    ROUND(cl.total_line_value / co.total_order_value, 4) as line_to_order_ratio
FROM customer_orders co
INNER JOIN customer_lineitems cl ON co.c_custkey = cl.c_custkey
WHERE co.total_orders > 5
ORDER BY co.total_order_value DESC
LIMIT 20;

-- ============================================
-- DATA WAREHOUSE BEST PRACTICES
-- ============================================

-- Example 12: Surrogate Keys vs Natural Keys
-- In a real data warehouse, we'd use surrogate keys for dimensions
-- TPC-H uses natural keys, but let's show the concept

CREATE VIEW dim_customer_with_surrogate AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY c_custkey) as customer_sk,  -- Surrogate Key
    c_custkey as customer_nk,  -- Natural Key
    c_name,
    c_address,
    c_nationkey,
    c_phone,
    c_acctbal,
    c_mktsegment,
    c_comment
FROM customer;

-- Benefits of surrogate keys:
-- 1. Stable - don't change when business keys change
-- 2. Performance - usually integers, faster joins
-- 3. Flexibility - can handle multiple source systems
-- 4. SCD Support - enable historical tracking

SELECT 'Surrogate Key Example' as concept;
SELECT customer_sk, customer_nk, c_name, c_mktsegment 
FROM dim_customer_with_surrogate 
LIMIT 10;

-- ============================================
-- CLEANUP
-- ============================================

-- Drop temporary objects
DROP VIEW IF EXISTS dim_customer_with_surrogate;
DROP TABLE IF EXISTS customer_history;
DROP VIEW IF EXISTS product_data_mart;
DROP VIEW IF EXISTS sales_data_mart;

-- ============================================
-- DATA WAREHOUSING BEST PRACTICES SUMMARY
-- ============================================

-- 1. DIMENSIONAL MODELING PRINCIPLES:
--    - Separate facts (measures) from dimensions (attributes)
--    - Design for business user understanding, not normalization
--    - Use star schema for simplicity and performance

-- 2. FACT TABLE DESIGN:
--    - Choose appropriate granularity (daily, transaction, line-item)
--    - Include all relevant foreign keys to dimensions
--    - Store additive measures when possible

-- 3. DIMENSION TABLE DESIGN:
--    - Include descriptive attributes for filtering and grouping
--    - Use surrogate keys for stability and performance
--    - Implement slowly changing dimension strategies

-- 4. DATA MART STRATEGY:
--    - Create subject-specific views for different business areas
--    - Use conformed dimensions for consistency across marts
--    - Balance detail vs. performance based on usage patterns

-- 5. QUERY PATTERNS:
--    - Leverage dimensional hierarchies for drill-down analysis
--    - Use time dimensions for trend analysis
--    - Combine multiple dimensions for multi-dimensional analysis

-- 6. PERFORMANCE CONSIDERATIONS:
--    - Index foreign keys in fact tables
--    - Consider partitioning large fact tables by date
--    - Pre-aggregate common queries into summary tables

-- The TPC-H database demonstrates these principles in a realistic business context,
-- making it an excellent foundation for learning data warehousing concepts.