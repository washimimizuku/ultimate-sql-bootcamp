-- Parquet Data Processing - Semi-Structured Data
-- This file demonstrates working with Parquet data in DuckDB
-- Parquet is a columnar storage format optimized for analytics workloads
-- ============================================
-- REQUIRED: This file uses various data sources in data/ folder
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-8-semi-structured-data/parquet-data.sql
-- ============================================

-- PARQUET CONCEPTS:
-- - Parquet is a columnar storage format for big data processing
-- - Provides efficient compression and encoding schemes
-- - Supports complex nested data structures (arrays, maps, structs)
-- - Schema evolution and predicate pushdown for performance
-- - Native support in DuckDB with zero-copy reads

-- PARQUET FUNCTIONS IN DUCKDB:
-- - read_parquet('file.parquet'): Read Parquet files directly
-- - parquet_metadata('file.parquet'): Get file metadata information
-- - parquet_schema('file.parquet'): Display schema information
-- - COPY FROM 'file.parquet': Import Parquet data into tables
-- - Glob patterns: read multiple files with wildcards
-- - Column projection: read only specific columns for performance

-- PARQUET ADVANTAGES:
-- - Columnar storage: efficient for analytical queries
-- - Compression: smaller file sizes with various algorithms
-- - Schema preservation: maintains data types and structure
-- - Predicate pushdown: filter data at file level
-- - Cross-platform: works across different systems and languages
-- - Nested data: supports complex data structures natively

-- =====================================================
-- BASIC PARQUET READING EXAMPLES
-- =====================================================

-- Example 1: Simple Parquet Reading with Schema Detection
-- DuckDB automatically detects column types and optimizes queries
SELECT 'Example 1: Basic Parquet Reading - Titanic Dataset' as example;

SELECT * FROM read_parquet('data/titanic/titanic.parquet') 
LIMIT 5;

-- Show the inferred schema and data types
DESCRIBE SELECT * FROM read_parquet('data/titanic/titanic.parquet');

-- Example 2: Parquet File Metadata Analysis
-- Examine file structure and compression information
SELECT 'Example 2: Parquet Metadata Analysis' as example;

-- Get basic file statistics
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT PassengerId) as unique_passengers,
    MIN(Age) as min_age,
    MAX(Age) as max_age,
    AVG(Age) as avg_age,
    MIN(Fare) as min_fare,
    MAX(Fare) as max_fare,
    AVG(Fare) as avg_fare
FROM read_parquet('data/titanic/titanic.parquet');

-- =====================================================
-- PARQUET PERFORMANCE FEATURES
-- =====================================================

-- Example 3: Column Projection (Reading Only Specific Columns)
-- Parquet's columnar format allows efficient column selection
SELECT 'Example 3: Column Projection Performance' as example;

-- Read only specific columns for better performance
SELECT 
    Name,
    Age,
    Sex,
    Survived,
    Pclass
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Age IS NOT NULL
ORDER BY Age DESC
LIMIT 10;

-- Example 4: Predicate Pushdown Optimization
-- Filters are applied at the file level before data is loaded
SELECT 'Example 4: Predicate Pushdown Optimization' as example;

-- Efficient filtering using predicate pushdown
SELECT 
    COUNT(*) as survivors_first_class,
    AVG(Age) as avg_age,
    AVG(Fare) as avg_fare
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Pclass = 1 AND Survived = 1;

-- Compare with different classes
SELECT 
    Pclass,
    COUNT(*) as total_passengers,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct,
    AVG(Age) as avg_age,
    AVG(Fare) as avg_fare
FROM read_parquet('data/titanic/titanic.parquet')
GROUP BY Pclass
ORDER BY Pclass;

-- =====================================================
-- ADVANCED PARQUET ANALYTICS
-- =====================================================

-- Example 5: Complex Analytical Queries on Parquet Data
SELECT 'Example 5: Complex Analytical Queries' as example;

