-- SQL VIEWS Examples - Advanced Data Query Language (DQL)
-- This file demonstrates view creation, usage, and management
-- Views are virtual tables based on SQL queries that simplify complex queries and enhance security
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-6-dql-intermediate/views.sql
-- ============================================

-- VIEW CONCEPTS:
-- - Views are stored queries that act as virtual tables
-- - They don't store data themselves (except materialized views)
-- - Simplify complex queries by encapsulating logic
-- - Provide security by limiting access to specific columns/rows
-- - Can be used in SELECT statements just like regular tables
-- - Some views are updatable (simple views without aggregations/joins)

-- VIEW OPERATIONS:
-- - CREATE VIEW: Define a new view
-- - CREATE OR REPLACE VIEW: Update existing view or create new one
-- - DROP VIEW: Remove a view
-- - DESCRIBE or SHOW: View structure information

-- ============================================
-- BASIC VIEW CREATION
-- ============================================

-- Example 1: Simple view for customer summary
-- Create a view that shows basic customer information with nation details
CREATE VIEW customer_summary AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_address,
    c.c_phone,
    c.c_acctbal,
    c.c_mktsegment,
    n.n_name as nation,
    r.r_name as region
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey;

-- Describe the view structure
DESCRIBE customer_summary;

-- Query the view like a regular table
SELECT * FROM customer_summary
WHERE region = 'AMERICA'
ORDER BY c_acctbal DESC
LIMIT 10;

-- Example 2: View for high-value orders
-- Create a view that filters orders above a certain threshold
CREATE VIEW high_value_orders AS
SELECT 
    o.o_orderkey,
    o.o_custkey,
    o.o_orderstatus,
    o.o_totalprice,
    o.o_orderdate,
    o.o_orderpriority,
    c.c_name as customer_name,
    n.n_name as customer_nation
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE o.o_totalprice > 200000;

-- Describe the view structure
DESCRIBE high_value_orders;

-- Use the view in queries
SELECT 
    customer_nation,
    COUNT(*) as high_value_order_count,
    AVG(o_totalprice) as avg_order_value,
    SUM(o_totalprice) as total_value
FROM high_value_orders
GROUP BY customer_nation
ORDER BY total_value DESC;

-- Example 3: View for part inventory summary
-- Create a view that aggregates part supplier information
CREATE VIEW part_inventory_summary AS
SELECT 
    p.p_partkey,
    p.p_name,
    p.p_mfgr,
    p.p_brand,
    p.p_type,
    p.p_size,
    p.p_retailprice,
    COUNT(ps.ps_suppkey) as supplier_count,
    MIN(ps.ps_supplycost) as min_supply_cost,
    AVG(ps.ps_supplycost) as avg_supply_cost,
    MAX(ps.ps_supplycost) as max_supply_cost,
    SUM(ps.ps_availqty) as total_available_qty
FROM part p
INNER JOIN partsupp ps ON p.p_partkey = ps.ps_partkey
GROUP BY p.p_partkey, p.p_name, p.p_mfgr, p.p_brand, p.p_type, p.p_size, p.p_retailprice;

-- Describe the view structure
DESCRIBE part_inventory_summary;

-- Query the inventory view
SELECT 
    p_name,
    p_brand,
    supplier_count,
    min_supply_cost,
    avg_supply_cost,
    total_available_qty
FROM part_inventory_summary
WHERE supplier_count > 3
ORDER BY total_available_qty DESC
LIMIT 15;

-- ============================================
-- CREATE OR REPLACE VIEW
-- ============================================

