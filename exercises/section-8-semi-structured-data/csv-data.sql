-- CSV Data Processing - Semi-Structured Data
-- This file demonstrates working with CSV data in DuckDB
-- CSV is a common format for tabular data with flexible schema handling
-- ============================================
-- REQUIRED: This file uses various data sources in data/ folder
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-8-semi-structured-data/csv-data.sql
-- ============================================

-- CSV CONCEPTS:
-- - CSV (Comma-Separated Values) is a simple tabular data format
-- - Each row represents a record, columns separated by delimiters
-- - Headers can define column names and types can be inferred
-- - DuckDB provides powerful CSV reading with automatic type detection

-- CSV FUNCTIONS IN DUCKDB:
-- - read_csv('file.csv'): Read CSV with automatic schema detection
-- - read_csv_auto('file.csv'): Alias for read_csv with auto-detection
-- - COPY FROM 'file.csv': Import CSV data into tables
-- - CSV reading options: delimiter, header, quote, escape, null_padding
-- - Schema inference: automatic type detection and column naming
-- - Error handling: skip_errors, ignore_errors for malformed data

-- CSV LOADING OPTIONS:
-- - header=true/false: First row contains column names
-- - delimiter=',': Character separating fields
-- - quote='"': Character for quoting fields
-- - escape='"': Character for escaping quotes
-- - null_padding=true: Pad missing columns with NULL
-- - sample_size: Number of rows to sample for type inference

-- =====================================================
-- BASIC CSV READING EXAMPLES
-- =====================================================

-- Example 1: Simple CSV Reading with Automatic Schema Detection
-- DuckDB automatically detects column types and handles headers
SELECT 'Example 1: Basic CSV Reading - Characters' as example;

SELECT * FROM read_csv('data/star-wars/csv/characters.csv') 
LIMIT 5;

-- Show the inferred schema
DESCRIBE SELECT * FROM read_csv('data/star-wars/csv/characters.csv');

-- Example 2: Reading Multiple CSV Files
-- Explore different Star Wars data files
SELECT 'Example 2: Reading Different CSV Files' as example;

-- Characters data
SELECT 'Characters:' as dataset;
SELECT COUNT(*) as total_characters FROM read_csv('data/star-wars/csv/characters.csv');

-- Planets data
SELECT 'Planets:' as dataset;
SELECT COUNT(*) as total_planets FROM read_csv('data/star-wars/csv/planets.csv');

-- Species data
SELECT 'Species:' as dataset;
SELECT COUNT(*) as total_species FROM read_csv('data/star-wars/csv/species.csv');

-- Starships data
SELECT 'Starships:' as dataset;
SELECT COUNT(*) as total_starships FROM read_csv('data/star-wars/csv/starships.csv');

-- Vehicles data
SELECT 'Vehicles:' as dataset;
SELECT COUNT(*) as total_vehicles FROM read_csv('data/star-wars/csv/vehicles.csv');

-- =====================================================
-- CSV SCHEMA ANALYSIS AND TYPE HANDLING
-- =====================================================

-- Example 3: Analyzing CSV Schema and Data Types
SELECT 'Example 3: Schema Analysis' as example;

-- Examine character data types and handle missing values
SELECT 
    name,
    height,
    mass,
    CASE WHEN hair_color = 'NA' THEN NULL ELSE hair_color END as hair_color,
    birth_year,
    gender,
    homeworld,
    species
FROM read_csv('data/star-wars/csv/characters.csv')
WHERE name IN ('Luke Skywalker', 'C-3PO', 'R2-D2', 'Darth Vader');

-- Example 4: Handling Different Data Types and NULL Values
SELECT 'Example 4: Data Type Conversion and NULL Handling' as example;

SELECT 
    name,
    CAST(height AS INTEGER) as height_cm,
    CASE 
        WHEN mass = 'NA' OR mass = 'unknown' THEN NULL 
        ELSE CAST(REPLACE(mass, ',', '') AS INTEGER) 
    END as mass_kg,
    CASE 
        WHEN birth_year LIKE '%BBY' THEN 
            CAST(REPLACE(birth_year, 'BBY', '') AS DECIMAL(5,1)) * -1
        WHEN birth_year LIKE '%ABY' THEN 
            CAST(REPLACE(birth_year, 'ABY', '') AS DECIMAL(5,1))
        ELSE NULL
    END as birth_year_numeric,
    species
FROM read_csv('data/star-wars/csv/characters.csv')
WHERE height != 'NA' AND mass != 'NA' AND mass != 'unknown'
ORDER BY height_cm DESC
LIMIT 10;

-- =====================================================
-- ADVANCED CSV READING WITH OPTIONS
-- =====================================================