-- Survival analysis by multiple dimensions
SELECT 
    Sex,
    Pclass,
    CASE 
        WHEN Age < 18 THEN 'Child'
        WHEN Age < 35 THEN 'Young Adult'
        WHEN Age < 55 THEN 'Middle Age'
        ELSE 'Senior'
    END as age_group,
    COUNT(*) as total_passengers,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Age IS NOT NULL
GROUP BY Sex, Pclass, age_group
ORDER BY Sex, Pclass, age_group;

-- Example 6: Window Functions on Parquet Data
SELECT 'Example 6: Window Functions on Parquet Data' as example;

-- Ranking passengers by fare within each class
SELECT 
    Name,
    Pclass,
    Fare,
    Survived,
    ROW_NUMBER() OVER (PARTITION BY Pclass ORDER BY Fare DESC) as fare_rank_in_class,
    PERCENT_RANK() OVER (PARTITION BY Pclass ORDER BY Fare) as fare_percentile_in_class,
    AVG(Fare) OVER (PARTITION BY Pclass) as avg_fare_in_class
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Fare IS NOT NULL
QUALIFY fare_rank_in_class <= 5
ORDER BY Pclass, fare_rank_in_class;

-- =====================================================
-- PARQUET DATA QUALITY AND EXPLORATION
-- =====================================================

-- Example 7: Data Quality Assessment
SELECT 'Example 7: Data Quality Assessment' as example;

-- Analyze missing values and data completeness
SELECT 
    'Data Completeness Analysis' as analysis_type,
    COUNT(*) as total_records,
    COUNT(PassengerId) as passengerid_count,
    COUNT(Name) as name_count,
    COUNT(Age) as age_count,
    COUNT(Cabin) as cabin_count,
    COUNT(Embarked) as embarked_count,
    ROUND((COUNT(Age) * 100.0 / COUNT(*)), 2) as age_completeness_pct,
    ROUND((COUNT(Cabin) * 100.0 / COUNT(*)), 2) as cabin_completeness_pct,
    ROUND((COUNT(Embarked) * 100.0 / COUNT(*)), 2) as embarked_completeness_pct
FROM read_parquet('data/titanic/titanic.parquet');

-- Example 8: Statistical Analysis of Parquet Data
SELECT 'Example 8: Statistical Analysis' as example;

-- Comprehensive statistical summary
SELECT 
    'Age Statistics' as metric_type,
    COUNT(Age) as count,
    ROUND(AVG(Age), 2) as mean,
    ROUND(STDDEV(Age), 2) as std_dev,
    MIN(Age) as minimum,
    ROUND(QUANTILE_CONT(Age, 0.25), 2) as q1,
    ROUND(QUANTILE_CONT(Age, 0.5), 2) as median,
    ROUND(QUANTILE_CONT(Age, 0.75), 2) as q3,
    MAX(Age) as maximum
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Age IS NOT NULL

UNION ALL

SELECT 
    'Fare Statistics' as metric_type,
    COUNT(Fare) as count,
    ROUND(AVG(Fare), 2) as mean,
    ROUND(STDDEV(Fare), 2) as std_dev,
    MIN(Fare) as minimum,
    ROUND(QUANTILE_CONT(Fare, 0.25), 2) as q1,
    ROUND(QUANTILE_CONT(Fare, 0.5), 2) as median,
    ROUND(QUANTILE_CONT(Fare, 0.75), 2) as q3,
    MAX(Fare) as maximum
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Fare IS NOT NULL;

-- =====================================================
-- PARQUET STRING PROCESSING AND ANALYSIS
-- =====================================================

-- Example 9: Advanced String Processing on Parquet Data
SELECT 'Example 9: Advanced String Processing' as example;

