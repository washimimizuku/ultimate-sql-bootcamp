-- SQL JOIN Examples - Advanced Data Query Language (DQL)
-- This file demonstrates JOIN operations for combining data from multiple tables
-- JOINs are essential for relational database queries and data relationships
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < examples/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-6-dql-intermediate/join.sql
-- ============================================

-- JOIN TYPES:
-- - INNER JOIN: Returns rows when there's a match in both tables
-- - LEFT JOIN: Returns all rows from left table, matched rows from right
-- - RIGHT JOIN: Returns all rows from right table, matched rows from left
-- - FULL OUTER JOIN: Returns all rows from both tables
-- - CROSS JOIN: Returns Cartesian product of both tables

-- JOIN SYNTAX:
-- SELECT columns FROM table1 JOIN table2 ON condition;           -- Basic JOIN (same as INNER)
-- SELECT columns FROM table1 INNER JOIN table2 ON condition;    -- Explicit INNER JOIN
-- SELECT columns FROM table1 LEFT JOIN table2 ON condition;     -- LEFT OUTER JOIN
-- SELECT columns FROM table1 RIGHT JOIN table2 ON condition;    -- RIGHT OUTER JOIN
-- SELECT columns FROM table1 FULL JOIN table2 ON condition;     -- FULL OUTER JOIN

-- Example 1: Basic JOIN (One-to-Many Relationship)
-- Join orders with customers - each customer can have multiple orders
SELECT c_name, c_address, o_orderdate
FROM orders
JOIN customer ON c_custkey = o_custkey
ORDER BY c_custkey;

-- Example 2: Explicit INNER JOIN (Same as above, more explicit)
-- Shows the relationship between orders and customers explicitly
SELECT c_name, c_address, o_orderdate
FROM orders
INNER JOIN customer ON c_custkey = o_custkey
ORDER BY c_custkey;

-- Example 3: Table Specification Order
-- Same join but with customer as the primary table (left side)
-- Order of tables in FROM clause can affect readability
SELECT c_name, c_address, o_orderdate
FROM customer
INNER JOIN orders ON c_custkey = o_custkey
ORDER BY c_custkey;

-- Example 4: Table Aliases for Identical Column Names
-- Using aliases (AS) to distinguish between columns with same names
SELECT c.c_name, c.c_address, o.o_orderdate
FROM orders AS o
INNER JOIN customer AS c ON c.c_custkey = o.o_custkey;

-- Example 5: Alternative Syntax with Parentheses
-- Parentheses around JOIN condition (optional but can improve readability)
SELECT c.c_name, c.c_address, o.o_orderdate
FROM orders AS o
INNER JOIN customer AS c ON (c.c_custkey = o.o_custkey);

-- Example 6: Join with Subquery (Derived Table)
-- Join customer table with a filtered subset of orders from 1995
SELECT c.c_custkey, c.c_name, c.c_address, o.o_orderkey, o.o_orderdate
FROM customer AS c
INNER JOIN (
    SELECT o_orderkey, o_custkey, o_orderdate
    FROM orders
    WHERE o_orderdate >= '1995-01-01' AND o_orderdate < '1996-01-01'
) AS o ON c.c_custkey = o.o_custkey;

-- Helper query: Show the filtered orders from 1995 for reference
SELECT o_orderkey, o_custkey, o_orderdate
FROM orders
WHERE o_orderdate >= '1995-01-01' AND o_orderdate < '1996-01-01';

-- Example 7: Multi-Table INNER JOIN (Three Tables)
-- Join orders, customers, and line items to get complete order details
-- Shows how to chain multiple JOINs for complex relationships
SELECT c.c_name, c.c_address, o.o_orderkey, o.o_orderdate, l.l_partkey
FROM orders AS o
INNER JOIN customer AS c ON (c.c_custkey = o.o_custkey)
INNER JOIN lineitem AS l ON (o.o_orderkey = l.l_orderkey)
WHERE c.c_name = 'Customer#000000036'
ORDER BY o.o_orderdate;