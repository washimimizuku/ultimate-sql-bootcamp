# Ultimate SQL Bootcamp - Cheatsheet

## DDL Operations (Section 2)

```sql
-- Create table
CREATE TABLE my_table (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_date DATE DEFAULT CURRENT_DATE
);

-- Alter table
ALTER TABLE my_table ADD COLUMN email VARCHAR(255);
ALTER TABLE my_table DROP COLUMN email;

-- Drop table
DROP TABLE my_table;
DROP TABLE IF EXISTS my_table;
```

## DML Operations (Section 3)

```sql
-- Insert data
INSERT INTO my_table (id, name) VALUES (1, 'John');
INSERT INTO my_table VALUES (2, 'Jane', '2023-01-01');

-- Update data
UPDATE my_table SET name = 'John Doe' WHERE id = 1;

-- Delete data
DELETE FROM my_table WHERE id = 1;

-- Truncate (remove all data)
TRUNCATE TABLE my_table;
```

## Basic Queries (Section 4)

```sql
-- Basic selection
SELECT * FROM customer;
SELECT c_name, c_nationkey FROM customer;
SELECT DISTINCT c_nationkey FROM customer;

-- With aliases
SELECT c_name AS customer_name, c_acctbal AS balance FROM customer;
```

## Filtering (Section 4)

```sql
-- Comparison operators
WHERE c_acctbal > 5000
WHERE c_nationkey = 15
WHERE c_name != 'Customer#000000001'

-- Pattern matching
WHERE c_name LIKE 'Customer%'
WHERE c_phone LIKE '%-555-%'

-- Set operations
WHERE c_nationkey IN (1, 5, 10)
WHERE c_acctbal BETWEEN 1000 AND 5000

-- NULL handling
WHERE c_comment IS NULL
WHERE c_comment IS NOT NULL

-- Logical operators
WHERE c_acctbal > 1000 AND c_nationkey = 15
WHERE c_acctbal < 0 OR c_acctbal > 9000
```

## Sorting & Limiting (Section 4)

```sql
-- Basic sorting
ORDER BY c_acctbal DESC;
ORDER BY c_nationkey ASC, c_acctbal DESC;

-- Limiting results
LIMIT 10;
LIMIT 10 OFFSET 20;  -- Skip first 20, take next 10

-- NULL ordering
ORDER BY c_comment NULLS FIRST;
ORDER BY c_comment NULLS LAST;
```

## Aggregations (Section 4)

```sql
-- Basic aggregates
COUNT(*), COUNT(c_custkey)
SUM(c_acctbal), AVG(c_acctbal)
MIN(c_acctbal), MAX(c_acctbal)

-- Grouping
GROUP BY c_nationkey
GROUP BY c_nationkey, c_mktsegment

-- Filtering groups
HAVING COUNT(*) > 5
HAVING AVG(c_acctbal) > 1000
```

## Common Functions (Section 4)

```sql
-- String functions
UPPER(c_name), LOWER(c_name)
LENGTH(c_name)
SUBSTRING(c_name, 1, 5)
CONCAT(c_name, ' - ', c_phone)

-- Numeric functions
ROUND(c_acctbal, 2)
ABS(c_acctbal)
CEIL(c_acctbal), FLOOR(c_acctbal)

-- Date functions
CURRENT_DATE, CURRENT_TIMESTAMP
EXTRACT(YEAR FROM o_orderdate)
DATE_DIFF('day', o_orderdate, CURRENT_DATE)

-- Conditional functions
CASE WHEN c_acctbal > 5000 THEN 'High' ELSE 'Low' END
COALESCE(c_comment, 'No comment')
NULLIF(c_acctbal, 0)
```

## Joins (Section 5)

```sql
-- Inner joins
SELECT c.c_name, o.o_totalprice
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey;

-- Outer joins
LEFT JOIN orders o ON c.c_custkey = o.o_custkey    -- All customers
RIGHT JOIN customer c ON c.c_custkey = o.o_custkey -- All orders
FULL OUTER JOIN orders o ON c.c_custkey = o.o_custkey -- All records

-- Multi-table joins
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
JOIN lineitem l ON o.o_orderkey = l.l_orderkey;
```