-- Extract titles from passenger names and analyze survival rates
WITH passenger_titles AS (
    SELECT 
        PassengerId,
        Name,
        REGEXP_EXTRACT(Name, '([A-Za-z]+)\.', 1) as title,
        Age,
        Sex,
        Pclass,
        Survived,
        Fare
    FROM read_parquet('data/titanic/titanic.parquet')
)
SELECT 
    title,
    COUNT(*) as passenger_count,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct,
    ROUND(AVG(Age), 1) as avg_age,
    ROUND(AVG(Fare), 2) as avg_fare
FROM passenger_titles
WHERE title IS NOT NULL
GROUP BY title
HAVING COUNT(*) >= 5  -- Only show titles with 5+ passengers
ORDER BY passenger_count DESC;

-- Example 10: Cabin Analysis from Parquet Data
SELECT 'Example 10: Cabin Analysis' as example;

-- Analyze cabin information and survival patterns
WITH cabin_analysis AS (
    SELECT 
        PassengerId,
        Name,
        Cabin,
        CASE 
            WHEN Cabin IS NULL THEN 'No Cabin'
            ELSE LEFT(Cabin, 1)
        END as cabin_deck,
        Pclass,
        Survived,
        Fare
    FROM read_parquet('data/titanic/titanic.parquet')
)
SELECT 
    cabin_deck,
    COUNT(*) as passenger_count,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct,
    ROUND(AVG(Fare), 2) as avg_fare,
    MODE() WITHIN GROUP (ORDER BY Pclass) as most_common_class
FROM cabin_analysis
GROUP BY cabin_deck
ORDER BY 
    CASE WHEN cabin_deck = 'No Cabin' THEN 'Z' ELSE cabin_deck END;

-- =====================================================
-- PARQUET AGGREGATION AND GROUPING
-- =====================================================

-- Example 11: Multi-Level Aggregation
SELECT 'Example 11: Multi-Level Aggregation' as example;

-- Family size analysis and survival patterns
WITH family_analysis AS (
    SELECT 
        PassengerId,
        Name,
        SibSp + Parch + 1 as family_size,
        CASE 
            WHEN SibSp + Parch = 0 THEN 'Alone'
            WHEN SibSp + Parch <= 2 THEN 'Small Family'
            WHEN SibSp + Parch <= 4 THEN 'Medium Family'
            ELSE 'Large Family'
        END as family_category,
        Age,
        Sex,
        Pclass,
        Survived,
        Fare,
        Embarked
    FROM read_parquet('data/titanic/titanic.parquet')
)
SELECT 
    family_category,
    Embarked,
    COUNT(*) as passenger_count,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct,
    ROUND(AVG(family_size), 1) as avg_family_size,
    ROUND(AVG(Age), 1) as avg_age
FROM family_analysis
WHERE Embarked IS NOT NULL
GROUP BY family_category, Embarked
ORDER BY family_category, Embarked;

-- =====================================================
-- PARQUET PERFORMANCE OPTIMIZATION
-- =====================================================

-- Example 12: Efficient Parquet Query Patterns
SELECT 'Example 12: Efficient Query Patterns' as example;

-- Demonstrate efficient filtering and aggregation
SELECT 
    'High-Value Passengers Analysis' as analysis_name,
    COUNT(*) as passenger_count,
    AVG(Age) as avg_age,
    AVG(Fare) as avg_fare,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Fare > (SELECT QUANTILE_CONT(Fare, 0.75) FROM read_parquet('data/titanic/titanic.parquet'))

UNION ALL

SELECT 
    'Budget Passengers Analysis' as analysis_name,
    COUNT(*) as passenger_count,
    AVG(Age) as avg_age,
    AVG(Fare) as avg_fare,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct
FROM read_parquet('data/titanic/titanic.parquet')
WHERE Fare <= (SELECT QUANTILE_CONT(Fare, 0.25) FROM read_parquet('data/titanic/titanic.parquet'));

-- =====================================================
-- CREATING TABLES FROM PARQUET DATA
-- =====================================================

