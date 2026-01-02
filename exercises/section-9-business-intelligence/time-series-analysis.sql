-- TIME SERIES ANALYSIS - Business Intelligence & Analytics
-- This file demonstrates time-based analytics, trend analysis, and temporal patterns
-- using the TPC-H database for realistic business scenarios
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-9-business-intelligence/time-series-analysis.sql
-- ============================================

-- TIME SERIES CONCEPTS:
-- - Trend Analysis: Identifying long-term patterns in data over time
-- - Seasonality: Recurring patterns that happen at regular intervals
-- - Moving Averages: Smoothing out short-term fluctuations to see trends
-- - Growth Rates: Measuring change over time (MoM, QoQ, YoY)
-- - Cohort Analysis: Tracking groups of customers over time
-- - Forecasting: Predicting future values based on historical patterns

-- BUSINESS CONTEXT:
-- The TPC-H database contains order data with timestamps, allowing us to:
-- - Track revenue trends over time
-- - Identify seasonal patterns in customer behavior
-- - Analyze customer cohorts by acquisition period
-- - Calculate growth rates and moving averages
-- - Understand business cycles and performance patterns

-- ============================================
-- TREND ANALYSIS
-- ============================================

-- WHAT IT IS: Trend analysis identifies the general direction of data over time,
-- helping businesses understand whether key metrics are improving or declining.
--
-- WHY IT MATTERS: Trends help businesses:
-- - Identify long-term performance patterns
-- - Make informed strategic decisions
-- - Detect early warning signs of problems
-- - Validate the effectiveness of business initiatives
--
-- KEY TECHNIQUES: Moving averages, linear regression, growth rate calculations
-- BENCHMARK: Look for consistent trends over 3+ time periods to avoid noise

-- Example 1: Monthly Revenue Trend Analysis
-- Business Question: "How is our revenue trending over time?"

WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        DATE_TRUNC('month', o_orderdate) as month_date,
        COUNT(o_orderkey) as total_orders,
        COUNT(DISTINCT o_custkey) as unique_customers,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate), DATE_TRUNC('month', o_orderdate)
),
revenue_trends AS (
    SELECT 
        order_year,
        order_month,
        month_date,
        total_orders,
        unique_customers,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        -- Previous month comparison
        LAG(total_revenue) OVER (ORDER BY order_year, order_month) as prev_month_revenue,
        -- 3-month moving average
        ROUND(AVG(total_revenue) OVER (
            ORDER BY order_year, order_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) as revenue_3month_avg,
        -- Running total (cumulative revenue)
        ROUND(SUM(total_revenue) OVER (
            ORDER BY order_year, order_month 
            ROWS UNBOUNDED PRECEDING
        ), 2) as cumulative_revenue
    FROM monthly_revenue
)
SELECT 
    order_year,
    order_month,
    total_orders,
    unique_customers,
    total_revenue,
    avg_order_value,
    revenue_3month_avg,
    cumulative_revenue,
    -- Month-over-month growth
    CASE 
        WHEN prev_month_revenue IS NOT NULL AND prev_month_revenue > 0 
        THEN ROUND((total_revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2)
        ELSE NULL 
    END as mom_growth_percent
FROM revenue_trends
ORDER BY order_year, order_month;

-- Example 2: Quarterly Business Performance Trends
-- Business Question: "What are our quarterly performance trends?"

WITH quarterly_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(QUARTER FROM o_orderdate) as order_quarter,
        COUNT(o_orderkey) as total_orders,
        COUNT(DISTINCT o_custkey) as unique_customers,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value,
        -- Customer metrics
        SUM(o_totalprice) / COUNT(DISTINCT o_custkey) as revenue_per_customer,
        COUNT(o_orderkey)::DECIMAL / COUNT(DISTINCT o_custkey) as orders_per_customer
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(QUARTER FROM o_orderdate)
),
quarterly_trends AS (
    SELECT 
        order_year,
        order_quarter,
        total_orders,
        unique_customers,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        ROUND(revenue_per_customer, 2) as revenue_per_customer,
        ROUND(orders_per_customer, 2) as orders_per_customer,
        -- Previous quarter comparison
        LAG(total_revenue) OVER (ORDER BY order_year, order_quarter) as prev_quarter_revenue,
        LAG(unique_customers) OVER (ORDER BY order_year, order_quarter) as prev_quarter_customers
    FROM quarterly_metrics
)
SELECT 
    order_year,
    order_quarter,
    total_orders,
    unique_customers,
    total_revenue,
    avg_order_value,
    revenue_per_customer,
    orders_per_customer,
    -- Quarter-over-quarter growth
    CASE 
        WHEN prev_quarter_revenue IS NOT NULL AND prev_quarter_revenue > 0 
        THEN ROUND((total_revenue - prev_quarter_revenue) * 100.0 / prev_quarter_revenue, 2)
        ELSE NULL 
    END as qoq_revenue_growth_percent,
    CASE 
        WHEN prev_quarter_customers IS NOT NULL AND prev_quarter_customers > 0 
        THEN ROUND((unique_customers - prev_quarter_customers) * 100.0 / prev_quarter_customers, 2)
        ELSE NULL 
    END as qoq_customer_growth_percent
FROM quarterly_trends
ORDER BY order_year, order_quarter;

-- ============================================
-- SEASONALITY ANALYSIS
-- ============================================

-- WHAT IT IS: Seasonality analysis identifies recurring patterns that happen at regular
-- intervals (daily, weekly, monthly, quarterly, or yearly cycles).
--
-- WHY IT MATTERS: Understanding seasonality helps:
-- - Plan inventory and staffing levels
-- - Optimize marketing spend timing
-- - Set realistic growth expectations
-- - Identify opportunities during peak/off-peak periods
--
-- KEY TECHNIQUES: Period-over-period comparisons, cyclical pattern detection
-- BENCHMARK: Seasonal variations of 20-30% are common in many industries

-- Example 3: Monthly Seasonality Patterns
-- Business Question: "Do we have seasonal patterns in our business?"

WITH monthly_patterns AS (
    SELECT 
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        MONTHNAME(o_orderdate) as month_name,
        COUNT(o_orderkey) as total_orders,
        COUNT(DISTINCT o_custkey) as unique_customers,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value
    FROM orders
    GROUP BY EXTRACT(MONTH FROM o_orderdate), MONTHNAME(o_orderdate)
),
seasonality_analysis AS (
    SELECT 
        order_month,
        month_name,
        total_orders,
        unique_customers,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        -- Calculate percentage of annual totals
        ROUND(total_orders * 100.0 / SUM(total_orders) OVER (), 2) as pct_of_annual_orders,
        ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) as pct_of_annual_revenue,
        -- Compare to average month (8.33% = 100%/12 months)
        ROUND((total_revenue * 100.0 / SUM(total_revenue) OVER ()) - 8.33, 2) as revenue_vs_avg_month
    FROM monthly_patterns
)
SELECT 
    order_month,
    month_name,
    total_orders,
    unique_customers,
    total_revenue,
    avg_order_value,
    pct_of_annual_orders,
    pct_of_annual_revenue,
    revenue_vs_avg_month,
    -- Seasonality classification
    CASE 
        WHEN revenue_vs_avg_month > 2 THEN 'Peak Season'
        WHEN revenue_vs_avg_month > 0 THEN 'Above Average'
        WHEN revenue_vs_avg_month > -2 THEN 'Average'
        ELSE 'Below Average'
    END as seasonality_category
FROM seasonality_analysis
ORDER BY order_month;

-- Example 4: Day of Week Patterns
-- Business Question: "Which days of the week are strongest for our business?"

