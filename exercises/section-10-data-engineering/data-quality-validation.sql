-- DATA QUALITY VALIDATION - Practical Data Engineering with SQL
-- This file demonstrates comprehensive data quality assessment and validation techniques
-- using both TPC-H and Star Wars databases for realistic data engineering scenarios
-- ============================================
-- REQUIRED: This file uses both TPC-H and Star Wars databases
-- Setup TPC-H: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-10-data-engineering/data-quality-validation.sql
-- ============================================

-- DATA QUALITY CONCEPTS:
-- - Data Profiling: Understanding the structure, content, and quality of data
-- - Completeness: Measuring missing or null values in datasets
-- - Uniqueness: Identifying and handling duplicate records
-- - Validity: Ensuring data conforms to business rules and constraints
-- - Consistency: Checking data integrity across related tables
-- - Accuracy: Validating data against known standards or reference data

-- BUSINESS CONTEXT:
-- Data quality is critical for reliable analytics and business decisions
-- Poor data quality costs organizations an average of $15 million annually
-- Automated data quality checks prevent downstream issues and build trust
-- This section shows practical techniques for assessing and improving data quality

-- ============================================
-- DATA PROFILING FUNDAMENTALS
-- ============================================

-- WHAT IT IS: Data profiling analyzes datasets to understand their structure,
-- content patterns, and quality characteristics before processing or analysis.
--
-- WHY IT MATTERS: Profiling helps:
-- - Identify data quality issues early in the pipeline
-- - Understand data distributions and patterns
-- - Plan appropriate data transformations
-- - Set realistic expectations for data consumers
--
-- KEY METRICS: Row counts, null percentages, distinct values, min/max ranges
-- BENCHMARK: Profile all new datasets before production use

-- Example 1: Comprehensive Data Profile for Customer Table
-- Business Question: "What's the overall quality and structure of our customer data?"

WITH customer_profile AS (
    SELECT 
        'customer' as table_name,
        COUNT(*) as total_rows,
        COUNT(DISTINCT c_custkey) as unique_customers,
        
        -- Completeness Analysis
        COUNT(c_name) as name_populated,
        COUNT(*) - COUNT(c_name) as name_missing,
        ROUND((COUNT(c_name) * 100.0 / COUNT(*)), 2) as name_completeness_pct,
        
        COUNT(c_address) as address_populated,
        ROUND((COUNT(c_address) * 100.0 / COUNT(*)), 2) as address_completeness_pct,
        
        COUNT(c_phone) as phone_populated,
        ROUND((COUNT(c_phone) * 100.0 / COUNT(*)), 2) as phone_completeness_pct,
        
        -- Value Distribution Analysis
        COUNT(DISTINCT c_mktsegment) as unique_segments,
        COUNT(DISTINCT c_nationkey) as unique_nations,
        
        -- Numeric Analysis
        MIN(c_acctbal) as min_account_balance,
        MAX(c_acctbal) as max_account_balance,
        ROUND(AVG(c_acctbal), 2) as avg_account_balance,
        ROUND(STDDEV(c_acctbal), 2) as stddev_account_balance
    FROM customer
)
SELECT 
    table_name,
    total_rows,
    unique_customers,
    CASE WHEN total_rows = unique_customers THEN 'PASS' ELSE 'FAIL' END as uniqueness_check,
    name_populated,
    name_missing,
    name_completeness_pct,
    address_completeness_pct,
    phone_completeness_pct,
    unique_segments,
    unique_nations,
    min_account_balance,
    max_account_balance,
    avg_account_balance,
    stddev_account_balance
FROM customer_profile;

-- Example 2: Multi-Table Data Profile Summary
-- Business Question: "What's the data quality status across all our main tables?"

