-- Data Loading Examples
-- This file demonstrates how to load and work with various data formats

-- Example 1: Loading CSV files directly
-- Query Star Wars characters from CSV
SELECT name, height, mass, species
FROM 'data/star-wars/csv/characters.csv'
WHERE species = 'Human'
ORDER BY name;

-- Example 2: Creating tables from CSV files
-- Create a temporary table from CSV data
CREATE TEMP TABLE temp_characters AS 
SELECT * FROM 'data/star-wars/csv/characters.csv';

-- Query the temporary table
SELECT species, COUNT(*) as character_count
FROM temp_characters
GROUP BY species
ORDER BY character_count DESC;

-- Example 3: Working with JSON files
-- Query JSON data directly
SELECT name, 
       height::INTEGER as height_cm,
       mass::INTEGER as mass_kg
FROM 'data/star-wars/json/characters.json'
WHERE height != 'unknown' AND mass != 'unknown'
ORDER BY height_cm DESC
LIMIT 10;

-- Example 4: Working with enriched JSON (nested data)
-- Extract nested homeworld information
SELECT name,
       homeworld.name as planet_name,
       len(films) as film_appearances
FROM 'data/star-wars/enriched/characters_enriched.json'
WHERE homeworld.name IS NOT NULL
ORDER BY film_appearances DESC;

-- Example 5: Parquet file analysis
-- Titanic survival analysis
SELECT Sex,
       Pclass,
       COUNT(*) as passengers,
       SUM(Survived) as survivors,
       ROUND(AVG(Survived) * 100, 1) as survival_rate_pct
FROM 'data/titanic/titanic.parquet'
GROUP BY Sex, Pclass
ORDER BY Sex, Pclass;

-- Example 6: Combining different data sources
-- Create a unified view of character data from CSV and database
SELECT 'CSV' as source, name, height, species
FROM 'data/star-wars/csv/characters.csv'
WHERE height != 'unknown'
UNION ALL
SELECT 'Database' as source, c.name, c.height, s.name as species
FROM characters c
LEFT JOIN species s ON c.species_id = s.id
WHERE c.height IS NOT NULL AND c.height != 'unknown'
ORDER BY source, name;

-- Example 7: Data type conversion and cleaning
-- Clean and convert Star Wars character data
SELECT name,
       CASE 
         WHEN height = 'unknown' THEN NULL
         ELSE CAST(height AS INTEGER)
       END as height_cm,
       CASE 
         WHEN mass = 'unknown' THEN NULL
         ELSE CAST(mass AS INTEGER)
       END as mass_kg,
       CASE 
         WHEN birth_year LIKE '%BBY' THEN -CAST(REPLACE(birth_year, 'BBY', '') AS FLOAT)
         WHEN birth_year LIKE '%ABY' THEN CAST(REPLACE(birth_year, 'ABY', '') AS FLOAT)
         ELSE NULL
       END as birth_year_numeric
FROM 'data/star-wars/csv/characters.csv'
WHERE name IS NOT NULL
ORDER BY birth_year_numeric;