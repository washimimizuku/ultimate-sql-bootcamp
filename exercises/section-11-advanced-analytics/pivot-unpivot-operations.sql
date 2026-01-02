-- PIVOT AND UNPIVOT OPERATIONS - Advanced Analytics with SQL
-- This file demonstrates data reshaping techniques using PIVOT and UNPIVOT operations
-- for cross-tabulation analysis, reporting, and dynamic data transformation
-- ============================================
-- REQUIRED: This file uses TPC-H database
-- Setup TPC-H: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-11-advanced-analytics/pivot-unpivot-operations.sql
-- ============================================

-- PIVOT/UNPIVOT CONCEPTS:
-- - PIVOT: Transforms rows into columns for cross-tabulation analysis
-- - UNPIVOT: Transforms columns into rows for normalization
-- - Cross-tabulation: Creating summary tables with categories as columns
-- - Data Reshaping: Converting between wide and long data formats
-- - Dynamic Pivoting: Creating pivots with variable column sets
-- - Conditional Aggregation: Using CASE statements for manual pivoting

-- BUSINESS CONTEXT:
-- Pivot operations are essential for creating executive dashboards, financial reports,
-- and analytical summaries. They transform normalized data into formats suitable for
-- business users, enabling quick insights and decision-making across multiple dimensions.

-- ============================================
-- MANUAL PIVOT USING CONDITIONAL AGGREGATION
-- ============================================

-- WHAT IT IS: Manual pivoting uses CASE statements and aggregate functions to
-- transform row data into columnar format without native PIVOT syntax.
--
-- WHY IT MATTERS: Manual pivoting provides:
-- - Full control over pivot logic and conditions
-- - Compatibility across all SQL databases
-- - Ability to handle complex aggregation scenarios
-- - Custom formatting and calculation options
--
-- TECHNIQUES: CASE WHEN with SUM/COUNT, conditional aggregation, GROUP BY
-- BENCHMARK: Pivot operations should reduce report generation time by 60-80%

-- Example 1: Customer Orders by Region and Year
-- Business Question: "Show order counts by region as columns for each year"

SELECT 
    EXTRACT(YEAR FROM o.o_orderdate) as order_year,
    
    -- Pivot regions as columns using conditional aggregation
    SUM(CASE WHEN r.r_name = 'AFRICA' THEN 1 ELSE 0 END) as africa_orders,
    SUM(CASE WHEN r.r_name = 'AMERICA' THEN 1 ELSE 0 END) as america_orders,
    SUM(CASE WHEN r.r_name = 'ASIA' THEN 1 ELSE 0 END) as asia_orders,
    SUM(CASE WHEN r.r_name = 'EUROPE' THEN 1 ELSE 0 END) as europe_orders,
    SUM(CASE WHEN r.r_name = 'MIDDLE EAST' THEN 1 ELSE 0 END) as middle_east_orders,
    
    -- Total orders for verification
    COUNT(*) as total_orders,
    
    -- Average order value by region
    ROUND(AVG(CASE WHEN r.r_name = 'AFRICA' THEN o.o_totalprice END), 2) as africa_avg_value,
    ROUND(AVG(CASE WHEN r.r_name = 'AMERICA' THEN o.o_totalprice END), 2) as america_avg_value,
    ROUND(AVG(CASE WHEN r.r_name = 'ASIA' THEN o.o_totalprice END), 2) as asia_avg_value,
    ROUND(AVG(CASE WHEN r.r_name = 'EUROPE' THEN o.o_totalprice END), 2) as europe_avg_value,
    ROUND(AVG(CASE WHEN r.r_name = 'MIDDLE EAST' THEN o.o_totalprice END), 2) as middle_east_avg_value

FROM orders o
JOIN customer c ON o.o_custkey = c.c_custkey
JOIN nation n ON c.c_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE o.o_orderdate >= '1995-01-01' AND o.o_orderdate < '1997-01-01'
GROUP BY EXTRACT(YEAR FROM o.o_orderdate)
ORDER BY order_year;

