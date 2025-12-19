-- SQL EXPLAIN Examples - Query Performance Analysis and Optimization
-- This file demonstrates how to use EXPLAIN to analyze query execution plans and optimize performance
-- EXPLAIN shows how the database engine will execute a query, revealing optimization opportunities
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-7-query-performance-tuning/explain.sql
-- ============================================

-- EXPLAIN CONCEPTS:
-- - EXPLAIN shows the query execution plan without running the query
-- - EXPLAIN ANALYZE runs the query and shows actual execution statistics
-- - Execution plans reveal join algorithms, scan methods, and optimization decisions
-- - Key metrics: estimated vs actual rows, execution time, memory usage
-- - Common operations: Seq Scan, Index Scan, Hash Join, Nested Loop, Sort, Aggregate

-- EXPLAIN SYNTAX:
-- EXPLAIN query;                    -- Show execution plan only
-- EXPLAIN ANALYZE query;            -- Execute query and show actual statistics
-- EXPLAIN (ANALYZE, BUFFERS) query; -- Include buffer usage information

-- OPTIMIZATION GOALS:
-- - Minimize full table scans (Seq Scan) by using indexes
-- - Choose efficient join algorithms (Hash Join vs Nested Loop)
-- - Reduce sorting operations through proper indexing
-- - Filter data early in the execution plan
-- - Optimize GROUP BY and aggregate operations

-- RELATED FILES:
-- - join-optimization.sql: Detailed JOIN optimization techniques
-- - order-by-optimization.sql: ORDER BY performance optimization
-- - group-by-optimization.sql: GROUP BY and aggregation optimization

-- Example query to analyze:
SELECT
    c.c_custkey,
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM
    customer c
INNER JOIN
    orders o ON c.c_custkey = o.o_custkey
INNER JOIN
    lineitem l ON o.o_orderkey = l.l_orderkey
WHERE
    o.o_orderdate >= DATE '1992-01-01'
    AND o.o_orderdate < DATE '1997-01-01'
GROUP BY
    c.c_custkey,
    c.c_name
HAVING
    total_revenue > 100000
ORDER BY
    total_revenue DESC;

-- Analyze the execution plan:
EXPLAIN
SELECT
    c.c_custkey,
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM
    customer c
INNER JOIN
    orders o ON c.c_custkey = o.o_custkey
INNER JOIN
    lineitem l ON o.o_orderkey = l.l_orderkey
WHERE
    o.o_orderdate >= DATE '1992-01-01'
    AND o.o_orderdate < DATE '1997-01-01'
GROUP BY
    c.c_custkey,
    c.c_name
HAVING
    total_revenue > 100000
ORDER BY
    total_revenue DESC;

-- Execute and Analyze the query:
EXPLAIN ANALYSE
SELECT
    c.c_custkey,
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM
    customer c
INNER JOIN
    orders o ON c.c_custkey = o.o_custkey
INNER JOIN
    lineitem l ON o.o_orderkey = l.l_orderkey
WHERE
    o.o_orderdate >= DATE '1992-01-01'
    AND o.o_orderdate < DATE '1997-01-01'
GROUP BY
    c.c_custkey,
    c.c_name
HAVING
    total_revenue > 100000
ORDER BY
    total_revenue DESC;

-- =====================================================
-- PERFORMANCE ANALYSIS TIPS
-- =====================================================
-- 1. Look for "Seq Scan" operations - these indicate full table scans
-- 2. Check for "Hash Join" vs "Nested Loop" - hash joins are usually better for large datasets
-- 3. Monitor "Sort" operations - these can be expensive, consider indexes
-- 4. Watch for "Aggregate" operations - ensure they're using appropriate algorithms
-- 5. Pay attention to row count estimates vs actual - large differences indicate outdated statistics

-- COMMON EXECUTION PLAN OPERATIONS:
-- - Seq Scan: Full table scan (expensive for large tables)
-- - Index Scan: Using an index to find rows (efficient)
-- - Hash Join: Build hash table from smaller relation, probe with larger (good for large datasets)
-- - Nested Loop: For each row in outer relation, scan inner relation (good for small datasets)
-- - Sort: Ordering data (expensive, consider indexes)
-- - Aggregate: GROUP BY, SUM, COUNT operations
-- - Filter: WHERE clause conditions

-- OPTIMIZATION STRATEGIES:
-- 1. Create indexes on frequently queried columns
-- 2. Use WHERE clauses to filter data early
-- 3. Choose appropriate JOIN types and order
-- 4. Optimize GROUP BY with proper cardinality considerations
-- 5. Use LIMIT when you only need top N results
-- 6. Consider materialized views for complex, frequently-run queries