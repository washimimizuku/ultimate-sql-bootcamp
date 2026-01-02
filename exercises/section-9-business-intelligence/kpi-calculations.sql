-- KPI CALCULATIONS - Business Intelligence & Analytics
-- This file demonstrates essential business Key Performance Indicators (KPIs)
-- using the TPC-H database to calculate real-world business metrics
-- ============================================
-- REQUIRED: This file uses the TPC-H database
-- Setup: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-9-business-intelligence/kpi-calculations.sql
-- ============================================

-- KPI CONCEPTS:
-- - Key Performance Indicators (KPIs) are measurable values that demonstrate business performance
-- - Customer Lifetime Value (CLV): Total revenue expected from a customer over their lifetime
-- - Churn Rate: Percentage of customers who stop doing business over a period
-- - Customer Acquisition Cost (CAC): Cost to acquire a new customer
-- - Monthly Recurring Revenue (MRR): Predictable revenue generated each month
-- - Retention Rate: Percentage of customers who continue doing business
-- - Average Order Value (AOV): Average amount spent per order

-- BUSINESS CONTEXT:
-- The TPC-H database represents a B2B wholesale business where:
-- - Customers place orders over time (customer lifecycle)
-- - We can track customer behavior, spending patterns, and retention
-- - Orders have dates, allowing us to calculate time-based metrics
-- - This mirrors real-world subscription, SaaS, and retail businesses

-- ============================================
-- CUSTOMER LIFETIME VALUE (CLV)
-- ============================================

-- Example 1: Basic Customer Lifetime Value
-- CLV = Average Order Value × Purchase Frequency × Customer Lifespan
-- Business Question: "What is the lifetime value of our customers?"

WITH customer_metrics AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        -- Order metrics
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        
        -- Time metrics
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days,
        
        -- Frequency metrics
        CASE 
            WHEN DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) > 0 
            THEN COUNT(o.o_orderkey)::DECIMAL / (DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) / 30.0)
            ELSE COUNT(o.o_orderkey)
        END as orders_per_month
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
    HAVING COUNT(o.o_orderkey) > 1  -- Only customers with multiple orders
)
SELECT 
    c_name,
    c_mktsegment,
    total_orders,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    customer_lifespan_days,
    ROUND(orders_per_month, 2) as orders_per_month,
    -- Simple CLV calculation
    ROUND(total_revenue, 2) as historical_clv,
    -- Projected CLV (assuming customer continues current pattern)
    ROUND(avg_order_value * orders_per_month * 12, 2) as projected_annual_clv
FROM customer_metrics
ORDER BY total_revenue DESC
LIMIT 20;

-- Example 2: Segmented Customer Lifetime Value
-- Business Question: "How does CLV vary by customer segment?"

WITH segment_clv AS (
    SELECT 
        c.c_mktsegment,
        COUNT(DISTINCT c.c_custkey) as total_customers,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        SUM(o.o_totalprice) / COUNT(DISTINCT c.c_custkey) as avg_clv_per_customer,
        COUNT(o.o_orderkey)::DECIMAL / COUNT(DISTINCT c.c_custkey) as avg_orders_per_customer
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_mktsegment
)
SELECT 
    c_mktsegment,
    total_customers,
    total_orders,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(avg_clv_per_customer, 2) as avg_clv_per_customer,
    ROUND(avg_orders_per_customer, 2) as avg_orders_per_customer,
    -- Revenue concentration
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) as pct_of_total_revenue
FROM segment_clv
ORDER BY avg_clv_per_customer DESC;

-- ============================================
-- CHURN RATE ANALYSIS
-- ============================================

-- Example 3: Customer Churn Rate Calculation
-- Churn Rate = (Customers Lost in Period / Customers at Start of Period) × 100
-- Business Question: "What is our customer churn rate?"

WITH customer_activity AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        COUNT(o.o_orderkey) as total_orders,
        -- Define active periods
        CASE 
            WHEN MAX(o.o_orderdate) >= '1995-07-01' THEN 'Active'
            WHEN MAX(o.o_orderdate) >= '1995-01-01' THEN 'At Risk'
            ELSE 'Churned'
        END as customer_status,
        -- Days since last order
        DATEDIFF('day', MAX(o.o_orderdate), '1995-12-31') as days_since_last_order
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
churn_analysis AS (
    SELECT 
        customer_status,
        COUNT(*) as customer_count,
        AVG(days_since_last_order) as avg_days_since_last_order,
        AVG(total_orders) as avg_orders_per_customer
    FROM customer_activity
    GROUP BY customer_status
)
SELECT 
    customer_status,
    customer_count,
    ROUND(avg_days_since_last_order, 1) as avg_days_since_last_order,
    ROUND(avg_orders_per_customer, 1) as avg_orders_per_customer,
    ROUND(customer_count * 100.0 / SUM(customer_count) OVER (), 2) as percentage_of_customers
