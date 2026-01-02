-- INDEX WORKSHOP - Hands-on Index Optimization Practice
-- This file provides practical exercises for learning index optimization
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-6-query-performance-tuning/indexes-workshop.sql
-- ============================================

-- WORKSHOP OBJECTIVES:
-- 1. Identify slow queries using EXPLAIN ANALYZE
-- 2. Design appropriate indexes for different scenarios
-- 3. Measure performance improvements
-- 4. Understand index trade-offs and limitations

-- ============================================
-- WORKSHOP SETUP - BASELINE MEASUREMENTS
-- ============================================

-- First, let's establish baseline performance without custom indexes
-- We'll measure these queries before and after adding indexes

-- Query 1: Customer lookup by account balance range
SELECT 'Query 1 - Customer Balance Range' as query_name;
EXPLAIN ANALYZE
SELECT c_custkey, c_name, c_acctbal, c_mktsegment
FROM customer
WHERE c_acctbal BETWEEN 5000 AND 8000
ORDER BY c_acctbal DESC;

-- Query 2: Customer-Order join with filtering
SELECT 'Query 2 - Customer-Order Join' as query_name;
EXPLAIN ANALYZE
SELECT c.c_name, COUNT(o.o_orderkey) as order_count, SUM(o.o_totalprice) as total_spent
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_nationkey = 15
GROUP BY c.c_name
HAVING COUNT(o.o_orderkey) > 5
ORDER BY total_spent DESC;

-- Query 3: Time-based order analysis
SELECT 'Query 3 - Time-based Analysis' as query_name;
EXPLAIN ANALYZE
SELECT 
    EXTRACT(MONTH FROM o_orderdate) as month,
    o_orderstatus,
    COUNT(*) as order_count,
    AVG(o_totalprice) as avg_order_value
FROM orders
WHERE o_orderdate >= '1995-01-01' AND o_orderdate < '1996-01-01'
GROUP BY EXTRACT(MONTH FROM o_orderdate), o_orderstatus
ORDER BY month, o_orderstatus;

-- Query 4: Complex multi-table join
SELECT 'Query 4 - Complex Join' as query_name;
EXPLAIN ANALYZE
SELECT 
    p.p_name,
    s.s_name,
    SUM(l.l_quantity) as total_quantity,
    COUNT(DISTINCT l.l_orderkey) as order_count
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
JOIN supplier s ON l.l_suppkey = s.s_suppkey
WHERE p.p_type LIKE '%STEEL%'
  AND l.l_shipdate >= '1995-01-01'
GROUP BY p.p_name, s.s_name
HAVING SUM(l.l_quantity) > 100
ORDER BY total_quantity DESC
LIMIT 20;

-- Query 5: Subquery with EXISTS
SELECT 'Query 5 - Subquery with EXISTS' as query_name;
EXPLAIN ANALYZE
SELECT c.c_custkey, c.c_name, c.c_acctbal
FROM customer c
WHERE EXISTS (
    SELECT 1 FROM orders o 
    WHERE o.o_custkey = c.c_custkey 
    AND o.o_totalprice > 100000
)
ORDER BY c.c_acctbal DESC
LIMIT 50;

-- ============================================
-- WORKSHOP EXERCISE 1: SINGLE COLUMN INDEXES
-- ============================================

-- TASK: Create indexes to optimize the queries above
-- HINT: Look at the WHERE clauses, JOIN conditions, and ORDER BY clauses

-- Exercise 1a: Optimize customer balance queries
-- TODO: Create an index on customer account balance
-- CREATE INDEX idx_customer_acctbal ON customer(c_acctbal);

-- Exercise 1b: Optimize foreign key joins
-- TODO: Create indexes on foreign key columns
-- CREATE INDEX idx_customer_nationkey ON customer(c_nationkey);
-- CREATE INDEX idx_orders_custkey ON orders(o_custkey);

-- Exercise 1c: Optimize date-based queries
-- TODO: Create an index on order date
-- CREATE INDEX idx_orders_orderdate ON orders(o_orderdate);

-- Exercise 1d: Optimize part and supplier lookups
-- TODO: Create indexes for the complex join query
-- CREATE INDEX idx_lineitem_partkey ON lineitem(l_partkey);
-- CREATE INDEX idx_lineitem_suppkey ON lineitem(l_suppkey);
-- CREATE INDEX idx_lineitem_shipdate ON lineitem(l_shipdate);

-- ============================================
-- WORKSHOP EXERCISE 2: COMPOSITE INDEXES
-- ============================================

-- TASK: Create composite indexes for multi-column conditions
-- HINT: Put the most selective column first

-- Exercise 2a: Customer nation and balance
-- TODO: Create a composite index for nation + balance queries
-- CREATE INDEX idx_customer_nation_balance ON customer(c_nationkey, c_acctbal);

-- Exercise 2b: Orders date and status
-- TODO: Create a composite index for date + status queries
-- CREATE INDEX idx_orders_date_status ON orders(o_orderdate, o_orderstatus);

