-- REPORTING PATTERNS - Business Intelligence & Analytics
-- This file demonstrates advanced reporting techniques, pivot operations, and dashboard patterns
-- using the TPC-H database for realistic business reporting scenarios
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-9-business-intelligence/reporting-patterns.sql
-- ============================================

-- REPORTING CONCEPTS:
-- - Pivot Tables: Transform rows to columns for cross-tabulation analysis
-- - Cross-Tab Reports: Matrix-style reports showing relationships between dimensions
-- - Comparative Analysis: Side-by-side comparisons across time periods or segments
-- - Executive Dashboards: High-level KPI summaries for leadership decision-making
-- - Drill-Down Reports: Hierarchical reports that allow detailed investigation
-- - Exception Reports: Highlighting outliers and anomalies that need attention

-- BUSINESS CONTEXT:
-- The TPC-H database provides rich data for creating realistic business reports:
-- - Sales performance across regions, nations, and customer segments
-- - Product performance by supplier and category
-- - Time-based comparisons and trend analysis
-- - Customer behavior and profitability analysis
-- - Operational efficiency and exception reporting

-- ============================================
-- PIVOT TABLE OPERATIONS
-- ============================================

-- WHAT IT IS: Pivot tables transform row-based data into column-based summaries,
-- creating cross-tabulation reports that show relationships between dimensions.
--
-- WHY IT MATTERS: Pivot operations enable:
-- - Quick summarization of large datasets
-- - Easy comparison across multiple dimensions
-- - Matrix-style reports familiar to business users
-- - Flexible data exploration and analysis
--
-- KEY TECHNIQUES: CASE statements for pivoting, conditional aggregation, dynamic columns
-- BENCHMARK: Pivot reports should summarize data by 80-90% while maintaining key insights

-- Example 1: Customer Segment vs Region Performance Matrix
-- Business Question: "How does revenue perform across customer segments and regions?"

SELECT 
    'Customer Segment vs Region Revenue Matrix' as report_title;

WITH segment_region_matrix AS (
    SELECT 
        c.c_mktsegment,
        -- Pivot regions into columns using conditional aggregation
        SUM(CASE WHEN r.r_name = 'AFRICA' THEN o.o_totalprice ELSE 0 END) as africa_revenue,
        SUM(CASE WHEN r.r_name = 'AMERICA' THEN o.o_totalprice ELSE 0 END) as america_revenue,
        SUM(CASE WHEN r.r_name = 'ASIA' THEN o.o_totalprice ELSE 0 END) as asia_revenue,
        SUM(CASE WHEN r.r_name = 'EUROPE' THEN o.o_totalprice ELSE 0 END) as europe_revenue,
        SUM(CASE WHEN r.r_name = 'MIDDLE EAST' THEN o.o_totalprice ELSE 0 END) as middle_east_revenue,
        SUM(o.o_totalprice) as total_revenue
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY c.c_mktsegment
)
SELECT 
    c_mktsegment as customer_segment,
    ROUND(africa_revenue, 2) as africa,
    ROUND(america_revenue, 2) as america,
    ROUND(asia_revenue, 2) as asia,
    ROUND(europe_revenue, 2) as europe,
    ROUND(middle_east_revenue, 2) as middle_east,
    ROUND(total_revenue, 2) as total,
    -- Percentage distribution
    ROUND(africa_revenue * 100.0 / total_revenue, 1) as africa_pct,
    ROUND(america_revenue * 100.0 / total_revenue, 1) as america_pct,
    ROUND(asia_revenue * 100.0 / total_revenue, 1) as asia_pct,
    ROUND(europe_revenue * 100.0 / total_revenue, 1) as europe_pct,
    ROUND(middle_east_revenue * 100.0 / total_revenue, 1) as middle_east_pct
FROM segment_region_matrix
ORDER BY total_revenue DESC;

-- Example 2: Monthly Sales Pivot by Quarter
-- Business Question: "Show monthly sales performance in a quarterly comparison format"

WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(QUARTER FROM o_orderdate) as order_quarter,
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        SUM(o_totalprice) as monthly_revenue,
        COUNT(o_orderkey) as monthly_orders
    FROM orders
    WHERE EXTRACT(YEAR FROM o_orderdate) = 1995
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(QUARTER FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)
)
SELECT 
    order_quarter,
    -- Pivot months within each quarter
    ROUND(SUM(CASE WHEN order_month IN (1,4,7,10) THEN monthly_revenue ELSE 0 END), 2) as month_1_revenue,
    ROUND(SUM(CASE WHEN order_month IN (2,5,8,11) THEN monthly_revenue ELSE 0 END), 2) as month_2_revenue,
    ROUND(SUM(CASE WHEN order_month IN (3,6,9,12) THEN monthly_revenue ELSE 0 END), 2) as month_3_revenue,
    ROUND(SUM(monthly_revenue), 2) as quarter_total,
    -- Order counts
    SUM(CASE WHEN order_month IN (1,4,7,10) THEN monthly_orders ELSE 0 END) as month_1_orders,
    SUM(CASE WHEN order_month IN (2,5,8,11) THEN monthly_orders ELSE 0 END) as month_2_orders,
    SUM(CASE WHEN order_month IN (3,6,9,12) THEN monthly_orders ELSE 0 END) as month_3_orders
FROM monthly_sales
GROUP BY order_quarter
ORDER BY order_quarter;

-- ============================================
-- COMPARATIVE ANALYSIS REPORTS
-- ============================================

-- WHAT IT IS: Comparative analysis reports show side-by-side comparisons of metrics
-- across different time periods, segments, or categories to identify trends and differences.
--
-- WHY IT MATTERS: Comparative reports help:
-- - Identify performance improvements or declines
-- - Benchmark against previous periods or competitors
-- - Highlight successful strategies that can be replicated
-- - Spot anomalies that require investigation
--
-- KEY TECHNIQUES: Period-over-period comparisons, variance analysis, ranking
-- BENCHMARK: Focus on metrics with >10% variance for actionable insights

-- Example 3: Year-over-Year Performance Comparison
-- Business Question: "How does this year compare to last year across key metrics?"

WITH yearly_comparison AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        COUNT(DISTINCT o_custkey) as unique_customers,
        COUNT(o_orderkey) as total_orders,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value,
        SUM(o_totalprice) / COUNT(DISTINCT o_custkey) as revenue_per_customer
    FROM orders
    WHERE EXTRACT(YEAR FROM o_orderdate) IN (1994, 1995)
    GROUP BY EXTRACT(YEAR FROM o_orderdate)
),
comparison_analysis AS (
    SELECT 
        MAX(CASE WHEN order_year = 1994 THEN unique_customers END) as customers_1994,
        MAX(CASE WHEN order_year = 1995 THEN unique_customers END) as customers_1995,
        MAX(CASE WHEN order_year = 1994 THEN total_orders END) as orders_1994,
        MAX(CASE WHEN order_year = 1995 THEN total_orders END) as orders_1995,
        MAX(CASE WHEN order_year = 1994 THEN total_revenue END) as revenue_1994,
        MAX(CASE WHEN order_year = 1995 THEN total_revenue END) as revenue_1995,
        MAX(CASE WHEN order_year = 1994 THEN avg_order_value END) as aov_1994,
        MAX(CASE WHEN order_year = 1995 THEN avg_order_value END) as aov_1995,
        MAX(CASE WHEN order_year = 1994 THEN revenue_per_customer END) as rpc_1994,
        MAX(CASE WHEN order_year = 1995 THEN revenue_per_customer END) as rpc_1995
    FROM yearly_comparison
)
SELECT 
    'Customers' as metric,
    customers_1994 as year_1994,
    customers_1995 as year_1995,
    customers_1995 - customers_1994 as absolute_change,
    ROUND((customers_1995 - customers_1994) * 100.0 / customers_1994, 2) as percent_change
FROM comparison_analysis

UNION ALL

SELECT 
    'Orders',
    orders_1994,
    orders_1995,
    orders_1995 - orders_1994,
    ROUND((orders_1995 - orders_1994) * 100.0 / orders_1994, 2)
FROM comparison_analysis

UNION ALL

SELECT 
    'Revenue',
    ROUND(revenue_1994, 2),
    ROUND(revenue_1995, 2),
    ROUND(revenue_1995 - revenue_1994, 2),
    ROUND((revenue_1995 - revenue_1994) * 100.0 / revenue_1994, 2)
FROM comparison_analysis

UNION ALL

SELECT 
    'Avg Order Value',
    ROUND(aov_1994, 2),
    ROUND(aov_1995, 2),
    ROUND(aov_1995 - aov_1994, 2),
    ROUND((aov_1995 - aov_1994) * 100.0 / aov_1994, 2)