WITH table_profiles AS (
    SELECT 
        'customer' as table_name,
        COUNT(*) as row_count,
        COUNT(DISTINCT c_custkey) as unique_keys,
        ROUND(AVG(CASE WHEN c_name IS NULL THEN 1.0 ELSE 0.0 END) * 100, 2) as null_pct_key_field
    FROM customer
    
    UNION ALL
    
    SELECT 
        'orders' as table_name,
        COUNT(*) as row_count,
        COUNT(DISTINCT o_orderkey) as unique_keys,
        ROUND(AVG(CASE WHEN o_orderdate IS NULL THEN 1.0 ELSE 0.0 END) * 100, 2) as null_pct_key_field
    FROM orders
    
    UNION ALL
    
    SELECT 
        'lineitem' as table_name,
        COUNT(*) as row_count,
        COUNT(DISTINCT CONCAT(l_orderkey, '-', l_linenumber)) as unique_keys,
        ROUND(AVG(CASE WHEN l_quantity IS NULL THEN 1.0 ELSE 0.0 END) * 100, 2) as null_pct_key_field
    FROM lineitem
    
    UNION ALL
    
    SELECT 
        'part' as table_name,
        COUNT(*) as row_count,
        COUNT(DISTINCT p_partkey) as unique_keys,
        ROUND(AVG(CASE WHEN p_name IS NULL THEN 1.0 ELSE 0.0 END) * 100, 2) as null_pct_key_field
    FROM part
    
    UNION ALL
    
    SELECT 
        'supplier' as table_name,
        COUNT(*) as row_count,
        COUNT(DISTINCT s_suppkey) as unique_keys,
        ROUND(AVG(CASE WHEN s_name IS NULL THEN 1.0 ELSE 0.0 END) * 100, 2) as null_pct_key_field
    FROM supplier
)
SELECT 
    table_name,
    row_count,
    unique_keys,
    CASE WHEN row_count = unique_keys THEN 'UNIQUE' ELSE 'DUPLICATES' END as uniqueness_status,
    null_pct_key_field,
    CASE 
        WHEN null_pct_key_field = 0 THEN 'EXCELLENT'
        WHEN null_pct_key_field < 5 THEN 'GOOD'
        WHEN null_pct_key_field < 15 THEN 'FAIR'
        ELSE 'POOR'
    END as data_quality_rating
FROM table_profiles
ORDER BY row_count DESC;

-- ============================================
-- DUPLICATE DETECTION AND ANALYSIS
-- ============================================

-- WHAT IT IS: Duplicate detection identifies records that appear multiple times
-- in a dataset, either as exact duplicates or near-duplicates with similar values.
--
-- WHY IT MATTERS: Duplicates can:
-- - Skew analytical results and business metrics
-- - Cause data processing errors and inconsistencies
-- - Waste storage space and processing resources
-- - Lead to incorrect business decisions
--
-- DETECTION METHODS: Exact matching, fuzzy matching, composite key analysis
-- BENCHMARK: Aim for <1% duplicate rate in master data tables

-- Example 3: Exact Duplicate Detection
-- Business Question: "Do we have any exact duplicate records in our data?"

-- Check for exact duplicates in customer table
WITH customer_duplicates AS (
    SELECT 
        c_name,
        c_address,
        c_nationkey,
        c_phone,
        c_mktsegment,
        COUNT(*) as duplicate_count
    FROM customer
    GROUP BY c_name, c_address, c_nationkey, c_phone, c_mktsegment
    HAVING COUNT(*) > 1
)
SELECT 
    'Customer Exact Duplicates' as check_type,
    COUNT(*) as duplicate_groups,
    SUM(duplicate_count) as total_duplicate_records,
    SUM(duplicate_count - 1) as records_to_remove
FROM customer_duplicates;

-- Check for potential duplicates based on name similarity
WITH name_analysis AS (
    SELECT 
        c_custkey,
        c_name,
        UPPER(TRIM(c_name)) as normalized_name,
        COUNT(*) OVER (PARTITION BY UPPER(TRIM(c_name))) as name_frequency
    FROM customer
)
SELECT 
    'Potential Name Duplicates' as check_type,
    COUNT(*) as suspicious_records,
    COUNT(DISTINCT normalized_name) as unique_normalized_names
FROM name_analysis
WHERE name_frequency > 1;

-- Example 4: Composite Key Duplicate Analysis
-- Business Question: "Are there any duplicate order line items that shouldn't exist?"

