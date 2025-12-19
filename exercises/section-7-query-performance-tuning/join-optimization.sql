-- SQL JOIN Optimization Examples - Query Performance Tuning
-- This file demonstrates JOIN optimization techniques and advanced query patterns
-- Focus on choosing efficient join algorithms, order, and advanced techniques like CTEs
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-7-query-performance-tuning/join-optimization.sql
-- ============================================

-- JOIN OPTIMIZATION CONCEPTS:
-- - Join order affects performance (smaller result sets first)
-- - Join algorithms: Hash Join (large datasets), Nested Loop (small datasets), Sort-Merge Join
-- - Semi-joins (EXISTS) vs Anti-joins (NOT EXISTS) optimization
-- - Proper join conditions prevent cartesian products
-- - Early filtering reduces join processing overhead

-- =====================================================
-- JOIN OPTIMIZATION EXAMPLES
-- =====================================================

-- Example 1: Inefficient JOIN - Cartesian Product Risk
-- BAD: No proper join condition leads to cartesian product
EXPLAIN
SELECT c.c_name, o.o_totalprice
FROM customer c, orders o
WHERE c.c_mktsegment = 'BUILDING';

-- GOOD: Proper JOIN with explicit conditions
EXPLAIN
SELECT c.c_name, o.o_totalprice
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_mktsegment = 'BUILDING';

-- Example 2: JOIN Order Optimization
-- The order of JOINs can significantly impact performance
-- Generally, join smaller result sets first

-- LESS EFFICIENT: Large table first
EXPLAIN
SELECT c.c_name, l.l_quantity, p.p_name
FROM lineitem l
INNER JOIN customer c ON l.l_orderkey IN (
    SELECT o_orderkey FROM orders WHERE o_custkey = c.c_custkey
)
INNER JOIN part p ON l.l_partkey = p.p_partkey
WHERE c.c_mktsegment = 'AUTOMOBILE';

-- MORE EFFICIENT: Filter early, join smaller sets
EXPLAIN
SELECT c.c_name, l.l_quantity, p.p_name
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
INNER JOIN part p ON l.l_partkey = p.p_partkey
WHERE c.c_mktsegment = 'AUTOMOBILE';

-- Example 3: Using EXISTS vs IN for Semi-Joins
-- EXISTS is often more efficient than IN for large datasets

-- LESS EFFICIENT: Using IN with subquery
EXPLAIN
SELECT c.c_name, c.c_acctbal
FROM customer c
WHERE c.c_custkey IN (
    SELECT o.o_custkey 
    FROM orders o 
    WHERE o.o_totalprice > 200000
);

-- MORE EFFICIENT: Using EXISTS
EXPLAIN
SELECT c.c_name, c.c_acctbal
FROM customer c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.o_custkey = c.c_custkey 
    AND o.o_totalprice > 200000
);

-- Example 4: LEFT JOIN vs NOT EXISTS for Anti-Joins
-- Finding customers with no orders

-- Using LEFT JOIN with NULL check
EXPLAIN
SELECT c.c_name, c.c_acctbal
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_custkey IS NULL;

-- Using NOT EXISTS (often more efficient)
EXPLAIN
SELECT c.c_name, c.c_acctbal
FROM customer c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.o_custkey = c.c_custkey
);

-- Example 5: JOIN with Filtering Optimization
-- Apply filters as early as possible in the execution plan

-- LESS EFFICIENT: Filter after all joins
EXPLAIN
SELECT c.c_name, o.o_orderdate, l.l_quantity
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
WHERE c.c_mktsegment = 'MACHINERY'
  AND o.o_orderdate >= DATE '1995-01-01'
  AND l.l_quantity > 30;

-- MORE EFFICIENT: Use subqueries to filter before joining
EXPLAIN
SELECT c.c_name, filtered_orders.o_orderdate, filtered_lineitem.l_quantity
FROM (
    SELECT c_custkey, c_name 
    FROM customer 
    WHERE c_mktsegment = 'MACHINERY'
) c
INNER JOIN (
    SELECT o_custkey, o_orderkey, o_orderdate 
    FROM orders 
    WHERE o_orderdate >= DATE '1995-01-01'
) filtered_orders ON c.c_custkey = filtered_orders.o_custkey
INNER JOIN (
    SELECT l_orderkey, l_quantity 
    FROM lineitem 
    WHERE l_quantity > 30
) filtered_lineitem ON filtered_orders.o_orderkey = filtered_lineitem.l_orderkey;

