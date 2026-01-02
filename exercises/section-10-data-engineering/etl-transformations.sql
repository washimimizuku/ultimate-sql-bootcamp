-- ETL TRANSFORMATIONS - Practical Data Engineering with SQL
-- This file demonstrates comprehensive ETL (Extract, Transform, Load) patterns
-- using DuckDB's powerful data processing capabilities with multiple data sources
-- ============================================
-- REQUIRED: This file uses TPC-H database and Star Wars CSV/JSON/Parquet files
-- Setup TPC-H: duckdb data/databases/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/databases/tpc-h.db < exercises/section-10-data-engineering/etl-transformations.sql
-- ============================================

-- ETL CONCEPTS:
-- - Extract: Reading data from various sources (databases, files, APIs)
-- - Transform: Cleansing, standardizing, and enriching data
-- - Load: Writing processed data to target systems
-- - Data Cleansing: Removing inconsistencies and errors
-- - Data Standardization: Ensuring consistent formats and values
-- - Data Enrichment: Adding calculated fields and derived metrics
-- - Incremental Loading: Processing only new or changed data

-- BUSINESS CONTEXT:
-- ETL processes are the backbone of data engineering pipelines
-- They ensure data quality, consistency, and reliability for analytics
-- Modern ETL handles multiple data formats and sources simultaneously
-- This section demonstrates practical patterns using DuckDB's capabilities

-- ============================================
-- DATA EXTRACTION PATTERNS
-- ============================================

-- WHAT IT IS: Data extraction involves reading data from various sources
-- including databases, CSV files, JSON documents, and Parquet files.
--
-- WHY IT MATTERS: Extraction patterns enable:
-- - Integration of data from multiple heterogeneous sources
-- - Handling of different data formats and structures
-- - Efficient data loading with minimal resource usage
-- - Scalable processing of large datasets
--
-- KEY TECHNIQUES: File globbing, schema inference, format detection
-- BENCHMARK: Extraction should handle 80% of common data formats automatically

-- Example 1: Multi-Source Data Extraction
-- Business Question: "How do we efficiently extract data from multiple sources?"

-- Extract from existing TPC-H tables (database source)
CREATE TEMPORARY TABLE extracted_customers AS
SELECT 
    'database' as source_type,
    'tpc-h' as source_name,
    c_custkey as customer_id,
    c_name as customer_name,
    c_mktsegment as market_segment,
    c_nationkey as nation_id,
    c_acctbal as account_balance,
    CURRENT_TIMESTAMP as extraction_timestamp
FROM customer
LIMIT 25;

-- Extract from Star Wars CSV files (file source)
CREATE TEMPORARY TABLE extracted_characters AS
SELECT 
    'csv_file' as source_type,
    'star-wars' as source_name,
    ROW_NUMBER() OVER (ORDER BY name) as character_id,
    name as character_name,
    species,
    homeworld,
    height,
    mass,
    CURRENT_TIMESTAMP as extraction_timestamp
FROM read_csv('data/star-wars/csv/characters.csv', header=true)
LIMIT 25;
-- Extract from JSON files (semi-structured source)
CREATE TEMPORARY TABLE extracted_films AS
SELECT 
    'json_file' as source_type,
    'star-wars' as source_name,
    CAST(episode_id AS INTEGER) as episode_id,
    title as film_title,
    director,
    producer,
    release_date,
    CURRENT_TIMESTAMP as extraction_timestamp
FROM read_json('data/star-wars/json/films.json')
LIMIT 10;

-- Show extraction results summary
SELECT 
    source_type,
    source_name,
    COUNT(*) as records_extracted,
    MIN(extraction_timestamp) as extraction_start,
    MAX(extraction_timestamp) as extraction_end
FROM (
    SELECT source_type, source_name, extraction_timestamp FROM extracted_customers
    UNION ALL
    SELECT source_type, source_name, extraction_timestamp FROM extracted_characters
    UNION ALL
    SELECT source_type, source_name, extraction_timestamp FROM extracted_films
) combined_extracts
GROUP BY source_type, source_name
ORDER BY records_extracted DESC;