-- Example 4: Update an existing view with additional logic
-- Replace the customer_summary view with enhanced information
CREATE OR REPLACE VIEW customer_summary AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_address,
    c.c_phone,
    c.c_acctbal,
    c.c_mktsegment,
    n.n_name as nation,
    r.r_name as region,
    CASE 
        WHEN c.c_acctbal > 8000 THEN 'Premium'
        WHEN c.c_acctbal > 5000 THEN 'Gold'
        WHEN c.c_acctbal > 2000 THEN 'Silver'
        ELSE 'Standard'
    END AS customer_tier,
    CASE 
        WHEN c.c_acctbal < 0 THEN 'Negative Balance'
        WHEN c.c_acctbal = 0 THEN 'Zero Balance'
        ELSE 'Positive Balance'
    END AS balance_status
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey;

-- Describe the updated view structure (now with additional columns)
DESCRIBE customer_summary;

-- Query the updated view
SELECT 
    customer_tier,
    balance_status,
    COUNT(*) as customer_count,
    AVG(c_acctbal) as avg_balance
FROM customer_summary
GROUP BY customer_tier, balance_status
ORDER BY customer_tier, balance_status;

-- ============================================
-- VIEWS WITH AGGREGATIONS
-- ============================================

-- Example 5: Customer order statistics view
-- Create a view with aggregated customer order data
CREATE VIEW customer_order_stats AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_mktsegment,
    n.n_name as nation,
    COUNT(o.o_orderkey) as total_orders,
    SUM(o.o_totalprice) as lifetime_value,
    AVG(o.o_totalprice) as avg_order_value,
    MIN(o.o_orderdate) as first_order_date,
    MAX(o.o_orderdate) as last_order_date,
    DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey, c.c_name, c.c_mktsegment, n.n_name;

-- Describe the aggregated view structure
DESCRIBE customer_order_stats;

-- Use the aggregated view
SELECT 
    c_name,
    nation,
    total_orders,
    lifetime_value,
    avg_order_value,
    customer_lifespan_days
FROM customer_order_stats
WHERE total_orders > 0
ORDER BY lifetime_value DESC
LIMIT 20;

-- Example 6: Supplier performance view
-- Create a view analyzing supplier performance metrics
CREATE VIEW supplier_performance AS
SELECT 
    s.s_suppkey,
    s.s_name,
    n.n_name as supplier_nation,
    r.r_name as supplier_region,
    COUNT(DISTINCT ps.ps_partkey) as parts_supplied,
    AVG(ps.ps_supplycost) as avg_supply_cost,
    SUM(ps.ps_availqty) as total_inventory,
    COUNT(DISTINCT l.l_orderkey) as orders_fulfilled,
    SUM(l.l_quantity) as total_quantity_shipped,
    SUM(l.l_extendedprice) as total_revenue
FROM supplier s
INNER JOIN nation n ON s.s_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey
LEFT JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
LEFT JOIN lineitem l ON s.s_suppkey = l.l_suppkey
GROUP BY s.s_suppkey, s.s_name, n.n_name, r.r_name;

-- Describe the supplier performance view structure
DESCRIBE supplier_performance;

-- Analyze supplier performance
SELECT 
    supplier_nation,
    COUNT(*) as supplier_count,
    AVG(parts_supplied) as avg_parts_per_supplier,
    AVG(total_revenue) as avg_revenue_per_supplier,
    SUM(total_revenue) as total_nation_revenue
FROM supplier_performance
WHERE orders_fulfilled > 0
GROUP BY supplier_nation
ORDER BY total_nation_revenue DESC;

-- ============================================
-- VIEWS WITH COMPLEX JOINS AND SUBQUERIES
-- ============================================

-- Example 7: Order line item details view
-- Create a comprehensive view combining order, customer, and product information
CREATE VIEW order_line_details AS
SELECT 
    l.l_orderkey,
    l.l_linenumber,
    l.l_partkey,
    l.l_suppkey,
    l.l_quantity,
    l.l_extendedprice,
    l.l_discount,
    l.l_tax,
    l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax) as net_price,
    o.o_orderdate,
    o.o_orderstatus,
    o.o_orderpriority,
    c.c_custkey,
    c.c_name as customer_name,
    c.c_mktsegment,
    cn.n_name as customer_nation,
    p.p_name as part_name,
    p.p_brand,
    p.p_type,
    s.s_name as supplier_name,
    sn.n_name as supplier_nation
