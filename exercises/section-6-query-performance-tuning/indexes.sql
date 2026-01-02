-- INDEX OPTIMIZATION Examples - Query Performance Tuning
-- This file demonstrates index creation, usage, and optimization strategies
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-6-query-performance-tuning/indexes.sql
-- ============================================

-- INDEX CONCEPTS:
-- - Indexes are data structures that improve query performance
-- - They create shortcuts to find data without scanning entire tables
-- - Trade-off: Faster SELECT queries vs slower INSERT/UPDATE/DELETE
-- - Common types: B-tree (default), Hash, Bitmap, Partial indexes
-- - DuckDB automatically creates indexes on PRIMARY KEY and UNIQUE constraints

-- INDEX OPERATIONS:
-- - CREATE INDEX: Create a new index
-- - DROP INDEX: Remove an index
-- - SHOW INDEXES: List all indexes (DuckDB specific)
-- - EXPLAIN: Analyze if indexes are being used

-- ============================================
-- UNDERSTANDING CURRENT INDEXES
-- ============================================

-- Show existing indexes in the database
-- Note: DuckDB may have different syntax for showing indexes
PRAGMA table_info(customer);
PRAGMA table_info(orders);

-- Check if there are any existing indexes
-- DuckDB automatically creates indexes for PRIMARY KEYs
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('customer', 'orders', 'lineitem')
ORDER BY table_name, ordinal_position;

-- ============================================
-- BASELINE PERFORMANCE WITHOUT INDEXES
-- ============================================

-- Example 1: Query without index (slow on large tables)
-- This will do a full table scan
EXPLAIN ANALYZE
SELECT c_name, c_acctbal, c_phone
FROM customer
WHERE c_acctbal > 8000;

-- Example 2: JOIN without indexes (slow)
EXPLAIN ANALYZE
SELECT c.c_name, COUNT(o.o_orderkey) as order_count
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_acctbal > 5000
GROUP BY c.c_name
LIMIT 10;

-- Example 3: ORDER BY without index (requires sorting)
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
ORDER BY c_acctbal DESC
LIMIT 20;

-- ============================================
-- SINGLE COLUMN INDEXES
-- ============================================

-- Example 4: Create index on frequently queried column
-- This will speed up WHERE clauses on c_acctbal
CREATE INDEX idx_customer_acctbal ON customer(c_acctbal);

-- Test the same query with index
EXPLAIN ANALYZE
SELECT c_name, c_acctbal, c_phone
FROM customer
WHERE c_acctbal > 8000;

-- Example 5: Create index on foreign key column
-- This will speed up JOINs
CREATE INDEX idx_customer_nationkey ON customer(c_nationkey);
CREATE INDEX idx_orders_custkey ON orders(o_custkey);

-- Test JOIN performance with indexes
EXPLAIN ANALYZE
SELECT c.c_name, COUNT(o.o_orderkey) as order_count
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_acctbal > 5000
GROUP BY c.c_name
LIMIT 10;

-- Example 6: Create index for ORDER BY optimization
CREATE INDEX idx_customer_acctbal_desc ON customer(c_acctbal DESC);

-- Test ORDER BY performance with index
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
ORDER BY c_acctbal DESC
LIMIT 20;

-- ============================================
-- COMPOSITE (MULTI-COLUMN) INDEXES
-- ============================================

-- Example 7: Composite index for multiple WHERE conditions
-- Index column order matters: most selective column first
CREATE INDEX idx_customer_nation_segment ON customer(c_nationkey, c_mktsegment);

-- This query can use the composite index efficiently
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
WHERE c_nationkey = 15 AND c_mktsegment = 'BUILDING';

-- This query can partially use the index (only first column)
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
WHERE c_nationkey = 15;

-- This query CANNOT use the index efficiently (second column only)
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
WHERE c_mktsegment = 'BUILDING';

-- Example 8: Composite index for ORDER BY optimization
CREATE INDEX idx_orders_date_priority ON orders(o_orderdate, o_orderpriority);

