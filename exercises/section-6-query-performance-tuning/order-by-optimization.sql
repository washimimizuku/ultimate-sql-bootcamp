-- SQL ORDER BY Optimization Examples - Query Performance Tuning
-- This file demonstrates ORDER BY optimization techniques for improved sorting performance
-- Focus on LIMIT optimization, column selection, and sorting strategies
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-6-query-performance-tuning/order-by-optimization.sql
-- ============================================

-- ORDER BY OPTIMIZATION CONCEPTS:
-- - LIMIT enables top-N heap sort optimization (much faster than full sort)
-- - Indexed columns sort faster than expressions or non-indexed columns
-- - Column order in multi-column sorts affects performance (high selectivity first)
-- - Filtering before sorting reduces dataset size
-- - Sort direction (ASC/DESC) can have different performance characteristics

-- =====================================================
-- ORDER BY OPTIMIZATION EXAMPLES
-- =====================================================

-- Example 1: ORDER BY Performance Impact - With vs Without LIMIT
-- Demonstrates how LIMIT can significantly improve ORDER BY performance

-- LESS EFFICIENT: ORDER BY without LIMIT (sorts entire result set)
EXPLAIN
SELECT 
    c.c_name,
    c.c_acctbal,
    c.c_mktsegment
FROM customer c
ORDER BY c.c_acctbal DESC;

-- MORE EFFICIENT: ORDER BY with LIMIT (can use top-N heap sort)
EXPLAIN
SELECT 
    c.c_name,
    c.c_acctbal,
    c.c_mktsegment
FROM customer c
ORDER BY c.c_acctbal DESC
LIMIT 20;

-- Example 2: ORDER BY Column Selection Optimization
-- Ordering by indexed columns vs non-indexed columns

-- LESS EFFICIENT: ORDER BY non-indexed expression
EXPLAIN
SELECT 
    o.o_orderkey,
    o.o_totalprice,
    UPPER(o.o_orderstatus) as status_upper
FROM orders o
ORDER BY UPPER(o.o_orderstatus), o.o_totalprice DESC
LIMIT 100;

-- MORE EFFICIENT: ORDER BY indexed columns when possible
EXPLAIN
SELECT 
    o.o_orderkey,
    o.o_totalprice,
    o.o_orderstatus
FROM orders o
ORDER BY o.o_orderdate DESC, o.o_orderkey
LIMIT 100;

-- Example 3: Multiple Column ORDER BY Optimization
-- Order of columns in ORDER BY clause affects performance

-- LESS EFFICIENT: ORDER BY low-selectivity column first
EXPLAIN
SELECT 
    l.l_orderkey,
    l.l_partkey,
    l.l_quantity,
    l.l_extendedprice
FROM lineitem l
ORDER BY l.l_returnflag, l.l_orderkey
LIMIT 1000;

-- MORE EFFICIENT: ORDER BY high-selectivity column first
EXPLAIN
SELECT 
    l.l_orderkey,
    l.l_partkey,
    l.l_quantity,
    l.l_extendedprice
FROM lineitem l
ORDER BY l.l_orderkey, l.l_returnflag
LIMIT 1000;

-- Example 4: ORDER BY with WHERE Clause Optimization
-- Filtering before sorting reduces the dataset size

-- LESS EFFICIENT: ORDER BY entire table then filter implicitly
EXPLAIN
SELECT 
    p.p_partkey,
    p.p_name,
    p.p_retailprice
FROM part p
ORDER BY p.p_retailprice DESC
LIMIT 50;

-- MORE EFFICIENT: Filter first, then sort smaller dataset
EXPLAIN
SELECT 
    p.p_partkey,
    p.p_name,
    p.p_retailprice
FROM part p
WHERE p.p_retailprice > 1500  -- Filter before sorting
ORDER BY p.p_retailprice DESC
LIMIT 50;

-- Example 5: ORDER BY Direction Optimization
-- ASC vs DESC can have different performance characteristics

-- Standard ascending sort
EXPLAIN
SELECT 
    s.s_suppkey,
    s.s_name,
    s.s_acctbal
FROM supplier s
ORDER BY s.s_acctbal ASC
LIMIT 25;

-- Descending sort (may require different optimization)
EXPLAIN
SELECT 
    s.s_suppkey,
    s.s_name,
    s.s_acctbal
FROM supplier s
ORDER BY s.s_acctbal DESC
LIMIT 25;

-- Example 6: ORDER BY with JOIN Optimization
-- Sorting after joins vs sorting before joins

-- LESS EFFICIENT: JOIN then ORDER BY (sorts larger result set)
EXPLAIN
SELECT 
    c.c_name,
    o.o_totalprice,
    o.o_orderdate
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
ORDER BY o.o_totalprice DESC
LIMIT 100;