-- Example 5: CSV Reading with Custom Options
SELECT 'Example 5: Custom CSV Reading Options' as example;

-- Read with specific options (DuckDB parameter names)
SELECT * FROM read_csv('data/star-wars/csv/planets.csv',
    header=true,
    delim=',',
    quote='"',
    null_padding=true
) LIMIT 5;

-- Example 6: Handling Complex String Data
SELECT 'Example 6: Processing Complex String Fields' as example;

-- Parse comma-separated values within fields
SELECT 
    name,
    climate,
    STRING_SPLIT(terrain, ', ') as terrain_list,
    CASE 
        WHEN diameter = 'NA' OR diameter = '0' THEN NULL 
        ELSE CAST(diameter AS INTEGER) 
    END as diameter_km,
    CASE 
        WHEN population = 'NA' OR population = 'unknown' THEN NULL 
        ELSE CAST(population AS BIGINT) 
    END as population_count
FROM read_csv('data/star-wars/csv/planets.csv')
WHERE climate != 'NA'
ORDER BY diameter_km DESC NULLS LAST;

-- =====================================================
-- CSV DATA ANALYSIS AND AGGREGATION
-- =====================================================

-- Example 7: Statistical Analysis of CSV Data
SELECT 'Example 7: Statistical Analysis' as example;

-- Character statistics
SELECT 
    'Character Statistics' as analysis_type,
    COUNT(*) as total_count,
    AVG(CASE WHEN height != 'NA' THEN CAST(height AS INTEGER) END) as avg_height,
    AVG(CASE WHEN mass != 'NA' AND mass != 'unknown' THEN CAST(REPLACE(mass, ',', '') AS INTEGER) END) as avg_mass,
    COUNT(DISTINCT species) as unique_species,
    COUNT(DISTINCT homeworld) as unique_homeworlds
FROM read_csv('data/star-wars/csv/characters.csv');

-- Species analysis
SELECT 
    'Species Analysis' as analysis_type,
    COUNT(*) as total_species,
    AVG(CASE WHEN average_height != 'NA' THEN CAST(average_height AS INTEGER) END) as avg_species_height,
    AVG(CASE WHEN average_lifespan != 'NA' AND average_lifespan != 'indefinite' THEN CAST(average_lifespan AS INTEGER) END) as avg_lifespan
FROM read_csv('data/star-wars/csv/species.csv');

-- Example 8: Grouping and Aggregation
SELECT 'Example 8: Grouping Analysis' as example;

-- Characters by species
SELECT 
    species,
    COUNT(*) as character_count,
    AVG(CASE WHEN height != 'NA' THEN CAST(height AS INTEGER) END) as avg_height,
    STRING_AGG(name, ', ') as character_names
FROM read_csv('data/star-wars/csv/characters.csv')
GROUP BY species
HAVING COUNT(*) > 1
ORDER BY character_count DESC;

-- =====================================================
-- JOINING CSV DATA
-- =====================================================

-- Example 9: Joining Multiple CSV Files
SELECT 'Example 9: Cross-File Analysis with Joins' as example;

-- Join characters with their homeworld details
SELECT 
    c.name as character_name,
    c.species,
    c.homeworld,
    p.climate,
    p.terrain,
    CASE WHEN p.population = 'NA' THEN NULL ELSE CAST(p.population AS BIGINT) END as homeworld_population
FROM read_csv('data/star-wars/csv/characters.csv') c
LEFT JOIN read_csv('data/star-wars/csv/planets.csv') p 
    ON c.homeworld = p.name
WHERE c.homeworld != 'NA'
ORDER BY homeworld_population DESC NULLS LAST
LIMIT 10;

-- =====================================================
-- CSV DATA QUALITY AND VALIDATION
-- =====================================================

-- Example 10: Data Quality Checks
SELECT 'Example 10: Data Quality Analysis' as example;

-- Check for missing values and data consistency
SELECT 
    'Characters' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN name IS NULL OR name = '' THEN 1 ELSE 0 END) as missing_names,
    SUM(CASE WHEN height = 'NA' THEN 1 ELSE 0 END) as missing_heights,
    SUM(CASE WHEN mass = 'NA' THEN 1 ELSE 0 END) as missing_mass,
    SUM(CASE WHEN homeworld = 'NA' THEN 1 ELSE 0 END) as missing_homeworld
FROM read_csv('data/star-wars/csv/characters.csv')

UNION ALL

