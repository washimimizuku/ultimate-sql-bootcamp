-- DATA MONITORING - Practical Data Engineering with SQL
-- This file demonstrates comprehensive data monitoring and observability patterns
-- for data engineering pipelines using SQL-based monitoring techniques
-- ============================================
-- REQUIRED: This file uses TPC-H database and Star Wars CSV/JSON/Parquet files
-- Setup TPC-H: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-10-data-engineering/data-monitoring.sql
-- ============================================

-- DATA MONITORING CONCEPTS:
-- - Data Quality Monitoring: Tracking data accuracy, completeness, and consistency
-- - Pipeline Health Monitoring: Monitoring ETL job performance and reliability
-- - Data Freshness Monitoring: Ensuring data is current and up-to-date
-- - Anomaly Detection: Identifying unusual patterns or outliers in data
-- - SLA Monitoring: Tracking service level agreement compliance
-- - Alert Management: Automated notifications for data issues

-- BUSINESS CONTEXT:
-- Data monitoring is essential for maintaining trust in data systems and
-- ensuring reliable analytics and decision-making. Modern data engineering
-- requires proactive monitoring to detect issues before they impact business
-- operations and to maintain high data quality standards.

-- ============================================
-- DATA QUALITY MONITORING DASHBOARDS
-- ============================================

-- WHAT IT IS: Data quality monitoring tracks key metrics about data accuracy,
-- completeness, consistency, and validity across all data sources and pipelines.
--
-- WHY IT MATTERS: Quality monitoring enables:
-- - Early detection of data quality degradation
-- - Proactive resolution of data issues before business impact
-- - Compliance with data governance and regulatory requirements
-- - Improved confidence in data-driven decision making
--
-- QUALITY DIMENSIONS: Accuracy, completeness, consistency, validity, timeliness
-- BENCHMARK: Data quality scores should maintain 95%+ across all dimensions

-- Example 1: Comprehensive Data Quality Dashboard
-- Business Question: "How do we monitor data quality across all our data sources?"

-- Create data quality metrics for customer data
CREATE TEMPORARY TABLE customer_quality_metrics AS
SELECT 
    'customer_data' as data_source,
    'TPC-H Database' as source_system,
    COUNT(*) as total_records,
    
    -- Completeness metrics
    COUNT(CASE WHEN c_name IS NOT NULL AND TRIM(c_name) != '' THEN 1 END) as complete_names,
    COUNT(CASE WHEN c_address IS NOT NULL AND TRIM(c_address) != '' THEN 1 END) as complete_addresses,
    COUNT(CASE WHEN c_phone IS NOT NULL AND TRIM(c_phone) != '' THEN 1 END) as complete_phones,
    
    -- Validity metrics
    COUNT(CASE WHEN c_acctbal IS NOT NULL AND c_acctbal >= -999999 AND c_acctbal <= 999999 THEN 1 END) as valid_balances,
    COUNT(CASE WHEN c_mktsegment IN ('AUTOMOBILE', 'BUILDING', 'FURNITURE', 'HOUSEHOLD', 'MACHINERY') THEN 1 END) as valid_segments,
    
    -- Consistency metrics
    COUNT(CASE WHEN LENGTH(c_phone) >= 10 THEN 1 END) as consistent_phone_format,
    COUNT(CASE WHEN c_custkey > 0 THEN 1 END) as valid_customer_keys,
    
    CURRENT_TIMESTAMP as measurement_timestamp
FROM customer;

-- Create data quality metrics for order data
CREATE TEMPORARY TABLE order_quality_metrics AS
SELECT 
    'order_data' as data_source,
    'TPC-H Database' as source_system,
    COUNT(*) as total_records,
    
    -- Completeness metrics
    COUNT(CASE WHEN o_orderdate IS NOT NULL THEN 1 END) as complete_order_dates,
    COUNT(CASE WHEN o_totalprice IS NOT NULL THEN 1 END) as complete_prices,
    COUNT(CASE WHEN o_custkey IS NOT NULL THEN 1 END) as complete_customer_refs,
    
    -- Validity metrics
    COUNT(CASE WHEN o_totalprice > 0 THEN 1 END) as valid_prices,
    COUNT(CASE WHEN o_orderdate >= '1992-01-01' AND o_orderdate <= '1998-12-31' THEN 1 END) as valid_dates,
    
    -- Consistency metrics
    COUNT(CASE WHEN o_orderkey > 0 THEN 1 END) as valid_order_keys,
    COUNT(CASE WHEN o_orderstatus IN ('O', 'F', 'P') THEN 1 END) as valid_status_codes,
    
    CURRENT_TIMESTAMP as measurement_timestamp