WITH lineitem_duplicates AS (
    SELECT 
        l_orderkey,
        l_linenumber,
        COUNT(*) as occurrence_count,
        STRING_AGG(CAST(l_partkey AS VARCHAR), ', ') as part_keys,
        STRING_AGG(CAST(l_suppkey AS VARCHAR), ', ') as supplier_keys
    FROM lineitem
    GROUP BY l_orderkey, l_linenumber
    HAVING COUNT(*) > 1
)
SELECT 
    'LineItem Composite Key Duplicates' as check_type,
    COUNT(*) as duplicate_line_groups,
    SUM(occurrence_count) as total_duplicate_lines,
    AVG(occurrence_count) as avg_duplicates_per_group
FROM lineitem_duplicates;

-- Example 5: Advanced Duplicate Detection with Similarity Scoring
-- Business Question: "Find potential duplicates using fuzzy matching techniques"

WITH supplier_similarity AS (
    SELECT 
        s1.s_suppkey as supplier1_key,
        s1.s_name as supplier1_name,
        s2.s_suppkey as supplier2_key,
        s2.s_name as supplier2_name,
        s1.s_nationkey as nation1,
        s2.s_nationkey as nation2,
        -- Simple similarity score based on name length and common characters
        CASE 
            WHEN s1.s_name = s2.s_name THEN 100
            WHEN UPPER(s1.s_name) = UPPER(s2.s_name) THEN 95
            WHEN LENGTH(s1.s_name) = LENGTH(s2.s_name) AND s1.s_nationkey = s2.s_nationkey THEN 80
            WHEN s1.s_nationkey = s2.s_nationkey AND ABS(LENGTH(s1.s_name) - LENGTH(s2.s_name)) <= 2 THEN 60
            ELSE 0
        END as similarity_score
    FROM supplier s1
    INNER JOIN supplier s2 ON s1.s_suppkey < s2.s_suppkey  -- Avoid self-joins and duplicates
    WHERE s1.s_nationkey = s2.s_nationkey  -- Same nation increases likelihood
)
SELECT 
    supplier1_key,
    supplier1_name,
    supplier2_key,
    supplier2_name,
    nation1,
    similarity_score,
    CASE 
        WHEN similarity_score >= 95 THEN 'HIGH - Likely Duplicate'
        WHEN similarity_score >= 80 THEN 'MEDIUM - Investigate'
        WHEN similarity_score >= 60 THEN 'LOW - Possible Match'
        ELSE 'NO MATCH'
    END as duplicate_likelihood
FROM supplier_similarity
WHERE similarity_score >= 60
ORDER BY similarity_score DESC, supplier1_key;

-- ============================================
-- MISSING VALUE ANALYSIS
-- ============================================

-- WHAT IT IS: Missing value analysis identifies patterns in incomplete data
-- to understand why data is missing and how to handle it appropriately.
--
-- WHY IT MATTERS: Missing data can:
-- - Bias analytical results and statistical models
-- - Reduce the power of statistical tests
-- - Lead to incorrect business conclusions
-- - Indicate data collection or processing issues
--
-- MISSING TYPES: Missing Completely at Random (MCAR), Missing at Random (MAR), Missing Not at Random (MNAR)
-- BENCHMARK: <5% missing values for critical business fields

-- Example 6: Comprehensive Missing Value Analysis
-- Business Question: "What's the pattern of missing values across our dataset?"