SELECT 
    'Planets' as table_name,
    COUNT(*) as total_rows,
    SUM(CASE WHEN name IS NULL OR name = '' THEN 1 ELSE 0 END) as missing_names,
    SUM(CASE WHEN diameter = 'NA' THEN 1 ELSE 0 END) as missing_diameter,
    SUM(CASE WHEN population = 'NA' THEN 1 ELSE 0 END) as missing_population,
    SUM(CASE WHEN climate = 'NA' THEN 1 ELSE 0 END) as missing_climate
FROM read_csv('data/star-wars/csv/planets.csv');

-- =====================================================
-- CREATING TABLES FROM CSV DATA
-- =====================================================

-- Example 11: Creating Persistent Tables from CSV
SELECT 'Example 11: Creating Tables from CSV Data' as example;

-- Create a cleaned characters table
CREATE TEMPORARY TABLE star_wars_characters AS
SELECT 
    name,
    CASE WHEN height = 'NA' THEN NULL ELSE CAST(height AS INTEGER) END as height,
    CASE 
        WHEN mass = 'NA' OR mass = 'unknown' THEN NULL 
        ELSE CAST(REPLACE(mass, ',', '') AS INTEGER) 
    END as mass,
    CASE WHEN hair_color = 'NA' THEN NULL ELSE hair_color END as hair_color,
    CASE WHEN skin_color = 'NA' THEN NULL ELSE skin_color END as skin_color,
    CASE WHEN eye_color = 'NA' THEN NULL ELSE eye_color END as eye_color,
    birth_year,
    CASE WHEN gender = 'NA' THEN NULL ELSE gender END as gender,
    CASE WHEN homeworld = 'NA' THEN NULL ELSE homeworld END as homeworld,
    species
FROM read_csv('data/star-wars/csv/characters.csv');

-- Verify the created table
SELECT 'Created table verification:' as info;
SELECT COUNT(*) as total_characters FROM star_wars_characters;
SELECT * FROM star_wars_characters WHERE height IS NOT NULL ORDER BY height DESC LIMIT 5;

-- =====================================================
-- ADVANCED CSV PROCESSING TECHNIQUES
-- =====================================================

-- Example 12: Complex Data Transformation
SELECT 'Example 12: Advanced Data Transformation' as example;

-- Create a comprehensive character profile
SELECT 
    name,
    species,
    homeworld,
    CASE 
        WHEN height IS NULL THEN 'Unknown'
        WHEN height < 100 THEN 'Very Short'
        WHEN height < 150 THEN 'Short'
        WHEN height < 180 THEN 'Average'
        WHEN height < 200 THEN 'Tall'
        ELSE 'Very Tall'
    END as height_category,
    CASE 
        WHEN mass IS NULL THEN 'Unknown'
        WHEN mass < 50 THEN 'Light'
        WHEN mass < 80 THEN 'Average'
        WHEN mass < 120 THEN 'Heavy'
        ELSE 'Very Heavy'
    END as mass_category,
    CASE 
        WHEN birth_year LIKE '%BBY' THEN 'Before Battle of Yavin'
        WHEN birth_year LIKE '%ABY' THEN 'After Battle of Yavin'
        ELSE 'Unknown Era'
    END as era
FROM star_wars_characters
ORDER BY height DESC NULLS LAST;

-- Example 13: Export Results to CSV
SELECT 'Example 13: Exporting Analysis Results' as example;

-- Create a summary report (would normally export to file)
SELECT 
    'Species Summary Report' as report_type,
    species,
    COUNT(*) as character_count,
    ROUND(AVG(height), 1) as avg_height,
    ROUND(AVG(mass), 1) as avg_mass,
    COUNT(DISTINCT homeworld) as unique_homeworlds
FROM star_wars_characters
WHERE species IS NOT NULL
GROUP BY species
HAVING COUNT(*) >= 1
ORDER BY character_count DESC, avg_height DESC;

-- Clean up temporary table
DROP TABLE star_wars_characters;

-- =====================================================
-- CSV BEST PRACTICES SUMMARY
-- =====================================================

SELECT 'CSV Processing Best Practices:' as summary;
SELECT '1. Always examine schema with DESCRIBE before processing' as practice
UNION ALL SELECT '2. Handle missing values (NA, empty strings) appropriately'
UNION ALL SELECT '3. Use appropriate data type casting for analysis'
UNION ALL SELECT '4. Validate data quality before complex operations'
UNION ALL SELECT '5. Consider creating temporary tables for complex transformations'
UNION ALL SELECT '6. Use STRING_SPLIT for comma-separated values within fields'
UNION ALL SELECT '7. Apply consistent NULL handling across your analysis'
UNION ALL SELECT '8. Test with LIMIT before processing large files'
UNION ALL SELECT '9. Use appropriate aggregation functions for your data types'
UNION ALL SELECT '10. Document your data cleaning and transformation steps';