FROM churn_analysis
ORDER BY 
    CASE customer_status 
        WHEN 'Active' THEN 1 
        WHEN 'At Risk' THEN 2 
        WHEN 'Churned' THEN 3 
    END;

-- Example 4: Churn Rate by Customer Segment
-- Business Question: "Which customer segments have the highest churn rates?"

WITH customer_last_order AS (
    SELECT 
        c.c_custkey,
        c.c_mktsegment,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days,
        CASE WHEN MAX(o.o_orderdate) < '1995-07-01' THEN 1 ELSE 0 END as is_churned
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_mktsegment
),
segment_churn AS (
    SELECT 
        c_mktsegment,
        COUNT(*) as total_customers,
        SUM(is_churned) as churned_customers,
        COUNT(*) - SUM(is_churned) as active_customers,
        AVG(customer_lifespan_days) as avg_customer_lifespan
    FROM customer_last_order
    GROUP BY c_mktsegment
)
SELECT 
    c_mktsegment,
    total_customers,
    churned_customers,
    active_customers,
    ROUND(churned_customers * 100.0 / total_customers, 2) as churn_rate_percent,
    ROUND(avg_customer_lifespan, 1) as avg_customer_lifespan_days
FROM segment_churn
ORDER BY churn_rate_percent DESC;

-- ============================================
-- CUSTOMER ACQUISITION COST (CAC)
-- ============================================

-- Example 5: Customer Acquisition Cost Analysis
-- CAC = Total Acquisition Costs / Number of New Customers
-- Note: TPC-H doesn't have marketing spend data, so we'll simulate it

WITH monthly_acquisitions AS (
    SELECT 
        EXTRACT(YEAR FROM first_order_date) as acquisition_year,
        EXTRACT(MONTH FROM first_order_date) as acquisition_month,
        c_mktsegment,
        COUNT(*) as new_customers,
        SUM(first_order_value) as first_month_revenue
    FROM (
        SELECT 
            c.c_custkey,
            c.c_mktsegment,
            MIN(o.o_orderdate) as first_order_date,
            MIN(o.o_totalprice) as first_order_value
        FROM customer c
        INNER JOIN orders o ON c.c_custkey = o.o_custkey
        GROUP BY c.c_custkey, c.c_mktsegment
    ) customer_first_orders
    GROUP BY EXTRACT(YEAR FROM first_order_date), EXTRACT(MONTH FROM first_order_date), c_mktsegment
),
-- Simulate marketing costs (in real scenario, this would come from marketing spend data)
marketing_costs AS (
    SELECT 
        acquisition_year,
        acquisition_month,
        c_mktsegment,
        new_customers,
        first_month_revenue,
        -- Simulate different CAC by segment (realistic business assumption)
        CASE c_mktsegment
            WHEN 'AUTOMOBILE' THEN new_customers * 150  -- Higher CAC for auto industry
            WHEN 'MACHINERY' THEN new_customers * 200   -- Highest CAC for machinery
            WHEN 'BUILDING' THEN new_customers * 120    -- Medium CAC for building
            WHEN 'FURNITURE' THEN new_customers * 100   -- Lower CAC for furniture
            ELSE new_customers * 80                     -- Lowest CAC for household
        END as estimated_acquisition_cost
    FROM monthly_acquisitions
)
SELECT 
    acquisition_year,
    acquisition_month,
    c_mktsegment,
    new_customers,
    ROUND(first_month_revenue, 2) as first_month_revenue,
    estimated_acquisition_cost,
    ROUND(estimated_acquisition_cost::DECIMAL / new_customers, 2) as cac_per_customer,
    ROUND(first_month_revenue / new_customers, 2) as avg_first_order_value,
    -- CAC Payback Period (months to recover acquisition cost)
    ROUND(estimated_acquisition_cost / first_month_revenue, 2) as cac_payback_ratio
FROM marketing_costs
WHERE new_customers > 0
ORDER BY acquisition_year, acquisition_month, cac_per_customer DESC;

-- ============================================
-- REVENUE GROWTH METRICS
-- ============================================

-- Example 6: Month-over-Month Revenue Growth
-- Business Question: "How is our revenue growing month over month?"