-- Example 2: Market Segment Analysis Pivot
-- Business Question: "Show customer distribution and spending by market segment and nation"

SELECT 
    n.n_name as nation,
    
    -- Customer counts by market segment
    COUNT(CASE WHEN c.c_mktsegment = 'AUTOMOBILE' THEN 1 END) as automobile_customers,
    COUNT(CASE WHEN c.c_mktsegment = 'BUILDING' THEN 1 END) as building_customers,
    COUNT(CASE WHEN c.c_mktsegment = 'FURNITURE' THEN 1 END) as furniture_customers,
    COUNT(CASE WHEN c.c_mktsegment = 'HOUSEHOLD' THEN 1 END) as household_customers,
    COUNT(CASE WHEN c.c_mktsegment = 'MACHINERY' THEN 1 END) as machinery_customers,
    
    -- Total spending by market segment
    ROUND(SUM(CASE WHEN c.c_mktsegment = 'AUTOMOBILE' THEN COALESCE(order_totals.total_spent, 0) END), 2) as automobile_spending,
    ROUND(SUM(CASE WHEN c.c_mktsegment = 'BUILDING' THEN COALESCE(order_totals.total_spent, 0) END), 2) as building_spending,
    ROUND(SUM(CASE WHEN c.c_mktsegment = 'FURNITURE' THEN COALESCE(order_totals.total_spent, 0) END), 2) as furniture_spending,
    ROUND(SUM(CASE WHEN c.c_mktsegment = 'HOUSEHOLD' THEN COALESCE(order_totals.total_spent, 0) END), 2) as household_spending,
    ROUND(SUM(CASE WHEN c.c_mktsegment = 'MACHINERY' THEN COALESCE(order_totals.total_spent, 0) END), 2) as machinery_spending,
    
    -- Summary metrics
    COUNT(*) as total_customers,
    ROUND(SUM(COALESCE(order_totals.total_spent, 0)), 2) as total_nation_spending

FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
LEFT JOIN (
    SELECT o_custkey, SUM(o_totalprice) as total_spent
    FROM orders
    GROUP BY o_custkey
) order_totals ON c.c_custkey = order_totals.o_custkey
GROUP BY n.n_name
ORDER BY total_nation_spending DESC
LIMIT 10;

-- ============================================
-- CROSS-TABULATION ANALYSIS
-- ============================================

-- WHAT IT IS: Cross-tabulation creates contingency tables showing relationships
-- between two or more categorical variables with counts or percentages.
--
-- WHY IT MATTERS: Cross-tabulation enables:
-- - Quick identification of patterns and correlations
-- - Statistical analysis of categorical relationships
-- - Executive dashboard creation with summary tables
-- - Comparative analysis across multiple dimensions
--
-- ANALYSIS TYPES: Frequency tables, percentage distributions, chi-square preparation
-- BENCHMARK: Cross-tabs should reveal 80%+ of key business patterns at a glance

-- Example 3: Order Status Cross-Tabulation by Priority
-- Business Question: "What's the relationship between order priority and order status?"

SELECT 
    o_orderpriority as order_priority,
    
    -- Order status distribution
    COUNT(CASE WHEN o_orderstatus = 'O' THEN 1 END) as open_orders,
    COUNT(CASE WHEN o_orderstatus = 'F' THEN 1 END) as fulfilled_orders,
    COUNT(CASE WHEN o_orderstatus = 'P' THEN 1 END) as partial_orders,
    
    -- Percentages within each priority level
    ROUND(COUNT(CASE WHEN o_orderstatus = 'O' THEN 1 END) * 100.0 / COUNT(*), 2) as open_pct,
    ROUND(COUNT(CASE WHEN o_orderstatus = 'F' THEN 1 END) * 100.0 / COUNT(*), 2) as fulfilled_pct,
    ROUND(COUNT(CASE WHEN o_orderstatus = 'P' THEN 1 END) * 100.0 / COUNT(*), 2) as partial_pct,
    
    -- Summary metrics
    COUNT(*) as total_orders,
    ROUND(AVG(o_totalprice), 2) as avg_order_value