FROM comparison_analysis

UNION ALL

SELECT 
    'Revenue per Customer',
    ROUND(rpc_1994, 2),
    ROUND(rpc_1995, 2),
    ROUND(rpc_1995 - rpc_1994, 2),
    ROUND((rpc_1995 - rpc_1994) * 100.0 / rpc_1994, 2)
FROM comparison_analysis;

-- Example 4: Top vs Bottom Performer Analysis
-- Business Question: "How do our top-performing regions compare to bottom performers?"

WITH region_performance AS (
    SELECT 
        r.r_name as region,
        COUNT(DISTINCT c.c_custkey) as unique_customers,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as revenue_per_customer,
        ROW_NUMBER() OVER (ORDER BY SUM(o.o_totalprice) DESC) as revenue_rank
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY r.r_name
),
top_bottom_analysis AS (
    SELECT 
        CASE WHEN revenue_rank <= 2 THEN 'Top Performers' ELSE 'Bottom Performers' END as performance_tier,
        SUM(unique_customers) as total_customers,
        SUM(total_orders) as total_orders,
        SUM(total_revenue) as total_revenue,
        AVG(avg_order_value) as avg_order_value,
        AVG(revenue_per_customer) as avg_revenue_per_customer
    FROM region_performance
    WHERE revenue_rank <= 2 OR revenue_rank >= 4  -- Top 2 and Bottom 2
    GROUP BY CASE WHEN revenue_rank <= 2 THEN 'Top Performers' ELSE 'Bottom Performers' END
)
SELECT 
    performance_tier,
    total_customers,
    total_orders,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(avg_revenue_per_customer, 2) as avg_revenue_per_customer,
    -- Performance ratios
    ROUND(total_revenue / total_customers, 2) as revenue_per_customer,
    ROUND(total_orders::DECIMAL / total_customers, 2) as orders_per_customer
FROM top_bottom_analysis
ORDER BY total_revenue DESC;

-- ============================================
-- EXECUTIVE DASHBOARD REPORTS
-- ============================================

-- WHAT IT IS: Executive dashboards provide high-level KPI summaries designed for
-- leadership decision-making, focusing on the most critical business metrics.
--
-- WHY IT MATTERS: Executive dashboards enable:
-- - Quick assessment of overall business health
-- - Identification of areas requiring immediate attention
-- - Data-driven strategic decision making
-- - Consistent communication of performance across leadership
--
-- KEY PRINCIPLES: Focus on actionable metrics, use clear benchmarks, highlight exceptions
-- BENCHMARK: Dashboards should answer 80% of executive questions in under 30 seconds

-- Example 5: Executive Summary Dashboard
-- Business Question: "What's our overall business performance at a glance?"

WITH executive_metrics AS (
    SELECT 
        -- Customer Metrics
        COUNT(DISTINCT c.c_custkey) as total_customers,
        COUNT(DISTINCT CASE WHEN o.o_orderdate >= '1995-07-01' THEN c.c_custkey END) as active_customers_h2,
        COUNT(DISTINCT CASE WHEN o.o_orderdate < '1995-07-01' THEN c.c_custkey END) as active_customers_h1,
        
        -- Revenue Metrics
        SUM(o.o_totalprice) as total_revenue,
        SUM(CASE WHEN o.o_orderdate >= '1995-07-01' THEN o.o_totalprice ELSE 0 END) as revenue_h2,
        SUM(CASE WHEN o.o_orderdate < '1995-07-01' THEN o.o_totalprice ELSE 0 END) as revenue_h1,
        
        -- Order Metrics
        COUNT(o.o_orderkey) as total_orders,
        COUNT(CASE WHEN o.o_orderdate >= '1995-07-01' THEN 1 END) as orders_h2,
        COUNT(CASE WHEN o.o_orderdate < '1995-07-01' THEN 1 END) as orders_h1,
        
        -- Efficiency Metrics
        AVG(o.o_totalprice) as avg_order_value,
        SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as avg_customer_value
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE EXTRACT(YEAR FROM o.o_orderdate) = 1995
)
SELECT 
    'BUSINESS OVERVIEW' as section,
    'Total Revenue' as metric,
    '$' || ROUND(total_revenue, 0) as value,
    CASE 
        WHEN revenue_h1 > 0 THEN ROUND((revenue_h2 - revenue_h1) * 100.0 / revenue_h1, 1) || '% H2 vs H1'
        ELSE 'N/A'
    END as trend
