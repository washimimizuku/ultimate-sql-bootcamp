-- COHORT RETENTION ANALYSIS - Advanced Analytics with SQL
-- This file demonstrates cohort analysis and customer retention patterns
-- using creative interpretation of TPC-H data for subscription and usage analytics
-- ============================================
-- REQUIRED: This file uses TPC-H database
-- Setup TPC-H: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-11-advanced-analytics/cohort-retention-analysis.sql
-- ============================================

-- COHORT ANALYSIS CONCEPTS:
-- - Cohort: A group of users who share a common characteristic or experience
-- - Retention: The percentage of users who continue to engage over time
-- - Acquisition Cohorts: Groups based on when users first engaged
-- - Behavioral Cohorts: Groups based on specific actions or characteristics
-- - Lifecycle Analysis: Understanding user journey from acquisition to churn
-- - Retention Curves: Visualizing how retention changes over time

-- BUSINESS CONTEXT:
-- Cohort analysis is essential for understanding customer behavior, measuring
-- product-market fit, and optimizing retention strategies. It helps businesses
-- identify which customer segments are most valuable and when churn typically occurs.

-- ============================================
-- CUSTOMER ACQUISITION COHORT ANALYSIS
-- ============================================

-- WHAT IT IS: Acquisition cohort analysis groups customers by their first
-- purchase date and tracks their purchasing behavior over subsequent periods.
--
-- WHY IT MATTERS: Acquisition cohorts reveal:
-- - Which acquisition periods produce the most valuable customers
-- - How customer behavior changes over time after acquisition
-- - The effectiveness of marketing campaigns and onboarding
-- - Long-term customer lifetime value patterns
--
-- COHORT METRICS: Retention rate, repeat purchase rate, revenue per cohort
-- BENCHMARK: Good SaaS retention: 90%+ month 1, 80%+ month 3, 70%+ month 6

-- Example 1: Monthly Acquisition Cohorts
-- Business Question: "How do customers acquired in different months behave over time?"

-- First, identify customer acquisition dates (first order)
WITH customer_acquisition AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        MIN(o.o_orderdate) as acquisition_date,
        DATE_TRUNC('month', MIN(o.o_orderdate)) as acquisition_month,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_spent
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),

-- Create monthly cohorts
monthly_cohorts AS (
    SELECT 
        acquisition_month,
        COUNT(*) as cohort_size,
        SUM(total_spent) as cohort_total_revenue,
        AVG(total_spent) as cohort_avg_revenue,
        AVG(total_orders) as cohort_avg_orders
    FROM customer_acquisition
    GROUP BY acquisition_month
),

-- Calculate retention by tracking subsequent order activity
customer_activity AS (
    SELECT 
        ca.c_custkey,
        ca.acquisition_month,
        o.o_orderdate,
        DATE_TRUNC('month', o.o_orderdate) as order_month,
        DATEDIFF('month', ca.acquisition_month, DATE_TRUNC('month', o.o_orderdate)) as months_since_acquisition,
        o.o_totalprice
    FROM customer_acquisition ca
    JOIN orders o ON ca.c_custkey = o.o_custkey
),

-- Calculate retention rates by cohort and period
cohort_retention AS (
    SELECT 
        acquisition_month,
        months_since_acquisition,
        COUNT(DISTINCT c_custkey) as active_customers,
        SUM(o_totalprice) as period_revenue,
        AVG(o_totalprice) as avg_order_value
    FROM customer_activity
    WHERE months_since_acquisition >= 0 AND months_since_acquisition <= 12
    GROUP BY acquisition_month, months_since_acquisition
)

SELECT 
    cr.acquisition_month,
    mc.cohort_size,
    cr.months_since_acquisition,
    cr.active_customers,
    ROUND(cr.active_customers * 100.0 / mc.cohort_size, 2) as retention_rate_pct,
    ROUND(cr.period_revenue, 2) as period_revenue,
    ROUND(cr.avg_order_value, 2) as avg_order_value,
    
    -- Calculate cumulative metrics
    ROUND(SUM(cr.period_revenue) OVER (
        PARTITION BY cr.acquisition_month 
        ORDER BY cr.months_since_acquisition 
        ROWS UNBOUNDED PRECEDING
    ), 2) as cumulative_revenue
    