WITH monthly_revenue AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as revenue_year,
        EXTRACT(MONTH FROM o_orderdate) as revenue_month,
        COUNT(DISTINCT o_custkey) as unique_customers,
        COUNT(o_orderkey) as total_orders,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate)
),
revenue_growth AS (
    SELECT 
        revenue_year,
        revenue_month,
        unique_customers,
        total_orders,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        -- Previous month comparison
        LAG(total_revenue) OVER (ORDER BY revenue_year, revenue_month) as prev_month_revenue,
        LAG(unique_customers) OVER (ORDER BY revenue_year, revenue_month) as prev_month_customers
    FROM monthly_revenue
)
SELECT 
    revenue_year,
    revenue_month,
    unique_customers,
    total_orders,
    total_revenue,
    avg_order_value,
    prev_month_revenue,
    -- Growth calculations
    CASE 
        WHEN prev_month_revenue IS NOT NULL AND prev_month_revenue > 0 
        THEN ROUND((total_revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2)
        ELSE NULL 
    END as revenue_growth_percent,
    CASE 
        WHEN prev_month_customers IS NOT NULL AND prev_month_customers > 0 
        THEN ROUND((unique_customers - prev_month_customers) * 100.0 / prev_month_customers, 2)
        ELSE NULL 
    END as customer_growth_percent
FROM revenue_growth
ORDER BY revenue_year, revenue_month;

-- Example 7: Year-over-Year Growth Analysis
-- Business Question: "How does this year compare to last year?"

WITH yearly_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as revenue_year,
        COUNT(DISTINCT o_custkey) as unique_customers,
        COUNT(o_orderkey) as total_orders,
        SUM(o_totalprice) as total_revenue,
        AVG(o_totalprice) as avg_order_value,
        SUM(o_totalprice) / COUNT(DISTINCT o_custkey) as revenue_per_customer
    FROM orders
    GROUP BY EXTRACT(YEAR FROM o_orderdate)
),
yoy_growth AS (
    SELECT 
        revenue_year,
        unique_customers,
        total_orders,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        ROUND(revenue_per_customer, 2) as revenue_per_customer,
        LAG(total_revenue) OVER (ORDER BY revenue_year) as prev_year_revenue,
        LAG(unique_customers) OVER (ORDER BY revenue_year) as prev_year_customers
    FROM yearly_metrics
)
SELECT 
    revenue_year,
    unique_customers,
    total_orders,
    total_revenue,
    avg_order_value,
    revenue_per_customer,
    -- Year-over-year growth
    CASE 
        WHEN prev_year_revenue IS NOT NULL AND prev_year_revenue > 0 
        THEN ROUND((total_revenue - prev_year_revenue) * 100.0 / prev_year_revenue, 2)
        ELSE NULL 
    END as yoy_revenue_growth_percent,
    CASE 
        WHEN prev_year_customers IS NOT NULL AND prev_year_customers > 0 
        THEN ROUND((unique_customers - prev_year_customers) * 100.0 / prev_year_customers, 2)
        ELSE NULL 
    END as yoy_customer_growth_percent
FROM yoy_growth
ORDER BY revenue_year;

-- ============================================
-- CUSTOMER RETENTION METRICS
-- ============================================

-- Example 8: Customer Retention Rate
-- Retention Rate = (Customers at End - New Customers) / Customers at Start × 100
-- Business Question: "What percentage of customers are we retaining?"

WITH customer_periods AS (
    SELECT 
        c.c_custkey,
        c.c_mktsegment,
        MIN(CASE WHEN o.o_orderdate < '1995-07-01' THEN o.o_orderdate END) as h1_first_order,
        MAX(CASE WHEN o.o_orderdate < '1995-07-01' THEN o.o_orderdate END) as h1_last_order,
        MIN(CASE WHEN o.o_orderdate >= '1995-07-01' THEN o.o_orderdate END) as h2_first_order,
        MAX(CASE WHEN o.o_orderdate >= '1995-07-01' THEN o.o_orderdate END) as h2_last_order,
        COUNT(CASE WHEN o.o_orderdate < '1995-07-01' THEN 1 END) as h1_orders,
        COUNT(CASE WHEN o.o_orderdate >= '1995-07-01' THEN 1 END) as h2_orders
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_mktsegment
),
retention_analysis AS (
    SELECT 
        c_mktsegment,
        -- H1 customers (first half of year)
        COUNT(CASE WHEN h1_orders > 0 THEN 1 END) as h1_customers,
        -- H2 customers (second half of year)
        COUNT(CASE WHEN h2_orders > 0 THEN 1 END) as h2_customers,
        -- Retained customers (active in both periods)
        COUNT(CASE WHEN h1_orders > 0 AND h2_orders > 0 THEN 1 END) as retained_customers,
        -- New customers in H2
        COUNT(CASE WHEN h1_orders = 0 AND h2_orders > 0 THEN 1 END) as new_h2_customers
    FROM customer_periods
    GROUP BY c_mktsegment
)
SELECT 
    c_mktsegment,
    h1_customers,
    h2_customers,
    retained_customers,
    new_h2_customers,
    -- Retention rate calculation
    CASE 
        WHEN h1_customers > 0 
        THEN ROUND(retained_customers * 100.0 / h1_customers, 2)
        ELSE 0 
    END as retention_rate_percent,
    -- Customer growth
    ROUND((h2_customers - h1_customers) * 100.0 / h1_customers, 2) as customer_growth_percent