FROM orders
GROUP BY o_orderpriority
ORDER BY 
    CASE o_orderpriority
        WHEN '1-URGENT' THEN 1
        WHEN '2-HIGH' THEN 2
        WHEN '3-MEDIUM' THEN 3
        WHEN '4-NOT SPECIFIED' THEN 4
        WHEN '5-LOW' THEN 5
        ELSE 6
    END;

-- Example 4: Supplier Performance Cross-Tabulation
-- Business Question: "How do suppliers perform across different part types and nations?"

SELECT 
    n.n_name as supplier_nation,
    
    -- Part type distribution
    COUNT(CASE WHEN p.p_type LIKE '%STEEL%' THEN 1 END) as steel_parts,
    COUNT(CASE WHEN p.p_type LIKE '%BRASS%' THEN 1 END) as brass_parts,
    COUNT(CASE WHEN p.p_type LIKE '%COPPER%' THEN 1 END) as copper_parts,
    COUNT(CASE WHEN p.p_type LIKE '%NICKEL%' THEN 1 END) as nickel_parts,
    COUNT(CASE WHEN p.p_type LIKE '%TIN%' THEN 1 END) as tin_parts,
    
    -- Performance metrics by material
    ROUND(AVG(CASE WHEN p.p_type LIKE '%STEEL%' THEN ps.ps_supplycost END), 2) as steel_avg_cost,
    ROUND(AVG(CASE WHEN p.p_type LIKE '%BRASS%' THEN ps.ps_supplycost END), 2) as brass_avg_cost,
    ROUND(AVG(CASE WHEN p.p_type LIKE '%COPPER%' THEN ps.ps_supplycost END), 2) as copper_avg_cost,
    
    -- Supplier summary
    COUNT(DISTINCT s.s_suppkey) as supplier_count,
    COUNT(DISTINCT p.p_partkey) as unique_parts_supplied,
    ROUND(AVG(ps.ps_supplycost), 2) as overall_avg_cost

FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN partsupp ps ON s.s_suppkey = ps.ps_suppkey
JOIN part p ON ps.ps_partkey = p.p_partkey
GROUP BY n.n_name
HAVING COUNT(DISTINCT p.p_partkey) >= 50  -- Focus on significant suppliers
ORDER BY unique_parts_supplied DESC
LIMIT 15;

-- ============================================
-- DYNAMIC PIVOT SIMULATION
-- ============================================

-- WHAT IT IS: Dynamic pivoting creates pivot tables with variable column sets
-- determined at runtime, simulated through conditional logic and CTEs.
--
-- WHY IT MATTERS: Dynamic pivoting provides:
-- - Flexible reporting that adapts to changing data
-- - Automated dashboard generation
-- - Scalable analytics for varying category counts
-- - Reduced maintenance for evolving business dimensions
--
-- SIMULATION TECHNIQUES: CTEs, conditional aggregation, metadata-driven queries
-- BENCHMARK: Dynamic pivots should handle 95%+ of category variations automatically

-- Example 5: Dynamic Customer Segment Analysis
-- Business Question: "Create a flexible pivot showing metrics by any categorical dimension"

-- First, create a reusable pattern for dynamic-style pivoting
WITH customer_metrics AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        n.n_name as nation,
        r.r_name as region,
        COUNT(o.o_orderkey) as order_count,
        COALESCE(SUM(o.o_totalprice), 0) as total_spent,
        COALESCE(AVG(o.o_totalprice), 0) as avg_order_value,
        
        -- Customer value tier
        CASE 
            WHEN COALESCE(SUM(o.o_totalprice), 0) >= 500000 THEN 'High Value'
            WHEN COALESCE(SUM(o.o_totalprice), 0) >= 200000 THEN 'Medium Value'
            WHEN COALESCE(SUM(o.o_totalprice), 0) >= 50000 THEN 'Low Value'
            ELSE 'Minimal Value'
        END as value_tier
        
    FROM customer c
    JOIN nation n ON c.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment, n.n_name, r.r_name
),