-- Example 13: Creating Optimized Tables from Parquet
SELECT 'Example 13: Creating Tables from Parquet Data' as example;

-- Create an enriched analysis table
CREATE TEMPORARY TABLE titanic_analysis AS
SELECT 
    PassengerId,
    Name,
    REGEXP_EXTRACT(Name, '([A-Za-z]+)\.', 1) as title,
    Age,
    CASE 
        WHEN Age < 18 THEN 'Child'
        WHEN Age < 35 THEN 'Young Adult'
        WHEN Age < 55 THEN 'Middle Age'
        ELSE 'Senior'
    END as age_group,
    Sex,
    Pclass,
    SibSp + Parch + 1 as family_size,
    CASE 
        WHEN SibSp + Parch = 0 THEN 'Alone'
        WHEN SibSp + Parch <= 2 THEN 'Small Family'
        WHEN SibSp + Parch <= 4 THEN 'Medium Family'
        ELSE 'Large Family'
    END as family_category,
    Fare,
    CASE 
        WHEN Fare <= 7.91 THEN 'Low'
        WHEN Fare <= 14.45 THEN 'Medium-Low'
        WHEN Fare <= 31.0 THEN 'Medium'
        ELSE 'High'
    END as fare_category,
    CASE 
        WHEN Cabin IS NULL THEN 'No Cabin'
        ELSE LEFT(Cabin, 1)
    END as cabin_deck,
    Embarked,
    Survived
FROM read_parquet('data/titanic/titanic.parquet');

-- Verify the created table
SELECT 'Created table verification:' as info;
SELECT COUNT(*) as total_passengers FROM titanic_analysis;
SELECT * FROM titanic_analysis WHERE Age IS NOT NULL ORDER BY Age DESC LIMIT 5;

-- =====================================================
-- ADVANCED PARQUET ANALYTICS
-- =====================================================

-- Example 14: Survival Prediction Factors Analysis
SELECT 'Example 14: Survival Prediction Factors Analysis' as example;

-- Comprehensive survival factor analysis
SELECT 
    'Overall Survival Factors' as analysis_type,
    Sex,
    age_group,
    Pclass,
    family_category,
    fare_category,
    COUNT(*) as passenger_count,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct
FROM titanic_analysis
WHERE Age IS NOT NULL
GROUP BY Sex, age_group, Pclass, family_category, fare_category
HAVING COUNT(*) >= 3  -- Only show combinations with 3+ passengers
ORDER BY survival_rate_pct DESC, passenger_count DESC
LIMIT 15;

-- Example 15: Port of Embarkation Analysis
SELECT 'Example 15: Port of Embarkation Analysis' as example;

-- Analyze passenger characteristics by embarkation port
SELECT 
    CASE 
        WHEN Embarked = 'C' THEN 'Cherbourg'
        WHEN Embarked = 'Q' THEN 'Queenstown'
        WHEN Embarked = 'S' THEN 'Southampton'
        ELSE 'Unknown'
    END as embarkation_port,
    COUNT(*) as passenger_count,
    SUM(Survived) as survivors,
    ROUND(AVG(CAST(Survived AS DOUBLE)) * 100, 2) as survival_rate_pct,
    ROUND(AVG(Age), 1) as avg_age,
    ROUND(AVG(Fare), 2) as avg_fare,
    MODE() WITHIN GROUP (ORDER BY Pclass) as most_common_class,
    COUNT(CASE WHEN Sex = 'female' THEN 1 END) as female_count,
    COUNT(CASE WHEN Sex = 'male' THEN 1 END) as male_count
FROM titanic_analysis
WHERE Embarked IS NOT NULL
GROUP BY Embarked, embarkation_port
ORDER BY passenger_count DESC;

-- =====================================================
-- PARQUET EXPORT AND OPTIMIZATION
-- =====================================================