-- This query can use the composite index for both filtering and sorting
EXPLAIN ANALYZE
SELECT o_orderkey, o_totalprice, o_orderdate, o_orderpriority
FROM orders
WHERE o_orderdate >= '1995-01-01'
ORDER BY o_orderdate, o_orderpriority
LIMIT 50;

-- ============================================
-- INDEXES FOR JOIN OPTIMIZATION
-- ============================================

-- Example 9: Optimize complex multi-table joins
CREATE INDEX idx_lineitem_orderkey ON lineitem(l_orderkey);
CREATE INDEX idx_lineitem_partkey ON lineitem(l_partkey);
CREATE INDEX idx_lineitem_suppkey ON lineitem(l_suppkey);

-- Test complex join with indexes
EXPLAIN ANALYZE
SELECT 
    c.c_name,
    p.p_name,
    s.s_name,
    SUM(l.l_quantity) as total_quantity,
    SUM(l.l_extendedprice) as total_price
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey
JOIN part p ON l.l_partkey = p.p_partkey
JOIN supplier s ON l.l_suppkey = s.s_suppkey
WHERE c.c_nationkey = 15
  AND o.o_orderdate >= '1995-01-01'
GROUP BY c.c_name, p.p_name, s.s_name
HAVING SUM(l.l_extendedprice) > 10000
ORDER BY total_price DESC
LIMIT 20;

-- ============================================
-- PARTIAL INDEXES (Conditional Indexes)
-- ============================================

-- Example 10: Partial index for specific conditions
-- Only index rows that meet certain criteria
CREATE INDEX idx_customer_high_balance ON customer(c_custkey) 
WHERE c_acctbal > 5000;

-- This query can use the partial index
EXPLAIN ANALYZE
SELECT c_name, c_acctbal
FROM customer
WHERE c_acctbal > 5000 AND c_custkey < 1000;

-- Example 11: Partial index for active orders only
CREATE INDEX idx_orders_active ON orders(o_orderdate, o_totalprice)
WHERE o_orderstatus IN ('O', 'P');  -- Only Open and Pending orders

-- Query using partial index
EXPLAIN ANALYZE
SELECT o_orderkey, o_totalprice, o_orderdate
FROM orders
WHERE o_orderstatus = 'O' AND o_orderdate >= '1995-01-01'
ORDER BY o_totalprice DESC
LIMIT 25;

-- ============================================
-- INDEX SELECTIVITY AND EFFECTIVENESS
-- ============================================

-- Example 12: Analyze index selectivity
-- High selectivity (good for indexes): many unique values
SELECT 
    'c_custkey' as column_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT c_custkey) as unique_values,
    ROUND(COUNT(DISTINCT c_custkey) * 100.0 / COUNT(*), 2) as selectivity_percent
FROM customer

UNION ALL

SELECT 
    'c_nationkey' as column_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT c_nationkey) as unique_values,
    ROUND(COUNT(DISTINCT c_nationkey) * 100.0 / COUNT(*), 2) as selectivity_percent
FROM customer

UNION ALL

SELECT 
    'c_mktsegment' as column_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT c_mktsegment) as unique_values,
    ROUND(COUNT(DISTINCT c_mktsegment) * 100.0 / COUNT(*), 2) as selectivity_percent
FROM customer;

-- Example 13: Test index effectiveness with different selectivity
-- High selectivity query (good for index)
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_custkey = 1000;

-- Low selectivity query (index may not help much)
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_mktsegment = 'BUILDING';

-- ============================================
-- INDEX MAINTENANCE AND MONITORING
-- ============================================

-- Example 14: Monitor index usage patterns
-- Create a test scenario with different query patterns

-- Queries that should use indexes efficiently
EXPLAIN ANALYZE SELECT * FROM customer WHERE c_acctbal BETWEEN 5000 AND 8000;
EXPLAIN ANALYZE SELECT * FROM orders WHERE o_custkey IN (1, 100, 500, 1000);
EXPLAIN ANALYZE SELECT * FROM lineitem WHERE l_orderkey = 1 AND l_partkey = 100;