FROM orders;

-- Unified data quality dashboard
CREATE TEMPORARY TABLE quality_dashboard AS
SELECT 
    data_source,
    source_system,
    total_records,
    
    -- Calculate quality percentages
    ROUND(complete_names * 100.0 / total_records, 2) as name_completeness_pct,
    ROUND(complete_addresses * 100.0 / total_records, 2) as address_completeness_pct,
    ROUND(complete_phones * 100.0 / total_records, 2) as phone_completeness_pct,
    ROUND(valid_balances * 100.0 / total_records, 2) as balance_validity_pct,
    ROUND(valid_segments * 100.0 / total_records, 2) as segment_validity_pct,
    
    -- Overall quality score
    ROUND((complete_names + complete_addresses + complete_phones + valid_balances + valid_segments) * 100.0 / (total_records * 5), 2) as overall_quality_score,
    
    -- Quality status
    CASE 
        WHEN (complete_names + complete_addresses + complete_phones + valid_balances + valid_segments) * 100.0 / (total_records * 5) >= 95 THEN 'EXCELLENT'
        WHEN (complete_names + complete_addresses + complete_phones + valid_balances + valid_segments) * 100.0 / (total_records * 5) >= 85 THEN 'GOOD'
        WHEN (complete_names + complete_addresses + complete_phones + valid_balances + valid_segments) * 100.0 / (total_records * 5) >= 70 THEN 'ACCEPTABLE'
        ELSE 'POOR'
    END as quality_status,
    
    measurement_timestamp
FROM customer_quality_metrics

UNION ALL

SELECT 
    data_source,
    source_system,
    total_records,
    
    -- Map order metrics to common schema
    ROUND(complete_order_dates * 100.0 / total_records, 2) as name_completeness_pct,
    ROUND(complete_prices * 100.0 / total_records, 2) as address_completeness_pct,
    ROUND(complete_customer_refs * 100.0 / total_records, 2) as phone_completeness_pct,
    ROUND(valid_prices * 100.0 / total_records, 2) as balance_validity_pct,
    ROUND(valid_dates * 100.0 / total_records, 2) as segment_validity_pct,
    
    ROUND((complete_order_dates + complete_prices + complete_customer_refs + valid_prices + valid_dates) * 100.0 / (total_records * 5), 2) as overall_quality_score,
    
    CASE 
        WHEN (complete_order_dates + complete_prices + complete_customer_refs + valid_prices + valid_dates) * 100.0 / (total_records * 5) >= 95 THEN 'EXCELLENT'
        WHEN (complete_order_dates + complete_prices + complete_customer_refs + valid_prices + valid_dates) * 100.0 / (total_records * 5) >= 85 THEN 'GOOD'
        WHEN (complete_order_dates + complete_prices + complete_customer_refs + valid_prices + valid_dates) * 100.0 / (total_records * 5) >= 70 THEN 'ACCEPTABLE'
        ELSE 'POOR'
    END as quality_status,
    
    measurement_timestamp
FROM order_quality_metrics;

-- Data quality summary report
SELECT 
    data_source,
    source_system,
    total_records,
    overall_quality_score,
    quality_status,
    CASE 
        WHEN quality_status = 'POOR' THEN 'IMMEDIATE_ACTION_REQUIRED'
        WHEN quality_status = 'ACCEPTABLE' THEN 'MONITOR_CLOSELY'
        ELSE 'CONTINUE_MONITORING'
    END as recommended_action,
    measurement_timestamp
FROM quality_dashboard
ORDER BY overall_quality_score DESC;

-- ============================================
-- PIPELINE HEALTH MONITORING
-- ============================================

-- WHAT IT IS: Pipeline health monitoring tracks the performance, reliability,
-- and operational status of data processing pipelines and ETL jobs.
--
-- WHY IT MATTERS: Health monitoring provides:
-- - Early warning of pipeline failures or performance degradation
-- - Insights into resource utilization and bottlenecks
-- - Historical trends for capacity planning
-- - Automated alerting for operational issues
--
-- HEALTH METRICS: Success rates, processing times, throughput, error rates
-- BENCHMARK: Pipeline success rates should exceed 99% with sub-minute latencies

-- Example 2: Pipeline Health Monitoring Dashboard
-- Business Question: "How do we monitor the health of our data pipelines?"

-- Simulate pipeline execution history
CREATE TEMPORARY TABLE pipeline_execution_history AS
SELECT 
    'customer_etl_pipeline' as pipeline_name,
    'ETL' as pipeline_type,
    '2024-01-01 08:00:00'::TIMESTAMP as execution_start,
    '2024-01-01 08:05:00'::TIMESTAMP as execution_end,
    'SUCCESS' as execution_status,
    1500 as records_processed,
    0 as error_count,
    'Completed successfully' as status_message

UNION ALL

SELECT 
    'customer_etl_pipeline' as pipeline_name,
    'ETL' as pipeline_type,
    '2024-01-01 09:00:00'::TIMESTAMP as execution_start,
    '2024-01-01 09:07:00'::TIMESTAMP as execution_end,
    'SUCCESS' as execution_status,
    1520 as records_processed,
    0 as error_count,
    'Completed successfully' as status_message

UNION ALL

SELECT 
    'customer_etl_pipeline' as pipeline_name,
    'ETL' as pipeline_type,
    '2024-01-01 10:00:00'::TIMESTAMP as execution_start,
    '2024-01-01 10:12:00'::TIMESTAMP as execution_end,
    'WARNING' as execution_status,
    1480 as records_processed,
    5 as error_count,
    'Completed with data quality warnings' as status_message

UNION ALL

SELECT 
    'order_processing_pipeline' as pipeline_name,
    'Stream' as pipeline_type,
    '2024-01-01 08:00:00'::TIMESTAMP as execution_start,
    '2024-01-01 08:02:00'::TIMESTAMP as execution_end,
    'SUCCESS' as execution_status,
    15000 as records_processed,
    0 as error_count,
    'Completed successfully' as status_message

UNION ALL

SELECT 
    'order_processing_pipeline' as pipeline_name,
    'Stream' as pipeline_type,
    '2024-01-01 08:15:00'::TIMESTAMP as execution_start,
    '2024-01-01 08:20:00'::TIMESTAMP as execution_end,
    'FAILED' as execution_status,
    0 as records_processed,
    1 as error_count,
    'Database connection timeout' as status_message

UNION ALL

SELECT 
    'data_validation_pipeline' as pipeline_name,
    'Validation' as pipeline_type,
    '2024-01-01 07:30:00'::TIMESTAMP as execution_start,
    '2024-01-01 07:35:00'::TIMESTAMP as execution_end,
    'SUCCESS' as execution_status,
    3000 as records_processed,
    0 as error_count,
    'All validations passed' as status_message;

-- Pipeline health metrics calculation
CREATE TEMPORARY TABLE pipeline_health_metrics AS
SELECT 
    pipeline_name,
    pipeline_type,
    COUNT(*) as total_executions,
    COUNT(CASE WHEN execution_status = 'SUCCESS' THEN 1 END) as successful_executions,
    COUNT(CASE WHEN execution_status = 'WARNING' THEN 1 END) as warning_executions,
    COUNT(CASE WHEN execution_status = 'FAILED' THEN 1 END) as failed_executions,
    
    -- Performance metrics
    AVG(DATEDIFF('second', execution_start, execution_end)) as avg_duration_seconds,
    MAX(DATEDIFF('second', execution_start, execution_end)) as max_duration_seconds,
    AVG(records_processed) as avg_records_processed,
    SUM(records_processed) as total_records_processed,
    
    -- Health scores
    ROUND(COUNT(CASE WHEN execution_status = 'SUCCESS' THEN 1 END) * 100.0 / COUNT(*), 2) as success_rate_pct,
    ROUND(COUNT(CASE WHEN execution_status IN ('SUCCESS', 'WARNING') THEN 1 END) * 100.0 / COUNT(*), 2) as completion_rate_pct,
    
    -- Health status
    CASE 
        WHEN COUNT(CASE WHEN execution_status = 'SUCCESS' THEN 1 END) * 100.0 / COUNT(*) >= 95 THEN 'HEALTHY'
        WHEN COUNT(CASE WHEN execution_status = 'SUCCESS' THEN 1 END) * 100.0 / COUNT(*) >= 85 THEN 'DEGRADED'
        ELSE 'UNHEALTHY'
    END as health_status,
    
    MIN(execution_start) as monitoring_period_start,
    MAX(execution_end) as monitoring_period_end
FROM pipeline_execution_history
GROUP BY pipeline_name, pipeline_type;

-- Pipeline health dashboard
SELECT 
    pipeline_name,
    pipeline_type,
    total_executions,
    successful_executions,
    failed_executions,
    success_rate_pct,
    avg_duration_seconds,
    avg_records_processed,
    health_status,
    CASE 
        WHEN health_status = 'UNHEALTHY' THEN 'INVESTIGATE_IMMEDIATELY'
        WHEN health_status = 'DEGRADED' THEN 'REVIEW_AND_OPTIMIZE'
        WHEN avg_duration_seconds > 600 THEN 'PERFORMANCE_REVIEW'
        ELSE 'CONTINUE_MONITORING'
    END as recommended_action
FROM pipeline_health_metrics
ORDER BY success_rate_pct ASC, avg_duration_seconds DESC;

-- ============================================
-- DATA FRESHNESS MONITORING
-- ============================================

-- WHAT IT IS: Data freshness monitoring ensures that data is current and
-- updated according to business requirements and SLA agreements.
--
-- WHY IT MATTERS: Freshness monitoring enables:
-- - Timely detection of stale or outdated data
-- - Compliance with data currency requirements
-- - Improved reliability of real-time analytics
-- - Better user experience with current information
--
-- FRESHNESS METRICS: Last update time, data age, update frequency, SLA compliance
-- BENCHMARK: Critical data should be updated within defined SLA windows (e.g., <1 hour)

-- Example 3: Data Freshness Monitoring
-- Business Question: "How do we ensure our data is fresh and up-to-date?"

-- Simulate data source freshness information
CREATE TEMPORARY TABLE data_freshness_status AS
SELECT 
    'customer_master' as data_source,
    'Critical' as criticality_level,
    '2024-01-01 08:30:00'::TIMESTAMP as last_update_time,
    60 as sla_minutes,
    'Daily batch update' as update_pattern,
    'customers' as business_domain

UNION ALL

SELECT 
    'order_transactions' as data_source,
    'Critical' as criticality_level,
    '2024-01-01 10:45:00'::TIMESTAMP as last_update_time,
    15 as sla_minutes,
    'Real-time streaming' as update_pattern,
    'orders' as business_domain

UNION ALL

SELECT 
    'product_catalog' as data_source,
    'Medium' as criticality_level,
    '2024-01-01 06:00:00'::TIMESTAMP as last_update_time,
    240 as sla_minutes,
    'Twice daily update' as update_pattern,
    'products' as business_domain

UNION ALL

SELECT 
    'customer_analytics' as data_source,
    'Low' as criticality_level,
    '2024-01-01 02:00:00'::TIMESTAMP as last_update_time,
    1440 as sla_minutes,
    'Daily analytical refresh' as update_pattern,
    'analytics' as business_domain;

-- Calculate freshness metrics
CREATE TEMPORARY TABLE freshness_monitoring AS
SELECT 
    data_source,
    criticality_level,
    last_update_time,
    sla_minutes,
    update_pattern,
    business_domain,
    
    -- Calculate data age
    DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) as data_age_minutes,
    
    -- SLA compliance
    CASE 
        WHEN DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) <= sla_minutes THEN 'COMPLIANT'
        WHEN DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) <= sla_minutes * 1.2 THEN 'WARNING'
        ELSE 'VIOLATION'
    END as sla_status,
    
    -- Freshness score (0-100)
    GREATEST(0, LEAST(100, 
        100 - (DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) * 100.0 / sla_minutes)
    )) as freshness_score,
    
    -- Alert priority
    CASE 
        WHEN criticality_level = 'Critical' AND DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) > sla_minutes THEN 'HIGH'
        WHEN criticality_level = 'Medium' AND DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) > sla_minutes * 1.5 THEN 'MEDIUM'
        WHEN DATEDIFF('minute', last_update_time, CURRENT_TIMESTAMP) > sla_minutes * 2 THEN 'LOW'
        ELSE 'NONE'
    END as alert_priority,
    
    CURRENT_TIMESTAMP as monitoring_timestamp
FROM data_freshness_status;

-- Freshness monitoring dashboard
SELECT 
    data_source,
    criticality_level,
    business_domain,
    data_age_minutes,
    sla_minutes,
    sla_status,
    freshness_score,
    alert_priority,
    CASE 
        WHEN alert_priority = 'HIGH' THEN 'IMMEDIATE_REFRESH_REQUIRED'
        WHEN alert_priority = 'MEDIUM' THEN 'SCHEDULE_REFRESH_SOON'
        WHEN freshness_score < 50 THEN 'MONITOR_CLOSELY'
        ELSE 'CONTINUE_MONITORING'
    END as recommended_action
FROM freshness_monitoring
ORDER BY alert_priority DESC, freshness_score ASC;

-- ============================================
-- ANOMALY DETECTION MONITORING
-- ============================================

-- WHAT IT IS: Anomaly detection identifies unusual patterns, outliers, or
-- unexpected changes in data that may indicate quality issues or system problems.
--
-- WHY IT MATTERS: Anomaly detection enables:
-- - Early identification of data corruption or system issues
-- - Detection of unusual business patterns that require investigation
-- - Automated alerting for significant data changes
-- - Improved data quality and system reliability
--
-- DETECTION METHODS: Statistical analysis, trend analysis, pattern recognition
-- BENCHMARK: Anomaly detection should identify 90%+ of significant data issues

-- Example 4: Anomaly Detection Monitoring
-- Business Question: "How do we detect anomalies and unusual patterns in our data?"

-- Calculate baseline statistics for anomaly detection
CREATE TEMPORARY TABLE baseline_statistics AS
SELECT 
    'daily_order_count' as metric_name,
    COUNT(*) as current_value,
    750 as historical_average,
    125 as historical_std_dev,
    600 as lower_threshold,
    900 as upper_threshold,
    'orders' as data_domain
FROM orders
WHERE o_orderdate = '1995-01-01'

UNION ALL

SELECT 
    'daily_order_value' as metric_name,
    CAST(SUM(o_totalprice) AS INTEGER) as current_value,
    125000 as historical_average,
    25000 as historical_std_dev,
    75000 as lower_threshold,
    175000 as upper_threshold,
    'orders' as data_domain
FROM orders
WHERE o_orderdate = '1995-01-01'

UNION ALL

SELECT 
    'average_order_size' as metric_name,
    CAST(AVG(o_totalprice) AS INTEGER) as current_value,
    150000 as historical_average,
    30000 as historical_std_dev,
    90000 as lower_threshold,
    210000 as upper_threshold,
    'orders' as data_domain
FROM orders
WHERE o_orderdate = '1995-01-01'

UNION ALL

SELECT 
    'customer_count' as metric_name,
    COUNT(*) as current_value,
    1500 as historical_average,
    150 as historical_std_dev,
    1200 as lower_threshold,
    1800 as upper_threshold,
    'customers' as data_domain
FROM customer;

-- Anomaly detection analysis
CREATE TEMPORARY TABLE anomaly_detection AS
SELECT 
    metric_name,
    data_domain,
    current_value,
    historical_average,
    lower_threshold,
    upper_threshold,
    
    -- Calculate z-score for statistical anomaly detection
    ROUND((current_value - historical_average) * 1.0 / historical_std_dev, 2) as z_score,
    
    -- Determine anomaly status
    CASE 
        WHEN current_value < lower_threshold THEN 'BELOW_THRESHOLD'
        WHEN current_value > upper_threshold THEN 'ABOVE_THRESHOLD'
        WHEN ABS(current_value - historical_average) > (2 * historical_std_dev) THEN 'STATISTICAL_OUTLIER'
        WHEN ABS(current_value - historical_average) > (1.5 * historical_std_dev) THEN 'POTENTIAL_ANOMALY'
        ELSE 'NORMAL'
    END as anomaly_status,
    
    -- Calculate deviation percentage
    ROUND(((current_value - historical_average) * 100.0 / historical_average), 2) as deviation_percent,
    
    -- Determine severity
    CASE 
        WHEN ABS(current_value - historical_average) > (3 * historical_std_dev) THEN 'CRITICAL'
        WHEN ABS(current_value - historical_average) > (2 * historical_std_dev) THEN 'HIGH'
        WHEN ABS(current_value - historical_average) > (1.5 * historical_std_dev) THEN 'MEDIUM'
        ELSE 'LOW'
    END as severity_level,
    
    CURRENT_TIMESTAMP as detection_timestamp
FROM baseline_statistics;

-- Anomaly detection dashboard
SELECT 
    metric_name,
    data_domain,
    current_value,
    historical_average,
    deviation_percent,
    z_score,
    anomaly_status,
    severity_level,
    CASE 
        WHEN severity_level = 'CRITICAL' THEN 'INVESTIGATE_IMMEDIATELY'
        WHEN severity_level = 'HIGH' THEN 'REVIEW_WITHIN_1_HOUR'
        WHEN severity_level = 'MEDIUM' THEN 'REVIEW_WITHIN_4_HOURS'
        ELSE 'CONTINUE_MONITORING'
    END as recommended_action
FROM anomaly_detection
WHERE anomaly_status != 'NORMAL'
ORDER BY severity_level DESC, ABS(deviation_percent) DESC;

-- ============================================
-- SLA MONITORING AND COMPLIANCE
-- ============================================

-- WHAT IT IS: SLA monitoring tracks compliance with service level agreements
-- for data availability, quality, and processing times across all systems.
--
-- WHY IT MATTERS: SLA monitoring ensures:
-- - Compliance with contractual obligations and business requirements
-- - Proactive identification of SLA violations before they impact users
-- - Historical tracking for performance improvement initiatives
-- - Accountability and transparency in data service delivery
--
-- SLA METRICS: Availability, response time, data quality, update frequency
-- BENCHMARK: SLA compliance should exceed 99.5% for critical data services

-- Example 5: SLA Monitoring and Compliance Tracking
-- Business Question: "How do we monitor and ensure SLA compliance?"

-- Define SLA requirements and current performance
CREATE TEMPORARY TABLE sla_monitoring AS
SELECT 
    'data_availability' as sla_metric,
    'Customer Data Service' as service_name,
    99.9 as sla_target_percent,
    99.7 as current_performance_percent,
    'Critical' as service_tier,
    '24x7' as availability_window,
    'Monthly' as reporting_period

UNION ALL

SELECT 
    'data_freshness' as sla_metric,
    'Order Processing Service' as service_name,
    95.0 as sla_target_percent,
    97.2 as current_performance_percent,
    'Critical' as service_tier,
    'Business Hours' as availability_window,
    'Monthly' as reporting_period

UNION ALL

SELECT 
    'processing_time' as sla_metric,
    'ETL Pipeline Service' as service_name,
    90.0 as sla_target_percent,
    88.5 as current_performance_percent,
    'High' as service_tier,
    '24x7' as availability_window,
    'Monthly' as reporting_period

UNION ALL

SELECT 
    'data_quality' as sla_metric,
    'Analytics Data Service' as service_name,
    95.0 as sla_target_percent,
    96.8 as current_performance_percent,
    'Medium' as service_tier,
    'Business Hours' as availability_window,
    'Monthly' as reporting_period

UNION ALL

SELECT 
    'response_time' as sla_metric,
    'API Data Service' as service_name,
    99.0 as sla_target_percent,
    94.2 as current_performance_percent,
    'Critical' as service_tier,
    '24x7' as availability_window,
    'Monthly' as reporting_period;

-- SLA compliance analysis
CREATE TEMPORARY TABLE sla_compliance_analysis AS
SELECT 
    sla_metric,
    service_name,
    service_tier,
    sla_target_percent,
    current_performance_percent,
    availability_window,
    
    -- Calculate compliance status
    CASE 
        WHEN current_performance_percent >= sla_target_percent THEN 'COMPLIANT'
        WHEN current_performance_percent >= sla_target_percent * 0.95 THEN 'AT_RISK'
        ELSE 'VIOLATION'
    END as compliance_status,
    
    -- Calculate performance gap
    ROUND(current_performance_percent - sla_target_percent, 2) as performance_gap,
    
    -- Determine risk level
    CASE 
        WHEN service_tier = 'Critical' AND current_performance_percent < sla_target_percent THEN 'HIGH_RISK'
        WHEN service_tier = 'High' AND current_performance_percent < sla_target_percent * 0.9 THEN 'MEDIUM_RISK'
        WHEN current_performance_percent < sla_target_percent * 0.8 THEN 'LOW_RISK'
        ELSE 'NO_RISK'
    END as risk_level,
    
    -- Calculate compliance score (0-100)
    LEAST(100, GREATEST(0, 
        100 * (current_performance_percent / sla_target_percent)
    )) as compliance_score,
    
    CURRENT_TIMESTAMP as measurement_timestamp
FROM sla_monitoring;

-- SLA compliance dashboard
SELECT 
    service_name,
    sla_metric,
    service_tier,
    sla_target_percent,
    current_performance_percent,
    performance_gap,
    compliance_status,
    risk_level,
    compliance_score,
    CASE 
        WHEN risk_level = 'HIGH_RISK' THEN 'ESCALATE_TO_MANAGEMENT'
        WHEN risk_level = 'MEDIUM_RISK' THEN 'IMPLEMENT_IMPROVEMENT_PLAN'
        WHEN compliance_status = 'AT_RISK' THEN 'MONITOR_CLOSELY'
        ELSE 'CONTINUE_MONITORING'
    END as recommended_action
FROM sla_compliance_analysis
ORDER BY risk_level DESC, compliance_score ASC;

-- ============================================
-- ALERT MANAGEMENT AND NOTIFICATIONS
-- ============================================

-- WHAT IT IS: Alert management provides automated notifications and escalation
-- procedures for data quality issues, pipeline failures, and SLA violations.
--
-- WHY IT MATTERS: Alert management enables:
-- - Rapid response to critical data issues
-- - Automated escalation for unresolved problems
-- - Reduced mean time to resolution (MTTR)
-- - Improved operational efficiency and reliability

-- Example 6: Comprehensive Alert Management System
-- Business Question: "How do we manage alerts and notifications effectively?"

-- Generate comprehensive monitoring alerts
CREATE TEMPORARY TABLE monitoring_alerts AS
SELECT 
    'DATA_QUALITY_ALERT' as alert_type,
    'Customer data quality score below threshold' as alert_message,
    'customer_data' as affected_system,
    'HIGH' as severity,
    'Data quality score: 82% (threshold: 85%)' as alert_details,
    'data_quality_team@company.com' as notification_target,
    CURRENT_TIMESTAMP as alert_timestamp

UNION ALL

SELECT 
    'PIPELINE_FAILURE_ALERT' as alert_type,
    'Order processing pipeline failed' as alert_message,
    'order_processing_pipeline' as affected_system,
    'CRITICAL' as severity,
    'Database connection timeout after 30 seconds' as alert_details,
    'data_engineering_team@company.com' as notification_target,
    CURRENT_TIMESTAMP as alert_timestamp

UNION ALL

SELECT 
    'SLA_VIOLATION_ALERT' as alert_type,
    'API response time SLA violation' as alert_message,
    'API Data Service' as affected_system,
    'HIGH' as severity,
    'Current performance: 94.2% (SLA: 99.0%)' as alert_details,
    'platform_team@company.com' as notification_target,
    CURRENT_TIMESTAMP as alert_timestamp

UNION ALL

SELECT 
    'FRESHNESS_WARNING' as alert_type,
    'Order transactions data is stale' as alert_message,
    'order_transactions' as affected_system,
    'MEDIUM' as severity,
    'Last update: 45 minutes ago (SLA: 15 minutes)' as alert_details,
    'data_ops_team@company.com' as notification_target,
    CURRENT_TIMESTAMP as alert_timestamp

UNION ALL

SELECT 
    'ANOMALY_DETECTED' as alert_type,
    'Unusual pattern detected in daily order count' as alert_message,
    'orders' as affected_system,
    'MEDIUM' as severity,
    'Current: 1250 orders (Expected: 750 ± 125)' as alert_details,
    'business_analysts@company.com' as notification_target,
    CURRENT_TIMESTAMP as alert_timestamp;

-- Alert prioritization and routing
SELECT 
    alert_type,
    alert_message,
    affected_system,
    severity,
    alert_details,
    notification_target,
    
    -- Calculate alert priority score
    CASE severity
        WHEN 'CRITICAL' THEN 100
        WHEN 'HIGH' THEN 75
        WHEN 'MEDIUM' THEN 50
        WHEN 'LOW' THEN 25
        ELSE 10
    END as priority_score,
    
    -- Determine escalation timeline
    CASE severity
        WHEN 'CRITICAL' THEN 'IMMEDIATE'
        WHEN 'HIGH' THEN '15_MINUTES'
        WHEN 'MEDIUM' THEN '1_HOUR'
        WHEN 'LOW' THEN '4_HOURS'
        ELSE '24_HOURS'
    END as escalation_timeline,
    
    -- Recommended response
    CASE severity
        WHEN 'CRITICAL' THEN 'PAGE_ON_CALL_ENGINEER'
        WHEN 'HIGH' THEN 'SEND_URGENT_EMAIL'
        WHEN 'MEDIUM' THEN 'SEND_STANDARD_EMAIL'
        ELSE 'LOG_FOR_REVIEW'
    END as recommended_response,
    
    alert_timestamp
FROM monitoring_alerts
ORDER BY priority_score DESC, alert_timestamp ASC;

-- ============================================
-- CLEANUP TEMPORARY OBJECTS
-- ============================================

DROP TABLE IF EXISTS customer_quality_metrics;
DROP TABLE IF EXISTS order_quality_metrics;
DROP TABLE IF EXISTS quality_dashboard;
DROP TABLE IF EXISTS pipeline_execution_history;
DROP TABLE IF EXISTS pipeline_health_metrics;
DROP TABLE IF EXISTS data_freshness_status;
DROP TABLE IF EXISTS freshness_monitoring;
DROP TABLE IF EXISTS baseline_statistics;
DROP TABLE IF EXISTS anomaly_detection;
DROP TABLE IF EXISTS sla_monitoring;
DROP TABLE IF EXISTS sla_compliance_analysis;
DROP TABLE IF EXISTS monitoring_alerts;

-- ============================================
-- DATA MONITORING BEST PRACTICES SUMMARY
-- ============================================

-- 1. DATA QUALITY MONITORING:
--    - Implement comprehensive quality metrics across all data dimensions
--    - Set appropriate thresholds based on business requirements
--    - Monitor quality trends over time to identify degradation patterns

-- 2. PIPELINE HEALTH MONITORING:
--    - Track success rates, processing times, and error patterns
--    - Implement automated health checks and heartbeat monitoring
--    - Monitor resource utilization and performance bottlenecks

-- 3. DATA FRESHNESS MONITORING:
--    - Define clear SLAs for data currency requirements
--    - Implement automated freshness checks based on business criticality
--    - Monitor update patterns and identify staleness issues

-- 4. ANOMALY DETECTION:
--    - Use statistical methods to identify unusual patterns
--    - Implement both threshold-based and trend-based detection
--    - Balance sensitivity to avoid alert fatigue

-- 5. SLA MONITORING:
--    - Define measurable SLAs aligned with business requirements
--    - Track compliance metrics and trends over time
--    - Implement proactive alerting before SLA violations occur

-- 6. ALERT MANAGEMENT:
--    - Implement severity-based alert routing and escalation
--    - Provide clear, actionable alert messages with context
--    - Monitor alert effectiveness and adjust thresholds as needed

-- These monitoring patterns provide comprehensive observability into data
-- systems, enabling proactive issue detection, rapid response to problems,
-- and continuous improvement of data quality and system reliability.