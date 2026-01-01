-- SQL GROUP BY Optimization Examples - Query Performance Tuning
-- This file demonstrates GROUP BY optimization techniques for improved aggregation performance
-- Focus on cardinality impact, filtering strategies, and aggregation optimization
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-6-query-performance-tuning/group-by-optimization.sql
-- ============================================

-- GROUP BY OPTIMIZATION CONCEPTS:
-- - Cardinality (number of distinct values) significantly affects performance
-- - Low cardinality = fewer groups = better performance
-- - Filter with WHERE before grouping, use HAVING for aggregate conditions
-- - LIMIT with GROUP BY enables optimized top-N group processing
-- - Pre-filtering reduces memory usage and processing time

-- =====================================================
-- GROUP BY OPTIMIZATION EXAMPLES
-- =====================================================

-- Example 1: Inefficient GROUP BY - No Index Support
-- BAD: Grouping by expression without index
EXPLAIN
SELECT 
    SUBSTR(c_name, 1, 1) as first_letter,
    COUNT(*) as customer_count,
    AVG(c_acctbal) as avg_balance
FROM customer
GROUP BY SUBSTR(c_name, 1, 1)
ORDER BY customer_count DESC;

-- BETTER: Pre-filter to reduce grouping set size
EXPLAIN
SELECT 
    SUBSTR(c_name, 1, 1) as first_letter,
    COUNT(*) as customer_count,
    AVG(c_acctbal) as avg_balance
FROM customer
WHERE c_acctbal > 0  -- Filter before grouping
GROUP BY SUBSTR(c_name, 1, 1)
ORDER BY customer_count DESC;

-- Example 2: Optimizing GROUP BY with HAVING
-- BAD: HAVING without proper filtering
EXPLAIN
SELECT 
    c.c_mktsegment,
    COUNT(*) as order_count,
    SUM(o.o_totalprice) as total_revenue
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_mktsegment
HAVING COUNT(*) > 1000;

-- BETTER: Use WHERE to filter before grouping when possible
EXPLAIN
SELECT 
    c.c_mktsegment,
    COUNT(*) as order_count,
    SUM(o.o_totalprice) as total_revenue
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate >= DATE '1995-01-01'  -- Filter early
GROUP BY c.c_mktsegment
HAVING COUNT(*) > 100;  -- Keep HAVING for aggregate conditions

-- Example 3: GROUP BY Cardinality Impact
-- Cardinality (number of distinct values) significantly affects GROUP BY performance
-- Low cardinality = fewer groups = better performance
-- High cardinality = many groups = more memory and processing

-- HIGH CARDINALITY: Grouping by unique/near-unique values (poor performance)
-- Each customer likely has unique total spending, creating many groups
EXPLAIN
SELECT 
    c.c_custkey,
    SUM(o.o_totalprice) as total_spent,
    COUNT(*) as order_count
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey  -- High cardinality: ~150,000 unique customers
ORDER BY total_spent DESC;

-- LOW CARDINALITY: Grouping by categorical values (better performance)
-- Market segments have only 5 distinct values, creating few groups
EXPLAIN
SELECT 
    c.c_mktsegment,
    SUM(o.o_totalprice) as total_revenue,
    COUNT(*) as order_count,
    AVG(o.o_totalprice) as avg_order_value
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_mktsegment  -- Low cardinality: only 5 market segments
ORDER BY total_revenue DESC;

-- MEDIUM CARDINALITY: Grouping by date parts (moderate performance)
-- Years/months have moderate cardinality, reasonable for grouping
EXPLAIN
SELECT 
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    EXTRACT(MONTH FROM o.o_orderdate) as order_month,
    COUNT(*) as order_count,
    SUM(o.o_totalprice) as monthly_revenue
FROM orders o
GROUP BY EXTRACT(YEAR FROM o.o_orderdate), EXTRACT(MONTH FROM o.o_orderdate)  -- Medium cardinality: ~84 year-month combinations
ORDER BY order_year, order_month;

-- OPTIMIZATION TIP: When you need high-cardinality grouping, consider:
-- 1. Adding WHERE clauses to reduce the dataset first
-- 2. Using LIMIT to get only top N results
-- 3. Creating summary tables for frequently accessed aggregations

