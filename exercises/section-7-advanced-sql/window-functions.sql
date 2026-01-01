-- SQL WINDOW FUNCTIONS Examples - Advanced SQL Concepts
-- This file demonstrates window functions for analytical queries and advanced data analysis
-- Window functions perform calculations across a set of rows related to the current row
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-7-advanced-sql/window-functions.sql
-- ============================================

-- WINDOW FUNCTION CONCEPTS:
-- - Window functions operate on a "window" of rows related to the current row
-- - Unlike aggregate functions, they don't collapse rows into groups
-- - Each row retains its identity while gaining access to aggregate information
-- - Syntax: function() OVER (PARTITION BY ... ORDER BY ... ROWS/RANGE ...)

-- WINDOW FUNCTION TYPES:
-- - Aggregate: SUM, AVG, COUNT, MIN, MAX (applied over a window)
-- - Ranking: ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- - Value: LAG, LEAD, FIRST_VALUE, LAST_VALUE, NTH_VALUE
-- - Statistical: PERCENT_RANK, CUME_DIST, QUANTILE_CONT, QUANTILE_DISC (DuckDB-specific)

-- WINDOW FRAME CLAUSES:
-- - ROWS BETWEEN: Physical number of rows (e.g., ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
-- - RANGE BETWEEN: Logical range based on values (e.g., RANGE BETWEEN INTERVAL '1' DAY PRECEDING AND CURRENT ROW)
-- - UNBOUNDED PRECEDING/FOLLOWING: From start/to end of partition
-- - CURRENT ROW: The current row being processed

-- Database exploration
SHOW DATABASES;
SHOW TABLES;

-- Sample data inspection
SELECT * FROM orders LIMIT 10;
SELECT COUNT(*) FROM orders LIMIT 10;

-- Example 1: Basic Window Function - Average per Customer
-- Calculate the average order amount for each customer while showing individual orders
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    AVG(o_totalprice) OVER (PARTITION BY o_custkey) AS avg_price
FROM 
    orders 
ORDER BY o_custkey, o_orderdate;

-- Example 2: Window Function with Multiple Partitions
-- Calculate total sales for each customer-priority combination
SELECT
    o_custkey,
    o_orderpriority,
    o_totalprice,
    SUM(o_totalprice) OVER (PARTITION BY o_custkey, o_orderpriority) AS cust_priority_total
FROM
    orders
ORDER BY o_custkey, o_orderpriority;

-- Example 3: Ranking Window Function with Aggregation
-- Find the 3 highest spending months for 1995 using RANK()
SELECT
    MONTHNAME(o_orderdate) AS order_month,
    SUM(o_totalprice) AS monthly_sales,
    RANK() OVER (ORDER BY SUM(o_totalprice) DESC) AS monthly_sales_rank
FROM
    orders
WHERE
    YEAR(o_orderdate) = 1995
GROUP BY
    order_month
ORDER BY
    monthly_sales_rank
LIMIT 3;

-- Example 4: Percentage Calculation with Window Functions
-- Calculate what percentage each order represents of the daily total
SELECT
    o_orderkey,
    o_orderdate,
    o_totalprice,
    o_totalprice / SUM(o_totalprice) OVER (PARTITION BY o_orderdate) * 100 AS pct_daily_total
FROM
    orders
ORDER BY
    o_orderdate;

-- Example 5: Using QUALIFY Clause with Window Functions
-- Filter results based on window function calculations (DuckDB-specific)
SELECT
    o_orderkey,
    o_orderdate,
    o_totalprice,
    o_totalprice / SUM(o_totalprice) OVER (PARTITION BY o_orderdate) * 100 AS pct_daily_total
FROM
    orders
QUALIFY
    pct_daily_total > 20
ORDER BY
    o_orderdate;

-- Example 6: Moving Average with Window Frames
-- Calculate a 7-day moving average of daily sales, resetting each month
SELECT
    MONTH(o_orderdate) AS order_month,
    DAY(o_orderdate) AS order_day,
    SUM(o_totalprice) AS total_sales,
    AVG(SUM(o_totalprice)) OVER (
        PARTITION BY MONTH(o_orderdate)
        ORDER BY DAY(o_orderdate)
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS sliding_average_amount
FROM
    orders
GROUP BY
    order_month, order_day
ORDER BY
    order_month, order_day;

-- =====================================================
-- ADDITIONAL WINDOW FUNCTION EXAMPLES
-- =====================================================

-- Setup: Create sample data to demonstrate ranking function differences
CREATE TEMPORARY TABLE ranking_demo AS
SELECT * FROM (
    VALUES 
        (1, 100.00),
        (2, 95.00),
        (3, 95.00),  -- Tie: same value as row 2
        (4, 90.00),
        (5, 90.00),  -- Tie: same value as row 4
        (6, 90.00),  -- Tie: same value as rows 4 and 5
        (7, 85.00),
        (8, 80.00)
) AS t(id, score);

-- Example 7: Ranking Functions Comparison
-- Compare different ranking functions on data with ties to see the differences
SELECT
    id,
    score,
    ROW_NUMBER() OVER (ORDER BY score DESC) AS row_num,        -- Always unique: 1,2,3,4,5,6,7,8
    RANK() OVER (ORDER BY score DESC) AS rank_val,             -- Gaps after ties: 1,2,2,4,4,4,7,8
    DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank_val, -- No gaps after ties: 1,2,2,3,3,3,4,5
    NTILE(4) OVER (ORDER BY score DESC) AS quartile            -- Divides into 4 equal groups
FROM ranking_demo
ORDER BY score DESC;

-- Cleanup: Remove the temporary table
DROP TABLE ranking_demo;

-- Example 7 (Alternative): Ranking Functions on Real TPC-H Data
-- Compare different ranking functions on actual order data
SELECT
    o_custkey,
    o_totalprice,
    ROW_NUMBER() OVER (ORDER BY o_totalprice DESC) AS row_num,
    RANK() OVER (ORDER BY o_totalprice DESC) AS rank_val,
    DENSE_RANK() OVER (ORDER BY o_totalprice DESC) AS dense_rank_val,
    NTILE(4) OVER (ORDER BY o_totalprice DESC) AS quartile
FROM orders
WHERE o_orderdate >= DATE '1995-01-01' 
  AND o_orderdate < DATE '1995-02-01'
ORDER BY o_totalprice DESC
LIMIT 20;

-- Example 8: LAG and LEAD Functions
-- Compare each order with the previous and next order for the same customer
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    LAG(o_totalprice, 1) OVER (PARTITION BY o_custkey ORDER BY o_orderdate) AS prev_order_amount,
    LEAD(o_totalprice, 1) OVER (PARTITION BY o_custkey ORDER BY o_orderdate) AS next_order_amount,
    o_totalprice - LAG(o_totalprice, 1) OVER (PARTITION BY o_custkey ORDER BY o_orderdate) AS amount_change
FROM orders
WHERE o_custkey IN (1, 2, 3, 4, 5)  -- Focus on first 5 customers
ORDER BY o_custkey, o_orderdate;

-- Example 9: FIRST_VALUE and LAST_VALUE
-- Show first and last order amounts within each customer's order history
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    FIRST_VALUE(o_totalprice) OVER (
        PARTITION BY o_custkey 
        ORDER BY o_orderdate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_order_amount,
    LAST_VALUE(o_totalprice) OVER (
        PARTITION BY o_custkey 
        ORDER BY o_orderdate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_amount
FROM orders
WHERE o_custkey IN (1, 2, 3, 4, 5)
ORDER BY o_custkey, o_orderdate;

-- Example 10: Running Totals and Cumulative Calculations
-- Calculate running total of sales for each customer
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    SUM(o_totalprice) OVER (
        PARTITION BY o_custkey 
        ORDER BY o_orderdate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    COUNT(*) OVER (
        PARTITION BY o_custkey 
        ORDER BY o_orderdate 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS order_sequence
FROM orders
WHERE o_custkey IN (1, 2, 3)
ORDER BY o_custkey, o_orderdate;

-- Example 11: MIN and MAX Window Functions
-- Show minimum and maximum order values within each customer's history
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    MIN(o_totalprice) OVER (PARTITION BY o_custkey) AS customer_min_order,
    MAX(o_totalprice) OVER (PARTITION BY o_custkey) AS customer_max_order,
    o_totalprice - MIN(o_totalprice) OVER (PARTITION BY o_custkey) AS above_min,
    MAX(o_totalprice) OVER (PARTITION BY o_custkey) - o_totalprice AS below_max
FROM orders
WHERE o_custkey IN (1, 2, 3, 4, 5)
ORDER BY o_custkey, o_orderdate;

-- Example 12: NTH_VALUE Function
-- Get the 2nd highest order value for each customer
SELECT
    o_custkey,
    o_orderdate,
    o_totalprice,
    NTH_VALUE(o_totalprice, 2) OVER (
        PARTITION BY o_custkey 
        ORDER BY o_totalprice DESC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_highest_order
FROM orders
WHERE o_custkey IN (1, 2, 3, 4, 5)
ORDER BY o_custkey, o_totalprice DESC;

-- Example 13: Statistical Window Functions
-- Calculate percentile ranks and cumulative distribution
SELECT
    o_custkey,
    o_totalprice,
    PERCENT_RANK() OVER (ORDER BY o_totalprice) AS percent_rank,
    CUME_DIST() OVER (ORDER BY o_totalprice) AS cumulative_dist,
    ROUND(PERCENT_RANK() OVER (ORDER BY o_totalprice) * 100, 2) AS percentile
FROM orders
WHERE o_orderdate >= DATE '1995-01-01' 
  AND o_orderdate < DATE '1995-02-01'
ORDER BY o_totalprice DESC
LIMIT 20;

-- Example 14: Quantile Functions (DuckDB Alternative to PERCENTILE_CONT/DISC)
-- Calculate quartiles and percentiles using DuckDB's QUANTILE functions
SELECT DISTINCT
    QUANTILE_CONT(o_totalprice, 0.25) OVER () AS q1_continuous,
    QUANTILE_CONT(o_totalprice, 0.50) OVER () AS median_continuous,
    QUANTILE_CONT(o_totalprice, 0.75) OVER () AS q3_continuous,
    QUANTILE_DISC(o_totalprice, 0.25) OVER () AS q1_discrete,
    QUANTILE_DISC(o_totalprice, 0.50) OVER () AS median_discrete,
    QUANTILE_DISC(o_totalprice, 0.75) OVER () AS q3_discrete
FROM orders
WHERE o_orderdate >= DATE '1995-01-01' 
  AND o_orderdate < DATE '1995-02-01';

-- Example 15: RANGE BETWEEN with Date Values
-- Calculate sales within a 30-day range around each order date
SELECT
    o_orderkey,
    o_orderdate,
    o_totalprice,
    SUM(o_totalprice) OVER (
        ORDER BY o_orderdate 
        RANGE BETWEEN INTERVAL '15' DAY PRECEDING 
                  AND INTERVAL '15' DAY FOLLOWING
    ) AS sales_30day_window,
    COUNT(*) OVER (
        ORDER BY o_orderdate 
        RANGE BETWEEN INTERVAL '15' DAY PRECEDING 
                  AND INTERVAL '15' DAY FOLLOWING
    ) AS orders_30day_window
FROM orders
WHERE o_orderdate >= DATE '1995-01-01' 
  AND o_orderdate <= DATE '1995-01-31'
ORDER BY o_orderdate
LIMIT 20;

-- =====================================================
-- WINDOW FUNCTION BEST PRACTICES
-- =====================================================

-- 1. PARTITION BY: Always consider what logical groups make sense
-- 2. ORDER BY: Required for ranking and frame-based functions
-- 3. Frame Clauses: Use ROWS for physical rows, RANGE for logical ranges
-- 4. Performance: Window functions can be expensive on large datasets
-- 5. QUALIFY: Use to filter based on window function results (DuckDB-specific)

-- COMMON PATTERNS:
-- - Running totals: SUM() OVER (ORDER BY date ROWS UNBOUNDED PRECEDING)
-- - Moving averages: AVG() OVER (ORDER BY date ROWS BETWEEN n PRECEDING AND CURRENT ROW)
-- - Ranking: ROW_NUMBER(), RANK(), DENSE_RANK() OVER (ORDER BY column)
-- - Comparisons: LAG(), LEAD() OVER (PARTITION BY group ORDER BY date)
-- - Percentiles: NTILE(n) OVER (ORDER BY column)