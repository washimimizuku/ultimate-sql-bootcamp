-- SQL SUBQUERIES Examples - Advanced Data Query Language (DQL)
-- This file demonstrates subquery usage for complex data retrieval in SELECT statements
-- Subqueries are nested queries that can be used in WHERE, FROM, SELECT clauses
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-5-dql-intermediate/subqueries.sql
-- ============================================

-- SUBQUERY TYPES:
-- - Scalar subquery: Returns single value (one row, one column)
-- - Single-column subquery: Returns multiple rows, single column (used with IN, ANY, ALL)
-- - Multi-column subquery: Returns multiple rows and columns (used in FROM clause)
-- - Correlated subquery: References outer query columns
-- - Uncorrelated subquery: Independent of outer query

-- SUBQUERY OPERATORS:
-- - Comparison: =, !=, <>, <, >, <=, >= (with scalar subqueries)
-- - Set: IN, NOT IN (with single-column subqueries)
-- - Quantified: ANY, ALL (with single-column subqueries)
-- - Existence: EXISTS, NOT EXISTS (with any subquery)

-- Example 1: Uncorrelated Scalar Subquery - Find orders above 95th percentile
-- Returns orders with total price greater than the 95th percentile value
SELECT o_orderkey, o_totalprice
FROM orders
WHERE o_totalprice > (
    SELECT APPROX_QUANTILE(o_totalprice, 0.95)
    FROM orders
)
ORDER BY o_totalprice DESC;

-- Helper query: Show the 95th percentile value for reference
SELECT APPROX_QUANTILE(o_totalprice, 0.95) as percentile_95
FROM orders;

-- Example 2: Uncorrelated Single Column / Multiple Row Subquery with IN
-- Find customer details for the top 5 customers by order value
SELECT c_custkey, c_name, c_nationkey
FROM customer
WHERE c_custkey IN (
    SELECT o_custkey
    FROM orders
    ORDER BY o_totalprice DESC
    LIMIT 5
);

-- Example 3: ALL Subquery Operator - Find customers equal to ALL values in subquery
-- This will typically return no results unless subquery returns identical values
SELECT c_custkey, c_name, c_nationkey
FROM customer
WHERE c_custkey = ALL (
    SELECT c_custkey
    FROM customer
    LIMIT 5
);

-- Example 4: ANY Subquery Operator - Find customers equal to ANY value in subquery
-- Returns customers whose key matches any of the first 5 customer keys
SELECT c_custkey, c_name, c_nationkey
FROM customer
WHERE c_custkey = ANY (
    SELECT c_custkey
    FROM customer
    LIMIT 5
);

-- Example 5: NOT EQUAL ALL - Find customers not in low-value order group
-- Returns customers who are not among those with small orders
SELECT c_custkey, c_name, c_nationkey
FROM customer
WHERE c_custkey <> ALL (
    SELECT o_custkey
    FROM orders
    WHERE o_totalprice < 10000
    ORDER BY o_totalprice DESC
    LIMIT 5
);

-- Example 6: Subquery in FROM Clause (Derived Table)
-- Create a derived table with limited customer data
SELECT c_custkey, c_name, c_nationkey
FROM (
    SELECT c_custkey, c_name, c_nationkey
    FROM customer 
    LIMIT 10
) limited_customers;

-- Example 7: Correlated Subquery - Find orders below average for their order date
-- Each order is compared to the average for orders on the same date
SELECT o.o_orderkey, o.o_orderdate, o.o_totalprice
FROM orders o
WHERE o.o_totalprice <= (
    SELECT AVG(o_totalprice) 
    FROM orders 
    WHERE o_orderdate = o.o_orderdate
)
ORDER BY o.o_orderdate, o.o_totalprice;

-- Example 8: EXISTS Subquery Operator - Basic existence check
-- This example always returns true (not practical, just for demonstration)
SELECT COUNT(*) as total_orders
FROM orders
WHERE EXISTS (SELECT 1);

-- Example 9: EXISTS with Correlation - Find customers who have placed orders
-- Returns customers who have at least one order in the orders table
SELECT c_custkey, c_name, c_nationkey
FROM customer c
WHERE EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.o_custkey = c.c_custkey
);

-- Example 10: EXISTS with Complex Correlation - Find parts that have been ordered
-- Returns parts that appear in at least one line item
SELECT p_name
FROM part p
WHERE EXISTS (
    SELECT 1
    FROM lineitem li
    WHERE li.l_partkey = p.p_partkey
);

-- ============================================
-- ADDITIONAL SUBQUERY EXAMPLES
-- ============================================
-- The following examples provide additional patterns and use cases
-- for subqueries organized by clause type and complexity

-- ============================================
-- SUBQUERIES IN WHERE CLAUSE
-- ============================================

-- Simple comparison: Find parts with price above average
SELECT p_name, p_retailprice 
FROM part 
WHERE p_retailprice > (
    SELECT AVG(p_retailprice) 
    FROM part
);

-- IN operator: Find orders with line items above average quantity
SELECT o_orderkey, o_totalprice
FROM orders
WHERE o_orderkey IN (
    SELECT l_orderkey
    FROM lineitem
    WHERE l_quantity > (
        SELECT AVG(l_quantity)
        FROM lineitem
    )
);