FROM executive_metrics

UNION ALL

SELECT 
    'BUSINESS OVERVIEW',
    'Total Customers',
    CAST(total_customers AS VARCHAR),
    CASE 
        WHEN active_customers_h1 > 0 THEN ROUND((active_customers_h2 - active_customers_h1) * 100.0 / active_customers_h1, 1) || '% H2 vs H1'
        ELSE 'N/A'
    END
FROM executive_metrics

UNION ALL

SELECT 
    'BUSINESS OVERVIEW',
    'Total Orders',
    CAST(total_orders AS VARCHAR),
    CASE 
        WHEN orders_h1 > 0 THEN ROUND((orders_h2 - orders_h1) * 100.0 / orders_h1, 1) || '% H2 vs H1'
        ELSE 'N/A'
    END
FROM executive_metrics

UNION ALL

SELECT 
    'EFFICIENCY METRICS',
    'Avg Order Value',
    '$' || ROUND(avg_order_value, 2),
    'Target: $150K+'
FROM executive_metrics

UNION ALL

SELECT 
    'EFFICIENCY METRICS',
    'Avg Customer Value',
    '$' || ROUND(avg_customer_value, 2),
    'Target: $750K+'
FROM executive_metrics

UNION ALL

SELECT 
    'EFFICIENCY METRICS',
    'Customer Retention',
    ROUND(active_customers_h2 * 100.0 / total_customers, 1) || '%',
    'Target: 70%+'
FROM executive_metrics

ORDER BY section, metric;

-- Example 6: Regional Performance Scorecard
-- Business Question: "How are our regions performing against targets?"

WITH regional_scorecard AS (
    SELECT 
        r.r_name as region,
        COUNT(DISTINCT c.c_custkey) as customers,
        COUNT(o.o_orderkey) as orders,
        SUM(o.o_totalprice) as revenue,
        AVG(o.o_totalprice) as avg_order_value,
        SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as revenue_per_customer,
        -- Performance scoring (1-5 scale)
        CASE 
            WHEN SUM(o.o_totalprice) >= 2000000 THEN 5
            WHEN SUM(o.o_totalprice) >= 1500000 THEN 4
            WHEN SUM(o.o_totalprice) >= 1000000 THEN 3
            WHEN SUM(o.o_totalprice) >= 500000 THEN 2
            ELSE 1
        END as revenue_score,
        CASE 
            WHEN COUNT(DISTINCT c.c_custkey) >= 300 THEN 5
            WHEN COUNT(DISTINCT c.c_custkey) >= 250 THEN 4
            WHEN COUNT(DISTINCT c.c_custkey) >= 200 THEN 3
            WHEN COUNT(DISTINCT c.c_custkey) >= 150 THEN 2
            ELSE 1
        END as customer_score
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY r.r_name
)
SELECT 
    region,
    customers,
    orders,
    ROUND(revenue, 2) as revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(revenue_per_customer, 2) as revenue_per_customer,
    revenue_score,
    customer_score,
    ROUND((revenue_score + customer_score) / 2.0, 1) as overall_score,
    -- Performance rating
    CASE 
        WHEN (revenue_score + customer_score) / 2.0 >= 4.5 THEN 'Excellent'
        WHEN (revenue_score + customer_score) / 2.0 >= 3.5 THEN 'Good'
        WHEN (revenue_score + customer_score) / 2.0 >= 2.5 THEN 'Average'
        WHEN (revenue_score + customer_score) / 2.0 >= 1.5 THEN 'Below Average'
        ELSE 'Poor'
    END as performance_rating
FROM regional_scorecard
ORDER BY overall_score DESC;

-- ============================================
-- DRILL-DOWN REPORTING
-- ============================================

-- WHAT IT IS: Drill-down reports provide hierarchical views that allow users to
-- start with summary data and progressively explore more detailed levels.
--
-- WHY IT MATTERS: Drill-down capabilities enable:
-- - Root cause analysis of performance issues
-- - Progressive disclosure of information complexity
-- - Self-service analytics for business users
-- - Efficient investigation of anomalies and opportunities
--
-- HIERARCHY LEVELS: Region → Nation → Customer → Order → Line Item
-- BENCHMARK: Each drill-down level should provide 3-5x more detail than the previous level