-- Dynamic pivot by region and value tier
region_value_analysis AS (
    SELECT 
        region,
        
        -- Value tier distribution
        COUNT(CASE WHEN value_tier = 'High Value' THEN 1 END) as high_value_customers,
        COUNT(CASE WHEN value_tier = 'Medium Value' THEN 1 END) as medium_value_customers,
        COUNT(CASE WHEN value_tier = 'Low Value' THEN 1 END) as low_value_customers,
        COUNT(CASE WHEN value_tier = 'Minimal Value' THEN 1 END) as minimal_value_customers,
        
        -- Spending by value tier
        SUM(CASE WHEN value_tier = 'High Value' THEN total_spent ELSE 0 END) as high_value_spending,
        SUM(CASE WHEN value_tier = 'Medium Value' THEN total_spent ELSE 0 END) as medium_value_spending,
        SUM(CASE WHEN value_tier = 'Low Value' THEN total_spent ELSE 0 END) as low_value_spending,
        SUM(CASE WHEN value_tier = 'Minimal Value' THEN total_spent ELSE 0 END) as minimal_value_spending,
        
        -- Regional summary
        COUNT(*) as total_customers,
        SUM(total_spent) as total_regional_spending,
        ROUND(AVG(total_spent), 2) as avg_customer_value
        
    FROM customer_metrics
    GROUP BY region
)

SELECT 
    region,
    high_value_customers,
    medium_value_customers,
    low_value_customers,
    minimal_value_customers,
    total_customers,
    
    -- Calculate percentages
    ROUND(high_value_customers * 100.0 / total_customers, 2) as high_value_pct,
    ROUND(medium_value_customers * 100.0 / total_customers, 2) as medium_value_pct,
    
    -- Spending analysis
    ROUND(high_value_spending, 2) as high_value_spending,
    ROUND(medium_value_spending, 2) as medium_value_spending,
    ROUND(total_regional_spending, 2) as total_regional_spending,
    
    -- Value concentration
    ROUND(high_value_spending * 100.0 / total_regional_spending, 2) as high_value_spending_pct
    
FROM region_value_analysis
ORDER BY total_regional_spending DESC;

-- ============================================
-- UNPIVOT OPERATIONS (NORMALIZATION)
-- ============================================

-- WHAT IT IS: Unpivot operations transform columnar data back into normalized
-- row format, converting wide tables into long tables for analysis.
--
-- WHY IT MATTERS: Unpivoting enables:
-- - Data normalization for analytical processing
-- - Time series analysis from cross-sectional data
-- - Machine learning feature preparation
-- - Integration with normalized data models
--
-- TECHNIQUES: UNION ALL, VALUES clause, cross joins with unnest
-- BENCHMARK: Unpivot operations should maintain 100% data integrity

-- Example 6: Unpivot Regional Sales Data
-- Business Question: "Convert regional summary data into normalized format for trend analysis"

-- First create a pivoted summary (simulating existing wide data)
WITH regional_summary AS (
    SELECT 
        EXTRACT(YEAR FROM o.o_orderdate) as year,
        SUM(CASE WHEN r.r_name = 'AFRICA' THEN o.o_totalprice ELSE 0 END) as africa_sales,
        SUM(CASE WHEN r.r_name = 'AMERICA' THEN o.o_totalprice ELSE 0 END) as america_sales,
        SUM(CASE WHEN r.r_name = 'ASIA' THEN o.o_totalprice ELSE 0 END) as asia_sales,
        SUM(CASE WHEN r.r_name = 'EUROPE' THEN o.o_totalprice ELSE 0 END) as europe_sales,
        SUM(CASE WHEN r.r_name = 'MIDDLE EAST' THEN o.o_totalprice ELSE 0 END) as middle_east_sales
    FROM orders o
    JOIN customer c ON o.o_custkey = c.c_custkey
    JOIN nation n ON c.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01' AND o.o_orderdate < '1997-01-01'
    GROUP BY EXTRACT(YEAR FROM o.o_orderdate)
),