-- Queries that may not use indexes effectively
EXPLAIN ANALYZE SELECT * FROM customer WHERE UPPER(c_name) LIKE 'CUSTOMER%';
EXPLAIN ANALYZE SELECT * FROM customer WHERE c_acctbal * 1.1 > 5000;

-- ============================================
-- INDEX ANTI-PATTERNS AND PITFALLS
-- ============================================

-- Example 15: Common index anti-patterns

-- BAD: Function on indexed column prevents index usage
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE UPPER(c_name) = 'CUSTOMER#000001000';

-- GOOD: Avoid functions on indexed columns
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_name = 'Customer#000001000';

-- BAD: Leading wildcard prevents index usage
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_name LIKE '%1000';

-- GOOD: Prefix matching can use index
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_name LIKE 'Customer%';

-- BAD: OR conditions may not use indexes efficiently
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_acctbal < 0 OR c_acctbal > 9000;

-- GOOD: Use UNION for OR conditions when appropriate
EXPLAIN ANALYZE
SELECT c_name FROM customer WHERE c_acctbal < 0
UNION
SELECT c_name FROM customer WHERE c_acctbal > 9000;

-- ============================================
-- INDEX STRATEGIES FOR DIFFERENT QUERY TYPES
-- ============================================

-- Example 16: Indexes for analytical queries
CREATE INDEX idx_orders_date_totalprice ON orders(o_orderdate, o_totalprice);

-- Time-based analysis
EXPLAIN ANALYZE
SELECT 
    EXTRACT(YEAR FROM o_orderdate) as year,
    EXTRACT(MONTH FROM o_orderdate) as month,
    COUNT(*) as order_count,
    SUM(o_totalprice) as total_revenue,
    AVG(o_totalprice) as avg_order_value
FROM orders
WHERE o_orderdate BETWEEN '1995-01-01' AND '1995-12-31'
GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)
ORDER BY year, month;

-- Example 17: Indexes for reporting queries
CREATE INDEX idx_lineitem_shipdate_flag ON lineitem(l_shipdate, l_returnflag);

-- Shipping analysis
EXPLAIN ANALYZE
SELECT 
    l_returnflag,
    COUNT(*) as shipment_count,
    SUM(l_quantity) as total_quantity,
    AVG(l_extendedprice) as avg_price
FROM lineitem
WHERE l_shipdate >= '1995-01-01'
GROUP BY l_returnflag
ORDER BY l_returnflag;

-- ============================================
-- INDEX SIZE AND STORAGE CONSIDERATIONS
-- ============================================

-- Example 18: Understand index overhead
-- Note: DuckDB may not have detailed index size information
-- This is conceptual for understanding trade-offs

-- Indexes consume storage space
-- More indexes = more storage overhead
-- Consider the trade-off between query performance and storage/maintenance cost

-- Rule of thumb: Create indexes for:
-- 1. Primary keys (automatic)
-- 2. Foreign keys used in JOINs
-- 3. Columns frequently used in WHERE clauses
-- 4. Columns used in ORDER BY (especially with LIMIT)
-- 5. Columns used in GROUP BY

-- Avoid creating indexes for:
-- 1. Columns that are rarely queried
-- 2. Tables with very high INSERT/UPDATE/DELETE rates
-- 3. Columns with very low selectivity (few unique values)
-- 4. Very wide columns (long strings, etc.)

-- ============================================
-- CLEANUP AND INDEX MANAGEMENT
-- ============================================

-- Example 19: Drop unused or redundant indexes
-- Always analyze before dropping indexes in production!

-- Drop single column indexes that are covered by composite indexes
DROP INDEX IF EXISTS idx_customer_nationkey;  -- Covered by idx_customer_nation_segment

-- Drop indexes that are no longer needed
DROP INDEX IF EXISTS idx_customer_high_balance;
DROP INDEX IF EXISTS idx_orders_active;