FROM cohort_retention cr
JOIN monthly_cohorts mc ON cr.acquisition_month = mc.acquisition_month
WHERE mc.cohort_size >= 3  -- Focus on cohorts with meaningful size
ORDER BY cr.acquisition_month, cr.months_since_acquisition;

-- Example 2: Market Segment Cohort Comparison
-- Business Question: "Which market segments have the best retention characteristics?"

WITH segment_cohorts AS (
    SELECT 
        c.c_mktsegment,
        c.c_custkey,
        MIN(o.o_orderdate) as first_order_date,
        DATE_TRUNC('quarter', MIN(o.o_orderdate)) as acquisition_quarter,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_spent,
        MAX(o.o_orderdate) as last_order_date
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_mktsegment, c.c_custkey
),

segment_activity AS (
    SELECT 
        sc.c_mktsegment,
        sc.acquisition_quarter,
        sc.c_custkey,
        o.o_orderdate,
        DATEDIFF('month', sc.first_order_date, o.o_orderdate) as months_since_first_order,
        o.o_totalprice
    FROM segment_cohorts sc
    JOIN orders o ON sc.c_custkey = o.o_custkey
),

segment_retention_analysis AS (
    SELECT 
        c_mktsegment,
        acquisition_quarter,
        
        -- Retention periods (0, 3, 6, 12 months)
        COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN c_custkey END) as month_0_customers,
        COUNT(DISTINCT CASE WHEN months_since_first_order BETWEEN 1 AND 3 THEN c_custkey END) as month_1_3_customers,
        COUNT(DISTINCT CASE WHEN months_since_first_order BETWEEN 4 AND 6 THEN c_custkey END) as month_4_6_customers,
        COUNT(DISTINCT CASE WHEN months_since_first_order BETWEEN 7 AND 12 THEN c_custkey END) as month_7_12_customers,
        
        -- Revenue by retention period
        SUM(CASE WHEN months_since_first_order = 0 THEN o_totalprice ELSE 0 END) as month_0_revenue,
        SUM(CASE WHEN months_since_first_order BETWEEN 1 AND 3 THEN o_totalprice ELSE 0 END) as month_1_3_revenue,
        SUM(CASE WHEN months_since_first_order BETWEEN 4 AND 6 THEN o_totalprice ELSE 0 END) as month_4_6_revenue,
        SUM(CASE WHEN months_since_first_order BETWEEN 7 AND 12 THEN o_totalprice ELSE 0 END) as month_7_12_revenue
        
    FROM segment_activity
    GROUP BY c_mktsegment, acquisition_quarter
)

SELECT 
    c_mktsegment,
    acquisition_quarter,
    month_0_customers as initial_cohort_size,
    
    -- Retention rates
    ROUND(month_1_3_customers * 100.0 / NULLIF(month_0_customers, 0), 2) as retention_1_3_months_pct,
    ROUND(month_4_6_customers * 100.0 / NULLIF(month_0_customers, 0), 2) as retention_4_6_months_pct,
    ROUND(month_7_12_customers * 100.0 / NULLIF(month_0_customers, 0), 2) as retention_7_12_months_pct,
    
    -- Revenue per customer by period
    ROUND(month_0_revenue / NULLIF(month_0_customers, 0), 2) as revenue_per_customer_month_0,
    ROUND(month_1_3_revenue / NULLIF(month_1_3_customers, 0), 2) as revenue_per_customer_month_1_3,
    ROUND(month_4_6_revenue / NULLIF(month_4_6_customers, 0), 2) as revenue_per_customer_month_4_6,
    
    -- Total cohort value
    ROUND(month_0_revenue + month_1_3_revenue + month_4_6_revenue + month_7_12_revenue, 2) as total_cohort_revenue
    
FROM segment_retention_analysis
WHERE month_0_customers >= 2  -- Focus on meaningful cohort sizes
ORDER BY c_mktsegment, acquisition_quarter;

-- ============================================
-- PRODUCT USAGE PATTERNS OVER TIME
-- ============================================

-- WHAT IT IS: Product usage analysis tracks how customers interact with
-- different products or services over time, identifying usage patterns and preferences.
--
-- WHY IT MATTERS: Usage pattern analysis reveals:
-- - Which products drive long-term engagement
-- - How product preferences evolve over customer lifecycle
-- - Cross-selling and upselling opportunities
-- - Product-market fit indicators
--
-- USAGE METRICS: Product adoption rate, usage frequency, product mix evolution
-- BENCHMARK: Successful products show 60%+ adoption within first 3 months