WITH daily_patterns AS (
    SELECT 
        EXTRACT(DAYOFWEEK FROM o_orderdate) as day_of_week,
        DAYNAME(o_orderdate) as day_name,
        COUNT(o_orderkey) as total_orders,
        COUNT(DISTINCT o_custkey) as unique_customers,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value
    FROM orders
    GROUP BY EXTRACT(DAYOFWEEK FROM o_orderdate), DAYNAME(o_orderdate)
)
SELECT 
    day_of_week,
    day_name,
    total_orders,
    unique_customers,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    -- Percentage of weekly totals
    ROUND(total_orders * 100.0 / SUM(total_orders) OVER (), 2) as pct_of_weekly_orders,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) as pct_of_weekly_revenue,
    -- Compare to average day (14.29% = 100%/7 days)
    ROUND((total_revenue * 100.0 / SUM(total_revenue) OVER ()) - 14.29, 2) as revenue_vs_avg_day
FROM daily_patterns
ORDER BY day_of_week;

-- ============================================
-- MOVING AVERAGES & SMOOTHING
-- ============================================

-- WHAT IT IS: Moving averages smooth out short-term fluctuations to reveal underlying
-- trends by calculating the average of data points over a rolling time window.
--
-- WHY IT MATTERS: Moving averages help:
-- - Filter out noise and random variations
-- - Identify true trends vs temporary fluctuations
-- - Create more stable forecasting baselines
-- - Detect trend changes and inflection points
--
-- TYPES: Simple Moving Average (SMA), Exponential Moving Average (EMA)
-- BENCHMARK: Use 3-month SMA for quarterly trends, 12-month for annual trends

-- Example 5: Revenue Moving Averages
-- Business Question: "What's the underlying trend when we smooth out monthly variations?"