-- MORE EFFICIENT: Filter and sort within subquery when possible
EXPLAIN
SELECT 
    c.c_name,
    top_orders.o_totalprice,
    top_orders.o_orderdate
FROM customer c
INNER JOIN (
    SELECT o_custkey, o_totalprice, o_orderdate
    FROM orders
    ORDER BY o_totalprice DESC
    LIMIT 1000  -- Pre-sort and limit before join
) top_orders ON c.c_custkey = top_orders.o_custkey
ORDER BY top_orders.o_totalprice DESC
LIMIT 100;

-- Example 7: Complex ORDER BY with Multiple Criteria
-- Optimizing sorts with multiple columns and mixed directions

-- LESS EFFICIENT: Complex multi-column sort without filtering
EXPLAIN
SELECT 
    c.c_name,
    c.c_mktsegment,
    c.c_acctbal,
    c.c_nationkey
FROM customer c
ORDER BY c.c_mktsegment ASC, c.c_acctbal DESC, c.c_name ASC;

-- MORE EFFICIENT: Filter first, then apply complex sort
EXPLAIN
SELECT 
    c.c_name,
    c.c_mktsegment,
    c.c_acctbal,
    c.c_nationkey
FROM customer c
WHERE c.c_acctbal > 1000  -- Reduce dataset first
ORDER BY c.c_mktsegment ASC, c.c_acctbal DESC, c.c_name ASC
LIMIT 200;

-- Example 8: ORDER BY with Aggregation
-- Sorting aggregated results efficiently

-- LESS EFFICIENT: Sort all aggregated results
EXPLAIN
SELECT 
    n.n_name,
    COUNT(*) as customer_count,
    AVG(c.c_acctbal) as avg_balance
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name, n.n_nationkey
ORDER BY avg_balance DESC;

-- MORE EFFICIENT: Use LIMIT with aggregation
EXPLAIN
SELECT 
    n.n_name,
    COUNT(*) as customer_count,
    AVG(c.c_acctbal) as avg_balance
FROM customer c
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
GROUP BY n.n_name, n.n_nationkey
ORDER BY avg_balance DESC
LIMIT 10;

-- Example 9: ORDER BY with Window Functions
-- Sometimes window functions can be more efficient than ORDER BY

-- LESS EFFICIENT: Multiple queries with ORDER BY
-- Query 1: Get top customers by balance
EXPLAIN
SELECT c_name, c_acctbal
FROM customer
ORDER BY c_acctbal DESC
LIMIT 10;

-- Query 2: Get customer rankings (separate query)
-- This would require a separate execution

-- MORE EFFICIENT: Single query with window function
EXPLAIN
SELECT 
    c_name,
    c_acctbal,
    ROW_NUMBER() OVER (ORDER BY c_acctbal DESC) as balance_rank,
    NTILE(10) OVER (ORDER BY c_acctbal DESC) as balance_decile
FROM customer
WHERE ROW_NUMBER() OVER (ORDER BY c_acctbal DESC) <= 100;

-- Example 10: Pagination Optimization
-- Efficient pagination with ORDER BY and OFFSET

-- LESS EFFICIENT: Large OFFSET (skips many rows)
EXPLAIN
SELECT 
    c.c_name,
    c.c_acctbal,
    c.c_mktsegment
FROM customer c
ORDER BY c.c_acctbal DESC
LIMIT 20 OFFSET 10000;  -- Inefficient for large offsets

-- MORE EFFICIENT: Cursor-based pagination using WHERE clause
EXPLAIN
SELECT 
    c.c_name,
    c.c_acctbal,
    c.c_mktsegment
FROM customer c
WHERE c.c_acctbal < 5000  -- Use last seen value as cursor
ORDER BY c.c_acctbal DESC
LIMIT 20;

-- =====================================================
-- SORTING ALGORITHM CONSIDERATIONS
-- =====================================================

-- Top-N Heap Sort: Used when LIMIT is present
-- - Only maintains N elements in memory
-- - Much faster than full sort for small LIMIT values
-- - Automatically chosen when LIMIT is used

-- Quick Sort: General purpose sorting
-- - Good average case performance
-- - Used for full result set sorting

-- External Sort: Used for very large datasets
-- - Spills to disk when data doesn't fit in memory
-- - Uses merge sort algorithm
-- - Performance depends on I/O speed

-- =====================================================
-- ORDER BY BEST PRACTICES
-- =====================================================

-- 1. Always use LIMIT when you only need top N results
-- 2. Filter data with WHERE before sorting when possible
-- 3. Order by indexed columns when available
-- 4. Put high-selectivity columns first in multi-column sorts
-- 5. Consider using window functions for complex ranking scenarios
-- 6. Use cursor-based pagination instead of large OFFSET values
-- 7. Pre-sort data in subqueries when joining with other tables
-- 8. Avoid sorting by expressions or functions when possible