-- Example 3: Product Category Usage Evolution
-- Business Question: "How does customer product usage evolve over their lifecycle?"

WITH customer_product_journey AS (
    SELECT 
        c.c_custkey,
        c.c_mktsegment,
        o.o_orderdate,
        
        -- Categorize parts by type for product analysis
        CASE 
            WHEN p.p_type LIKE '%STEEL%' THEN 'Steel Products'
            WHEN p.p_type LIKE '%BRASS%' THEN 'Brass Products'
            WHEN p.p_type LIKE '%COPPER%' THEN 'Copper Products'
            WHEN p.p_type LIKE '%NICKEL%' THEN 'Nickel Products'
            WHEN p.p_type LIKE '%TIN%' THEN 'Tin Products'
            ELSE 'Other Products'
        END as product_category,
        
        l.l_quantity,
        l.l_extendedprice,
        p.p_size
        
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    JOIN part p ON l.l_partkey = p.p_partkey
),

customer_acquisition_dates AS (
    SELECT 
        c_custkey,
        MIN(o_orderdate) as acquisition_date
    FROM customer_product_journey
    GROUP BY c_custkey
),

customer_product_journey_with_months AS (
    SELECT 
        cpj.*,
        DATEDIFF('month', cad.acquisition_date, cpj.o_orderdate) as months_since_acquisition
    FROM customer_product_journey cpj
    JOIN customer_acquisition_dates cad ON cpj.c_custkey = cad.c_custkey
),

product_usage_by_lifecycle AS (
    SELECT 
        CASE 
            WHEN months_since_acquisition = 0 THEN 'Month 0 (Acquisition)'
            WHEN months_since_acquisition BETWEEN 1 AND 3 THEN 'Months 1-3 (Early)'
            WHEN months_since_acquisition BETWEEN 4 AND 6 THEN 'Months 4-6 (Growth)'
            WHEN months_since_acquisition BETWEEN 7 AND 12 THEN 'Months 7-12 (Mature)'
            ELSE 'Beyond Year 1'
        END as lifecycle_stage,
        
        product_category,
        COUNT(DISTINCT c_custkey) as unique_customers,
        COUNT(*) as total_orders,
        SUM(l_quantity) as total_quantity,
        SUM(l_extendedprice) as total_revenue,
        AVG(l_extendedprice) as avg_order_value,
        AVG(p_size) as avg_product_size
        
    FROM customer_product_journey_with_months
    WHERE months_since_acquisition <= 12
    GROUP BY 
        CASE 
            WHEN months_since_acquisition = 0 THEN 'Month 0 (Acquisition)'
            WHEN months_since_acquisition BETWEEN 1 AND 3 THEN 'Months 1-3 (Early)'
            WHEN months_since_acquisition BETWEEN 4 AND 6 THEN 'Months 4-6 (Growth)'
            WHEN months_since_acquisition BETWEEN 7 AND 12 THEN 'Months 7-12 (Mature)'
            ELSE 'Beyond Year 1'
        END,
        product_category
)

SELECT 
    lifecycle_stage,
    product_category,
    unique_customers,
    total_orders,
    total_quantity,
    ROUND(total_revenue, 2) as total_revenue,
    ROUND(avg_order_value, 2) as avg_order_value,
    ROUND(avg_product_size, 2) as avg_product_size,
    
    -- Calculate product category share within lifecycle stage
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (PARTITION BY lifecycle_stage), 2) as category_revenue_share_pct,
    
    -- Calculate customer penetration
    ROUND(unique_customers * 100.0 / SUM(unique_customers) OVER (PARTITION BY lifecycle_stage), 2) as customer_penetration_pct
    
FROM product_usage_by_lifecycle
WHERE unique_customers > 0
ORDER BY lifecycle_stage, total_revenue DESC;

-- ============================================
-- SUBSCRIPTION LIFECYCLE SIMULATION
-- ============================================

-- WHAT IT IS: Subscription lifecycle analysis simulates subscription-based
-- business patterns using order frequency and customer behavior data.
--
-- WHY IT MATTERS: Subscription analysis provides:
-- - Understanding of customer engagement patterns
-- - Churn prediction and prevention insights
-- - Revenue forecasting and planning
-- - Customer lifetime value optimization
--
-- SIMULATION APPROACH: Use order frequency as proxy for subscription activity
-- BENCHMARK: Healthy subscription businesses maintain 95%+ monthly retention