WITH daily_revenue AS (
    SELECT 
        o_orderdate,
        COUNT(o_orderkey) as daily_orders,
        SUM(o_totalprice) as daily_revenue
    FROM orders
    GROUP BY o_orderdate
),
moving_averages AS (
    SELECT 
        o_orderdate,
        daily_orders,
        ROUND(daily_revenue, 2) as daily_revenue,
        -- 7-day moving average
        ROUND(AVG(daily_revenue) OVER (
            ORDER BY o_orderdate 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) as revenue_7day_avg,
        -- 30-day moving average
        ROUND(AVG(daily_revenue) OVER (
            ORDER BY o_orderdate 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2) as revenue_30day_avg,
        -- Moving standard deviation (volatility measure)
        ROUND(STDDEV(daily_revenue) OVER (
            ORDER BY o_orderdate 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 2) as revenue_30day_stddev
    FROM daily_revenue
)
SELECT 
    o_orderdate,
    daily_orders,
    daily_revenue,
    revenue_7day_avg,
    revenue_30day_avg,
    revenue_30day_stddev,
    -- Trend indicators
    CASE 
        WHEN daily_revenue > revenue_30day_avg + revenue_30day_stddev THEN 'Above Trend'
        WHEN daily_revenue < revenue_30day_avg - revenue_30day_stddev THEN 'Below Trend'
        ELSE 'Within Trend'
    END as trend_position
FROM moving_averages
WHERE revenue_30day_avg IS NOT NULL  -- Only show dates with full 30-day window
ORDER BY o_orderdate;

-- ============================================
-- COHORT ANALYSIS
-- ============================================

-- WHAT IT IS: Cohort analysis tracks groups of customers who share a common characteristic
-- (like acquisition month) over time to understand behavior patterns and retention.
--
-- WHY IT MATTERS: Cohort analysis reveals:
-- - Customer retention patterns over time
-- - Lifetime value trends by acquisition period
-- - Impact of product/service changes on customer behavior
-- - Seasonal effects on customer acquisition quality
--
-- KEY METRICS: Retention rate, revenue per cohort, cohort size trends
-- BENCHMARK: Look for improving retention rates in newer cohorts

-- Example 6: Customer Acquisition Cohorts
-- Business Question: "How do customers acquired in different months perform over time?"

WITH customer_first_order AS (
    SELECT 
        c.c_custkey,
        c.c_mktsegment,
        MIN(o.o_orderdate) as first_order_date,
        DATE_TRUNC('month', MIN(o.o_orderdate)) as acquisition_month
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_mktsegment
),
cohort_data AS (
    SELECT 
        cfo.acquisition_month,
        COUNT(DISTINCT cfo.c_custkey) as cohort_size,
        -- Month 0: Acquisition month revenue
        SUM(CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month 
                 THEN o.o_totalprice ELSE 0 END) as month_0_revenue,
        COUNT(CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month 
                   THEN o.o_orderkey END) as month_0_orders,
        -- Month 1: First month after acquisition
        SUM(CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month + INTERVAL '1 month' 
                 THEN o.o_totalprice ELSE 0 END) as month_1_revenue,
        COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month + INTERVAL '1 month' 
                            THEN cfo.c_custkey END) as month_1_customers,
        -- Month 2: Second month after acquisition
        SUM(CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month + INTERVAL '2 months' 
                 THEN o.o_totalprice ELSE 0 END) as month_2_revenue,
        COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', o.o_orderdate) = cfo.acquisition_month + INTERVAL '2 months' 
                            THEN cfo.c_custkey END) as month_2_customers,
        -- Total lifetime value so far
        SUM(o.o_totalprice) as total_cohort_ltv
    FROM customer_first_order cfo
    LEFT JOIN orders o ON cfo.c_custkey = o.o_custkey
    GROUP BY cfo.acquisition_month
)
SELECT 
    acquisition_month,
    cohort_size,
    ROUND(month_0_revenue, 2) as month_0_revenue,
    month_0_orders,
    ROUND(month_1_revenue, 2) as month_1_revenue,
    month_1_customers,
    ROUND(month_2_revenue, 2) as month_2_revenue,
    month_2_customers,
    ROUND(total_cohort_ltv, 2) as total_cohort_ltv,
    -- Cohort metrics
    ROUND(month_0_revenue / cohort_size, 2) as avg_first_month_revenue,
    ROUND(total_cohort_ltv / cohort_size, 2) as avg_ltv_per_customer,
    -- Retention rates
    CASE WHEN cohort_size > 0 THEN ROUND(month_1_customers * 100.0 / cohort_size, 2) ELSE 0 END as month_1_retention_rate,
    CASE WHEN cohort_size > 0 THEN ROUND(month_2_customers * 100.0 / cohort_size, 2) ELSE 0 END as month_2_retention_rate
FROM cohort_data
WHERE cohort_size > 0
ORDER BY acquisition_month;

-- ============================================
-- GROWTH RATE CALCULATIONS
-- ============================================

-- WHAT IT IS: Growth rates measure the percentage change in key metrics over time,
-- providing standardized ways to compare performance across different periods.
--
-- WHY IT MATTERS: Growth rates help:
-- - Compare performance across different time periods
-- - Set realistic targets and expectations
-- - Identify acceleration or deceleration in business metrics
-- - Communicate progress to stakeholders and investors
--
-- TYPES: Period-over-period, compound annual growth rate (CAGR), rolling growth
-- BENCHMARK: Consistent positive growth rates indicate healthy business momentum

-- Example 7: Comprehensive Growth Rate Analysis
-- Business Question: "What are our growth rates across different time horizons?"

WITH monthly_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        DATE_TRUNC('month', o_orderdate) as month_date,
        COUNT(o_orderkey) as total_orders,
        COUNT(DISTINCT o_custkey) as unique_customers,
        SUM(o_totalprice) as total_revenue
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate), DATE_TRUNC('month', o_orderdate)
),
growth_calculations AS (
    SELECT 
        order_year,
        order_month,
        month_date,
        total_orders,
        unique_customers,
        ROUND(total_revenue, 2) as total_revenue,
        -- Previous periods for comparison
        LAG(total_revenue, 1) OVER (ORDER BY order_year, order_month) as prev_month_revenue,
        LAG(total_revenue, 3) OVER (ORDER BY order_year, order_month) as three_months_ago_revenue,
        LAG(total_revenue, 12) OVER (ORDER BY order_year, order_month) as year_ago_revenue,
        -- Customer growth comparisons
        LAG(unique_customers, 1) OVER (ORDER BY order_year, order_month) as prev_month_customers,
        LAG(unique_customers, 12) OVER (ORDER BY order_year, order_month) as year_ago_customers
    FROM monthly_metrics
)
SELECT 
    order_year,
    order_month,
    total_orders,
    unique_customers,
    total_revenue,
    -- Month-over-month growth
    CASE 
        WHEN prev_month_revenue IS NOT NULL AND prev_month_revenue > 0 
        THEN ROUND((total_revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2)
        ELSE NULL 
    END as mom_revenue_growth,
    -- Quarter-over-quarter growth (3 months)
    CASE 
        WHEN three_months_ago_revenue IS NOT NULL AND three_months_ago_revenue > 0 
        THEN ROUND((total_revenue - three_months_ago_revenue) * 100.0 / three_months_ago_revenue, 2)
        ELSE NULL 
    END as qoq_revenue_growth,
    -- Year-over-year growth
    CASE 
        WHEN year_ago_revenue IS NOT NULL AND year_ago_revenue > 0 
        THEN ROUND((total_revenue - year_ago_revenue) * 100.0 / year_ago_revenue, 2)
        ELSE NULL 
    END as yoy_revenue_growth,
    -- Customer growth rates
    CASE 
        WHEN prev_month_customers IS NOT NULL AND prev_month_customers > 0 
        THEN ROUND((unique_customers - prev_month_customers) * 100.0 / prev_month_customers, 2)
        ELSE NULL 
    END as mom_customer_growth,
    CASE 
        WHEN year_ago_customers IS NOT NULL AND year_ago_customers > 0 
        THEN ROUND((unique_customers - year_ago_customers) * 100.0 / year_ago_customers, 2)
        ELSE NULL 
    END as yoy_customer_growth
FROM growth_calculations
ORDER BY order_year, order_month;

-- ============================================
-- FORECASTING BASICS
-- ============================================

-- WHAT IT IS: Forecasting uses historical data patterns to predict future values,
-- helping businesses plan for upcoming periods and make informed decisions.
--
-- WHY IT MATTERS: Forecasting enables:
-- - Better resource planning and budgeting
-- - Inventory management and capacity planning
-- - Goal setting and performance expectations
-- - Risk assessment and scenario planning
--
-- METHODS: Linear trends, seasonal adjustments, moving average projections
-- BENCHMARK: Forecast accuracy within 10-20% is considered good for most businesses

-- Example 8: Simple Linear Trend Forecasting
-- Business Question: "Based on historical trends, what can we expect for future months?"

WITH monthly_data AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        ROW_NUMBER() OVER (ORDER BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)) as period_number,
        COUNT(o_orderkey) as total_orders,
        SUM(o_totalprice) as total_revenue
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)
),
trend_analysis AS (
    SELECT 
        order_year,
        order_month,
        period_number,
        total_orders,
        ROUND(total_revenue, 2) as total_revenue,
        -- Calculate linear trend using simple regression concepts
        AVG(total_revenue) OVER () as avg_revenue,
        AVG(period_number) OVER () as avg_period,
        -- Trend slope calculation (simplified)
        ROUND(
            (SUM(period_number * total_revenue) OVER () - COUNT(*) OVER () * AVG(period_number) OVER () * AVG(total_revenue) OVER ()) /
            (SUM(period_number * period_number) OVER () - COUNT(*) OVER () * AVG(period_number) OVER () * AVG(period_number) OVER ()),
            2
        ) as trend_slope
    FROM monthly_data
),
forecasting AS (
    SELECT 
        order_year,
        order_month,
        period_number,
        total_orders,
        total_revenue,
        trend_slope,
        -- Simple linear forecast
        ROUND(avg_revenue + trend_slope * (period_number - avg_period), 2) as forecasted_revenue,
        -- Forecast accuracy (actual vs predicted)
        ROUND(ABS(total_revenue - (avg_revenue + trend_slope * (period_number - avg_period))) * 100.0 / total_revenue, 2) as forecast_error_percent
    FROM trend_analysis
)
SELECT 
    order_year,
    order_month,
    period_number,
    total_orders,
    total_revenue,
    forecasted_revenue,
    forecast_error_percent,
    -- Trend direction
    CASE 
        WHEN trend_slope > 100 THEN 'Strong Growth'
        WHEN trend_slope > 0 THEN 'Moderate Growth'
        WHEN trend_slope > -100 THEN 'Slight Decline'
        ELSE 'Strong Decline'
    END as trend_direction