FROM retention_analysis
ORDER BY retention_rate_percent DESC;

-- ============================================
-- AVERAGE ORDER VALUE (AOV) TRENDS
-- ============================================

-- Example 9: Average Order Value Analysis
-- Business Question: "How is our average order value trending?"

WITH monthly_aov AS (
    SELECT 
        EXTRACT(YEAR FROM o_orderdate) as order_year,
        EXTRACT(MONTH FROM o_orderdate) as order_month,
        c.c_mktsegment,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY o.o_totalprice) as median_order_value
    FROM orders o
    INNER JOIN customer c ON o.o_custkey = c.c_custkey
    GROUP BY EXTRACT(YEAR FROM o_orderdate), EXTRACT(MONTH FROM o_orderdate), c.c_mktsegment
),
aov_trends AS (
    SELECT 
        order_year,
        order_month,
        c_mktsegment,
        total_orders,
        ROUND(total_revenue, 2) as total_revenue,
        ROUND(avg_order_value, 2) as avg_order_value,
        ROUND(median_order_value, 2) as median_order_value,
        LAG(avg_order_value) OVER (PARTITION BY c_mktsegment ORDER BY order_year, order_month) as prev_month_aov
    FROM monthly_aov
)
SELECT 
    order_year,
    order_month,
    c_mktsegment,
    total_orders,
    total_revenue,
    avg_order_value,
    median_order_value,
    -- AOV trend
    CASE 
        WHEN prev_month_aov IS NOT NULL AND prev_month_aov > 0 
        THEN ROUND((avg_order_value - prev_month_aov) * 100.0 / prev_month_aov, 2)
        ELSE NULL 
    END as aov_growth_percent
FROM aov_trends
WHERE total_orders > 0
ORDER BY c_mktsegment, order_year, order_month;

-- ============================================
-- CUSTOMER SEGMENTATION BY VALUE
-- ============================================

-- Example 10: RFM Analysis (Recency, Frequency, Monetary)
-- Business Question: "How should we segment our customers for targeted marketing?"

WITH customer_rfm AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        -- Recency: Days since last order
        DATEDIFF('day', MAX(o.o_orderdate), '1995-12-31') as recency_days,
        -- Frequency: Number of orders
        COUNT(o.o_orderkey) as frequency_orders,
        -- Monetary: Total revenue
        SUM(o.o_totalprice) as monetary_value
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),
rfm_scores AS (
    SELECT 
        *,
        -- RFM Scoring (1-5 scale, 5 being best)
        CASE 
            WHEN recency_days <= 90 THEN 5
            WHEN recency_days <= 180 THEN 4
            WHEN recency_days <= 270 THEN 3
            WHEN recency_days <= 365 THEN 2
            ELSE 1
        END as recency_score,
        CASE 
            WHEN frequency_orders >= 10 THEN 5
            WHEN frequency_orders >= 7 THEN 4
            WHEN frequency_orders >= 4 THEN 3
            WHEN frequency_orders >= 2 THEN 2
            ELSE 1
        END as frequency_score,
        CASE 
            WHEN monetary_value >= 500000 THEN 5
            WHEN monetary_value >= 300000 THEN 4
            WHEN monetary_value >= 150000 THEN 3
            WHEN monetary_value >= 50000 THEN 2
            ELSE 1
        END as monetary_score
    FROM customer_rfm
),
customer_segments AS (
    SELECT 
        *,
        -- Overall RFM Score
        (recency_score + frequency_score + monetary_score) as rfm_total_score,
        -- Customer Segments
        CASE 
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
            WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 4 THEN 'Loyal Customers'
            WHEN recency_score >= 4 AND frequency_score <= 2 AND monetary_value >= 4 THEN 'Big Spenders'
            WHEN recency_score >= 4 AND frequency_score >= 3 AND monetary_score <= 3 THEN 'Promising'
            WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Potential Loyalists'
            WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 4 THEN 'Cannot Lose Them'
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'Lost'
            ELSE 'New Customers'
        END as customer_segment
    FROM rfm_scores
)
SELECT 
    customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(recency_days), 1) as avg_recency_days,
    ROUND(AVG(frequency_orders), 1) as avg_frequency,
    ROUND(AVG(monetary_value), 2) as avg_monetary_value,
    ROUND(SUM(monetary_value), 2) as total_segment_value,
    ROUND(AVG(rfm_total_score), 1) as avg_rfm_score
