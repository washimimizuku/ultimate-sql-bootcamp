-- =============================================
-- Section 7: Advanced SQL - Collations
-- =============================================
-- This file demonstrates collation usage in DuckDB
-- Collations control how text is sorted and compared
-- Based on Tom Bailey's SQL course, adapted for DuckDB
-- =============================================

-- Setup: Use TPC-H database for examples
-- Note: Database connection is handled by the SQL runner

-- =============================================
-- 1. UNDERSTANDING COLLATIONS
-- =============================================

-- What are collations?
-- Collations provide rules for how text should be sorted or compared
-- They are essential for internationalization and proper text handling
-- Different languages have different sorting rules

-- Check available collations (requires ICU extension)
-- PRAGMA collations;

-- =============================================
-- 2. BINARY COLLATION (DEFAULT)
-- =============================================

-- Default behavior: BINARY collation (case-sensitive, fastest)
SELECT 'Binary Collation Examples' as section;

-- Case-sensitive comparison (default)
SELECT 
    'Apple' = 'apple' as case_sensitive_equal,
    'Apple' < 'apple' as case_sensitive_less_than;

-- Sorting with default BINARY collation
SELECT c_name, c_nationkey
FROM customer 
WHERE c_name LIKE 'Customer#00000001%'
ORDER BY c_name
LIMIT 10;

-- =============================================
-- 3. NOCASE COLLATION
-- =============================================

-- Case-insensitive operations
SELECT 'NOCASE Collation Examples' as section;

-- Case-insensitive comparison
SELECT 
    'Apple' = 'apple' COLLATE NOCASE as nocase_equal,
    'Apple' < 'apple' COLLATE NOCASE as nocase_less_than;

-- Case-insensitive sorting
SELECT c_name, c_nationkey
FROM customer 
WHERE c_name LIKE 'Customer#00000001%'
ORDER BY c_name COLLATE NOCASE
LIMIT 10;

-- Case-insensitive filtering
SELECT COUNT(*) as customer_count
FROM customer 
WHERE c_name COLLATE NOCASE LIKE '%customer%';

-- =============================================
-- 4. NOACCENT COLLATION
-- =============================================

-- Accent-insensitive operations (useful for international names)
SELECT 'NOACCENT Collation Examples' as section;

-- Create test data with accented characters
WITH international_names AS (
    SELECT name FROM VALUES 
        ('José'), ('Jose'), ('François'), ('Francois'),
        ('Müller'), ('Mueller'), ('Café'), ('Cafe')
    AS t(name)
)
SELECT 
    name,
    name = 'Jose' COLLATE NOACCENT as matches_jose,
    name = 'Francois' COLLATE NOACCENT as matches_francois
FROM international_names
ORDER BY name COLLATE NOACCENT;

-- =============================================
-- 5. NFC COLLATION
-- =============================================

-- Unicode normalization (NFC = Normalized Form Canonical)
SELECT 'NFC Collation Examples' as section;

-- NFC normalization ensures consistent Unicode representation
WITH unicode_test AS (
    SELECT name FROM VALUES 
        ('café'), ('cafe'), ('naïve'), ('naive')
    AS t(name)
)
SELECT 
    name,
    LENGTH(name) as char_length,
    name COLLATE NFC as normalized
FROM unicode_test
ORDER BY name COLLATE NFC;

-- =============================================
-- 6. COMBINING COLLATIONS
-- =============================================

-- NOCASE can be combined with other collations
SELECT 'Combined Collations Examples' as section;

WITH mixed_text AS (
    SELECT text FROM VALUES 
        ('CAFÉ'), ('Café'), ('café'), ('CAFE'), ('Cafe'), ('cafe')
    AS t(text)
)
SELECT 
    text,
    text = 'cafe' COLLATE NOCASE as nocase_match,
    text = 'cafe' COLLATE NOCASE.NOACCENT as combined_match
FROM mixed_text
ORDER BY text COLLATE NOCASE.NOACCENT;

-- =============================================
-- 7. COLUMN-LEVEL COLLATIONS
-- =============================================

-- Set collation when creating tables
SELECT 'Column-Level Collations' as section;

-- Create table with column collations
DROP TABLE IF EXISTS products_collation_demo;
CREATE TABLE products_collation_demo (
    id INTEGER,
    name VARCHAR COLLATE NOCASE,
    description VARCHAR COLLATE NOCASE.NOACCENT,
    category VARCHAR
);

-- Insert test data
INSERT INTO products_collation_demo VALUES
    (1, 'iPhone', 'Smartphone with advanced features', 'Electronics'),
    (2, 'IPHONE', 'Another iPhone entry', 'Electronics'),
    (3, 'Café Blend', 'Premium coffee blend', 'Food'),
    (4, 'CAFE BLEND', 'Same coffee, different case', 'Food');

-- Column collation automatically applied
SELECT * FROM products_collation_demo
WHERE name = 'iphone'  -- Will match both iPhone and IPHONE
ORDER BY description;

-- =============================================
-- 8. GLOBAL DEFAULT COLLATION
-- =============================================

-- Set database-wide default collation
SELECT 'Global Default Collation' as section;

-- Check current default collation (not available in current DuckDB version)
-- PRAGMA default_collation;

-- Set global default (affects new comparisons)
-- PRAGMA default_collation = 'NOCASE';

-- Reset to default
-- PRAGMA default_collation = 'BINARY';

-- =============================================
-- 9. ICU EXTENSION FOR LANGUAGE-SPECIFIC COLLATIONS
-- =============================================

-- Load ICU extension for language-specific rules
SELECT 'ICU Extension Examples' as section;

-- Note: ICU extension provides 100+ language collations
-- Uncomment to use (requires ICU extension):
-- LOAD icu;