FROM forecasting
ORDER BY order_year, order_month;

-- ============================================
-- TIME SERIES SUMMARY DASHBOARD
-- ============================================

-- WHAT IT IS: A time series dashboard provides key temporal insights at a glance,
-- combining trends, seasonality, and growth metrics for executive decision-making.
--
-- WHY IT MATTERS: Time series dashboards help:
-- - Quickly identify performance patterns and anomalies
-- - Track progress against time-based goals
-- - Understand cyclical business patterns
-- - Make data-driven decisions about timing and resource allocation

-- Example 9: Executive Time Series Summary
-- Business Question: "What are our key time-based performance indicators?"

WITH daily_stats AS (
    SELECT 
        o_orderdate,
        COUNT(*) as daily_orders,
        SUM(o_totalprice) as daily_revenue
    FROM orders
    GROUP BY o_orderdate
),
time_series_summary AS (
    SELECT 
        -- Overall time range
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as total_days_active,
        
        -- Volume metrics
        COUNT(o.o_orderkey) as total_orders,
        COUNT(DISTINCT o.o_custkey) as total_customers,
        SUM(o.o_totalprice) as total_revenue,
        
        -- Time-based averages
        COUNT(o.o_orderkey)::DECIMAL / COUNT(DISTINCT DATE_TRUNC('month', o.o_orderdate)) as avg_orders_per_month,
        SUM(o.o_totalprice) / COUNT(DISTINCT DATE_TRUNC('month', o.o_orderdate)) as avg_revenue_per_month,
        COUNT(DISTINCT o.o_custkey)::DECIMAL / COUNT(DISTINCT DATE_TRUNC('month', o.o_orderdate)) as avg_new_customers_per_month,
        
        -- Peak performance
        MAX(ds.daily_orders) as peak_daily_orders,
        MAX(ds.daily_revenue) as peak_daily_revenue
    FROM orders o
    INNER JOIN daily_stats ds ON o.o_orderdate = ds.o_orderdate
),
recent_performance AS (
    SELECT 
        -- Last 30 days performance
        COUNT(CASE WHEN o_orderdate >= (SELECT MAX(o_orderdate) - INTERVAL '30 days' FROM orders) THEN 1 END) as orders_last_30_days,
        SUM(CASE WHEN o_orderdate >= (SELECT MAX(o_orderdate) - INTERVAL '30 days' FROM orders) THEN o_totalprice ELSE 0 END) as revenue_last_30_days,
        -- Previous 30 days for comparison
        COUNT(CASE WHEN o_orderdate >= (SELECT MAX(o_orderdate) - INTERVAL '60 days' FROM orders) 
                   AND o_orderdate < (SELECT MAX(o_orderdate) - INTERVAL '30 days' FROM orders) THEN 1 END) as orders_prev_30_days,
        SUM(CASE WHEN o_orderdate >= (SELECT MAX(o_orderdate) - INTERVAL '60 days' FROM orders) 
                 AND o_orderdate < (SELECT MAX(o_orderdate) - INTERVAL '30 days' FROM orders) THEN o_totalprice ELSE 0 END) as revenue_prev_30_days
    FROM orders
)
SELECT 
    'TIME RANGE' as metric_category,
    CAST(ts.first_order_date AS VARCHAR) as metric_value,
    'First Order Date' as metric_name