WITH missing_analysis AS (
    SELECT 
        'customer' as table_name,
        'c_name' as column_name,
        COUNT(*) as total_records,
        COUNT(c_name) as populated_records,
        COUNT(*) - COUNT(c_name) as missing_records,
        ROUND((COUNT(*) - COUNT(c_name)) * 100.0 / COUNT(*), 2) as missing_percentage
    FROM customer
    
    UNION ALL
    
    SELECT 
        'customer' as table_name,
        'c_address' as column_name,
        COUNT(*) as total_records,
        COUNT(c_address) as populated_records,
        COUNT(*) - COUNT(c_address) as missing_records,
        ROUND((COUNT(*) - COUNT(c_address)) * 100.0 / COUNT(*), 2) as missing_percentage
    FROM customer
    
    UNION ALL
    
    SELECT 
        'customer' as table_name,
        'c_phone' as column_name,
        COUNT(*) as total_records,
        COUNT(c_phone) as populated_records,
        COUNT(*) - COUNT(c_phone) as missing_records,
        ROUND((COUNT(*) - COUNT(c_phone)) * 100.0 / COUNT(*), 2) as missing_percentage
    FROM customer
    
    UNION ALL
    
    SELECT 
        'orders' as table_name,
        'o_comment' as column_name,
        COUNT(*) as total_records,
        COUNT(o_comment) as populated_records,
        COUNT(*) - COUNT(o_comment) as missing_records,
        ROUND((COUNT(*) - COUNT(o_comment)) * 100.0 / COUNT(*), 2) as missing_percentage
    FROM orders
)
SELECT 
    table_name,
    column_name,
    total_records,
    populated_records,
    missing_records,
    missing_percentage,
    CASE 
        WHEN missing_percentage = 0 THEN 'COMPLETE'
        WHEN missing_percentage < 5 THEN 'EXCELLENT'
        WHEN missing_percentage < 15 THEN 'GOOD'
        WHEN missing_percentage < 30 THEN 'FAIR'
        ELSE 'POOR'
    END as completeness_rating
FROM missing_analysis
ORDER BY missing_percentage DESC;

-- Example 7: Missing Value Pattern Analysis
-- Business Question: "Are missing values random or do they follow patterns?"

WITH customer_missing_patterns AS (
    SELECT 
        c_custkey,
        c_mktsegment,
        c_nationkey,
        CASE WHEN c_name IS NULL THEN 1 ELSE 0 END as name_missing,
        CASE WHEN c_address IS NULL THEN 1 ELSE 0 END as address_missing,
        CASE WHEN c_phone IS NULL THEN 1 ELSE 0 END as phone_missing,
        CASE WHEN c_comment IS NULL THEN 1 ELSE 0 END as comment_missing
    FROM customer
),
pattern_summary AS (
    SELECT 
        c_mktsegment,
        COUNT(*) as total_customers,
        SUM(name_missing) as name_missing_count,
        SUM(address_missing) as address_missing_count,
        SUM(phone_missing) as phone_missing_count,
        SUM(comment_missing) as comment_missing_count,
        SUM(name_missing + address_missing + phone_missing + comment_missing) as total_missing_fields
    FROM customer_missing_patterns
    GROUP BY c_mktsegment
)
SELECT 
    c_mktsegment,
    total_customers,
    name_missing_count,
    address_missing_count,
    phone_missing_count,
    comment_missing_count,
    total_missing_fields,
    ROUND(total_missing_fields::DECIMAL / (total_customers * 4) * 100, 2) as overall_missing_pct,
    CASE 
        WHEN total_missing_fields = 0 THEN 'NO MISSING DATA'
        WHEN total_missing_fields < total_customers * 0.1 THEN 'LOW MISSING'
        WHEN total_missing_fields < total_customers * 0.3 THEN 'MODERATE MISSING'
        ELSE 'HIGH MISSING'
    END as missing_severity
FROM pattern_summary
ORDER BY overall_missing_pct DESC;

-- ============================================
-- DATA CONSISTENCY VALIDATION
-- ============================================

-- WHAT IT IS: Data consistency validation ensures that related data across
-- tables maintains logical relationships and business rule compliance.
--
-- WHY IT MATTERS: Inconsistent data leads to:
-- - Incorrect analytical results and reporting
-- - Failed data processing and ETL jobs
-- - Loss of trust in data systems
-- - Compliance and audit issues
--
-- VALIDATION TYPES: Referential integrity, business rule compliance, cross-table consistency
-- BENCHMARK: 100% consistency for critical business relationships

-- Example 8: Referential Integrity Validation
-- Business Question: "Are all foreign key relationships properly maintained?"