-- Example 7: Hierarchical Sales Drill-Down
-- Business Question: "Show sales performance from region down to individual customers"

-- Level 1: Regional Summary
SELECT 'LEVEL 1: REGIONAL SUMMARY' as drill_level;
SELECT 
    r.r_name as region,
    COUNT(DISTINCT n.n_nationkey) as nations,
    COUNT(DISTINCT c.c_custkey) as customers,
    COUNT(o.o_orderkey) as orders,
    ROUND(SUM(o.o_totalprice), 2) as total_revenue,
    ROUND(AVG(o.o_totalprice), 2) as avg_order_value
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY r.r_name
ORDER BY total_revenue DESC;

-- Level 2: Nation Detail (for top region)
SELECT 'LEVEL 2: NATION DETAIL (AMERICA)' as drill_level;
WITH top_region AS (
    SELECT r.r_regionkey
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
    INNER JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY r.r_regionkey, r.r_name
    ORDER BY SUM(o.o_totalprice) DESC
    LIMIT 1
)
SELECT 
    n.n_name as nation,
    COUNT(DISTINCT c.c_custkey) as customers,
    COUNT(o.o_orderkey) as orders,
    ROUND(SUM(o.o_totalprice), 2) as total_revenue,
    ROUND(AVG(o.o_totalprice), 2) as avg_order_value,
    ROUND(SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey), 2) as revenue_per_customer
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
INNER JOIN top_region tr ON n.n_regionkey = tr.r_regionkey
WHERE o.o_orderdate >= '1995-01-01'
GROUP BY n.n_name
ORDER BY total_revenue DESC;

-- Level 3: Customer Detail (for top nation in top region)
SELECT 'LEVEL 3: TOP CUSTOMERS (UNITED STATES)' as drill_level;
SELECT 
    c.c_name as customer_name,
    c.c_mktsegment as segment,
    COUNT(o.o_orderkey) as orders,
    ROUND(SUM(o.o_totalprice), 2) as total_revenue,
    ROUND(AVG(o.o_totalprice), 2) as avg_order_value,
    MIN(o.o_orderdate) as first_order,
    MAX(o.o_orderdate) as last_order
FROM orders o
INNER JOIN customer c ON o.o_custkey = c.c_custkey
INNER JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'UNITED STATES'
  AND o.o_orderdate >= '1995-01-01'
GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
ORDER BY total_revenue DESC
LIMIT 10;

-- ============================================
-- EXCEPTION REPORTING
-- ============================================

-- WHAT IT IS: Exception reports highlight outliers, anomalies, and items that deviate
-- significantly from normal patterns or expected values.
--
-- WHY IT MATTERS: Exception reporting helps:
-- - Focus attention on items requiring immediate action
-- - Identify potential problems before they become critical
-- - Discover unexpected opportunities or high performers
-- - Improve operational efficiency through targeted interventions
--
-- KEY TECHNIQUES: Statistical outliers, threshold-based alerts, variance analysis
-- BENCHMARK: Exception reports should flag 5-10% of data points for investigation

-- Example 8: Revenue Anomaly Detection
-- Business Question: "Which orders or customers show unusual patterns that need investigation?"

WITH revenue_statistics AS (
    SELECT 
        AVG(o_totalprice) as avg_order_value,
        STDDEV(o_totalprice) as stddev_order_value,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY o_totalprice) as p95_order_value,
        PERCENTILE_CONT(0.05) WITHIN GROUP (ORDER BY o_totalprice) as p5_order_value
    FROM orders
    WHERE o_orderdate >= '1995-01-01'
),
order_anomalies AS (
    SELECT 
        o.o_orderkey,
        o.o_custkey,
        c.c_name,
        o.o_orderdate,
        o.o_totalprice,
        rs.avg_order_value,
        rs.stddev_order_value,
        -- Z-score calculation
        (o.o_totalprice - rs.avg_order_value) / rs.stddev_order_value as z_score,
        -- Anomaly classification
        CASE 
            WHEN o.o_totalprice > rs.p95_order_value THEN 'High Value Outlier'
            WHEN o.o_totalprice < rs.p5_order_value THEN 'Low Value Outlier'
            WHEN ABS((o.o_totalprice - rs.avg_order_value) / rs.stddev_order_value) > 2 THEN 'Statistical Outlier'
            ELSE 'Normal'
        END as anomaly_type
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    CROSS JOIN revenue_statistics rs
    WHERE o.o_orderdate >= '1995-01-01'
)
SELECT 
    anomaly_type,
    COUNT(*) as anomaly_count,
    ROUND(AVG(o_totalprice), 2) as avg_anomaly_value,
    ROUND(MIN(o_totalprice), 2) as min_value,
    ROUND(MAX(o_totalprice), 2) as max_value,
    ROUND(AVG(ABS(z_score)), 2) as avg_z_score