## Subqueries (Section 5)

```sql
-- Scalar subquery
WHERE c_acctbal > (SELECT AVG(c_acctbal) FROM customer);

-- IN subquery
WHERE c_custkey IN (SELECT o_custkey FROM orders WHERE o_totalprice > 100000);

-- EXISTS subquery
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.o_custkey = c.c_custkey);

-- Correlated subquery
WHERE c_acctbal > (SELECT AVG(c_acctbal) FROM customer c2 WHERE c2.c_nationkey = c.c_nationkey);
```

## Set Operators (Section 5)

```sql
-- Union (removes duplicates)
SELECT c_nationkey FROM customer
UNION
SELECT s_nationkey FROM supplier;

-- Union All (keeps duplicates)
SELECT c_nationkey FROM customer
UNION ALL
SELECT s_nationkey FROM supplier;

-- Intersect (common values)
SELECT c_nationkey FROM customer
INTERSECT
SELECT s_nationkey FROM supplier;

-- Except (difference)
SELECT c_nationkey FROM customer
EXCEPT
SELECT s_nationkey FROM supplier;
```

## TPC-H Quick Queries (Section 5)

```sql
-- Top customers by account balance
SELECT c_name, c_acctbal FROM customer ORDER BY c_acctbal DESC LIMIT 5;

-- Orders by priority
SELECT o_orderpriority, COUNT(*) FROM orders GROUP BY o_orderpriority;

-- Customer orders summary
SELECT c.c_name, COUNT(o.o_orderkey) as order_count, SUM(o.o_totalprice) as total_spent
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_name
ORDER BY total_spent DESC NULLS LAST;
```

## Query Performance Tuning (Section 6)

```sql
-- Explain query plans
EXPLAIN SELECT * FROM customer WHERE c_acctbal > 5000;
EXPLAIN ANALYZE SELECT * FROM customer WHERE c_acctbal > 5000;

-- Index creation and optimization
CREATE INDEX idx_customer_acctbal ON customer(c_acctbal);
CREATE INDEX idx_customer_nation_balance ON customer(c_nationkey, c_acctbal);

-- Partial indexes for specific conditions
CREATE INDEX idx_customer_high_balance ON customer(c_custkey) WHERE c_acctbal > 5000;

-- Join optimization
-- Use smaller table as driving table
SELECT c.c_name, o.o_totalprice
FROM customer c
JOIN orders o ON c.c_custkey = o.o_custkey
WHERE c.c_acctbal > 5000;

-- Avoid functions in WHERE clauses
-- Bad: WHERE UPPER(c_name) = 'CUSTOMER'
-- Good: WHERE c_name = 'Customer'
```

## Views (Section 5)

```sql
-- Basic view creation
CREATE VIEW customer_summary AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_acctbal,
    n.n_name as nation
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey;

-- View with aggregations
CREATE VIEW customer_order_stats AS
SELECT 
    c.c_custkey,
    c.c_name,
    COUNT(o.o_orderkey) as total_orders,
    SUM(o.o_totalprice) as lifetime_value
FROM customer c
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey, c.c_name;

-- Views with window functions
CREATE VIEW customer_ranking AS
SELECT 
    c_name,
    c_acctbal,
    ROW_NUMBER() OVER (ORDER BY c_acctbal DESC) as balance_rank,
    NTILE(4) OVER (ORDER BY c_acctbal) as balance_quartile
FROM customer;

-- Update or replace views
CREATE OR REPLACE VIEW customer_summary AS
SELECT c.c_custkey, c.c_name, c.c_acctbal FROM customer;

-- Drop views
DROP VIEW IF EXISTS customer_summary;
```

## Window Functions (Section 7)