-- Check customer-nation relationship
WITH customer_nation_check AS (
    SELECT 
        'customer-nation' as relationship,
        COUNT(*) as total_customers,
        COUNT(n.n_nationkey) as valid_nation_refs,
        COUNT(*) - COUNT(n.n_nationkey) as invalid_nation_refs
    FROM customer c
    LEFT JOIN nation n ON c.c_nationkey = n.n_nationkey
),
-- Check orders-customer relationship
order_customer_check AS (
    SELECT 
        'orders-customer' as relationship,
        COUNT(*) as total_orders,
        COUNT(c.c_custkey) as valid_customer_refs,
        COUNT(*) - COUNT(c.c_custkey) as invalid_customer_refs
    FROM orders o
    LEFT JOIN customer c ON o.o_custkey = c.c_custkey
),
-- Check lineitem-orders relationship
lineitem_order_check AS (
    SELECT 
        'lineitem-orders' as relationship,
        COUNT(*) as total_lineitems,
        COUNT(o.o_orderkey) as valid_order_refs,
        COUNT(*) - COUNT(o.o_orderkey) as invalid_order_refs
    FROM lineitem l
    LEFT JOIN orders o ON l.l_orderkey = o.o_orderkey
)
SELECT relationship, total_customers as total_records, valid_nation_refs as valid_refs, invalid_nation_refs as invalid_refs,
       CASE WHEN invalid_nation_refs = 0 THEN 'PASS' ELSE 'FAIL' END as integrity_status
FROM customer_nation_check
UNION ALL
SELECT relationship, total_orders, valid_customer_refs, invalid_customer_refs,
       CASE WHEN invalid_customer_refs = 0 THEN 'PASS' ELSE 'FAIL' END
FROM order_customer_check
UNION ALL
SELECT relationship, total_lineitems, valid_order_refs, invalid_order_refs,
       CASE WHEN invalid_order_refs = 0 THEN 'PASS' ELSE 'FAIL' END
FROM lineitem_order_check;

-- Example 9: Business Rule Validation
-- Business Question: "Do our records comply with business rules and constraints?"

WITH business_rule_checks AS (
    -- Rule 1: Order dates should not be in the future
    SELECT 
        'Future Order Dates' as rule_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN o_orderdate > CURRENT_DATE THEN 1 END) as violations,
        'Orders should not have future dates' as rule_description
    FROM orders
    
    UNION ALL
    
    -- Rule 2: Line item quantities should be positive
    SELECT 
        'Negative Quantities' as rule_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN l_quantity <= 0 THEN 1 END) as violations,
        'Line item quantities must be positive' as rule_description
    FROM lineitem
    
    UNION ALL
    
    -- Rule 3: Customer account balances should be reasonable
    SELECT 
        'Extreme Account Balances' as rule_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN c_acctbal < -999999 OR c_acctbal > 999999 THEN 1 END) as violations,
        'Account balances should be within reasonable range' as rule_description
    FROM customer
    
    UNION ALL
    
    -- Rule 4: Part retail prices should be positive
    SELECT 
        'Non-positive Prices' as rule_name,
        COUNT(*) as total_records,
        COUNT(CASE WHEN p_retailprice <= 0 THEN 1 END) as violations,
        'Part retail prices must be positive' as rule_description
    FROM part
)
SELECT 
    rule_name,
    total_records,
    violations,
    ROUND(violations * 100.0 / total_records, 2) as violation_percentage,
    CASE 
        WHEN violations = 0 THEN 'PASS'
        WHEN violations * 100.0 / total_records < 1 THEN 'WARNING'
        ELSE 'FAIL'
    END as compliance_status,
    rule_description
FROM business_rule_checks
ORDER BY violation_percentage DESC;

-- ============================================
-- STATISTICAL OUTLIER DETECTION
-- ============================================

-- WHAT IT IS: Statistical outlier detection identifies data points that deviate
-- significantly from the normal distribution or expected patterns in the dataset.
--
-- WHY IT MATTERS: Outliers can indicate:
-- - Data entry errors or system malfunctions
-- - Fraudulent activities or anomalous behavior
-- - Exceptional business events worth investigating
-- - Data quality issues requiring attention
--
-- DETECTION METHODS: Z-score, IQR method, percentile-based, domain-specific rules
-- BENCHMARK: Investigate values beyond 2-3 standard deviations from the mean

-- Example 10: Z-Score Based Outlier Detection
-- Business Question: "Which records have statistically unusual values?"

