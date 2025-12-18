-- TPC-H Database Demo Queries
-- This file demonstrates common business analytics queries using the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql

-- Example 1: Customer Analysis - Top customers by account balance
SELECT c_name, c_acctbal, c_mktsegment
FROM customer
ORDER BY c_acctbal DESC
LIMIT 10;

-- Example 2: Regional Sales Analysis - Orders by region
SELECT r.r_name as region, 
       COUNT(o.o_orderkey) as total_orders,
       SUM(o.o_totalprice) as total_revenue,
       AVG(o.o_totalprice) as avg_order_value
FROM region r
JOIN nation n ON r.r_regionkey = n.n_regionkey
JOIN customer c ON n.n_nationkey = c.c_nationkey
JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY r.r_name
ORDER BY total_revenue DESC;

-- Example 3: Product Analysis - Most expensive parts by type
SELECT p_type, 
       COUNT(*) as part_count,
       AVG(p_retailprice) as avg_price,
       MAX(p_retailprice) as max_price
FROM part
GROUP BY p_type
ORDER BY avg_price DESC
LIMIT 10;

-- Example 4: Supply Chain Analysis - Supplier performance
SELECT s.s_name,
       n.n_name as nation,
       COUNT(DISTINCT ps.ps_partkey) as parts_supplied,
       AVG(ps.ps_supplycost) as avg_supply_cost
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
GROUP BY s.s_name, n.n_name
ORDER BY parts_supplied DESC
LIMIT 15;

-- Example 5: Order Priority Analysis
SELECT o_orderpriority,
       COUNT(*) as order_count,
       AVG(o_totalprice) as avg_total,
       SUM(o_totalprice) as total_revenue
FROM orders
GROUP BY o_orderpriority
ORDER BY total_revenue DESC;