FROM time_series_summary ts

UNION ALL

SELECT 
    'TIME RANGE',
    CAST(ts.last_order_date AS VARCHAR),
    'Last Order Date'
FROM time_series_summary ts

UNION ALL

SELECT 
    'TIME RANGE',
    CAST(ts.total_days_active AS VARCHAR),
    'Total Days Active'
FROM time_series_summary ts

UNION ALL

SELECT 
    'VOLUME METRICS',
    CAST(ts.total_orders AS VARCHAR),
    'Total Orders'
FROM time_series_summary ts

UNION ALL

SELECT 
    'VOLUME METRICS',
    CAST(ROUND(ts.total_revenue, 2) AS VARCHAR),
    'Total Revenue'
FROM time_series_summary ts

UNION ALL

SELECT 
    'AVERAGES',
    CAST(ROUND(ts.avg_orders_per_month, 1) AS VARCHAR),
    'Avg Orders per Month'
FROM time_series_summary ts

UNION ALL

SELECT 
    'AVERAGES',
    CAST(ROUND(ts.avg_revenue_per_month, 2) AS VARCHAR),
    'Avg Revenue per Month'
FROM time_series_summary ts

UNION ALL

SELECT 
    'RECENT PERFORMANCE',
    CAST(rp.orders_last_30_days AS VARCHAR),
    'Orders Last 30 Days'