-- Example 16: Query Optimization Demonstration
SELECT 'Example 16: Query Optimization Demonstration' as example;

-- Show how Parquet enables efficient analytical queries
WITH survival_summary AS (
    SELECT 
        title,
        Sex,
        Pclass,
        COUNT(*) as total,
        SUM(Survived) as survived,
        AVG(Age) as avg_age,
        AVG(Fare) as avg_fare
    FROM titanic_analysis
    WHERE title IN ('Mr', 'Mrs', 'Miss', 'Master')
    GROUP BY title, Sex, Pclass
)
SELECT 
    title,
    Sex,
    Pclass,
    total,
    survived,
    ROUND((survived * 100.0 / total), 2) as survival_rate_pct,
    ROUND(avg_age, 1) as avg_age,
    ROUND(avg_fare, 2) as avg_fare,
    RANK() OVER (ORDER BY (survived * 100.0 / total) DESC) as survival_rank
FROM survival_summary
ORDER BY survival_rate_pct DESC;

-- Clean up temporary table
DROP TABLE titanic_analysis;

-- =====================================================
-- COMPLEX NESTED PARQUET STRUCTURES
-- =====================================================

-- Example 17: Reading Nested Parquet with Arrays and Structs
SELECT 'Example 17: Reading Nested Parquet with Arrays and Structs' as example;

-- Read nested character data with arrays and struct fields
SELECT 
    name,
    height,
    films,
    len(films) as film_count,
    appearance.hair_color,
    appearance.skin_color,
    personal_info.gender,
    personal_info.homeworld
FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
LIMIT 5;

-- Show the schema of nested Parquet data
DESCRIBE SELECT * FROM read_parquet('data/star-wars/parquet/characters_nested.parquet');

-- Example 18: Unnesting Arrays in Nested Parquet Data
SELECT 'Example 18: Unnesting Arrays in Nested Parquet Data' as example;

-- Unnest film arrays from nested Parquet structure
SELECT 
    name,
    appearance.hair_color as hair_color,
    personal_info.gender as gender,
    UNNEST(films) as film_url,
    len(films) as total_films
FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
WHERE len(films) > 0
ORDER BY total_films DESC, name
LIMIT 15;

-- Example 19: Complex Nested Film Data with Maps and Structs
SELECT 'Example 19: Complex Nested Film Data with Maps and Structs' as example;

-- Read complex nested film data with maps and struct aggregations
SELECT 
    title,
    episode_id,
    director,
    len(characters) as character_count,
    len(planets) as planet_count,
    film_stats.total_entities,
    entity_counts['characters'] as char_count_from_map,
    entity_counts['planets'] as planet_count_from_map,
    film_stats.character_count + film_stats.planet_count as combined_count
FROM read_parquet('data/star-wars/parquet/films_nested.parquet')
ORDER BY episode_id;

-- Example 20: Filtering on Nested Struct Fields
SELECT 'Example 20: Filtering on Nested Struct Fields' as example;

-- Filter characters based on nested struct properties
SELECT 
    name,
    height,
    appearance.hair_color,
    appearance.eye_color,
    personal_info.gender,
    len(films) as film_appearances
FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
WHERE appearance.hair_color != 'n/a' 
  AND appearance.hair_color IS NOT NULL
  AND personal_info.gender = 'female'
ORDER BY film_appearances DESC;

-- Example 21: Aggregating Nested Array Data
SELECT 'Example 21: Aggregating Nested Array Data' as example;

-- Aggregate statistics on nested array lengths
SELECT 
    personal_info.gender,
    COUNT(*) as character_count,
    AVG(len(films)) as avg_film_appearances,
    AVG(len(vehicles)) as avg_vehicle_count,
    AVG(len(starships)) as avg_starship_count,
    MAX(len(films)) as max_film_appearances,
    SUM(len(films)) as total_film_appearances
FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
WHERE personal_info.gender IS NOT NULL AND personal_info.gender != 'n/a'
GROUP BY personal_info.gender
ORDER BY avg_film_appearances DESC;

-- Example 22: Complex Nested Data Analysis with Multiple Levels
SELECT 'Example 22: Complex Nested Data Analysis with Multiple Levels' as example;

-- Analyze character appearance patterns with nested data
WITH character_analysis AS (
    SELECT 
        name,
        CASE 
            WHEN height = 'unknown' THEN NULL 
            ELSE CAST(height AS INTEGER) 
        END as height_numeric,
        appearance.hair_color,
        appearance.skin_color,
        appearance.eye_color,
        personal_info.gender,
        len(films) as film_count,
        len(vehicles) as vehicle_count,
        len(starships) as starship_count
    FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
)
SELECT 
    hair_color,
    eye_color,
    gender,
    COUNT(*) as character_count,
    AVG(height_numeric) as avg_height,
    AVG(film_count) as avg_films,
    SUM(vehicle_count + starship_count) as total_vehicles_starships
FROM character_analysis
WHERE hair_color != 'n/a' 
  AND eye_color != 'n/a'
  AND gender != 'n/a'
GROUP BY hair_color, eye_color, gender
HAVING COUNT(*) >= 1
ORDER BY character_count DESC, avg_films DESC
LIMIT 10;

-- Example 23: Working with Map Data Types in Parquet
SELECT 'Example 23: Working with Map Data Types in Parquet' as example;

-- Extract and analyze map data from nested Parquet
SELECT 
    title,
    episode_id,
    film_stats.total_entities,
    entity_counts,
    MAP_KEYS(entity_counts) as entity_types,
    MAP_VALUES(entity_counts) as entity_counts_values,
    entity_counts['characters'] + entity_counts['planets'] as main_entities,
    CASE 
        WHEN film_stats.total_entities > 50 THEN 'Complex'
        WHEN film_stats.total_entities > 30 THEN 'Moderate'
        ELSE 'Simple'
    END as complexity_level
FROM read_parquet('data/star-wars/parquet/films_nested.parquet')
ORDER BY film_stats.total_entities DESC;

-- Example 24: Creating Complex Nested Structures from Flat Data
SELECT 'Example 24: Creating Complex Nested Structures from Flat Data' as example;

-- Create nested structures from the Titanic flat data
WITH nested_titanic AS (
    SELECT 
        PassengerId,
        Name,
        STRUCT_PACK(
            age := Age,
            sex := Sex,
            survived := CAST(Survived AS BOOLEAN)
        ) as passenger_info,
        STRUCT_PACK(
            class := Pclass,
            fare := Fare,
            cabin := Cabin,
            embarked := Embarked
        ) as travel_info,
        STRUCT_PACK(
            siblings_spouses := SibSp,
            parents_children := Parch,
            family_size := SibSp + Parch + 1
        ) as family_info
    FROM read_parquet('data/titanic/titanic.parquet')
    WHERE Age IS NOT NULL
    LIMIT 10
)
SELECT 
    Name,
    passenger_info.age,
    passenger_info.sex,
    passenger_info.survived,
    travel_info.class,
    travel_info.fare,
    family_info.family_size,
    CASE 
        WHEN family_info.family_size = 1 THEN 'Alone'
        WHEN family_info.family_size <= 3 THEN 'Small Family'
        ELSE 'Large Family'
    END as family_category
FROM nested_titanic
ORDER BY travel_info.fare DESC;

-- Example 25: Advanced Nested Data Querying with Arrays of Structs
SELECT 'Example 25: Advanced Nested Data Querying with Arrays of Structs' as example;