-- Now unpivot using UNION ALL
unpivoted_sales AS (
    SELECT year, 'AFRICA' as region, africa_sales as sales_amount FROM regional_summary
    UNION ALL
    SELECT year, 'AMERICA' as region, america_sales as sales_amount FROM regional_summary
    UNION ALL
    SELECT year, 'ASIA' as region, asia_sales as sales_amount FROM regional_summary
    UNION ALL
    SELECT year, 'EUROPE' as region, europe_sales as sales_amount FROM regional_summary
    UNION ALL
    SELECT year, 'MIDDLE EAST' as region, middle_east_sales as sales_amount FROM regional_summary
)

SELECT 
    year,
    region,
    ROUND(sales_amount, 2) as sales_amount,
    
    -- Calculate year-over-year growth
    ROUND(sales_amount - LAG(sales_amount) OVER (PARTITION BY region ORDER BY year), 2) as yoy_change,
    ROUND((sales_amount - LAG(sales_amount) OVER (PARTITION BY region ORDER BY year)) * 100.0 / 
          LAG(sales_amount) OVER (PARTITION BY region ORDER BY year), 2) as yoy_growth_pct,
    
    -- Regional market share
    ROUND(sales_amount * 100.0 / SUM(sales_amount) OVER (PARTITION BY year), 2) as market_share_pct
    
FROM unpivoted_sales
WHERE sales_amount > 0
ORDER BY year, sales_amount DESC;

-- Example 7: Unpivot Customer Segment Metrics
-- Business Question: "Transform customer segment summary into normalized format for analysis"

WITH segment_metrics AS (
    SELECT 
        'Customer Count' as metric_type,
        COUNT(CASE WHEN c_mktsegment = 'AUTOMOBILE' THEN 1 END) as automobile,
        COUNT(CASE WHEN c_mktsegment = 'BUILDING' THEN 1 END) as building,
        COUNT(CASE WHEN c_mktsegment = 'FURNITURE' THEN 1 END) as furniture,
        COUNT(CASE WHEN c_mktsegment = 'HOUSEHOLD' THEN 1 END) as household,
        COUNT(CASE WHEN c_mktsegment = 'MACHINERY' THEN 1 END) as machinery
    FROM customer
    
    UNION ALL
    
    SELECT 
        'Average Balance' as metric_type,
        ROUND(AVG(CASE WHEN c_mktsegment = 'AUTOMOBILE' THEN c_acctbal END), 2) as automobile,
        ROUND(AVG(CASE WHEN c_mktsegment = 'BUILDING' THEN c_acctbal END), 2) as building,
        ROUND(AVG(CASE WHEN c_mktsegment = 'FURNITURE' THEN c_acctbal END), 2) as furniture,
        ROUND(AVG(CASE WHEN c_mktsegment = 'HOUSEHOLD' THEN c_acctbal END), 2) as household,
        ROUND(AVG(CASE WHEN c_mktsegment = 'MACHINERY' THEN c_acctbal END), 2) as machinery
    FROM customer
),

-- Unpivot the segment metrics
unpivoted_segments AS (
    SELECT metric_type, 'AUTOMOBILE' as segment, automobile as metric_value FROM segment_metrics
    UNION ALL
    SELECT metric_type, 'BUILDING' as segment, building as metric_value FROM segment_metrics
    UNION ALL
    SELECT metric_type, 'FURNITURE' as segment, furniture as metric_value FROM segment_metrics
    UNION ALL
    SELECT metric_type, 'HOUSEHOLD' as segment, household as metric_value FROM segment_metrics
    UNION ALL
    SELECT metric_type, 'MACHINERY' as segment, machinery as metric_value FROM segment_metrics
)

SELECT 
    segment,
    metric_type,
    metric_value,
    
    -- Rank segments within each metric
    RANK() OVER (PARTITION BY metric_type ORDER BY metric_value DESC) as segment_rank,
    
    -- Calculate percentage of total for each metric
    ROUND(metric_value * 100.0 / SUM(metric_value) OVER (PARTITION BY metric_type), 2) as pct_of_total
    