FROM order_anomalies
WHERE anomaly_type != 'Normal'
GROUP BY anomaly_type
ORDER BY anomaly_count DESC;

-- Example 9: Customer Behavior Exceptions
-- Business Question: "Which customers show unusual ordering patterns?"

WITH customer_patterns AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days,
        -- Order frequency
        CASE 
            WHEN DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) > 0 
            THEN COUNT(o.o_orderkey)::DECIMAL / (DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) / 30.0)
            ELSE COUNT(o.o_orderkey)
        END as orders_per_month
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    WHERE o.o_orderdate >= '1995-01-01'
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
customer_exceptions AS (
    SELECT 
        *,
        -- Exception flags
        CASE WHEN total_orders >= 15 THEN 'High Frequency Customer' ELSE NULL END as frequency_exception,
        CASE WHEN total_revenue >= 1000000 THEN 'High Value Customer' ELSE NULL END as value_exception,
        CASE WHEN avg_order_value >= 500000 THEN 'Large Order Customer' ELSE NULL END as order_size_exception,
        CASE WHEN orders_per_month >= 3 THEN 'Very Active Customer' ELSE NULL END as activity_exception
    FROM customer_patterns
)
SELECT 
    c_name,
    c_mktsegment,
    total_orders,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(orders_per_month, 2) as orders_per_month,
    -- Combine all exception flags
    COALESCE(frequency_exception, '') ||
    CASE WHEN frequency_exception IS NOT NULL AND value_exception IS NOT NULL THEN ', ' ELSE '' END ||
    COALESCE(value_exception, '') ||
    CASE WHEN (frequency_exception IS NOT NULL OR value_exception IS NOT NULL) AND order_size_exception IS NOT NULL THEN ', ' ELSE '' END ||
    COALESCE(order_size_exception, '') ||
    CASE WHEN (frequency_exception IS NOT NULL OR value_exception IS NOT NULL OR order_size_exception IS NOT NULL) AND activity_exception IS NOT NULL THEN ', ' ELSE '' END ||
    COALESCE(activity_exception, '') as exception_flags
FROM customer_exceptions
WHERE frequency_exception IS NOT NULL 
   OR value_exception IS NOT NULL 
   OR order_size_exception IS NOT NULL 
   OR activity_exception IS NOT NULL
ORDER BY total_revenue DESC;

-- ============================================
-- DYNAMIC REPORTING PATTERNS
-- ============================================

-- WHAT IT IS: Dynamic reporting patterns create flexible reports that can adapt
-- to different parameters, time periods, or business requirements without code changes.
--
-- WHY IT MATTERS: Dynamic reports provide:
-- - Reusable report templates for different scenarios
-- - Self-service capabilities for business users
-- - Consistent formatting across different data slices
-- - Reduced maintenance overhead for report developers
--
-- KEY TECHNIQUES: Parameterized queries, conditional logic, template patterns
-- BENCHMARK: Dynamic reports should handle 80% of similar reporting needs with parameter changes

-- Example 10: Parameterized Performance Report Template
-- Business Question: "Create a flexible template for analyzing any dimension's performance"

-- This example shows how to create a reusable template for different dimensions
-- In practice, parameters would be passed in from a reporting tool or application