FROM lineitem l
INNER JOIN orders o ON l.l_orderkey = o.o_orderkey
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation cn ON c.c_nationkey = cn.n_nationkey
INNER JOIN part p ON l.l_partkey = p.p_partkey
INNER JOIN supplier s ON l.l_suppkey = s.s_suppkey
INNER JOIN nation sn ON s.s_nationkey = sn.n_nationkey;

-- Describe the comprehensive order line details view structure
DESCRIBE order_line_details;

-- Query the detailed view for business insights
SELECT 
    customer_nation,
    supplier_nation,
    COUNT(*) as transaction_count,
    SUM(l_quantity) as total_quantity,
    SUM(net_price) as total_revenue
FROM order_line_details
WHERE o_orderdate >= '1995-01-01'
GROUP BY customer_nation, supplier_nation
HAVING SUM(net_price) > 1000000
ORDER BY total_revenue DESC
LIMIT 20;

-- ============================================
-- DESCRIBING AND INSPECTING VIEWS
-- ============================================

-- Show all views in the database
-- Note: DuckDB uses information_schema to list views
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_type = 'VIEW'
ORDER BY table_name;

-- Describe a specific view structure
DESCRIBE customer_summary;

-- Show the SQL definition of a view (DuckDB specific)
-- This shows how the view was created
SELECT 
    table_name,
    view_definition
FROM information_schema.views
WHERE table_name = 'customer_summary';

-- ============================================
-- PRACTICAL VIEW USAGE EXAMPLES
-- ============================================

-- Example 8: Using views to simplify complex reporting
-- Query multiple views together for comprehensive analysis
SELECT 
    cs.c_name,
    cs.nation,
    cs.customer_tier,
    cos.total_orders,
    cos.lifetime_value,
    cos.avg_order_value
FROM customer_summary cs
INNER JOIN customer_order_stats cos ON cs.c_custkey = cos.c_custkey
WHERE cs.region = 'EUROPE' 
  AND cos.total_orders > 10
ORDER BY cos.lifetime_value DESC
LIMIT 15;

-- Example 9: View for security and data access control
-- Create a view that limits sensitive information
CREATE VIEW customer_public_info AS
SELECT 
    c_custkey,
    c_name,
    c_mktsegment,
    nation,
    region,
    customer_tier
FROM customer_summary;

-- Describe the security-focused view structure (notice missing sensitive columns)
DESCRIBE customer_public_info;

-- Users can query this view without accessing sensitive data like phone, address, balance
SELECT * FROM customer_public_info
WHERE customer_tier = 'Premium'
LIMIT 10;

-- ============================================
-- DROPPING VIEWS
-- ============================================

-- Drop individual views when no longer needed
DROP VIEW IF EXISTS customer_public_info;
DROP VIEW IF EXISTS order_line_details;
DROP VIEW IF EXISTS supplier_performance;
DROP VIEW IF EXISTS customer_order_stats;
DROP VIEW IF EXISTS part_inventory_summary;
DROP VIEW IF EXISTS high_value_orders;
DROP VIEW IF EXISTS customer_summary;

-- Verify views are dropped
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_type = 'VIEW'
ORDER BY table_name;

-- ============================================
-- BEST PRACTICES FOR VIEWS
-- ============================================

-- 1. Use descriptive names that indicate the view's purpose
-- 2. Document complex views with comments
-- 3. Avoid SELECT * in view definitions for better performance
-- 4. Consider performance impact of complex views with multiple joins
-- 5. Use views to encapsulate business logic and maintain consistency
-- 6. Create views for frequently used complex queries
-- 7. Use CREATE OR REPLACE to update views without dropping dependencies
-- 8. Drop views when they're no longer needed to reduce clutter
-- 9. Be aware that views are re-executed each time they're queried
-- 10. For frequently accessed complex aggregations, consider materialized views (if supported)