-- Example: Optimized high-cardinality GROUP BY with filtering and limiting
EXPLAIN
SELECT 
    c.c_custkey,
    c.c_name,
    SUM(o.o_totalprice) as total_spent,
    COUNT(*) as order_count
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate >= DATE '1995-01-01'  -- Filter to reduce dataset
  AND c.c_mktsegment = 'BUILDING'         -- Further reduce cardinality
GROUP BY c.c_custkey, c.c_name
ORDER BY total_spent DESC
LIMIT 50;  -- Only get top 50, allowing for optimized sorting

-- Example 4: GROUP BY with Complex Aggregations
-- Optimize by reducing the number of rows before aggregation

-- LESS EFFICIENT: Complex calculation in SELECT
EXPLAIN
SELECT 
    l.l_returnflag,
    l.l_linestatus,
    SUM(l.l_quantity) as sum_qty,
    SUM(l.l_extendedprice) as sum_base_price,
    SUM(l.l_extendedprice * (1 - l.l_discount)) as sum_disc_price,
    SUM(l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax)) as sum_charge,
    AVG(l.l_quantity) as avg_qty,
    AVG(l.l_extendedprice) as avg_price,
    AVG(l.l_discount) as avg_disc,
    COUNT(*) as count_order
FROM lineitem l
GROUP BY l.l_returnflag, l.l_linestatus
ORDER BY l.l_returnflag, l.l_linestatus;

-- MORE EFFICIENT: Filter first, then aggregate
EXPLAIN
SELECT 
    l.l_returnflag,
    l.l_linestatus,
    SUM(l.l_quantity) as sum_qty,
    SUM(l.l_extendedprice) as sum_base_price,
    SUM(l.l_extendedprice * (1 - l.l_discount)) as sum_disc_price,
    SUM(l.l_extendedprice * (1 - l.l_discount) * (1 + l.l_tax)) as sum_charge,
    AVG(l.l_quantity) as avg_qty,
    AVG(l.l_extendedprice) as avg_price,
    AVG(l.l_discount) as avg_disc,
    COUNT(*) as count_order
FROM lineitem l
WHERE l.l_shipdate <= DATE '1998-12-01'  -- Filter to reduce dataset
GROUP BY l.l_returnflag, l.l_linestatus
ORDER BY l.l_returnflag, l.l_linestatus;

-- Example 5: GROUP BY Performance Impact - With vs Without LIMIT
-- Demonstrates how LIMIT can significantly improve performance when you only need top results

-- LESS EFFICIENT: GROUP BY without LIMIT (processes and sorts all groups)
EXPLAIN
SELECT 
    p.p_brand,
    COUNT(*) as part_count,
    AVG(p.p_retailprice) as avg_price
FROM part p
GROUP BY p.p_brand
ORDER BY part_count DESC;

-- MORE EFFICIENT: GROUP BY with LIMIT (can optimize sorting and processing)
EXPLAIN
SELECT 
    p.p_brand,
    COUNT(*) as part_count,
    AVG(p.p_retailprice) as avg_price
FROM part p
GROUP BY p.p_brand
ORDER BY part_count DESC
LIMIT 10;

-- Even better: When you know you only need top N, consider filtering early
EXPLAIN
SELECT 
    p.p_brand,
    COUNT(*) as part_count,
    AVG(p.p_retailprice) as avg_price
FROM part p
WHERE p.p_retailprice > 1000  -- Filter before grouping when possible
GROUP BY p.p_brand
ORDER BY part_count DESC
LIMIT 10;

-- Example 6: Advanced LIMIT with GROUP BY Optimization
-- When you only need top N groups, use subqueries or window functions

-- LESS EFFICIENT: GROUP BY then LIMIT (processes all groups)
EXPLAIN
SELECT 
    c.c_mktsegment,
    COUNT(*) as customer_count
FROM customer c
GROUP BY c.c_mktsegment
ORDER BY customer_count DESC
LIMIT 3;