FROM unpivoted_segments
WHERE metric_value IS NOT NULL
ORDER BY metric_type, metric_value DESC;

-- ============================================
-- ADVANCED PIVOT PATTERNS
-- ============================================

-- WHAT IT IS: Advanced pivot patterns combine multiple aggregations, time series,
-- and complex business logic in pivot operations for sophisticated analysis.
--
-- WHY IT MATTERS: Advanced patterns enable:
-- - Multi-dimensional business analysis
-- - Complex financial and operational reporting
-- - Executive dashboard creation with rich metrics
-- - Comparative analysis across time and categories

-- Example 8: Multi-Metric Time Series Pivot
-- Business Question: "Show quarterly trends with multiple metrics pivoted by region"

WITH quarterly_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM o.o_orderdate) as year,
        EXTRACT(QUARTER FROM o.o_orderdate) as quarter,
        r.r_name as region,
        COUNT(DISTINCT o.o_orderkey) as order_count,
        COUNT(DISTINCT c.c_custkey) as customer_count,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value
    FROM orders o
    JOIN customer c ON o.o_custkey = c.c_custkey
    JOIN nation n ON c.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE o.o_orderdate >= '1995-01-01' AND o.o_orderdate < '1997-01-01'
    GROUP BY EXTRACT(YEAR FROM o.o_orderdate), EXTRACT(QUARTER FROM o.o_orderdate), r.r_name
)

SELECT 
    year,
    quarter,
    
    -- Revenue by region
    ROUND(SUM(CASE WHEN region = 'AMERICA' THEN total_revenue ELSE 0 END), 2) as america_revenue,
    ROUND(SUM(CASE WHEN region = 'EUROPE' THEN total_revenue ELSE 0 END), 2) as europe_revenue,
    ROUND(SUM(CASE WHEN region = 'ASIA' THEN total_revenue ELSE 0 END), 2) as asia_revenue,
    
    -- Order counts by region
    SUM(CASE WHEN region = 'AMERICA' THEN order_count ELSE 0 END) as america_orders,
    SUM(CASE WHEN region = 'EUROPE' THEN order_count ELSE 0 END) as europe_orders,
    SUM(CASE WHEN region = 'ASIA' THEN order_count ELSE 0 END) as asia_orders,
    
    -- Average order values by region
    ROUND(AVG(CASE WHEN region = 'AMERICA' THEN avg_order_value END), 2) as america_aov,
    ROUND(AVG(CASE WHEN region = 'EUROPE' THEN avg_order_value END), 2) as europe_aov,
    ROUND(AVG(CASE WHEN region = 'ASIA' THEN avg_order_value END), 2) as asia_aov,
    
    -- Quarter totals
    ROUND(SUM(total_revenue), 2) as quarter_total_revenue,
    SUM(order_count) as quarter_total_orders
    
FROM quarterly_metrics
GROUP BY year, quarter
ORDER BY year, quarter;

-- ============================================
-- PIVOT PERFORMANCE OPTIMIZATION
-- ============================================

-- WHAT IT IS: Performance optimization for pivot operations focuses on efficient
-- aggregation, indexing strategies, and query structure for large datasets.
--
-- WHY IT MATTERS: Optimization ensures:
-- - Fast response times for interactive dashboards
-- - Scalable reporting for growing data volumes
-- - Efficient resource utilization
-- - Better user experience in analytical applications

-- Example 9: Optimized Pivot with Pre-Aggregation
-- Business Question: "Create an efficient pivot for large-scale customer analysis"

-- Use pre-aggregation for better performance
WITH customer_summary AS (
    SELECT 
        c.c_custkey,
        c.c_mktsegment,
        n.n_name as nation,
        r.r_name as region,
        COUNT(o.o_orderkey) as order_count,
        SUM(o.o_totalprice) as total_spent,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date
    FROM customer c
    LEFT JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN nation n ON c.c_nationkey = n.n_nationkey
    JOIN region r ON n.n_regionkey = r.r_regionkey
    GROUP BY c.c_custkey, c.c_mktsegment, n.n_name, r.r_name
),