FROM recent_performance rp

UNION ALL

SELECT 
    'RECENT PERFORMANCE',
    CAST(ROUND(rp.revenue_last_30_days, 2) AS VARCHAR),
    'Revenue Last 30 Days'
FROM recent_performance rp

UNION ALL

SELECT 
    'RECENT PERFORMANCE',
    CAST(ROUND(
        CASE WHEN rp.revenue_prev_30_days > 0 
             THEN (rp.revenue_last_30_days - rp.revenue_prev_30_days) * 100.0 / rp.revenue_prev_30_days
             ELSE 0 END, 2
    ) AS VARCHAR) || '%',
    'Revenue Growth Last 30 Days'
FROM recent_performance rp

ORDER BY metric_category, metric_name;

-- ============================================
-- TIME SERIES ANALYSIS BEST PRACTICES
-- ============================================

-- 1. TREND ANALYSIS:
--    - Use moving averages to smooth out noise and identify true trends
--    - Look for consistent patterns over multiple time periods
--    - Consider external factors that might influence trends

-- 2. SEASONALITY DETECTION:
--    - Compare same periods across different years (YoY)
--    - Look for recurring patterns at regular intervals
--    - Adjust forecasts and targets for seasonal variations

-- 3. GROWTH RATE CALCULATIONS:
--    - Use multiple time horizons (MoM, QoQ, YoY) for complete picture
--    - Focus on sustainable growth rates rather than short-term spikes
--    - Consider both absolute and percentage growth

-- 4. COHORT ANALYSIS:
--    - Track customer groups by acquisition period
--    - Monitor retention and lifetime value trends
--    - Identify factors that improve cohort performance

-- 5. FORECASTING:
--    - Use historical patterns but adjust for known future changes
--    - Provide confidence intervals, not just point estimates
--    - Regularly update forecasts with new data

-- 6. DATA QUALITY:
--    - Ensure consistent time periods and data collection methods
--    - Handle missing data points appropriately
--    - Account for business calendar differences (holidays, weekends)

-- Time series analysis provides the foundation for understanding business performance
-- over time and making informed decisions about future strategy and resource allocation.