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

-- Execute and Analyze the query with actual runtime statistics:
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
-- BASIC EXPLAIN EXAMPLES
-- =====================================================

-- Example 1: Simple table scan
-- This shows a sequential scan (Seq Scan) of the entire lineitem table
EXPLAIN
SELECT * 
FROM lineitem;

-- Example 2: Table scan with WHERE clause
-- Shows how filtering affects the execution plan
EXPLAIN
SELECT *
FROM lineitem
WHERE l_shipdate = DATE '1995-01-01';

-- Example 3: Table scan with multiple conditions
-- Demonstrates filter pushdown and condition evaluation
EXPLAIN
SELECT l_orderkey, l_partkey, l_quantity, l_extendedprice
FROM lineitem
WHERE l_shipdate >= DATE '1995-01-01' 
  AND l_shipdate < DATE '1996-01-01'
  AND l_quantity > 30;

-- Example 4: Simple aggregation
-- Shows how GROUP BY operations appear in execution plans
EXPLAIN
SELECT 
    l_returnflag,
    COUNT(*) as item_count,
    SUM(l_quantity) as total_quantity
FROM lineitem
GROUP BY l_returnflag;

-- =====================================================
-- JOIN EXAMPLES
-- =====================================================

-- Example 5: Proper INNER JOIN
-- Shows efficient join execution plan
EXPLAIN
SELECT c.c_name, o.o_totalprice, o.o_orderdate
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_mktsegment = 'BUILDING';

-- Example 6: Cartesian product (AVOID THIS!)
-- WARNING: This creates a cartesian product - very expensive!
-- Notice the massive row count in the execution plan
EXPLAIN
SELECT l.l_orderkey, o.o_orderkey
FROM lineitem l, orders o
LIMIT 10;  -- LIMIT added to prevent excessive output

-- Example 7: Multi-table join with filtering
-- Shows join order and filtering optimization
EXPLAIN
SELECT c.c_name, o.o_orderdate, l.l_quantity
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
WHERE c.c_nationkey = 1
  AND o.o_orderdate >= DATE '1995-01-01'
LIMIT 100;

-- =====================================================
-- SORTING AND ORDERING EXAMPLES
-- =====================================================

-- Example 8: Simple ORDER BY
-- Shows sorting operation in execution plan
EXPLAIN
SELECT c_name, c_acctbal
FROM customer
ORDER BY c_acctbal DESC
LIMIT 20;

-- Example 9: ORDER BY with multiple columns
-- Demonstrates multi-column sorting complexity
EXPLAIN
SELECT c_name, c_mktsegment, c_acctbal
FROM customer
ORDER BY c_mktsegment ASC, c_acctbal DESC
LIMIT 50;

-- Example 10: ORDER BY with JOIN
-- Shows how sorting interacts with join operations
EXPLAIN
SELECT c.c_name, o.o_totalprice
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
ORDER BY o.o_totalprice DESC
LIMIT 25;

-- =====================================================
-- SUBQUERY EXAMPLES
-- =====================================================

-- Example 11: Correlated subquery
-- Shows how correlated subqueries affect execution plans
EXPLAIN
SELECT c.c_name, c.c_acctbal
FROM customer c
WHERE c.c_acctbal > (
    SELECT AVG(c2.c_acctbal)
    FROM customer c2
    WHERE c2.c_mktsegment = c.c_mktsegment
);

-- Example 12: EXISTS subquery
-- Demonstrates semi-join execution
EXPLAIN
SELECT c.c_name
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.o_custkey = c.c_custkey
    AND o.o_totalprice > 100000
);

-- Example 13: IN subquery vs JOIN comparison
-- Compare execution plans for semantically equivalent queries

-- Using IN subquery:
EXPLAIN
SELECT c.c_name
FROM customer c
WHERE c.c_custkey IN (
    SELECT o.o_custkey
    FROM orders o
    WHERE o.o_totalprice > 100000
);