-- Example 4: Simulated Subscription Lifecycle Analysis
-- Business Question: "If we treated repeat orders as subscription renewals, what would retention look like?"

WITH customer_order_frequency AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) as total_orders,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days,
        
        -- Calculate average days between orders (subscription frequency proxy)
        CASE 
            WHEN COUNT(o.o_orderkey) > 1 
            THEN DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) / (COUNT(o.o_orderkey) - 1)
            ELSE NULL
        END as avg_days_between_orders,
        
        SUM(o.o_totalprice) as total_revenue
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),

-- Simulate subscription tiers based on order frequency
subscription_tiers AS (
    SELECT 
        *,
        CASE 
            WHEN total_orders = 1 THEN 'One-time Customer'
            WHEN avg_days_between_orders <= 30 THEN 'Monthly Subscriber'
            WHEN avg_days_between_orders <= 90 THEN 'Quarterly Subscriber'
            WHEN avg_days_between_orders <= 180 THEN 'Semi-Annual Subscriber'
            WHEN avg_days_between_orders <= 365 THEN 'Annual Subscriber'
            ELSE 'Irregular Customer'
        END as subscription_tier,
        
        -- Calculate subscription value metrics
        CASE 
            WHEN total_orders > 1 AND avg_days_between_orders IS NOT NULL
            THEN total_revenue / (customer_lifespan_days / avg_days_between_orders)
            ELSE total_revenue
        END as avg_subscription_value
        
    FROM customer_order_frequency
),

-- Analyze subscription lifecycle patterns
subscription_lifecycle_analysis AS (
    SELECT 
        subscription_tier,
        c_mktsegment,
        COUNT(*) as customer_count,
        AVG(total_orders) as avg_orders_per_customer,
        AVG(customer_lifespan_days) as avg_lifespan_days,
        AVG(avg_days_between_orders) as avg_renewal_frequency_days,
        AVG(total_revenue) as avg_customer_ltv,
        AVG(avg_subscription_value) as avg_subscription_value,
        
        -- Calculate retention proxy (customers with multiple orders)
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) as retained_customers,
        ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*), 2) as retention_rate_pct
        
    FROM subscription_tiers
    GROUP BY subscription_tier, c_mktsegment
)

SELECT 
    subscription_tier,
    c_mktsegment,
    customer_count,
    ROUND(avg_orders_per_customer, 2) as avg_orders_per_customer,
    ROUND(avg_lifespan_days, 0) as avg_lifespan_days,
    ROUND(avg_renewal_frequency_days, 0) as avg_renewal_frequency_days,
    ROUND(avg_customer_ltv, 2) as avg_customer_ltv,
    ROUND(avg_subscription_value, 2) as avg_subscription_value,
    retained_customers,
    retention_rate_pct,
    
    -- Calculate subscription tier performance score
    ROUND((retention_rate_pct * avg_customer_ltv) / 1000, 2) as tier_performance_score
    
FROM subscription_lifecycle_analysis
WHERE customer_count >= 2  -- Focus on meaningful segments
ORDER BY tier_performance_score DESC, customer_count DESC;

-- ============================================
-- CHURN PREDICTION AND ANALYSIS
-- ============================================

-- WHAT IT IS: Churn analysis identifies customers at risk of leaving and
-- analyzes patterns that lead to customer attrition.
--
-- WHY IT MATTERS: Churn analysis enables:
-- - Proactive customer retention efforts
-- - Understanding of churn risk factors
-- - Revenue impact assessment of customer loss
-- - Optimization of customer success strategies
--
-- CHURN INDICATORS: Declining order frequency, reduced spend, long gaps
-- BENCHMARK: Proactive churn prevention can reduce churn by 15-25%

-- Example 5: Customer Churn Risk Analysis
-- Business Question: "Which customers are at risk of churning and why?"