-- Exercise 2c: Lineitem ship date and part
-- TODO: Create a composite index for shipping analysis
-- CREATE INDEX idx_lineitem_ship_part ON lineitem(l_shipdate, l_partkey);

-- ============================================
-- WORKSHOP EXERCISE 3: INDEX EFFECTIVENESS TESTING
-- ============================================

-- After creating your indexes, re-run the baseline queries and compare performance

-- Test Query 1 with index
SELECT 'Query 1 - WITH INDEX' as query_name;
-- Uncomment after creating indexes:
-- EXPLAIN ANALYZE
-- SELECT c_custkey, c_name, c_acctbal, c_mktsegment
-- FROM customer
-- WHERE c_acctbal BETWEEN 5000 AND 8000
-- ORDER BY c_acctbal DESC;

-- Test Query 2 with indexes
SELECT 'Query 2 - WITH INDEXES' as query_name;
-- Uncomment after creating indexes:
-- EXPLAIN ANALYZE
-- SELECT c.c_name, COUNT(o.o_orderkey) as order_count, SUM(o.o_totalprice) as total_spent
-- FROM customer c
-- LEFT JOIN orders o ON c.c_custkey = o.o_custkey
-- WHERE c.c_nationkey = 15
-- GROUP BY c.c_name
-- HAVING COUNT(o.o_orderkey) > 5
-- ORDER BY total_spent DESC;

-- ============================================
-- WORKSHOP EXERCISE 4: INDEX DESIGN CHALLENGES
-- ============================================

-- Challenge 1: Optimize this query with minimal indexes
-- GOAL: Use the fewest indexes possible while maximizing performance
SELECT 
    c.c_name,
    c.c_mktsegment,
    n.n_name as nation,
    COUNT(o.o_orderkey) as order_count,
    SUM(o.o_totalprice) as total_revenue,
    AVG(o.o_totalprice) as avg_order_value
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_acctbal > 1000
  AND (o.o_orderdate IS NULL OR o.o_orderdate >= '1995-01-01')
GROUP BY c.c_name, c.c_mktsegment, n.n_name
HAVING COUNT(o.o_orderkey) > 0
ORDER BY total_revenue DESC
LIMIT 25;

-- TODO: Design indexes for Challenge 1
-- Consider: What columns are used in WHERE, JOIN, GROUP BY, ORDER BY?
-- Your solution:
-- CREATE INDEX ??? ON ???;

-- Challenge 2: Optimize this analytical query
-- GOAL: Support fast aggregation and filtering
SELECT 
    EXTRACT(YEAR FROM l.l_shipdate) as ship_year,
    EXTRACT(QUARTER FROM l.l_shipdate) as ship_quarter,
    l.l_returnflag,
    l.l_linestatus,
    COUNT(*) as line_count,
    SUM(l.l_quantity) as total_quantity,
    SUM(l.l_extendedprice) as total_price,
    AVG(l.l_discount) as avg_discount
FROM lineitem l
WHERE l.l_shipdate >= '1995-01-01'
  AND l.l_shipdate < '1997-01-01'
  AND l.l_returnflag IN ('R', 'A')
GROUP BY 
    EXTRACT(YEAR FROM l.l_shipdate),
    EXTRACT(QUARTER FROM l.l_shipdate),
    l.l_returnflag,
    l.l_linestatus
ORDER BY ship_year, ship_quarter, l.l_returnflag, l.l_linestatus;

-- TODO: Design indexes for Challenge 2
-- Consider: Date ranges, categorical filters, grouping columns
-- Your solution:
-- CREATE INDEX ??? ON ???;

-- ============================================
-- WORKSHOP EXERCISE 5: INDEX ANTI-PATTERNS
-- ============================================

-- Identify why these queries might not use indexes effectively
-- and suggest improvements

-- Anti-pattern 1: Function on indexed column
SELECT c_name, c_acctbal
FROM customer
WHERE ROUND(c_acctbal, -3) = 5000;  -- Rounds to nearest thousand

-- TODO: How would you rewrite this to use an index?
-- Hint: Avoid functions on the indexed column

-- Anti-pattern 2: Leading wildcard
SELECT c_name, c_phone
FROM customer
WHERE c_phone LIKE '%555%';

-- TODO: How could you optimize phone number searches?
-- Hint: Consider different indexing strategies or query patterns

-- Anti-pattern 3: OR conditions
SELECT c_name, c_acctbal
FROM customer
WHERE c_acctbal < 0 OR c_acctbal > 9000;

-- TODO: How could you optimize this OR condition?
-- Hint: Consider UNION or different index strategies

-- ============================================
-- WORKSHOP EXERCISE 6: PARTIAL INDEXES
-- ============================================

-- Create partial indexes for specific use cases

-- Scenario: You frequently query high-value customers (balance > 5000)
-- but rarely query low-value customers
-- TODO: Create a partial index for high-value customers
-- CREATE INDEX idx_customer_high_value ON customer(c_custkey, c_acctbal) 
-- WHERE c_acctbal > 5000;