-- Keep essential indexes
-- DROP INDEX IF EXISTS idx_customer_acctbal;  -- Keep this one
-- DROP INDEX IF EXISTS idx_orders_custkey;    -- Keep this one

-- List remaining indexes (conceptual - DuckDB syntax may vary)
SELECT 
    table_name,
    index_name
FROM information_schema.statistics
WHERE table_schema = 'main'
ORDER BY table_name, index_name;

-- ============================================
-- COMPREHENSIVE INDEX STRATEGY
-- ============================================

-- Example 20: Complete indexing strategy for TPC-H workload

-- Core business entity indexes
CREATE INDEX IF NOT EXISTS idx_customer_key ON customer(c_custkey);
CREATE INDEX IF NOT EXISTS idx_orders_key ON orders(o_orderkey);
CREATE INDEX IF NOT EXISTS idx_part_key ON part(p_partkey);
CREATE INDEX IF NOT EXISTS idx_supplier_key ON supplier(s_suppkey);

-- Foreign key indexes for joins
CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(o_custkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_order ON lineitem(l_orderkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_part ON lineitem(l_partkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_supplier ON lineitem(l_suppkey);
CREATE INDEX IF NOT EXISTS idx_partsupp_part ON partsupp(ps_partkey);
CREATE INDEX IF NOT EXISTS idx_partsupp_supplier ON partsupp(ps_suppkey);

-- Analytical query indexes
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(o_orderdate);
CREATE INDEX IF NOT EXISTS idx_lineitem_shipdate ON lineitem(l_shipdate);
CREATE INDEX IF NOT EXISTS idx_customer_balance ON customer(c_acctbal);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_customer_nation_balance ON customer(c_nationkey, c_acctbal);
CREATE INDEX IF NOT EXISTS idx_orders_date_status ON orders(o_orderdate, o_orderstatus);
CREATE INDEX IF NOT EXISTS idx_lineitem_ship_return ON lineitem(l_shipdate, l_returnflag);

-- Test the complete indexing strategy with a complex business query
EXPLAIN ANALYZE
SELECT 
    n.n_name as nation,
    EXTRACT(YEAR FROM o.o_orderdate) as year,
    COUNT(DISTINCT c.c_custkey) as unique_customers,
    COUNT(o.o_orderkey) as total_orders,
    SUM(o.o_totalprice) as total_revenue,
    AVG(o.o_totalprice) as avg_order_value
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE o.o_orderdate >= '1995-01-01'
  AND o.o_orderdate < '1996-01-01'
  AND c.c_acctbal > 0
GROUP BY n.n_name, EXTRACT(YEAR FROM o.o_orderdate)
HAVING COUNT(o.o_orderkey) > 100
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================
-- INDEX BEST PRACTICES SUMMARY
-- ============================================

-- 1. ANALYSIS FIRST:
--    - Use EXPLAIN ANALYZE to identify slow queries
--    - Analyze query patterns and frequency
--    - Measure baseline performance before creating indexes

-- 2. STRATEGIC INDEX CREATION:
--    - Index primary keys (automatic in most databases)
--    - Index foreign keys used in JOINs
--    - Index columns in WHERE clauses
--    - Index columns in ORDER BY (especially with LIMIT)

-- 3. COMPOSITE INDEX GUIDELINES:
--    - Put most selective columns first
--    - Consider query patterns when ordering columns
--    - Avoid too many columns in one index

-- 4. MAINTENANCE CONSIDERATIONS:
--    - Monitor index usage and effectiveness
--    - Drop unused indexes to reduce overhead
--    - Consider partial indexes for specific use cases
--    - Balance query performance vs. write performance

-- 5. AVOID COMMON PITFALLS:
--    - Don't use functions on indexed columns in WHERE clauses
--    - Avoid leading wildcards in LIKE patterns
--    - Be careful with OR conditions
--    - Don't over-index tables with high write activity

-- 6. TESTING AND MONITORING:
--    - Test index effectiveness with realistic data volumes
--    - Monitor query performance over time
--    - Use database-specific tools to analyze index usage
--    - Document indexing decisions and rationale