WITH customer_behavior_metrics AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_mktsegment,
        COUNT(o.o_orderkey) as total_orders,
        SUM(o.o_totalprice) as total_spent,
        MIN(o.o_orderdate) as first_order_date,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MAX(o.o_orderdate), CURRENT_DATE) as days_since_last_order,
        
        -- Calculate order frequency trends
        AVG(o.o_totalprice) as avg_order_value,
        STDDEV(o.o_totalprice) as order_value_volatility,
        
        -- Calculate recency, frequency, monetary (RFM) components
        DATEDIFF('day', MAX(o.o_orderdate), CURRENT_DATE) as recency_days,
        COUNT(o.o_orderkey) as frequency_orders,
        SUM(o.o_totalprice) as monetary_value
        
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_custkey, c.c_name, c.c_mktsegment
),

-- Calculate churn risk scores
churn_risk_analysis AS (
    SELECT 
        *,
        -- Recency score (higher recency = higher churn risk)
        CASE 
            WHEN recency_days <= 30 THEN 1
            WHEN recency_days <= 90 THEN 2
            WHEN recency_days <= 180 THEN 3
            WHEN recency_days <= 365 THEN 4
            ELSE 5
        END as recency_risk_score,
        
        -- Frequency score (lower frequency = higher churn risk)
        CASE 
            WHEN frequency_orders >= 5 THEN 1
            WHEN frequency_orders >= 3 THEN 2
            WHEN frequency_orders >= 2 THEN 3
            ELSE 4
        END as frequency_risk_score,
        
        -- Monetary score (lower value = higher churn risk)
        CASE 
            WHEN monetary_value >= 500000 THEN 1
            WHEN monetary_value >= 200000 THEN 2
            WHEN monetary_value >= 100000 THEN 3
            ELSE 4
        END as monetary_risk_score,
        
        -- Order value volatility (higher volatility = higher risk)
        CASE 
            WHEN order_value_volatility IS NULL THEN 2  -- Single order customers
            WHEN order_value_volatility <= 50000 THEN 1
            WHEN order_value_volatility <= 100000 THEN 2
            ELSE 3
        END as volatility_risk_score
        
    FROM customer_behavior_metrics
),

-- Calculate composite churn risk
final_churn_analysis AS (
    SELECT 
        *,
        (recency_risk_score + frequency_risk_score + monetary_risk_score + volatility_risk_score) as composite_churn_risk_score,
        
        -- Classify churn risk levels
        CASE 
            WHEN (recency_risk_score + frequency_risk_score + monetary_risk_score + volatility_risk_score) <= 6 THEN 'Low Risk'
            WHEN (recency_risk_score + frequency_risk_score + monetary_risk_score + volatility_risk_score) <= 10 THEN 'Medium Risk'
            WHEN (recency_risk_score + frequency_risk_score + monetary_risk_score + volatility_risk_score) <= 14 THEN 'High Risk'
            ELSE 'Critical Risk'
        END as churn_risk_category
        
    FROM churn_risk_analysis
)

SELECT 
    churn_risk_category,
    c_mktsegment,
    COUNT(*) as customer_count,
    ROUND(AVG(recency_days), 0) as avg_days_since_last_order,
    ROUND(AVG(frequency_orders), 2) as avg_order_frequency,
    ROUND(AVG(monetary_value), 2) as avg_customer_value,
    ROUND(SUM(monetary_value), 2) as total_at_risk_revenue,
    ROUND(AVG(composite_churn_risk_score), 2) as avg_risk_score,
    
    -- Calculate percentage of customers in each risk category
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_customer_base,
    
    -- Calculate revenue at risk percentage
    ROUND(SUM(monetary_value) * 100.0 / SUM(SUM(monetary_value)) OVER (), 2) as pct_of_total_revenue
    
FROM final_churn_analysis
GROUP BY churn_risk_category, c_mktsegment
ORDER BY 
    CASE churn_risk_category
        WHEN 'Critical Risk' THEN 1
        WHEN 'High Risk' THEN 2
        WHEN 'Medium Risk' THEN 3
        WHEN 'Low Risk' THEN 4
    END,
    total_at_risk_revenue DESC;

-- ============================================
-- COHORT LIFETIME VALUE ANALYSIS
-- ============================================

-- WHAT IT IS: Cohort lifetime value analysis calculates the total value
-- generated by customer cohorts over their entire lifecycle.
--
-- WHY IT MATTERS: CLV analysis provides:
-- - Customer acquisition cost (CAC) payback insights
-- - Long-term profitability forecasting
-- - Marketing budget allocation guidance
-- - Customer segment prioritization