FROM customer_segments
GROUP BY customer_segment
ORDER BY avg_rfm_score DESC;

-- ============================================
-- KPI DASHBOARD SUMMARY
-- ============================================

-- Example 11: Executive KPI Dashboard
-- Business Question: "What are our key metrics at a glance?"

WITH kpi_summary AS (
    SELECT 
        -- Customer Metrics
        COUNT(DISTINCT c.c_custkey) as total_customers,
        COUNT(DISTINCT CASE WHEN o.o_orderdate >= '1995-07-01' THEN c.c_custkey END) as active_customers,
        
        -- Order Metrics
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_revenue,
        AVG(o.o_totalprice) as avg_order_value,
        
        -- Time-based Metrics
        COUNT(CASE WHEN o.o_orderdate >= '1995-07-01' THEN 1 END) as h2_orders,
        SUM(CASE WHEN o.o_orderdate >= '1995-07-01' THEN o.o_totalprice ELSE 0 END) as h2_revenue,
        COUNT(CASE WHEN o.o_orderdate < '1995-07-01' THEN 1 END) as h1_orders,
        SUM(CASE WHEN o.o_orderdate < '1995-07-01' THEN o.o_totalprice ELSE 0 END) as h1_revenue
    FROM customer c
    INNER JOIN orders o ON c.c_custkey = o.o_custkey
)
SELECT 
    'CUSTOMER METRICS' as metric_category,
    total_customers as value,
    'Total Customers' as metric_name
FROM kpi_summary

UNION ALL

SELECT 
    'CUSTOMER METRICS',
    active_customers,
    'Active Customers (H2)'
FROM kpi_summary

UNION ALL

SELECT 
    'CUSTOMER METRICS',
    ROUND((active_customers * 100.0 / total_customers), 2),
    'Customer Retention Rate %'
FROM kpi_summary

UNION ALL

SELECT 
    'REVENUE METRICS',
    ROUND(total_revenue, 2),
    'Total Revenue'
FROM kpi_summary

UNION ALL

SELECT 
    'REVENUE METRICS',
    ROUND(avg_order_value, 2),
    'Average Order Value'
FROM kpi_summary

UNION ALL

SELECT 
    'REVENUE METRICS',
    ROUND(total_revenue / total_customers, 2),
    'Revenue per Customer'
FROM kpi_summary

UNION ALL

SELECT 
    'GROWTH METRICS',
    ROUND((h2_revenue - h1_revenue) * 100.0 / h1_revenue, 2),
    'Revenue Growth H1 vs H2 %'
FROM kpi_summary

UNION ALL

SELECT 
    'GROWTH METRICS',
    ROUND((h2_orders - h1_orders) * 100.0 / h1_orders, 2),
    'Order Growth H1 vs H2 %'
FROM kpi_summary

ORDER BY metric_category, metric_name;

-- ============================================
-- KPI BEST PRACTICES SUMMARY
-- ============================================

-- 1. CUSTOMER LIFETIME VALUE (CLV):
--    - Track both historical and projected CLV
--    - Segment CLV by customer type, acquisition channel, geography
--    - Use CLV to guide customer acquisition spending limits

-- 2. CHURN RATE ANALYSIS:
--    - Define clear criteria for "churned" vs "at risk" customers
--    - Track churn by segment to identify patterns
--    - Calculate churn impact on revenue, not just customer count

-- 3. CUSTOMER ACQUISITION COST (CAC):
--    - Include all acquisition costs: marketing, sales, onboarding
--    - Track CAC by channel and campaign for optimization
--    - Monitor CAC payback period and LTV:CAC ratio

-- 4. RETENTION METRICS:
--    - Use cohort analysis for accurate retention measurement
--    - Track both customer and revenue retention
--    - Identify early warning signs of churn

-- 5. GROWTH METRICS:
--    - Monitor both absolute and percentage growth
--    - Track leading indicators (new customers, trial conversions)
--    - Separate organic growth from acquisition-driven growth

-- 6. SEGMENTATION:
--    - Use RFM analysis for behavioral segmentation
--    - Create actionable segments with clear characteristics
--    - Regularly update segmentation criteria based on business changes

-- These KPIs provide the foundation for data-driven business decisions
-- and should be monitored regularly with automated dashboards and alerts.