```sql
-- Row number and ranking
ROW_NUMBER() OVER (ORDER BY c_acctbal DESC)
RANK() OVER (ORDER BY c_acctbal DESC)
DENSE_RANK() OVER (ORDER BY c_acctbal DESC)

-- Partitioned window functions
ROW_NUMBER() OVER (PARTITION BY c_nationkey ORDER BY c_acctbal DESC)
AVG(c_acctbal) OVER (PARTITION BY c_nationkey)

-- Running totals and moving averages
SUM(o_totalprice) OVER (ORDER BY o_orderdate ROWS UNBOUNDED PRECEDING)
AVG(o_totalprice) OVER (ORDER BY o_orderdate ROWS 2 PRECEDING)

-- Lead and lag
LAG(o_totalprice, 1) OVER (ORDER BY o_orderdate)
LEAD(o_totalprice, 1) OVER (ORDER BY o_orderdate)
```

## CTEs (Section 7)

```sql
-- Basic CTE
WITH high_value_customers AS (
    SELECT c_custkey, c_name, c_acctbal 
    FROM customer 
    WHERE c_acctbal > 5000
)
SELECT * FROM high_value_customers;

-- Recursive CTE
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, name, manager_id, 1 as level
    FROM employees 
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy;
```

## Semi-Structured Data (Section 8)

```sql
-- CSV files
SELECT * FROM 'data/star-wars/csv/characters.csv';
SELECT name, height::INTEGER FROM 'data/star-wars/csv/characters.csv' WHERE height != 'unknown';

-- JSON files
SELECT * FROM 'data/star-wars/json/characters.json';
SELECT name, homeworld.name as planet FROM 'data/star-wars/enriched/characters_enriched.json';

-- Complex JSON traversal
SELECT 
    galaxy.name as galaxy_name,
    sector.name as sector_name
FROM 'data/star-wars/json/complex-hierarchy.json'
UNNEST(galaxy.sectors) as t(sector);

-- Parquet files with nested structures
SELECT 
    name,
    physical_attributes.height,
    UNNEST(films) as film_title
FROM 'data/star-wars/parquet/characters_nested.parquet';
```

## DuckDB Specific

```sql
-- Read CSV files
SELECT * FROM 'data/file.csv';

-- Export results
COPY (SELECT * FROM customer LIMIT 10) TO 'output.csv' (HEADER, DELIMITER ',');

-- Show tables and schema
SHOW TABLES;
DESCRIBE customer;

-- JSON extraction
SELECT json_extract(data, '$.name') FROM json_table;

-- Array operations
SELECT UNNEST(['a', 'b', 'c']) as items;
```
## Business Intelligence & Analytics (Section 9)

### Data Warehousing Patterns
```sql
-- Star Schema Query (Fact + Dimensions)
SELECT 
    r.r_name as region,
    c.c_mktsegment as segment,
    SUM(o.o_totalprice) as total_revenue,
    COUNT(o.o_orderkey) as order_count
FROM orders o                                    -- FACT TABLE
INNER JOIN customer c ON o.o_custkey = c.c_custkey    -- DIMENSION
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey -- DIMENSION
INNER JOIN region r ON n.n_regionkey = r.r_regionkey -- DIMENSION
GROUP BY r.r_name, c.c_mktsegment;

-- Data Mart Creation
CREATE VIEW sales_data_mart AS
SELECT 
    o.o_orderdate,
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    c.c_mktsegment as customer_segment,
    r.r_name as region,
    o.o_totalprice as order_total
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey;
```

