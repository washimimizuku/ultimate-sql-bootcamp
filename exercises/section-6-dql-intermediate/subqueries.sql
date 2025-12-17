-- ============================================
-- SUBQUERIES EXERCISES - TPC-H Database
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < examples/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-6-dql-intermediate/subqueries.sql
-- ============================================

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