-- Multi-level nested: Find suppliers from nations in a specific region
SELECT s_name
FROM supplier
WHERE s_nationkey IN (
    SELECT n_nationkey 
    FROM nation 
    WHERE n_regionkey IN (
        SELECT r_regionkey 
        FROM region 
        WHERE r_name = 'AMERICA'
    )
);

-- ============================================
-- CORRELATED SUBQUERIES
-- ============================================

-- Find parts with price above average for their type
SELECT p_name, p_retailprice, p_type
FROM part p1
WHERE p_retailprice > (
    SELECT AVG(p_retailprice)
    FROM part p2 
    WHERE p2.p_type = p1.p_type
);

-- Find orders with highest total value per customer
SELECT o_orderkey, o_custkey, o_totalprice
FROM orders o1
WHERE o_totalprice = (
    SELECT MAX(o_totalprice)
    FROM orders o2 
    WHERE o2.o_custkey = o1.o_custkey
);

-- Find suppliers with above average parts supply count in their nation
SELECT s_name
FROM supplier s
WHERE (
    SELECT COUNT(*)
    FROM partsupp ps
    WHERE ps.ps_suppkey = s.s_suppkey
) > (
    SELECT AVG(part_count)
    FROM (
        SELECT COUNT(*) as part_count
        FROM partsupp ps2
        JOIN supplier s2 ON s2.s_suppkey = ps2.ps_suppkey
        WHERE s2.s_nationkey = s.s_nationkey
        GROUP BY s2.s_suppkey
    ) nation_avg
);

-- ============================================
-- EXISTS / NOT EXISTS SUBQUERIES
-- ============================================

-- Find customers who have placed orders after 1995
SELECT c_name
FROM customer c
WHERE EXISTS (
    SELECT 1 
    FROM orders o
    WHERE o.o_custkey = c.c_custkey
    AND o.o_orderdate >= '1995-01-01'
);

-- Find customers who have placed orders with total value greater than their nation's average
SELECT c_name, c_acctbal
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.o_custkey = c.c_custkey
    AND o.o_totalprice > (
        SELECT AVG(o_totalprice)
        FROM orders o2
        JOIN customer c2 ON c2.c_custkey = o2.o_custkey
        WHERE c2.c_nationkey = c.c_nationkey
    )
);

-- Find customers who have ordered all parts of a specific type (division operation)
SELECT c_name 
FROM customer c
WHERE NOT EXISTS (
    SELECT p_partkey
    FROM part
    WHERE p_type = 'BRASS'
    AND p_partkey NOT IN (
        SELECT l_partkey
        FROM orders o
        JOIN lineitem l ON l.l_orderkey = o.o_orderkey
        WHERE o.o_custkey = c.c_custkey
    )
);

-- ============================================
-- SUBQUERIES IN SELECT CLAUSE
-- ============================================

-- Show each nation with comparison to average customer count
SELECT 
    n_name,
    (SELECT COUNT(*) FROM customer c WHERE c.c_nationkey = n.n_nationkey) as customer_count,
    (SELECT AVG(cnt) FROM (SELECT COUNT(*) as cnt FROM customer GROUP BY c_nationkey)) as avg_customers_per_nation
FROM nation n;

-- Show parts and their price rank within their type
SELECT p_name, p_type, p_retailprice,
    (SELECT COUNT(*) + 1
     FROM part p2
     WHERE p2.p_type = p1.p_type
     AND p2.p_retailprice > p1.p_retailprice) as price_rank
FROM part p1
ORDER BY p_type, price_rank;

-- Calculate market share percentage by region
SELECT r_name,
    (SELECT SUM(o_totalprice)
     FROM orders o
     JOIN customer c ON c.c_custkey = o.o_custkey
     JOIN nation n ON n.n_nationkey = c.c_nationkey
     WHERE n.n_regionkey = r.r_regionkey) * 100.0 / 
    (SELECT SUM(o_totalprice) FROM orders) as market_share_pct
FROM region r;

-- ============================================
-- SUBQUERIES IN FROM CLAUSE (Derived Tables)
-- ============================================

-- Average order total by nation
SELECT n.n_name, avg_total
FROM (
    SELECT c_nationkey, AVG(o_totalprice) as avg_total 
    FROM orders o
    JOIN customer c ON c.c_custkey = o.o_custkey
    GROUP BY c_nationkey
) nation_averages
JOIN nation n ON n.n_nationkey = nation_averages.c_nationkey;

-- Find regions with above average supplier count
SELECT r_name
FROM region r
WHERE (
    SELECT COUNT(*)
    FROM supplier s
    JOIN nation n ON n.n_nationkey = s.s_nationkey
    WHERE n.n_regionkey = r.r_regionkey
) > (
    SELECT AVG(supp_count)
    FROM (
        SELECT COUNT(*) as supp_count
        FROM supplier s
        JOIN nation n ON n.n_nationkey = s.s_nationkey
        GROUP BY n.n_regionkey
    ) avg_suppliers
);

-- Get parts supplied by suppliers from multiple nations
SELECT p_name, p_partkey
FROM part
WHERE p_partkey IN (
    SELECT ps_partkey 
    FROM partsupp ps
    JOIN supplier s ON s.s_suppkey = ps.ps_suppkey
    GROUP BY ps_partkey
    HAVING COUNT(DISTINCT s_nationkey) > 1
);