-- Test the partial index
-- EXPLAIN ANALYZE
-- SELECT c_name, c_acctbal
-- FROM customer
-- WHERE c_acctbal > 7500
-- ORDER BY c_acctbal DESC;

-- Scenario: You frequently analyze recent orders but rarely query old ones
-- TODO: Create a partial index for recent orders
-- CREATE INDEX idx_orders_recent ON orders(o_orderdate, o_totalprice)
-- WHERE o_orderdate >= '1995-01-01';

-- ============================================
-- WORKSHOP EXERCISE 7: INDEX MONITORING
-- ============================================

-- Create queries to monitor index effectiveness

-- Exercise 7a: Analyze column selectivity
-- TODO: Write a query to calculate selectivity for different columns
-- High selectivity = good for indexes, Low selectivity = poor for indexes

SELECT 'Column Selectivity Analysis' as analysis_type;

-- Template for selectivity analysis:
-- SELECT 
--     'table_name.column_name' as column_ref,
--     COUNT(*) as total_rows,
--     COUNT(DISTINCT column_name) as unique_values,
--     ROUND(COUNT(DISTINCT column_name) * 100.0 / COUNT(*), 2) as selectivity_percent
-- FROM table_name;

-- Exercise 7b: Query performance comparison
-- TODO: Create a script that times queries before and after index creation

-- Template for timing queries:
-- SELECT 'Before Index' as timing_phase, current_timestamp as start_time;
-- -- Run your query here
-- SELECT 'After Index' as timing_phase, current_timestamp as end_time;

-- ============================================
-- WORKSHOP SOLUTIONS AND DISCUSSION
-- ============================================

-- SOLUTION SECTION (Uncomment to see suggested solutions)

-- Solution for Exercise 1: Single Column Indexes
/*
CREATE INDEX idx_customer_acctbal ON customer(c_acctbal);
CREATE INDEX idx_customer_nationkey ON customer(c_nationkey);
CREATE INDEX idx_orders_custkey ON orders(o_custkey);
CREATE INDEX idx_orders_orderdate ON orders(o_orderdate);
CREATE INDEX idx_lineitem_partkey ON lineitem(l_partkey);
CREATE INDEX idx_lineitem_suppkey ON lineitem(l_suppkey);
CREATE INDEX idx_lineitem_shipdate ON lineitem(l_shipdate);
*/

-- Solution for Exercise 2: Composite Indexes
/*
CREATE INDEX idx_customer_nation_balance ON customer(c_nationkey, c_acctbal);
CREATE INDEX idx_orders_date_status ON orders(o_orderdate, o_orderstatus);
CREATE INDEX idx_lineitem_ship_part ON lineitem(l_shipdate, l_partkey);
*/

-- Solution for Challenge 1: Minimal Index Set
/*
-- Analysis: Query uses c_acctbal in WHERE, c_nationkey for JOIN, 
-- o_custkey for JOIN, o_orderdate in WHERE
CREATE INDEX idx_customer_balance_nation ON customer(c_acctbal, c_nationkey);
CREATE INDEX idx_orders_cust_date ON orders(o_custkey, o_orderdate);
*/

-- Solution for Challenge 2: Analytical Query
/*
-- Analysis: Query filters by l_shipdate and l_returnflag, groups by same plus l_linestatus
CREATE INDEX idx_lineitem_analytics ON lineitem(l_shipdate, l_returnflag, l_linestatus);
*/

-- ============================================
-- WORKSHOP CLEANUP
-- ============================================

-- Clean up workshop indexes (uncomment if needed)
/*
DROP INDEX IF EXISTS idx_customer_acctbal;
DROP INDEX IF EXISTS idx_customer_nationkey;
DROP INDEX IF EXISTS idx_orders_custkey;
DROP INDEX IF EXISTS idx_orders_orderdate;
DROP INDEX IF EXISTS idx_lineitem_partkey;
DROP INDEX IF EXISTS idx_lineitem_suppkey;
DROP INDEX IF EXISTS idx_lineitem_shipdate;
DROP INDEX IF EXISTS idx_customer_nation_balance;
DROP INDEX IF EXISTS idx_orders_date_status;
DROP INDEX IF EXISTS idx_lineitem_ship_part;
*/

-- ============================================
-- WORKSHOP REFLECTION QUESTIONS
-- ============================================

-- 1. Which queries showed the most improvement with indexes?
-- 2. Which indexes provided the least benefit? Why?
-- 3. How did composite indexes compare to single-column indexes?
-- 4. What trade-offs did you observe between query performance and index overhead?
-- 5. How would you prioritize index creation in a real-world scenario?
-- 6. What monitoring would you put in place to track index effectiveness over time?

-- NEXT STEPS:
-- 1. Practice with your own queries and datasets
-- 2. Learn about database-specific index types (B-tree, Hash, Bitmap, etc.)
-- 3. Study advanced topics like covering indexes and index-only scans
-- 4. Explore automated index recommendation tools
-- 5. Practice index maintenance and reorganization techniques