-- Create and query arrays of structs (simulated complex nested data)
WITH complex_nested AS (
    SELECT 
        title,
        episode_id,
        characters,
        planets,
        -- Create array of structs for entity analysis
        [
            STRUCT_PACK(type := 'characters', count := len(characters), urls := characters),
            STRUCT_PACK(type := 'planets', count := len(planets), urls := planets),
            STRUCT_PACK(type := 'starships', count := len(starships), urls := starships)
        ] as entity_arrays
    FROM read_parquet('data/star-wars/parquet/films_nested.parquet')
)
SELECT 
    title,
    episode_id,
    entity.type as entity_type,
    entity.count as entity_count,
    len(entity.urls) as url_count
FROM complex_nested,
     UNNEST(entity_arrays) as t(entity)
WHERE entity.count > 0
ORDER BY title, entity.count DESC;

-- =====================================================
-- NESTED PARQUET PERFORMANCE OPTIMIZATION
-- =====================================================

-- Example 26: Efficient Nested Data Access Patterns
SELECT 'Example 26: Efficient Nested Data Access Patterns' as example;

-- Demonstrate efficient access to nested fields
SELECT 
    'Efficient Nested Access' as query_type,
    COUNT(*) as total_characters,
    COUNT(CASE WHEN appearance.hair_color != 'n/a' THEN 1 END) as characters_with_hair_info,
    COUNT(CASE WHEN len(films) > 3 THEN 1 END) as frequent_characters,
    AVG(len(films)) as avg_film_appearances
FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')

UNION ALL

SELECT 
    'Film Complexity Analysis' as query_type,
    COUNT(*) as total_films,
    COUNT(CASE WHEN film_stats.total_entities > 40 THEN 1 END) as complex_films,
    COUNT(CASE WHEN entity_counts['characters'] > 20 THEN 1 END) as character_heavy_films,
    AVG(film_stats.total_entities) as avg_entities_per_film
FROM read_parquet('data/star-wars/parquet/films_nested.parquet');

-- =====================================================
-- NESTED PARQUET BEST PRACTICES SUMMARY
-- =====================================================

SELECT 'Parquet Processing Best Practices:' as summary;
SELECT '1. Use read_parquet() for optimal columnar data access' as practice
UNION ALL SELECT '2. Leverage column projection to read only needed columns'
UNION ALL SELECT '3. Apply filters early to benefit from predicate pushdown'
UNION ALL SELECT '4. Use appropriate data types for better compression'
UNION ALL SELECT '5. Partition large datasets for better query performance'
UNION ALL SELECT '6. Take advantage of built-in compression algorithms'
UNION ALL SELECT '7. Use statistical functions for efficient data analysis'
UNION ALL SELECT '8. Combine with window functions for advanced analytics'
UNION ALL SELECT '9. Create temporary tables for complex multi-step analysis'
UNION ALL SELECT '10. Monitor query performance and optimize accordingly'
UNION ALL SELECT '11. Use QUANTILE functions for percentile analysis'
UNION ALL SELECT '12. Apply REGEXP functions for string pattern extraction'
UNION ALL SELECT '13. Leverage GROUP BY with HAVING for filtered aggregations'
UNION ALL SELECT '14. Use CASE statements for categorical data analysis'
UNION ALL SELECT '15. Combine multiple analytical techniques for insights'
UNION ALL SELECT '16. Use STRUCT_PACK() to create nested object structures'
UNION ALL SELECT '17. Leverage MAP data types for key-value associations'
UNION ALL SELECT '18. Use UNNEST() to flatten arrays in nested structures'
UNION ALL SELECT '19. Access nested fields with dot notation (struct.field)'
UNION ALL SELECT '20. Filter efficiently on nested struct properties'
UNION ALL SELECT '21. Aggregate array lengths for statistical analysis'
UNION ALL SELECT '22. Use MAP_KEYS() and MAP_VALUES() for map analysis'
UNION ALL SELECT '23. Create arrays of structs for complex hierarchical data'
UNION ALL SELECT '24. Optimize nested data access patterns for performance'
UNION ALL SELECT '25. Preserve schema evolution capabilities with nested structures';