-- MORE EFFICIENT for large datasets: Use window functions when appropriate
EXPLAIN
SELECT DISTINCT
    c_mktsegment,
    COUNT(*) OVER (PARTITION BY c_mktsegment) as customer_count
FROM customer
ORDER BY customer_count DESC
LIMIT 3;

-- Example 7: GROUP BY with Multiple Aggregation Levels
-- Hierarchical grouping optimization

-- LESS EFFICIENT: Multiple separate GROUP BY queries
-- This would require multiple query executions:
-- Query 1: National level
EXPLAIN
SELECT 
    n.n_name,
    COUNT(*) as customer_count,
    SUM(c.c_acctbal) as total_balance
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name;

-- Query 2: Regional level (separate execution)
-- Query 3: Market segment level (separate execution)

-- MORE EFFICIENT: Single query with ROLLUP or multiple CTEs
EXPLAIN
WITH national_stats AS (
    SELECT 
        n.n_name,
        COUNT(*) as customer_count,
        SUM(c.c_acctbal) as total_balance
    FROM customer c
    INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
    GROUP BY n.n_name
),
segment_stats AS (
    SELECT 
        c.c_mktsegment,
        COUNT(*) as customer_count,
        AVG(c.c_acctbal) as avg_balance
    FROM customer c
    GROUP BY c.c_mktsegment
)
SELECT 'National' as level, n_name as category, customer_count, total_balance as amount
FROM national_stats
UNION ALL
SELECT 'Segment' as level, c_mktsegment as category, customer_count, avg_balance as amount
FROM segment_stats
ORDER BY level, amount DESC;

-- Example 8: GROUP BY Memory Optimization
-- Reducing memory usage for large grouping operations

-- MEMORY INTENSIVE: Large number of groups with complex aggregations
EXPLAIN
SELECT 
    c.c_custkey,
    c.c_name,
    COUNT(DISTINCT o.o_orderkey) as unique_orders,
    COUNT(DISTINCT l.l_partkey) as unique_parts,
    SUM(l.l_extendedprice * (1 - l.l_discount)) as total_revenue,
    AVG(l.l_quantity) as avg_quantity,
    STRING_AGG(DISTINCT p.p_type, ', ') as part_types  -- Memory intensive
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
INNER JOIN part p ON l.l_partkey = p.p_partkey
GROUP BY c.c_custkey, c.c_name;

-- MEMORY OPTIMIZED: Reduce aggregation complexity and filter early
EXPLAIN
SELECT 
    c.c_custkey,
    c.c_name,
    COUNT(DISTINCT o.o_orderkey) as unique_orders,
    SUM(l.l_extendedprice * (1 - l.l_discount)) as total_revenue,
    AVG(l.l_quantity) as avg_quantity
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
WHERE o.o_orderdate >= DATE '1995-01-01'  -- Filter to reduce dataset
  AND c.c_mktsegment IN ('BUILDING', 'MACHINERY')  -- Reduce customer set
GROUP BY c.c_custkey, c.c_name
HAVING COUNT(DISTINCT o.o_orderkey) > 5  -- Only customers with multiple orders
ORDER BY total_revenue DESC
LIMIT 100;

-- =====================================================
-- GROUP BY ALGORITHM CONSIDERATIONS
-- =====================================================

-- Hash Aggregation: Most common for GROUP BY
-- - Builds hash table with group keys
-- - Efficient for moderate number of groups
-- - Memory usage grows with number of distinct groups

-- Sort-Based Aggregation: Used when memory is limited
-- - Sorts data by group keys first
-- - Processes groups sequentially
-- - More I/O intensive but uses less memory

-- =====================================================
-- GROUP BY BEST PRACTICES
-- =====================================================

-- 1. Filter data with WHERE before GROUP BY when possible
-- 2. Use HAVING only for conditions on aggregate functions
-- 3. Consider cardinality when choosing grouping columns
-- 4. Use LIMIT when you only need top N groups
-- 5. Pre-aggregate in subqueries for complex multi-level grouping
-- 6. Avoid grouping by expressions or functions when possible
-- 7. Consider materialized views for frequently accessed aggregations
-- 8. Monitor memory usage for high-cardinality grouping operations