### KPI Calculations
```sql
-- Customer Lifetime Value (CLV)
SELECT 
    c.c_custkey,
    COUNT(o.o_orderkey) as total_orders,
    SUM(o.o_totalprice) as total_revenue,
    AVG(o.o_totalprice) as avg_order_value,
    SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as clv
FROM customer c
INNER JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey;

-- Churn Rate Analysis
WITH customer_activity AS (
    SELECT 
        c.c_custkey,
        MAX(o.o_orderdate) as last_order_date,
        CASE WHEN MAX(o.o_orderdate) < '1995-07-01' THEN 1 ELSE 0 END as is_churned
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey
)
SELECT 
    COUNT(*) as total_customers,
    SUM(is_churned) as churned_customers,
    ROUND(SUM(is_churned) * 100.0 / COUNT(*), 2) as churn_rate_percent
FROM customer_activity;

-- Growth Rate Calculation
SELECT 
    EXTRACT(MONTH FROM o_orderdate) as month,
    SUM(o_totalprice) as monthly_revenue,
    LAG(SUM(o_totalprice)) OVER (ORDER BY EXTRACT(MONTH FROM o_orderdate)) as prev_month_revenue,
    ROUND((SUM(o_totalprice) - LAG(SUM(o_totalprice)) OVER (ORDER BY EXTRACT(MONTH FROM o_orderdate))) * 100.0 / 
          LAG(SUM(o_totalprice)) OVER (ORDER BY EXTRACT(MONTH FROM o_orderdate)), 2) as growth_rate_percent
FROM orders
GROUP BY EXTRACT(MONTH FROM o_orderdate);
```

### Time Series Analysis
```sql
-- Moving Averages
SELECT 
    o_orderdate,
    SUM(o_totalprice) as daily_revenue,
    AVG(SUM(o_totalprice)) OVER (
        ORDER BY o_orderdate 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as revenue_7day_avg
FROM orders
GROUP BY o_orderdate
ORDER BY o_orderdate;

-- Seasonality Analysis
SELECT 
    EXTRACT(MONTH FROM o_orderdate) as month,
    SUM(o_totalprice) as monthly_revenue,
    ROUND(SUM(o_totalprice) * 100.0 / SUM(SUM(o_totalprice)) OVER (), 2) as pct_of_annual_revenue
FROM orders
GROUP BY EXTRACT(MONTH FROM o_orderdate)
ORDER BY month;

-- Cohort Analysis
WITH customer_cohorts AS (
    SELECT 
        c.c_custkey,
        DATE_TRUNC('month', MIN(o.o_orderdate)) as acquisition_month
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey
)
SELECT 
    acquisition_month,
    COUNT(*) as cohort_size,
    SUM(o.o_totalprice) as cohort_revenue
FROM customer_cohorts cc
INNER JOIN orders o ON cc.c_custkey = o.o_custkey
GROUP BY acquisition_month;
```

### Reporting Patterns
```sql
-- Pivot Table (Cross-tabulation)
SELECT 
    c.c_mktsegment,
    SUM(CASE WHEN r.r_name = 'AFRICA' THEN o.o_totalprice ELSE 0 END) as africa_revenue,
    SUM(CASE WHEN r.r_name = 'AMERICA' THEN o.o_totalprice ELSE 0 END) as america_revenue,
    SUM(CASE WHEN r.r_name = 'ASIA' THEN o.o_totalprice ELSE 0 END) as asia_revenue,
    SUM(CASE WHEN r.r_name = 'EUROPE' THEN o.o_totalprice ELSE 0 END) as europe_revenue
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey
GROUP BY c.c_mktsegment;

-- Year-over-Year Comparison
WITH yearly_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as year,
        SUM(o_totalprice) as annual_revenue
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate)
)
SELECT 
    year,
    annual_revenue,
    LAG(annual_revenue) OVER (ORDER BY year) as prev_year_revenue,
    ROUND((annual_revenue - LAG(annual_revenue) OVER (ORDER BY year)) * 100.0 / 
          LAG(annual_revenue) OVER (ORDER BY year), 2) as yoy_growth_percent
FROM yearly_metrics;

-- Exception Reporting (Outliers)
WITH revenue_stats AS (
    SELECT 
        AVG(o_totalprice) as avg_revenue,
        STDDEV(o_totalprice) as stddev_revenue
    FROM orders
)
SELECT 
    o.o_orderkey,
    o.o_totalprice,
    CASE 
        WHEN ABS(o.o_totalprice - rs.avg_revenue) > 2 * rs.stddev_revenue THEN 'Outlier'
        ELSE 'Normal'
    END as revenue_classification
FROM orders o
CROSS JOIN revenue_stats rs
WHERE ABS(o.o_totalprice - rs.avg_revenue) > 2 * rs.stddev_revenue;
```