-- Efficient pivot using pre-aggregated data
segment_analysis AS (
    SELECT 
        region,
        
        -- Customer counts by segment
        COUNT(CASE WHEN c_mktsegment = 'AUTOMOBILE' THEN 1 END) as auto_customers,
        COUNT(CASE WHEN c_mktsegment = 'BUILDING' THEN 1 END) as building_customers,
        COUNT(CASE WHEN c_mktsegment = 'FURNITURE' THEN 1 END) as furniture_customers,
        COUNT(CASE WHEN c_mktsegment = 'HOUSEHOLD' THEN 1 END) as household_customers,
        COUNT(CASE WHEN c_mktsegment = 'MACHINERY' THEN 1 END) as machinery_customers,
        
        -- Revenue by segment
        SUM(CASE WHEN c_mktsegment = 'AUTOMOBILE' THEN total_spent ELSE 0 END) as auto_revenue,
        SUM(CASE WHEN c_mktsegment = 'BUILDING' THEN total_spent ELSE 0 END) as building_revenue,
        SUM(CASE WHEN c_mktsegment = 'FURNITURE' THEN total_spent ELSE 0 END) as furniture_revenue,
        SUM(CASE WHEN c_mktsegment = 'HOUSEHOLD' THEN total_spent ELSE 0 END) as household_revenue,
        SUM(CASE WHEN c_mktsegment = 'MACHINERY' THEN total_spent ELSE 0 END) as machinery_revenue,
        
        -- Performance metrics
        COUNT(*) as total_customers,
        SUM(total_spent) as total_revenue
        
    FROM customer_summary
    GROUP BY region
)

SELECT 
    region,
    auto_customers,
    building_customers,
    furniture_customers,
    household_customers,
    machinery_customers,
    
    -- Calculate market share percentages
    ROUND(auto_revenue * 100.0 / total_revenue, 2) as auto_revenue_pct,
    ROUND(building_revenue * 100.0 / total_revenue, 2) as building_revenue_pct,
    ROUND(furniture_revenue * 100.0 / total_revenue, 2) as furniture_revenue_pct,
    ROUND(household_revenue * 100.0 / total_revenue, 2) as household_revenue_pct,
    ROUND(machinery_revenue * 100.0 / total_revenue, 2) as machinery_revenue_pct,
    
    total_customers,
    ROUND(total_revenue, 2) as total_revenue
    
FROM segment_analysis
ORDER BY total_revenue DESC;

-- ============================================
-- PIVOT AND UNPIVOT BEST PRACTICES SUMMARY
-- ============================================

-- 1. MANUAL PIVOT TECHNIQUES:
--    - Use CASE WHEN with aggregate functions for maximum control
--    - Include verification columns (totals) to validate pivot accuracy
--    - Consider performance implications of complex CASE statements

-- 2. CROSS-TABULATION ANALYSIS:
--    - Include both counts and percentages for comprehensive analysis
--    - Add summary rows/columns for context and validation
--    - Use appropriate ordering for categorical variables

-- 3. DYNAMIC PIVOT SIMULATION:
--    - Use CTEs to create reusable pivot patterns
--    - Implement metadata-driven approaches for scalability
--    - Consider code generation for truly dynamic scenarios

-- 4. UNPIVOT OPERATIONS:
--    - Use UNION ALL for reliable unpivoting across SQL databases
--    - Maintain data type consistency across unpivoted columns
--    - Include source tracking for data lineage

-- 5. PERFORMANCE OPTIMIZATION:
--    - Pre-aggregate data when possible to reduce pivot complexity
--    - Use appropriate indexes on grouping and pivot columns
--    - Consider materialized views for frequently-used pivots

-- 6. BUSINESS APPLICATIONS:
--    - Design pivots with end-user readability in mind
--    - Include relevant business context and calculations
--    - Provide both absolute values and percentages for analysis

-- These pivot and unpivot patterns enable sophisticated data reshaping
-- for reporting, analysis, and dashboard creation while maintaining
-- performance and readability for business users.