-- Using JOIN (often more efficient):
EXPLAIN
SELECT DISTINCT c.c_name
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_totalprice > 100000;

-- =====================================================
-- WINDOW FUNCTION EXAMPLES
-- =====================================================

-- Example 14: Window function with partitioning
-- Shows how window functions are processed
EXPLAIN
SELECT 
    c_name,
    c_acctbal,
    ROW_NUMBER() OVER (PARTITION BY c_mktsegment ORDER BY c_acctbal DESC) as segment_rank
FROM customer
WHERE c_mktsegment IN ('BUILDING', 'MACHINERY');

-- Example 15: Multiple window functions
-- Demonstrates complex window function execution
EXPLAIN
SELECT 
    o_orderkey,
    o_totalprice,
    ROW_NUMBER() OVER (ORDER BY o_totalprice DESC) as price_rank,
    NTILE(4) OVER (ORDER BY o_totalprice) as price_quartile
FROM orders
WHERE o_orderdate >= DATE '1995-01-01';

-- =====================================================
-- PERFORMANCE ANALYSIS GUIDE
-- =====================================================

-- READING EXECUTION PLANS:
-- 1. Plans are read from bottom-up (leaf nodes to root)
-- 2. Each operation shows estimated rows, cost, and time
-- 3. Look for operations that process many more rows than expected
-- 4. Identify the most expensive operations (highest cost)

-- KEY OPERATIONS TO MONITOR:
-- - Seq Scan: Full table scan (expensive for large tables)
--   * Good: When scanning small tables or most rows needed
--   * Bad: When only few rows needed from large table
-- - Index Scan: Using an index to find rows (efficient)
--   * Good: When selecting small percentage of rows
--   * Bad: When index selectivity is poor
-- - Hash Join: Build hash table from smaller relation, probe with larger
--   * Good: For large datasets with equi-joins
--   * Bad: When one relation is much smaller (nested loop better)
-- - Nested Loop: For each row in outer relation, scan inner relation
--   * Good: When inner relation is small or has good indexes
--   * Bad: For large datasets without proper indexes
-- - Sort: Ordering data (expensive, consider indexes)
--   * Good: When result set is small or sorting is necessary
--   * Bad: When sorting large datasets that could be avoided
-- - Aggregate: GROUP BY, SUM, COUNT operations
--   * Good: When grouping set is reasonable size
--   * Bad: When high cardinality creates many groups

-- PERFORMANCE OPTIMIZATION CHECKLIST:
-- 1. ✓ Look for "Seq Scan" operations on large tables
-- 2. ✓ Check join algorithms (Hash vs Nested Loop vs Sort-Merge)
-- 3. ✓ Monitor "Sort" operations - can they be eliminated with indexes?
-- 4. ✓ Watch "Aggregate" operations - is cardinality reasonable?
-- 5. ✓ Compare estimated vs actual rows (with EXPLAIN ANALYZE)
-- 6. ✓ Identify filter operations - are they pushed down early?
-- 7. ✓ Check for cartesian products (very high row counts)
-- 8. ✓ Look for expensive function calls in WHERE/SELECT clauses

-- OPTIMIZATION STRATEGIES:
-- 1. Create indexes on frequently queried columns
-- 2. Use WHERE clauses to filter data early in execution
-- 3. Choose appropriate JOIN types and optimize join order
-- 4. Optimize GROUP BY with proper cardinality considerations
-- 5. Use LIMIT when you only need top N results
-- 6. Avoid functions in WHERE clauses when possible
-- 7. Consider materialized views for complex, frequently-run queries
-- 8. Update table statistics regularly for accurate cost estimates

-- NEXT STEPS:
-- For detailed optimization techniques, see:
-- - join-optimization.sql: Advanced JOIN patterns and techniques
-- - order-by-optimization.sql: Sorting and LIMIT optimization strategies  
-- - group-by-optimization.sql: Aggregation and cardinality optimization