WITH report_parameters AS (
    SELECT 
        'c_mktsegment' as dimension_column,
        'Customer Segment' as dimension_name,
        '1995-01-01' as start_date,
        '1995-12-31' as end_date,
        5 as top_n_limit
),
dimension_performance AS (
    SELECT 
        c.c_mktsegment as dimension_value,
        COUNT(DISTINCT c.c_custkey) as unique_customers,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as revenue_per_customer,
        ROW_NUMBER() OVER (ORDER BY SUM(o.o_totalprice) DESC) as performance_rank
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    CROSS JOIN report_parameters rp
    WHERE o.o_orderdate BETWEEN rp.start_date::DATE AND rp.end_date::DATE
    GROUP BY c.c_mktsegment
)
SELECT 
    rp.dimension_name as report_dimension,
    dp.dimension_value,
    dp.performance_rank,
    dp.unique_customers,
    dp.total_orders,
    ROUND(dp.total_revenue, 2) as total_revenue,
    ROUND(dp.avg_order_value, 2) as avg_order_value,
    ROUND(dp.revenue_per_customer, 2) as revenue_per_customer,
    -- Performance indicators
    CASE 
        WHEN dp.performance_rank <= 2 THEN 'Top Performer'
        WHEN dp.performance_rank <= 4 THEN 'Above Average'
        ELSE 'Below Average'
    END as performance_tier,
    -- Market share
    ROUND(dp.total_revenue * 100.0 / SUM(dp.total_revenue) OVER (), 2) as market_share_percent
FROM dimension_performance dp
CROSS JOIN report_parameters rp
WHERE dp.performance_rank <= rp.top_n_limit
ORDER BY dp.performance_rank;

-- ============================================
-- REPORTING BEST PRACTICES SUMMARY
-- ============================================

-- WHAT IT IS: A comprehensive summary of reporting best practices that ensure
-- reports are accurate, actionable, and aligned with business needs.
--
-- WHY IT MATTERS: Following best practices ensures:
-- - Reports provide reliable insights for decision-making
-- - Consistent user experience across different reports
-- - Efficient development and maintenance processes
-- - High adoption rates among business users

-- Example 11: Report Quality Checklist
SELECT 'REPORTING BEST PRACTICES CHECKLIST' as section;

SELECT 
    'Data Quality' as category,
    'Verify data accuracy and completeness' as best_practice,
    'Check for missing values, duplicates, and outliers' as implementation
    
UNION ALL

SELECT 
    'Data Quality',
    'Include data freshness indicators',
    'Show last update time and data coverage period'
    
UNION ALL

SELECT 
    'User Experience',
    'Use clear, descriptive column names',
    'Avoid technical jargon and abbreviations'
    
UNION ALL

SELECT 
    'User Experience',
    'Provide context with benchmarks',
    'Include targets, industry averages, or historical comparisons'
    
UNION ALL

SELECT 
    'Performance',
    'Optimize query performance',
    'Use appropriate indexes, limit result sets, avoid unnecessary joins'
    
UNION ALL

SELECT 
    'Performance',
    'Consider data aggregation levels',
    'Pre-aggregate common queries, use appropriate granularity'
    
UNION ALL

SELECT 
    'Business Value',
    'Focus on actionable metrics',
    'Include only metrics that drive business decisions'
    
UNION ALL

SELECT 
    'Business Value',
    'Highlight exceptions and anomalies',
    'Draw attention to items requiring immediate action'
    
UNION ALL

SELECT 
    'Maintenance',
    'Document report logic and assumptions',
    'Include business rules, calculations, and data sources'
    
UNION ALL

SELECT 
    'Maintenance',
    'Design for reusability',
    'Create templates and parameterized queries for similar reports'

ORDER BY category, best_practice;

-- ============================================
-- REPORTING PATTERNS SUMMARY
-- ============================================

-- 1. PIVOT OPERATIONS:
--    - Use conditional aggregation (CASE WHEN) for cross-tabulation
--    - Consider readability vs. performance trade-offs
--    - Include percentage distributions alongside absolute values

-- 2. COMPARATIVE ANALYSIS:
--    - Always include both absolute and percentage changes
--    - Use consistent time periods for fair comparisons
--    - Highlight significant variances (>10% typically)

-- 3. EXECUTIVE DASHBOARDS:
--    - Focus on 5-7 key metrics maximum
--    - Include trend indicators and benchmarks
--    - Use traffic light colors for quick status assessment

-- 4. DRILL-DOWN REPORTS:
--    - Design clear hierarchical relationships
--    - Maintain consistent metrics across drill levels
--    - Provide navigation breadcrumbs for user orientation

-- 5. EXCEPTION REPORTS:
--    - Use statistical methods (z-scores, percentiles) for objectivity
--    - Set appropriate thresholds based on business context
--    - Include recommended actions for each exception type

-- 6. DYNAMIC REPORTING:
--    - Parameterize common variables (dates, dimensions, thresholds)
--    - Use CTEs for parameter management
--    - Design for reusability across similar use cases

-- These reporting patterns provide the foundation for creating professional,
-- actionable business intelligence reports that drive informed decision-making.