-- ============================================
-- DATA CLEANSING TRANSFORMATIONS
-- ============================================

-- WHAT IT IS: Data cleansing removes inconsistencies, errors, and invalid values
-- from datasets to ensure high-quality data for downstream processing.
--
-- WHY IT MATTERS: Clean data ensures:
-- - Accurate analytical results and business insights
-- - Reliable machine learning model performance
-- - Consistent reporting across different systems
-- - Reduced errors in automated processes
--
-- CLEANSING TECHNIQUES: Trimming whitespace, standardizing formats, handling nulls
-- BENCHMARK: Cleansing should improve data quality scores by 20-50%

-- Example 2: Comprehensive Data Cleansing
-- Business Question: "How do we standardize and clean messy data?"

-- Create a sample of messy data to demonstrate cleansing
CREATE TEMPORARY TABLE messy_customer_data AS
SELECT 
    c_custkey,
    '  ' || UPPER(c_name) || '  ' as dirty_name,  -- Extra spaces and inconsistent case
    CASE 
        WHEN c_custkey % 3 = 0 THEN NULL
        WHEN c_custkey % 5 = 0 THEN 'UNKNOWN'
        ELSE c_address
    END as dirty_address,
    CASE 
        WHEN c_custkey % 4 = 0 THEN REPLACE(c_phone, '-', '')  -- Inconsistent phone format
        WHEN c_custkey % 7 = 0 THEN c_phone || 'x123'         -- Extra characters
        ELSE c_phone
    END as dirty_phone,
    c_mktsegment,
    c_acctbal
FROM customer
LIMIT 20;

-- Apply comprehensive cleansing transformations
CREATE TEMPORARY TABLE cleaned_customer_data AS
SELECT 
    c_custkey,
    -- Name cleansing: trim whitespace, proper case
    TRIM(UPPER(LEFT(dirty_name, 1)) || LOWER(SUBSTRING(dirty_name, 2))) as clean_name,
    
    -- Address cleansing: handle nulls and unknown values
    CASE 
        WHEN dirty_address IS NULL OR UPPER(dirty_address) = 'UNKNOWN' 
        THEN 'Address Not Available'
        ELSE TRIM(dirty_address)
    END as clean_address,
    
    -- Phone cleansing: standardize format, remove invalid characters
    CASE 
        WHEN dirty_phone IS NULL THEN 'Phone Not Available'
        WHEN LENGTH(REGEXP_REPLACE(dirty_phone, '[^0-9-]', '', 'g')) < 10 THEN 'Invalid Phone'
        ELSE REGEXP_REPLACE(dirty_phone, '[^0-9-]', '', 'g')
    END as clean_phone,
    
    -- Market segment standardization
    UPPER(TRIM(c_mktsegment)) as clean_market_segment,
    
    -- Account balance validation and formatting
    CASE 
        WHEN c_acctbal IS NULL THEN 0.00
        WHEN c_acctbal < -999999 THEN -999999.00  -- Cap extreme negative values
        WHEN c_acctbal > 999999 THEN 999999.00    -- Cap extreme positive values
        ELSE ROUND(c_acctbal, 2)
    END as clean_account_balance,
    
    -- Add data quality flags
    CASE 
        WHEN dirty_address IS NULL OR UPPER(dirty_address) = 'UNKNOWN' THEN 1 
        ELSE 0 
    END as address_quality_flag,
    
    CASE 
        WHEN dirty_phone IS NULL OR LENGTH(REGEXP_REPLACE(dirty_phone, '[^0-9-]', '', 'g')) < 10 THEN 1 
        ELSE 0 
    END as phone_quality_flag
FROM messy_customer_data;

-- Show cleansing results
SELECT 
    'Before Cleansing' as stage,
    COUNT(*) as total_records,
    COUNT(CASE WHEN dirty_address IS NULL OR UPPER(dirty_address) = 'UNKNOWN' THEN 1 END) as missing_addresses,
    COUNT(CASE WHEN dirty_phone IS NULL OR LENGTH(REGEXP_REPLACE(dirty_phone, '[^0-9-]', '', 'g')) < 10 THEN 1 END) as invalid_phones
FROM messy_customer_data

UNION ALL

SELECT 
    'After Cleansing' as stage,
    COUNT(*) as total_records,
    SUM(address_quality_flag) as flagged_addresses,
    SUM(phone_quality_flag) as flagged_phones
FROM cleaned_customer_data;
FROM cleaned_customer_data;

-- ============================================
-- DATA STANDARDIZATION PATTERNS
-- ============================================

-- WHAT IT IS: Data standardization ensures consistent formats, units, and values
-- across different data sources and systems.
--
-- WHY IT MATTERS: Standardization enables:
-- - Consistent data integration across multiple sources
-- - Reliable data comparisons and analysis
-- - Automated data processing without manual intervention
-- - Improved data quality and user experience
--
-- STANDARDIZATION AREAS: Dates, currencies, units, categories, naming conventions
-- BENCHMARK: 95%+ of values should conform to standard formats after processing

-- Example 3: Multi-Format Data Standardization
-- Business Question: "How do we standardize data from different sources with different formats?"

-- Standardize character data from multiple sources
CREATE TEMPORARY TABLE standardized_characters AS
SELECT 
    -- Standardized ID with source prefix
    'SW-' || LPAD(CAST(ROW_NUMBER() OVER (ORDER BY name) AS VARCHAR), 6, '0') as standard_character_id,
    
    -- Standardized name format
    TRIM(UPPER(LEFT(name, 1)) || LOWER(SUBSTRING(name, 2))) as standard_name,
    
    -- Standardized height (convert to meters, handle unknown values)
    CASE 
        WHEN height IS NULL OR UPPER(height) = 'UNKNOWN' OR height = 'n/a' THEN NULL
        WHEN TRY_CAST(height AS DECIMAL) IS NOT NULL THEN 
            ROUND(TRY_CAST(height AS DECIMAL) / 100.0, 2)  -- Convert cm to meters
        ELSE NULL
    END as height_meters,
    
    -- Standardized mass (convert to kg, handle unknown values)
    CASE 
        WHEN mass IS NULL OR UPPER(mass) = 'UNKNOWN' OR mass = 'n/a' THEN NULL
        WHEN TRY_CAST(REPLACE(mass, ',', '') AS DECIMAL) IS NOT NULL THEN 
            TRY_CAST(REPLACE(mass, ',', '') AS DECIMAL)
        ELSE NULL
    END as mass_kg,
    
    -- Standardized gender categories
    CASE 
        WHEN UPPER(gender) IN ('MALE', 'M') THEN 'Male'
        WHEN UPPER(gender) IN ('FEMALE', 'F') THEN 'Female'
        WHEN UPPER(gender) = 'HERMAPHRODITE' THEN 'Other'
        WHEN gender IS NULL OR UPPER(gender) = 'UNKNOWN' OR gender = 'n/a' THEN 'Unknown'
        ELSE 'Other'
    END as standard_gender,
    
    -- Standardized eye color (group similar colors)
    CASE 
        WHEN UPPER(eye_color) LIKE '%BLUE%' THEN 'Blue'
        WHEN UPPER(eye_color) LIKE '%BROWN%' THEN 'Brown'
        WHEN UPPER(eye_color) LIKE '%GREEN%' THEN 'Green'
        WHEN UPPER(eye_color) LIKE '%YELLOW%' THEN 'Yellow'
        WHEN UPPER(eye_color) LIKE '%RED%' THEN 'Red'
        WHEN UPPER(eye_color) LIKE '%BLACK%' THEN 'Black'
        WHEN eye_color IS NULL OR UPPER(eye_color) = 'UNKNOWN' OR eye_color = 'n/a' THEN 'Unknown'
        ELSE 'Other'
    END as standard_eye_color,
    
    -- Add standardization quality score
    (CASE WHEN height IS NOT NULL AND UPPER(height) != 'UNKNOWN' AND height != 'n/a' THEN 1 ELSE 0 END +
     CASE WHEN mass IS NOT NULL AND UPPER(mass) != 'UNKNOWN' AND mass != 'n/a' THEN 1 ELSE 0 END +
     CASE WHEN gender IS NOT NULL AND UPPER(gender) != 'UNKNOWN' AND gender != 'n/a' THEN 1 ELSE 0 END +
     CASE WHEN eye_color IS NOT NULL AND UPPER(eye_color) != 'UNKNOWN' AND eye_color != 'n/a' THEN 1 ELSE 0 END
    ) as data_completeness_score,
    
    CURRENT_TIMESTAMP as standardization_timestamp
FROM read_csv('data/star-wars/csv/characters.csv', header=true)
LIMIT 25;

-- Show standardization results
SELECT 
    standard_gender,
    standard_eye_color,
    COUNT(*) as character_count,
    AVG(height_meters) as avg_height_meters,
    AVG(mass_kg) as avg_mass_kg,
    AVG(data_completeness_score) as avg_completeness_score
FROM standardized_characters
WHERE standard_gender != 'Unknown'
GROUP BY standard_gender, standard_eye_color
ORDER BY character_count DESC;

-- ============================================
-- DATA ENRICHMENT TRANSFORMATIONS
-- ============================================

-- WHAT IT IS: Data enrichment adds calculated fields, derived metrics, and
-- additional context to raw data to increase its analytical value.
--
-- WHY IT MATTERS: Enrichment provides:
-- - Additional insights not available in raw data
-- - Pre-calculated metrics for faster query performance
-- - Business context that aids in decision-making
-- - Standardized derived fields across different analyses
--
-- ENRICHMENT TYPES: Calculated fields, lookups, aggregations, business rules
-- BENCHMARK: Enriched datasets should provide 30-50% more analytical value

-- Example 4: Comprehensive Data Enrichment
-- Business Question: "How do we add business value through data enrichment?"

-- Enrich customer data with calculated metrics and business context
CREATE TEMPORARY TABLE enriched_customers AS
SELECT 
    c.c_custkey,
    c.c_name,
    c.c_mktsegment,
    c.c_acctbal,
    n.n_name as nation_name,
    r.r_name as region_name,
    
    -- Order-based enrichment
    COUNT(o.o_orderkey) as total_orders,
    COALESCE(SUM(o.o_totalprice), 0) as total_order_value,
    COALESCE(AVG(o.o_totalprice), 0) as avg_order_value,
    COALESCE(MIN(o.o_orderdate), '1900-01-01') as first_order_date,
    COALESCE(MAX(o.o_orderdate), '1900-01-01') as last_order_date,
    
    -- Customer lifecycle calculations
    CASE 
        WHEN COUNT(o.o_orderkey) = 0 THEN 'Prospect'
        WHEN COUNT(o.o_orderkey) = 1 THEN 'New Customer'
        WHEN COUNT(o.o_orderkey) BETWEEN 2 AND 5 THEN 'Regular Customer'
        WHEN COUNT(o.o_orderkey) > 5 THEN 'Loyal Customer'
    END as customer_lifecycle_stage,
    
    -- Customer value segmentation
    CASE 
        WHEN COALESCE(SUM(o.o_totalprice), 0) >= 500000 THEN 'High Value'
        WHEN COALESCE(SUM(o.o_totalprice), 0) >= 200000 THEN 'Medium Value'
        WHEN COALESCE(SUM(o.o_totalprice), 0) >= 50000 THEN 'Low Value'
        WHEN COALESCE(SUM(o.o_totalprice), 0) > 0 THEN 'Minimal Value'
        ELSE 'No Orders'
    END as customer_value_segment,
    
    -- Account balance category
    CASE 
        WHEN c.c_acctbal >= 5000 THEN 'High Balance'
        WHEN c.c_acctbal >= 1000 THEN 'Medium Balance'
        WHEN c.c_acctbal >= 0 THEN 'Low Balance'
        ELSE 'Negative Balance'
    END as account_balance_category,
    
    -- Customer activity recency
    CASE 
        WHEN MAX(o.o_orderdate) IS NULL THEN 'Never Ordered'
        WHEN MAX(o.o_orderdate) >= '1995-01-01' THEN 'Recent Activity'
        WHEN MAX(o.o_orderdate) >= '1994-01-01' THEN 'Moderate Activity'
        ELSE 'Inactive'
    END as activity_recency,
    
    -- Risk assessment score (0-100)
    LEAST(100, GREATEST(0, 
        50 +  -- Base score
        (CASE WHEN c.c_acctbal >= 0 THEN 20 ELSE -20 END) +  -- Account balance factor
        (CASE WHEN COUNT(o.o_orderkey) > 0 THEN 15 ELSE -15 END) +  -- Order history factor
        (CASE WHEN MAX(o.o_orderdate) >= '1995-01-01' THEN 15 ELSE -10 END)  -- Recency factor
    )) as customer_risk_score,
    
    CURRENT_TIMESTAMP as enrichment_timestamp
FROM customer c
LEFT JOIN nation n ON c.c_nationkey = n.n_nationkey
LEFT JOIN region r ON n.n_regionkey = r.r_regionkey
LEFT JOIN orders o ON c.c_custkey = o.o_custkey
GROUP BY c.c_custkey, c.c_name, c.c_mktsegment, c.c_acctbal, n.n_name, r.r_name;

-- Show enrichment results summary
SELECT 
    customer_lifecycle_stage,
    customer_value_segment,
    account_balance_category,
    activity_recency,
    COUNT(*) as customer_count,
    AVG(customer_risk_score) as avg_risk_score,
    AVG(total_order_value) as avg_total_value
FROM enriched_customers
GROUP BY customer_lifecycle_stage, customer_value_segment, account_balance_category, activity_recency
ORDER BY customer_count DESC;

-- ============================================
-- INCREMENTAL DATA LOADING PATTERNS
-- ============================================

-- WHAT IT IS: Incremental loading processes only new or changed data since the
-- last ETL run, improving efficiency and reducing processing time.
--
-- WHY IT MATTERS: Incremental loading provides:
-- - Faster ETL processing for large datasets
-- - Reduced system resource consumption
-- - Near real-time data availability
-- - Better system performance and user experience
--
-- TECHNIQUES: Change data capture, timestamp-based loading, checksum comparison
-- BENCHMARK: Incremental loads should process 90%+ fewer records than full loads

-- Example 5: Timestamp-Based Incremental Loading
-- Business Question: "How do we efficiently process only new or changed data?"

-- Simulate a data warehouse table with last update tracking
CREATE TEMPORARY TABLE customer_warehouse AS
SELECT 
    c_custkey,
    c_name,
    c_mktsegment,
    c_acctbal,
    '2024-01-01 00:00:00'::TIMESTAMP as last_updated,
    'initial_load' as load_type
FROM customer
WHERE c_custkey <= 25;  -- Simulate existing data

-- Simulate new/changed source data
CREATE TEMPORARY TABLE customer_source_changes AS
SELECT 
    c_custkey,
    c_name,
    c_mktsegment,
    c_acctbal + (RANDOM() * 1000 - 500) as c_acctbal,  -- Simulate balance changes
    CURRENT_TIMESTAMP as source_last_modified
FROM customer
WHERE c_custkey BETWEEN 20 AND 35;  -- Overlap + new records

-- Incremental loading logic
CREATE TEMPORARY TABLE incremental_load_results AS
SELECT 
    s.c_custkey,
    s.c_name,
    s.c_mktsegment,
    s.c_acctbal,
    s.source_last_modified,
    CASE 
        WHEN w.c_custkey IS NULL THEN 'INSERT'
        WHEN w.last_updated < s.source_last_modified THEN 'UPDATE'
        ELSE 'NO_CHANGE'
    END as load_action,
    CURRENT_TIMESTAMP as processing_timestamp
FROM customer_source_changes s
LEFT JOIN customer_warehouse w ON s.c_custkey = w.c_custkey;

-- Show incremental loading results
SELECT 
    load_action,
    COUNT(*) as record_count,
    MIN(processing_timestamp) as batch_start,
    MAX(processing_timestamp) as batch_end
FROM incremental_load_results
GROUP BY load_action
ORDER BY 
    CASE load_action 
        WHEN 'INSERT' THEN 1 
        WHEN 'UPDATE' THEN 2 
        WHEN 'NO_CHANGE' THEN 3 
    END;

-- ============================================
-- ERROR HANDLING AND DATA VALIDATION
-- ============================================

-- WHAT IT IS: Error handling in ETL processes ensures data quality and
-- system reliability by catching, logging, and appropriately handling data issues.
--
-- WHY IT MATTERS: Robust error handling:
-- - Prevents bad data from corrupting downstream systems
-- - Provides visibility into data quality issues
-- - Enables automated recovery and retry mechanisms
-- - Maintains system reliability and user trust
--
-- ERROR TYPES: Data type mismatches, constraint violations, business rule failures
-- BENCHMARK: ETL processes should handle 99%+ of data errors gracefully

-- Example 6: Comprehensive Error Handling
-- Business Question: "How do we handle data errors gracefully in ETL processes?"

-- Create a table to log ETL errors
CREATE TEMPORARY TABLE etl_error_log (
    error_id INTEGER,
    source_table VARCHAR,
    source_key VARCHAR,
    error_type VARCHAR,
    error_message VARCHAR,
    error_timestamp TIMESTAMP,
    raw_data VARCHAR
);

-- Simulate processing data with various error conditions
CREATE TEMPORARY TABLE error_prone_data AS
SELECT 
    c_custkey,
    CASE 
        WHEN c_custkey % 7 = 0 THEN NULL  -- Missing name
        ELSE c_name 
    END as c_name,
    CASE 
        WHEN c_custkey % 11 = 0 THEN 'INVALID_SEGMENT'  -- Invalid segment
        ELSE c_mktsegment 
    END as c_mktsegment,
    CASE 
        WHEN c_custkey % 13 = 0 THEN 'NOT_A_NUMBER'  -- Invalid balance
        ELSE CAST(c_acctbal AS VARCHAR)
    END as c_acctbal_str,
    c_nationkey
FROM customer
LIMIT 30;

-- Process data with error handling
CREATE TEMPORARY TABLE processed_with_errors AS
SELECT 
    c_custkey,
    -- Handle missing names
    CASE 
        WHEN c_name IS NULL THEN 'UNKNOWN_CUSTOMER_' || c_custkey
        ELSE c_name
    END as clean_name,
    
    -- Validate market segments
    CASE 
        WHEN c_mktsegment IN ('AUTOMOBILE', 'BUILDING', 'FURNITURE', 'HOUSEHOLD', 'MACHINERY') 
        THEN c_mktsegment
        ELSE 'OTHER'
    END as clean_segment,
    
    -- Handle numeric conversion errors
    CASE 
        WHEN TRY_CAST(c_acctbal_str AS DECIMAL) IS NOT NULL 
        THEN TRY_CAST(c_acctbal_str AS DECIMAL)
        ELSE 0.00
    END as clean_balance,
    
    c_nationkey,
    
    -- Error flags
    CASE WHEN c_name IS NULL THEN 1 ELSE 0 END as name_error_flag,
    CASE WHEN c_mktsegment NOT IN ('AUTOMOBILE', 'BUILDING', 'FURNITURE', 'HOUSEHOLD', 'MACHINERY') THEN 1 ELSE 0 END as segment_error_flag,
    CASE WHEN TRY_CAST(c_acctbal_str AS DECIMAL) IS NULL THEN 1 ELSE 0 END as balance_error_flag,
    
    CURRENT_TIMESTAMP as processing_timestamp
FROM error_prone_data;

-- Generate error summary report
SELECT 
    'Data Processing Error Summary' as report_title,
    COUNT(*) as total_records_processed,
    SUM(name_error_flag) as name_errors,
    SUM(segment_error_flag) as segment_errors,
    SUM(balance_error_flag) as balance_errors,
    SUM(name_error_flag + segment_error_flag + balance_error_flag) as total_errors,
    ROUND(SUM(name_error_flag + segment_error_flag + balance_error_flag) * 100.0 / COUNT(*), 2) as error_rate_percent
FROM processed_with_errors;

-- ============================================
-- MULTI-FORMAT DATA INTEGRATION
-- ============================================

-- WHAT IT IS: Multi-format integration combines data from different file formats
-- and sources into a unified, consistent dataset for analysis.
--
-- WHY IT MATTERS: Integration enables:
-- - Comprehensive analysis across all data sources
-- - Consistent data models regardless of source format
-- - Efficient processing of heterogeneous data
-- - Simplified downstream analytics and reporting
--
-- FORMATS: CSV, JSON, Parquet, databases, APIs
-- BENCHMARK: Integration should preserve 100% of critical data relationships

-- Example 7: Cross-Format Data Integration
-- Business Question: "How do we integrate data from CSV, JSON, and database sources?"

-- Create separate temporary tables for each source
CREATE TEMPORARY TABLE characters_source AS
SELECT 
    'characters' as entity_type,
    ROW_NUMBER() OVER (ORDER BY name) as entity_id,
    name as entity_name,
    'csv' as source_format,
    height,
    mass,
    gender,
    NULL as additional_info,
    CURRENT_TIMESTAMP as integration_timestamp
FROM read_csv('data/star-wars/csv/characters.csv', header=true)
WHERE name IS NOT NULL
LIMIT 15;

CREATE TEMPORARY TABLE films_source AS
SELECT 
    'films' as entity_type,
    CAST(episode_id AS INTEGER) as entity_id,
    title as entity_name,
    'json' as source_format,
    NULL as height,
    NULL as mass,
    NULL as gender,
    '{"director":"' || director || '","producer":"' || producer || '","release_date":"' || release_date || '"}' as additional_info,
    CURRENT_TIMESTAMP as integration_timestamp
FROM read_json('data/star-wars/json/films.json')
WHERE episode_id IS NOT NULL;

CREATE TEMPORARY TABLE customers_source AS
SELECT 
    'customers' as entity_type,
    c_custkey as entity_id,
    c_name as entity_name,
    'database' as source_format,
    NULL as height,
    NULL as mass,
    NULL as gender,
    '{"market_segment":"' || c_mktsegment || '","account_balance":"' || CAST(c_acctbal AS VARCHAR) || '","nation_key":"' || CAST(c_nationkey as VARCHAR) || '"}' as additional_info,
    CURRENT_TIMESTAMP as integration_timestamp
FROM customer
LIMIT 10;

-- Combine all sources into integrated table
CREATE TEMPORARY TABLE integrated_star_wars_data AS
SELECT * FROM characters_source
UNION ALL
SELECT * FROM films_source
UNION ALL
SELECT * FROM customers_source;

-- Show integration results
SELECT 
    entity_type,
    source_format,
    COUNT(*) as record_count,
    COUNT(CASE WHEN entity_name IS NOT NULL THEN 1 END) as named_entities,
    COUNT(CASE WHEN additional_info IS NOT NULL THEN 1 END) as entities_with_extra_info
FROM integrated_star_wars_data
GROUP BY entity_type, source_format
ORDER BY entity_type, source_format;

-- ============================================
-- DATA TRANSFORMATION PIPELINE SUMMARY
-- ============================================

-- WHAT IT IS: A transformation pipeline orchestrates multiple ETL steps
-- in a logical sequence to produce high-quality, analysis-ready data.
--
-- WHY IT MATTERS: Pipelines provide:
-- - Consistent, repeatable data processing
-- - Clear data lineage and transformation tracking
-- - Automated quality assurance and validation
-- - Scalable processing for growing data volumes

-- Example 8: Complete ETL Pipeline Summary
-- Business Question: "What does a complete ETL pipeline look like?"

CREATE TEMPORARY TABLE pipeline_execution_log AS (
SELECT 
    'EXTRACT' as pipeline_stage,
    'Multi-source data extraction' as stage_description,
    3 as sources_processed,
    60 as records_processed,
    0 as errors_encountered,
    '2024-01-01 10:00:00'::TIMESTAMP as stage_start,
    '2024-01-01 10:02:00'::TIMESTAMP as stage_end

UNION ALL

SELECT 
    'CLEANSE' as pipeline_stage,
    'Data cleansing and standardization' as stage_description,
    1 as sources_processed,
    60 as records_processed,
    5 as errors_encountered,
    '2024-01-01 10:02:00'::TIMESTAMP as stage_start,
    '2024-01-01 10:05:00'::TIMESTAMP as stage_end

UNION ALL

SELECT 
    'ENRICH' as pipeline_stage,
    'Data enrichment and calculation' as stage_description,
    1 as sources_processed,
    55 as records_processed,
    0 as errors_encountered,
    '2024-01-01 10:05:00'::TIMESTAMP as stage_start,
    '2024-01-01 10:08:00'::TIMESTAMP as stage_end

UNION ALL

SELECT 
    'LOAD' as pipeline_stage,
    'Incremental loading to warehouse' as stage_description,
    1 as sources_processed,
    55 as records_processed,
    0 as errors_encountered,
    '2024-01-01 10:08:00'::TIMESTAMP as stage_start,
    '2024-01-01 10:10:00'::TIMESTAMP as stage_end
);

-- Pipeline execution summary
SELECT 
    pipeline_stage,
    stage_description,
    sources_processed,
    records_processed,
    errors_encountered,
    DATEDIFF('second', stage_start, stage_end) as duration_seconds,
    CASE 
        WHEN errors_encountered = 0 THEN 'SUCCESS'
        WHEN errors_encountered < records_processed * 0.05 THEN 'SUCCESS_WITH_WARNINGS'
        ELSE 'FAILED'
    END as stage_status
FROM pipeline_execution_log
ORDER BY stage_start;

-- ============================================
-- CLEANUP TEMPORARY OBJECTS
-- ============================================

DROP TABLE IF EXISTS extracted_customers;
DROP TABLE IF EXISTS extracted_characters;
DROP TABLE IF EXISTS extracted_films;
DROP TABLE IF EXISTS messy_customer_data;
DROP TABLE IF EXISTS cleaned_customer_data;
DROP TABLE IF EXISTS standardized_characters;
DROP TABLE IF EXISTS enriched_customers;
DROP TABLE IF EXISTS customer_warehouse;
DROP TABLE IF EXISTS customer_source_changes;
DROP TABLE IF EXISTS incremental_load_results;
DROP TABLE IF EXISTS etl_error_log;
DROP TABLE IF EXISTS error_prone_data;
DROP TABLE IF EXISTS processed_with_errors;
DROP TABLE IF EXISTS characters_source;
DROP TABLE IF EXISTS films_source;
DROP TABLE IF EXISTS customers_source;
DROP TABLE IF EXISTS integrated_star_wars_data;
DROP TABLE IF EXISTS pipeline_execution_log;

-- ============================================
-- ETL TRANSFORMATIONS BEST PRACTICES SUMMARY
-- ============================================

-- 1. DATA EXTRACTION:
--    - Support multiple data formats (CSV, JSON, Parquet, databases)
--    - Implement schema inference and validation
--    - Use efficient file reading patterns and parallel processing

-- 2. DATA CLEANSING:
--    - Standardize text formatting (trim, case conversion)
--    - Handle null values and missing data consistently
--    - Validate data types and ranges

-- 3. DATA STANDARDIZATION:
--    - Establish consistent formats for dates, currencies, and units
--    - Create standard category mappings and lookups
--    - Implement data quality scoring and flagging

-- 4. DATA ENRICHMENT:
--    - Add calculated fields and derived metrics
--    - Implement business logic and rules
--    - Create customer segmentation and scoring

-- 5. INCREMENTAL LOADING:
--    - Use timestamp-based change detection
--    - Implement upsert (insert/update) logic
--    - Track data lineage and processing metadata

-- 6. ERROR HANDLING:
--    - Implement graceful error recovery
--    - Log errors with sufficient detail for debugging
--    - Provide data quality metrics and alerts

-- 7. PIPELINE ORCHESTRATION:
--    - Design modular, reusable transformation components
--    - Implement proper error handling and rollback mechanisms
--    - Monitor pipeline performance and data quality metrics

-- These ETL transformation patterns provide the foundation for robust,
-- scalable data engineering pipelines that ensure high-quality data
-- for analytics and business intelligence applications.