-- Example 6: Cohort-Based Customer Lifetime Value
-- Business Question: "What is the lifetime value progression of different customer cohorts?"

WITH cohort_clv_analysis AS (
    SELECT 
        c.c_mktsegment,
        c.c_custkey,
        MIN(o.o_orderdate) as acquisition_date,
        DATE_TRUNC('quarter', MIN(o.o_orderdate)) as acquisition_cohort,
        COUNT(o.o_orderkey) as lifetime_orders,
        SUM(o.o_totalprice) as lifetime_value,
        MAX(o.o_orderdate) as last_order_date,
        DATEDIFF('day', MIN(o.o_orderdate), MAX(o.o_orderdate)) as customer_lifespan_days
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_mktsegment, c.c_custkey
),

cohort_clv_summary AS (
    SELECT 
        acquisition_cohort,
        c_mktsegment,
        COUNT(*) as cohort_size,
        AVG(lifetime_orders) as avg_lifetime_orders,
        AVG(lifetime_value) as avg_customer_ltv,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lifetime_value) as median_customer_ltv,
        AVG(customer_lifespan_days) as avg_lifespan_days,
        SUM(lifetime_value) as total_cohort_value,
        
        -- Calculate LTV distribution
        COUNT(CASE WHEN lifetime_value >= 500000 THEN 1 END) as high_value_customers,
        COUNT(CASE WHEN lifetime_value BETWEEN 100000 AND 499999 THEN 1 END) as medium_value_customers,
        COUNT(CASE WHEN lifetime_value < 100000 THEN 1 END) as low_value_customers
        
    FROM cohort_clv_analysis
    GROUP BY acquisition_cohort, c_mktsegment
)

SELECT 
    acquisition_cohort,
    c_mktsegment,
    cohort_size,
    ROUND(avg_lifetime_orders, 2) as avg_lifetime_orders,
    ROUND(avg_customer_ltv, 2) as avg_customer_ltv,
    ROUND(median_customer_ltv, 2) as median_customer_ltv,
    ROUND(avg_lifespan_days, 0) as avg_lifespan_days,
    ROUND(total_cohort_value, 2) as total_cohort_value,
    
    -- Value distribution
    high_value_customers,
    medium_value_customers,
    low_value_customers,
    
    -- Calculate value concentration
    ROUND(high_value_customers * 100.0 / cohort_size, 2) as high_value_customer_pct,
    
    -- Calculate cohort performance metrics
    ROUND(total_cohort_value / cohort_size, 2) as revenue_per_customer,
    ROUND(avg_customer_ltv / NULLIF(avg_lifespan_days, 0) * 365, 2) as annualized_customer_value
    
FROM cohort_clv_summary
WHERE cohort_size >= 3  -- Focus on meaningful cohort sizes
ORDER BY acquisition_cohort, avg_customer_ltv DESC;

-- ============================================
-- COHORT RETENTION ANALYSIS BEST PRACTICES SUMMARY
-- ============================================

-- 1. ACQUISITION COHORT ANALYSIS:
--    - Group customers by acquisition period (month/quarter)
--    - Track retention rates over consistent time periods
--    - Include both customer count and revenue retention

-- 2. BEHAVIORAL COHORT ANALYSIS:
--    - Segment customers by actions, not just acquisition date
--    - Analyze product usage patterns and preferences
--    - Track cross-selling and upselling success

-- 3. SUBSCRIPTION LIFECYCLE SIMULATION:
--    - Use order frequency as proxy for subscription behavior
--    - Calculate renewal rates and subscription value
--    - Identify optimal subscription tiers and pricing

-- 4. CHURN PREDICTION:
--    - Implement RFM (Recency, Frequency, Monetary) analysis
--    - Create composite risk scores for churn prediction
--    - Focus on high-value customers at risk

-- 5. LIFETIME VALUE ANALYSIS:
--    - Calculate cohort-based CLV for accurate forecasting
--    - Analyze value distribution within cohorts
--    - Use CLV for customer acquisition cost optimization

-- 6. ACTIONABLE INSIGHTS:
--    - Identify which cohorts have the best retention
--    - Understand product usage evolution over customer lifecycle
--    - Prioritize retention efforts based on risk and value

-- These cohort retention analysis patterns provide deep insights into
-- customer behavior, enabling data-driven decisions for customer success,
-- product development, and marketing optimization strategies.