-- Examples of language-specific collations (when ICU is loaded):
-- German collation (ä, ö, ü sorting)
-- SELECT * FROM table ORDER BY name COLLATE de;

-- French collation
-- SELECT * FROM table ORDER BY name COLLATE fr;

-- Chinese collation
-- SELECT * FROM table ORDER BY name COLLATE zh_CN;

-- List all available collations
-- SELECT * FROM pragma_collations() ORDER BY collation_name;

-- =============================================
-- 10. PRACTICAL COLLATION PATTERNS
-- =============================================

-- Common real-world scenarios
SELECT 'Practical Patterns' as section;

-- 1. User search (case-insensitive)
SELECT c_custkey, c_name, c_phone
FROM customer 
WHERE c_name COLLATE NOCASE LIKE '%smith%'
LIMIT 5;

-- 2. Duplicate detection (case and accent insensitive)
WITH customer_names AS (
    SELECT 
        c_custkey,
        c_name,
        c_name COLLATE NOCASE.NOACCENT as normalized_name
    FROM customer
    LIMIT 100
)
SELECT 
    normalized_name,
    COUNT(*) as duplicate_count,
    STRING_AGG(c_name, ', ') as original_names
FROM customer_names
GROUP BY normalized_name
HAVING COUNT(*) > 1;

-- 3. Sorting for display (case-insensitive)
SELECT 
    n_name as nation,
    COUNT(*) as customer_count
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
GROUP BY n_name
ORDER BY n_name COLLATE NOCASE;

-- =============================================
-- 11. PERFORMANCE CONSIDERATIONS
-- =============================================

-- Performance comparison of different collations
SELECT 'Performance Considerations' as section;

-- BINARY is fastest (default)
-- NOCASE has moderate overhead
-- Combined collations (NOCASE.NOACCENT) have higher overhead
-- ICU language collations have the highest overhead

-- For large datasets, consider:
-- 1. Using BINARY when case sensitivity is acceptable
-- 2. Creating computed columns with normalized values
-- 3. Using indexes on normalized columns

-- Example: Computed column approach for performance
DROP TABLE IF EXISTS customer_normalized;
CREATE TABLE customer_normalized AS
SELECT 
    c_custkey,
    c_name,
    UPPER(c_name) as c_name_upper,  -- Pre-computed for fast case-insensitive searches
    c_nationkey
FROM customer
LIMIT 1000;

-- Fast case-insensitive search using computed column
SELECT c_custkey, c_name
FROM customer_normalized
WHERE c_name_upper = UPPER('Customer#000000001');

-- =============================================
-- 12. COLLATION LIMITATIONS AND WORKAROUNDS
-- =============================================

-- DuckDB collation limitations
SELECT 'Limitations and Workarounds' as section;

-- 1. No CREATE COLLATION command
-- Workaround: Use built-in collations or ICU extension

-- 2. Limited collation combinations
-- Workaround: Use CASE expressions for custom sorting

-- Custom sort order example
WITH priority_categories AS (
    SELECT category FROM VALUES 
        ('Critical'), ('High'), ('Medium'), ('Low')
    AS t(category)
)
SELECT category
FROM priority_categories
ORDER BY CASE category
    WHEN 'Critical' THEN 1
    WHEN 'High' THEN 2
    WHEN 'Medium' THEN 3
    WHEN 'Low' THEN 4
    ELSE 5
END;

-- 3. Complex text transformations
-- Workaround: Use string functions with collations
SELECT 
    c_name,
    REPLACE(REPLACE(c_name, 'Customer#', ''), '000000', '') as simplified_name
FROM customer
WHERE c_custkey <= 10
ORDER BY simplified_name COLLATE NOCASE;

-- =============================================
-- 13. BEST PRACTICES
-- =============================================

-- Collation best practices:
SELECT 'Best Practices Summary' as section;

/*
1. PERFORMANCE:
   - Use BINARY (default) when case sensitivity is acceptable
   - Consider computed columns for frequently searched text
   - Test performance impact of collations on large datasets

2. CONSISTENCY:
   - Set column-level collations at table creation
   - Use consistent collations across related tables
   - Document collation choices for team understanding

3. INTERNATIONALIZATION:
   - Use NOCASE for case-insensitive applications
   - Use NOACCENT for international character support
   - Load ICU extension for language-specific rules

4. MAINTENANCE:
   - Avoid mixing different collations in joins
   - Use explicit COLLATE clauses when needed
   - Test collation behavior with your specific data

5. COMPATIBILITY:
   - Understand that DuckDB doesn't support CREATE COLLATION
   - Plan for collation differences when migrating from other databases
   - Use standard collations for better portability
*/

-- Cleanup
DROP TABLE IF EXISTS products_collation_demo;
DROP TABLE IF EXISTS customer_normalized;

-- =============================================
-- SUMMARY
-- =============================================

/*
This file covered:

1. Understanding collations and their importance
2. BINARY collation (default, fastest)
3. NOCASE collation (case-insensitive)
4. NOACCENT collation (accent-insensitive)
5. NFC collation (Unicode normalization)
6. Combining collations (NOCASE.NOACCENT)
7. Column-level collation settings
8. Global default collation configuration
9. ICU extension for language-specific rules
10. Practical collation patterns and use cases
11. Performance considerations and optimization
12. Limitations and workarounds
13. Best practices for collation usage

Key takeaways:
- Collations control text sorting and comparison behavior
- DuckDB provides built-in collations optimized for performance
- ICU extension adds 100+ language-specific collations
- Choose collations based on application requirements and performance needs
- Use explicit COLLATE clauses when mixing different collation requirements
*/