-- =====================================================
-- ADVANCED OPTIMIZATION TECHNIQUES
-- =====================================================

-- Example 6: Materialized Subqueries for Complex JOINs
-- When the same subquery is used multiple times, consider CTEs

-- LESS EFFICIENT: Repeated subquery execution
EXPLAIN
SELECT 
    c.c_name,
    (SELECT COUNT(*) FROM orders o WHERE o.o_custkey = c.c_custkey) as order_count,
    (SELECT SUM(o.o_totalprice) FROM orders o WHERE o.o_custkey = c.c_custkey) as total_spent
FROM customer c
WHERE c.c_mktsegment = 'BUILDING';

-- MORE EFFICIENT: Use CTE or derived table
EXPLAIN
WITH customer_stats AS (
    SELECT 
        o.o_custkey,
        COUNT(*) as order_count,
        SUM(o.o_totalprice) as total_spent
    FROM orders o
    GROUP BY o.o_custkey
)
SELECT 
    c.c_name,
    COALESCE(cs.order_count, 0) as order_count,
    COALESCE(cs.total_spent, 0) as total_spent
FROM customer c
LEFT JOIN customer_stats cs ON c.c_custkey = cs.o_custkey
WHERE c.c_mktsegment = 'BUILDING';

-- Example 7: Complex Multi-Table JOIN Optimization
-- Optimize complex queries with multiple tables and conditions

-- LESS EFFICIENT: Multiple nested subqueries
EXPLAIN
SELECT 
    c.c_name,
    c.c_mktsegment,
    (SELECT COUNT(*) FROM orders o WHERE o.o_custkey = c.c_custkey) as total_orders,
    (SELECT COUNT(*) FROM orders o 
     INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey 
     WHERE o.o_custkey = c.c_custkey AND l.l_returnflag = 'R') as returned_items
FROM customer c
WHERE c.c_acctbal > 5000;

-- MORE EFFICIENT: Single query with CTEs and proper joins
EXPLAIN
WITH customer_orders AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(DISTINCT o.o_orderkey) as total_orders
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE c.c_acctbal > 5000
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
returned_items AS (
    SELECT 
        o.o_custkey,
        COUNT(*) as returned_count
    FROM orders o
    INNER JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    WHERE l.l_returnflag = 'R'
    GROUP BY o.o_custkey
)
SELECT 
    co.c_name,
    co.c_mktsegment,
    co.total_orders,
    COALESCE(ri.returned_count, 0) as returned_items
FROM customer_orders co
LEFT JOIN returned_items ri ON co.c_custkey = ri.o_custkey;

-- Example 8: Window Functions vs Self-Joins
-- Sometimes window functions can replace complex self-joins

-- LESS EFFICIENT: Self-join to find customer ranking
EXPLAIN
SELECT 
    c1.c_name,
    c1.c_acctbal,
    COUNT(c2.c_custkey) + 1 as balance_rank
FROM customer c1
LEFT JOIN customer c2 ON c2.c_acctbal > c1.c_acctbal
GROUP BY c1.c_custkey, c1.c_name, c1.c_acctbal
ORDER BY c1.c_acctbal DESC;

-- MORE EFFICIENT: Use window function
EXPLAIN
SELECT 
    c_name,
    c_acctbal,
    RANK() OVER (ORDER BY c_acctbal DESC) as balance_rank
FROM customer
ORDER BY c_acctbal DESC;

-- =====================================================
-- JOIN ALGORITHM SELECTION TIPS
-- =====================================================

-- Hash Join: Best for large datasets, equi-joins
-- - Build hash table from smaller relation
-- - Probe with larger relation
-- - Memory intensive but efficient for large data

-- Nested Loop Join: Best for small datasets or when one side is very small
-- - For each row in outer relation, scan inner relation
-- - CPU intensive, good when inner relation is small or has good indexes

-- Sort-Merge Join: Good for sorted data or when both relations are large
-- - Sort both relations on join key
-- - Merge sorted results
-- - Good when data is already sorted or memory is limited

-- Example: Forcing different join algorithms (database-specific syntax)
-- Note: Most databases choose the best algorithm automatically
-- These are examples of how you might influence the choice:

-- Small dataset - Nested Loop might be chosen
EXPLAIN
SELECT c.c_name, o.o_totalprice
FROM (SELECT * FROM customer LIMIT 100) c
INNER JOIN orders o ON c.c_custkey = o.o_custkey;

-- Large dataset - Hash Join likely chosen
EXPLAIN
SELECT c.c_name, o.o_totalprice
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey;