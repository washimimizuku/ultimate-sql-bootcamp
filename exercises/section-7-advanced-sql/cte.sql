-- SQL CTE (Common Table Expressions) Examples - Advanced SQL Concepts
-- This file demonstrates CTEs for complex query organization and recursive operations
-- CTEs provide a way to create temporary named result sets within a query
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-7-advanced-sql/cte.sql
-- ============================================

-- CTE CONCEPTS:
-- - CTEs create temporary named result sets that exist only for the duration of a query
-- - They improve readability by breaking complex queries into logical components
-- - CTEs can be referenced multiple times within the same query
-- - Recursive CTEs can reference themselves for hierarchical or iterative operations
-- - CTEs are often more readable than subqueries or derived tables

-- CTE SYNTAX:
-- WITH cte_name AS (
--     SELECT ...
-- )
-- SELECT ... FROM cte_name;

-- MULTIPLE CTEs:
-- WITH cte1 AS (...),
--      cte2 AS (...)
-- SELECT ... FROM cte1 JOIN cte2 ...;

-- RECURSIVE CTE:
-- WITH RECURSIVE cte_name AS (
--     -- Base case
--     SELECT ...
--     UNION ALL
--     -- Recursive case
--     SELECT ... FROM cte_name WHERE ...
-- )

-- Database exploration
SHOW TABLES;

-- =====================================================
-- BASIC CTE EXAMPLES
-- =====================================================

-- Example 1: Basic CTE - Monthly Customer Analysis
-- Analyze how customer order patterns change by month using CTE
WITH agg_by_user AS (
    SELECT
        c_custkey,
        YEAR(o_orderdate) AS order_year,
        MONTH(o_orderdate) AS order_month,
        COUNT(o_orderkey) AS number_of_orders,
        SUM(o_totalprice) AS value_of_purchase
    FROM customer
    INNER JOIN orders ON c_custkey = o_custkey
    GROUP BY YEAR(o_orderdate), MONTH(o_orderdate), c_custkey
)
SELECT
    order_year,
    order_month,
    AVG(number_of_orders) AS avg_order_number,
    AVG(value_of_purchase) AS avg_order_value
FROM agg_by_user
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Example 2: CTE vs Derived Table (Subquery) Comparison
-- Same logic as Example 1 but using a derived table - notice the difference in readability
SELECT 
    order_year,
    order_month,
    AVG(number_of_orders) AS avg_order_number,
    AVG(value_of_purchase) AS avg_order_value
FROM (
    SELECT 
        c_custkey,
        YEAR(o_orderdate) AS order_year,
        MONTH(o_orderdate) AS order_month,
        COUNT(o_orderkey) AS number_of_orders,
        SUM(o_totalprice) AS value_of_purchase
    FROM customer
    INNER JOIN orders ON c_custkey = o_custkey
    GROUP BY YEAR(o_orderdate), MONTH(o_orderdate), c_custkey
) AS agg_by_user
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Example 3: Basic CTE - Customer Order Summary
-- Calculate customer order statistics using a CTE instead of a subquery
WITH customer_orders AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) AS order_count,
        SUM(o.o_totalprice) AS total_spent,
        AVG(o.o_totalprice) AS avg_order_value
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
)
SELECT 
    c_name,
    c_mktsegment,
    order_count,
    total_spent,
    ROUND(avg_order_value, 2) AS avg_order_value
FROM customer_orders
WHERE order_count > 0
ORDER BY total_spent DESC
LIMIT 20;

-- Example 4: CTE vs Subquery Comparison
-- Same logic as Example 3 but using a subquery (less readable)
SELECT 
    c_name,
    c_mktsegment,
    order_count,
    total_spent,
    ROUND(avg_order_value, 2) AS avg_order_value
FROM (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) AS order_count,
        SUM(o.o_totalprice) AS total_spent,
        AVG(o.o_totalprice) AS avg_order_value
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
) AS customer_orders
WHERE order_count > 0
ORDER BY total_spent DESC
LIMIT 20;

-- =====================================================
-- MULTIPLE CTE EXAMPLES
-- =====================================================

-- Example 5: Multiple CTEs - Monthly Sales Analysis
-- Analyze monthly sales trends with multiple CTEs for better organization
WITH monthly_sales AS (
    SELECT 
        YEAR(o_orderdate) AS order_year,
        MONTH(o_orderdate) AS order_month,
        COUNT(*) AS order_count,
        SUM(o_totalprice) AS monthly_revenue,
        AVG(o_totalprice) AS avg_order_value
    FROM orders
    WHERE o_orderdate >= DATE '1995-01-01' 
      AND o_orderdate < DATE '1997-01-01'
    GROUP BY YEAR(o_orderdate), MONTH(o_orderdate)
),
sales_with_growth AS (
    SELECT 
        order_year,
        order_month,
        order_count,
        monthly_revenue,
        avg_order_value,
        LAG(monthly_revenue) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
        monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY order_year, order_month) AS revenue_change
    FROM monthly_sales
)
SELECT 
    order_year,
    order_month,
    order_count,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(revenue_change, 2) AS revenue_change,
    CASE 
        WHEN prev_month_revenue IS NOT NULL THEN 
            ROUND((revenue_change / prev_month_revenue) * 100, 2)
        ELSE NULL 
    END AS growth_percentage
FROM sales_with_growth
ORDER BY order_year, order_month;

-- =====================================================
-- COMPLEX CTE EXAMPLES
-- =====================================================

-- Example 6: CTE for Complex Filtering - High-Value Customer Analysis
-- Find customers who have both high-value orders and frequent purchases
WITH high_value_orders AS (
    SELECT DISTINCT o_custkey
    FROM orders
    WHERE o_totalprice > (
        SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY o_totalprice)
        FROM orders
    )
),
frequent_customers AS (
    SELECT 
        o_custkey,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY o_custkey
    HAVING COUNT(*) >= 10
),
premium_customers AS (
    SELECT hvo.o_custkey
    FROM high_value_orders hvo
    INNER JOIN frequent_customers fc ON hvo.o_custkey = fc.o_custkey
)
SELECT 
    c.c_name,
    c.c_mktsegment,
    COUNT(o.o_orderkey) AS total_orders,
    SUM(o.o_totalprice) AS total_spent,
    MAX(o.o_totalprice) AS highest_order,
    ROUND(AVG(o.o_totalprice), 2) AS avg_order_value
FROM premium_customers pc
INNER JOIN customer c ON pc.o_custkey = c.c_custkey
INNER JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
ORDER BY total_spent DESC;

-- =====================================================
-- RECURSIVE CTE EXAMPLES
-- =====================================================

-- Example 7: Recursive CTE - Hierarchical Data (Simulated)
-- Create a simple hierarchy and traverse it recursively
WITH RECURSIVE number_sequence AS (
    -- Base case: start with 1
    SELECT 1 AS n, 1 AS factorial
    
    UNION ALL
    
    -- Recursive case: calculate factorial up to 10
    SELECT 
        n + 1,
        (n + 1) * factorial
    FROM number_sequence
    WHERE n < 10
)
SELECT 
    n AS number,
    factorial
FROM number_sequence
ORDER BY n;

-- Example 8: Recursive CTE - Date Series Generation
-- Generate a series of dates using recursive CTE
WITH RECURSIVE date_series AS (
    -- Base case: start date
    SELECT DATE '1995-01-01' AS date_value
    
    UNION ALL
    
    -- Recursive case: add one day until end date
    SELECT date_value + INTERVAL '1' DAY
    FROM date_series
    WHERE date_value < DATE '1995-01-31'
),
daily_sales AS (
    SELECT 
        ds.date_value,
        COALESCE(SUM(o.o_totalprice), 0) AS daily_revenue,
        COUNT(o.o_orderkey) AS order_count
    FROM date_series ds
    LEFT JOIN orders o ON ds.date_value = o.o_orderdate
    GROUP BY ds.date_value
)
SELECT 
    date_value,
    daily_revenue,
    order_count,
    SUM(daily_revenue) OVER (ORDER BY date_value ROWS UNBOUNDED PRECEDING) AS running_total
FROM daily_sales
ORDER BY date_value;

-- Example 9: Recursive CTE - Employee Hierarchy Traversal
-- Create a realistic employee hierarchy and traverse it to show organizational structure

-- Setup: Create employee hierarchy table
CREATE TEMPORARY TABLE employees AS
SELECT * FROM (
    VALUES 
        (1, 'Alice Johnson', 'CEO', NULL),
        (2, 'Bob Smith', 'CTO', 1),
        (3, 'Carol Davis', 'CFO', 1),
        (4, 'David Wilson', 'VP Engineering', 2),
        (5, 'Eve Brown', 'VP Product', 2),
        (6, 'Frank Miller', 'Senior Developer', 4),
        (7, 'Grace Lee', 'Senior Developer', 4),
        (8, 'Henry Taylor', 'Product Manager', 5),
        (9, 'Ivy Chen', 'Junior Developer', 6),
        (10, 'Jack Anderson', 'Junior Developer', 7),
        (11, 'Kate Williams', 'Accountant', 3),
        (12, 'Liam Garcia', 'Financial Analyst', 3)
) AS t(employee_id, employee_name, job_title, manager_id);

-- Recursive CTE: Add manager name to each employee record
WITH RECURSIVE employee_with_manager AS (
    -- Base case: Employees without managers (top level)
    SELECT 
        employee_id,
        employee_name,
        job_title,
        manager_id,
        'No Manager' AS manager_name
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: Employees with managers
    SELECT 
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.manager_id,
        ewm.employee_name AS manager_name
    FROM employees e
    INNER JOIN employee_with_manager ewm ON e.manager_id = ewm.employee_id
)
SELECT 
    employee_id,
    employee_name,
    job_title,
    manager_id,
    manager_name
FROM employee_with_manager
ORDER BY employee_id;

-- Recursive CTE to build organizational hierarchy with levels and paths
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: Top-level managers (no manager)
    SELECT 
        employee_id,
        employee_name,
        job_title,
        manager_id,
        0 AS level,
        employee_name AS hierarchy_path,
        CAST(employee_id AS VARCHAR) AS id_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: Employees with managers
    SELECT 
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.manager_id,
        eh.level + 1,
        eh.hierarchy_path || ' -> ' || e.employee_name AS hierarchy_path,
        eh.id_path || ',' || CAST(e.employee_id AS VARCHAR) AS id_path
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
    employee_id,
    REPEAT('  ', level) || employee_name AS indented_name,
    job_title,
    level,
    hierarchy_path,
    manager_id
FROM employee_hierarchy
ORDER BY id_path;

-- Alternative: Count subordinates for each employee using recursive CTE
WITH RECURSIVE subordinate_count AS (
    -- Base case: Start with each employee and their direct reports
    SELECT 
        e1.employee_id,
        e1.employee_name,
        e1.job_title,
        e2.employee_id AS subordinate_id
    FROM employees e1
    LEFT JOIN employees e2 ON e1.employee_id = e2.manager_id
    
    UNION ALL
    
    -- Recursive case: Find subordinates of subordinates
    SELECT 
        sc.employee_id,
        sc.employee_name,
        sc.job_title,
        e.employee_id AS subordinate_id
    FROM subordinate_count sc
    INNER JOIN employees e ON sc.subordinate_id = e.manager_id
    WHERE sc.subordinate_id IS NOT NULL
)
SELECT 
    employee_name,
    job_title,
    COUNT(subordinate_id) AS total_subordinates
FROM subordinate_count
GROUP BY employee_id, employee_name, job_title
ORDER BY total_subordinates DESC;

-- Cleanup: Remove the temporary table
DROP TABLE employees;

-- =====================================================
-- ADVANCED CTE EXAMPLES
-- =====================================================

-- Example 10: CTE for Data Transformation - Pivot-like Operation
-- Transform order priority data into a more analytical format
WITH priority_stats AS (
    SELECT 
        c.c_mktsegment,
        o.o_orderpriority,
        COUNT(*) AS order_count,
        SUM(o.o_totalprice) AS total_revenue
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE o.o_orderdate >= DATE '1995-01-01' 
      AND o.o_orderdate < DATE '1996-01-01'
    GROUP BY c.c_mktsegment, o.o_orderpriority
),
segment_totals AS (
    SELECT 
        c_mktsegment,
        SUM(order_count) AS total_orders,
        SUM(total_revenue) AS total_segment_revenue
    FROM priority_stats
    GROUP BY c_mktsegment
)
SELECT 
    ps.c_mktsegment,
    ps.o_orderpriority,
    ps.order_count,
    ps.total_revenue,
    ROUND((ps.order_count::FLOAT / st.total_orders) * 100, 2) AS pct_of_segment_orders,
    ROUND((ps.total_revenue / st.total_segment_revenue) * 100, 2) AS pct_of_segment_revenue
FROM priority_stats ps
INNER JOIN segment_totals st ON ps.c_mktsegment = st.c_mktsegment
ORDER BY ps.c_mktsegment, ps.total_revenue DESC;

-- Example 11: CTE for Window Function Preparation
-- Prepare data for complex window function analysis
WITH customer_monthly_spend AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        YEAR(o.o_orderdate) AS order_year,
        MONTH(o.o_orderdate) AS order_month,
        SUM(o.o_totalprice) AS monthly_spend,
        COUNT(o.o_orderkey) AS monthly_orders
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE o.o_orderdate >= DATE '1995-01-01' 
      AND o.o_orderdate < DATE '1996-01-01'
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment, 
             YEAR(o.o_orderdate), MONTH(o.o_orderdate)
),
customer_trends AS (
    SELECT 
        c_custkey,
        c_name,
        c_mktsegment,
        order_year,
        order_month,
        monthly_spend,
        monthly_orders,
        AVG(monthly_spend) OVER (
            PARTITION BY c_custkey 
            ORDER BY order_year, order_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS three_month_avg_spend,
        LAG(monthly_spend, 1) OVER (
            PARTITION BY c_custkey 
            ORDER BY order_year, order_month
        ) AS prev_month_spend
    FROM customer_monthly_spend
)
SELECT 
    c_name,
    c_mktsegment,
    order_year,
    order_month,
    ROUND(monthly_spend, 2) AS monthly_spend,
    monthly_orders,
    ROUND(three_month_avg_spend, 2) AS three_month_avg,
    CASE 
        WHEN prev_month_spend IS NOT NULL THEN
            ROUND(((monthly_spend - prev_month_spend) / prev_month_spend) * 100, 2)
        ELSE NULL
    END AS month_over_month_growth
FROM customer_trends
WHERE c_custkey IN (1, 2, 3, 4, 5)  -- Focus on first 5 customers
ORDER BY c_custkey, order_year, order_month;

-- =====================================================
-- CTE BEST PRACTICES AND PATTERNS
-- =====================================================

-- Example 12: CTE for Code Reusability - Referenced Multiple Times
-- Use the same CTE in multiple parts of the query
WITH active_customers AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) AS order_count,
        SUM(o.o_totalprice) AS total_spent
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE o.o_orderdate >= DATE '1995-01-01'
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
    HAVING COUNT(o.o_orderkey) >= 3
)
SELECT 
    'Summary' AS report_type,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_customer_value,
    NULL AS customer_name,
    NULL AS segment
FROM active_customers

UNION ALL

SELECT 
    'Detail' AS report_type,
    NULL AS customer_count,
    total_spent AS total_revenue,
    NULL AS avg_customer_value,
    c_name AS customer_name,
    c_mktsegment AS segment
FROM active_customers
WHERE total_spent > (SELECT AVG(total_spent) FROM active_customers)
ORDER BY report_type, total_revenue DESC;

-- =====================================================
-- CTE PERFORMANCE CONSIDERATIONS
-- =====================================================

-- CTEs vs Subqueries vs Temporary Tables:
-- 1. CTEs: Good for readability, may be materialized or inlined by optimizer
-- 2. Subqueries: Often inlined by optimizer, can be less readable
-- 3. Temporary Tables: Explicitly materialized, good for complex reused logic

-- When to use CTEs:
-- ✓ Complex queries that benefit from logical breakdown
-- ✓ When the same subquery logic is used multiple times
-- ✓ Recursive operations (hierarchical data, series generation)
-- ✓ Improving query readability and maintainability

-- When to avoid CTEs:
-- ✗ Simple queries where a subquery is clearer
-- ✗ When performance testing shows subqueries are faster
-- ✗ Very large result sets that might benefit from explicit temp tables