WITH customer_stats AS (
    SELECT 
        AVG(c_acctbal) as mean_balance,
        STDDEV(c_acctbal) as stddev_balance,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY c_acctbal) as q1_balance,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY c_acctbal) as q3_balance
    FROM customer
),
customer_outliers AS (
    SELECT 
        c.c_custkey,
        c.c_name,
        c.c_acctbal,
        cs.mean_balance,
        cs.stddev_balance,
        -- Z-score calculation
        (c.c_acctbal - cs.mean_balance) / cs.stddev_balance as z_score,
        -- IQR method
        cs.q3_balance - cs.q1_balance as iqr,
        cs.q1_balance - 1.5 * (cs.q3_balance - cs.q1_balance) as lower_fence,
        cs.q3_balance + 1.5 * (cs.q3_balance - cs.q1_balance) as upper_fence
    FROM customer c
    CROSS JOIN customer_stats cs
)
SELECT 
    c_custkey,
    c_name,
    c_acctbal,
    ROUND(z_score, 2) as z_score,
    CASE 
        WHEN ABS(z_score) > 3 THEN 'EXTREME OUTLIER'
        WHEN ABS(z_score) > 2 THEN 'MODERATE OUTLIER'
        WHEN ABS(z_score) > 1.5 THEN 'MILD OUTLIER'
        ELSE 'NORMAL'
    END as z_score_classification,
    CASE 
        WHEN c_acctbal < lower_fence OR c_acctbal > upper_fence THEN 'IQR OUTLIER'
        ELSE 'IQR NORMAL'
    END as iqr_classification
FROM customer_outliers
WHERE ABS(z_score) > 2 OR c_acctbal < lower_fence OR c_acctbal > upper_fence
ORDER BY ABS(z_score) DESC
LIMIT 20;

-- Example 11: Multi-Dimensional Outlier Detection
-- Business Question: "Find orders with unusual combinations of characteristics"

WITH order_stats AS (
    SELECT 
        AVG(o_totalprice) as mean_price,
        STDDEV(o_totalprice) as stddev_price,
        AVG(o_shippriority) as mean_ship_priority,
        STDDEV(o_shippriority) as stddev_ship_priority
    FROM orders
    WHERE o_shippriority IS NOT NULL
),
order_analysis AS (
    SELECT 
        o.o_orderkey,
        o.o_custkey,
        o.o_totalprice,
        o.o_orderdate,
        o.o_shippriority,
        -- Calculate z-scores for multiple dimensions
        (o.o_totalprice - os.mean_price) / os.stddev_price as price_z_score,
        (o.o_shippriority - os.mean_ship_priority) / os.stddev_ship_priority as priority_z_score,
        -- Count line items per order
        (SELECT COUNT(*) FROM lineitem l WHERE l.l_orderkey = o.o_orderkey) as line_item_count
    FROM orders o
    CROSS JOIN order_stats os
    WHERE o.o_shippriority IS NOT NULL
)
SELECT 
    o_orderkey,
    o_custkey,
    o_totalprice,
    o_orderdate,
    o_shippriority,
    line_item_count,
    ROUND(price_z_score, 2) as price_z_score,
    ROUND(priority_z_score, 2) as priority_z_score,
    -- Composite outlier score
    ROUND(SQRT(price_z_score * price_z_score + priority_z_score * priority_z_score), 2) as composite_outlier_score,
    CASE 
        WHEN SQRT(price_z_score * price_z_score + priority_z_score * priority_z_score) > 3 THEN 'HIGH PRIORITY'
        WHEN SQRT(price_z_score * price_z_score + priority_z_score * priority_z_score) > 2 THEN 'MEDIUM PRIORITY'
        WHEN SQRT(price_z_score * price_z_score + priority_z_score * priority_z_score) > 1.5 THEN 'LOW PRIORITY'
        ELSE 'NORMAL'
    END as investigation_priority
FROM order_analysis
WHERE SQRT(price_z_score * price_z_score + priority_z_score * priority_z_score) > 1.5
ORDER BY composite_outlier_score DESC
LIMIT 25;

-- ============================================
-- DATA QUALITY SUMMARY DASHBOARD
-- ============================================

-- WHAT IT IS: A comprehensive data quality dashboard provides executives and
-- data teams with a high-level view of data health across all systems.
--
-- WHY IT MATTERS: Executive dashboards enable:
-- - Quick assessment of overall data quality status
-- - Identification of areas requiring immediate attention
-- - Tracking of data quality improvements over time
-- - Data-driven decisions about data investments

-- Example 12: Executive Data Quality Dashboard
-- Business Question: "What's our overall data quality status at a glance?"

WITH quality_summary AS (
    -- Table completeness
    SELECT 
        'Table Completeness' as metric_category,
        'Customer Records' as metric_name,
        COUNT(*) as metric_value,
        'Records' as unit,
        CASE WHEN COUNT(*) > 100 THEN 'GOOD' ELSE 'POOR' END as status
    FROM customer
    
    UNION ALL
    
    SELECT 
        'Table Completeness',
        'Order Records',
        COUNT(*),
        'Records',
        CASE WHEN COUNT(*) > 1000 THEN 'GOOD' ELSE 'POOR' END
    FROM orders
    
    UNION ALL
    
    -- Data freshness
    SELECT 
        'Data Freshness',
        'Latest Order Date',
        DATEDIFF('day', MAX(o_orderdate), CURRENT_DATE),
        'Days Ago',
        CASE 
            WHEN DATEDIFF('day', MAX(o_orderdate), CURRENT_DATE) <= 1 THEN 'EXCELLENT'
            WHEN DATEDIFF('day', MAX(o_orderdate), CURRENT_DATE) <= 7 THEN 'GOOD'
            WHEN DATEDIFF('day', MAX(o_orderdate), CURRENT_DATE) <= 30 THEN 'FAIR'
            ELSE 'POOR'
        END
    FROM orders
    
    UNION ALL
    
    -- Referential integrity
    SELECT 
        'Data Integrity',
        'Customer-Order Links',
        COUNT(c.c_custkey) * 100 / COUNT(*),
        'Percent Valid',
        CASE WHEN COUNT(c.c_custkey) = COUNT(*) THEN 'EXCELLENT' ELSE 'POOR' END
    FROM orders o
    LEFT JOIN customer c ON o.o_custkey = c.c_custkey
    
    UNION ALL
    
    -- Duplicate detection
    SELECT 
        'Data Uniqueness',
        'Customer Duplicates',
        COUNT(*) - COUNT(DISTINCT c_custkey),
        'Duplicate Records',
        CASE WHEN COUNT(*) = COUNT(DISTINCT c_custkey) THEN 'EXCELLENT' ELSE 'POOR' END
    FROM customer
)
SELECT 
    metric_category,
    metric_name,
    metric_value,
    unit,
    status,
    CASE 
        WHEN status = 'EXCELLENT' THEN '🟢'
        WHEN status = 'GOOD' THEN '🟡'
        WHEN status = 'FAIR' THEN '🟠'
        ELSE '🔴'
    END as status_indicator
FROM quality_summary
ORDER BY metric_category, metric_name;

-- ============================================
-- DATA QUALITY BEST PRACTICES SUMMARY
-- ============================================

-- 1. DATA PROFILING:
--    - Profile all new datasets before production use
--    - Automate profiling for regular data quality monitoring
--    - Document data quality expectations and thresholds

-- 2. DUPLICATE DETECTION:
--    - Implement both exact and fuzzy duplicate detection
--    - Use composite keys for complex duplicate scenarios
--    - Establish clear deduplication rules and processes

-- 3. MISSING VALUE HANDLING:
--    - Analyze missing value patterns to understand root causes
--    - Implement appropriate imputation strategies by data type
--    - Monitor missing value trends over time

-- 4. CONSISTENCY VALIDATION:
--    - Validate referential integrity across all table relationships
--    - Implement business rule validation for critical constraints
--    - Use automated checks in data pipelines

-- 5. OUTLIER DETECTION:
--    - Use multiple statistical methods for comprehensive detection
--    - Establish domain-specific outlier rules and thresholds
--    - Investigate outliers promptly to prevent downstream issues

-- 6. MONITORING AND ALERTING:
--    - Create automated data quality monitoring dashboards
--    - Set up alerts for critical data quality threshold breaches
--    - Track data quality metrics over time for trend analysis

-- These data quality validation techniques provide the foundation for reliable
-- data engineering pipelines and trustworthy analytics systems.