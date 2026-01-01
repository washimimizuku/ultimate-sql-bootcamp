-- JSON Data Processing - Semi-Structured Data
-- This file demonstrates working with JSON data in DuckDB
-- JSON is a flexible format for storing nested and semi-structured data
-- ============================================
-- REQUIRED: This file uses various data sources
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-8-semi-structured-data/json-data.sql
-- ============================================

-- JSON CONCEPTS:
-- - JSON (JavaScript Object Notation) is a lightweight data interchange format
-- - Supports nested objects, arrays, strings, numbers, booleans, and null values
-- - DuckDB provides native JSON support with functions for parsing and querying
-- - JSON data can be stored in VARCHAR columns or loaded from JSON files

-- JSON FUNCTIONS IN DUCKDB:
-- - json_extract(json, path): Extract values from JSON using JSONPath
-- - json_extract_path(json, path...): Extract using path components
-- - json_array_length(json): Get length of JSON array
-- - json_type(json): Get the type of JSON value
-- - json_valid(json): Check if string is valid JSON
-- - json_merge_patch(json1, json2): Merge JSON objects
-- - json_keys(json): Get keys from JSON object
-- - json_structure(json): Analyze JSON structure

-- LOADING JSON DATA:
-- - FROM 'file.json': Load JSON file directly
-- - read_json('file.json'): Read JSON with options
-- - COPY FROM 'file.json' FORMAT JSON: Import JSON data
-- - INSERT with JSON literals: Create JSON data inline

-- =====================================================
-- BASIC JSON READING EXAMPLES
-- =====================================================

-- Example 1: Simple JSON Reading - Load JSON Arrays
-- DuckDB can read JSON files directly and flatten array structures
SELECT 'Example 1: Basic JSON Reading - Characters' as example;

SELECT * FROM read_json('data/star-wars/json/characters.json') 
LIMIT 3;

-- Show the inferred schema for JSON data
DESCRIBE SELECT * FROM read_json('data/star-wars/json/characters.json');

-- Example 2: Reading Different JSON Files
-- Explore the structure of different Star Wars JSON files
SELECT 'Example 2: Reading Different JSON Files' as example;

-- Characters data
SELECT 'Characters:' as dataset;
SELECT COUNT(*) as total_characters FROM read_json('data/star-wars/json/characters.json');

-- Films data
SELECT 'Films:' as dataset;
SELECT COUNT(*) as total_films FROM read_json('data/star-wars/json/films.json');

-- Planets data
SELECT 'Planets:' as dataset;
SELECT COUNT(*) as total_planets FROM read_json('data/star-wars/json/planets.json');

-- Species data
SELECT 'Species:' as dataset;
SELECT COUNT(*) as total_species FROM read_json('data/star-wars/json/species.json');

-- =====================================================
-- JSON EXTRACTION AND PARSING
-- =====================================================

-- Example 3: Basic JSON Field Extraction
SELECT 'Example 3: JSON Field Extraction' as example;

-- Extract basic fields from characters
SELECT 
    name,
    height,
    mass,
    hair_color,
    eye_color,
    gender,
    birth_year
FROM read_json('data/star-wars/json/characters.json')
WHERE name IN ('Luke Skywalker', 'Darth Vader', 'Leia Organa')
ORDER BY name;

-- Example 4: Working with JSON Arrays
SELECT 'Example 4: JSON Array Processing' as example;

-- Extract and analyze array fields
SELECT 
    name,
    len(films) as film_count,
    len(vehicles) as vehicle_count,
    len(starships) as starship_count,
    films[1] as first_film_url,
    CASE WHEN len(species) > 0 THEN species[1] ELSE NULL END as species_url
FROM read_json('data/star-wars/json/characters.json')
WHERE name IN ('Luke Skywalker', 'C-3PO', 'R2-D2', 'Darth Vader', 'Chewbacca')
ORDER BY film_count DESC;

-- =====================================================
-- ADVANCED JSON PROCESSING
-- =====================================================

-- Example 5: JSON Array Unnesting
SELECT 'Example 5: JSON Array Unnesting' as example;

-- Unnest film arrays to create character-film relationships
SELECT 
    name as character_name,
    UNNEST(films) as film_url,
    len(films) as total_films
FROM read_json('data/star-wars/json/characters.json')
WHERE len(films) > 0
ORDER BY total_films DESC, character_name
LIMIT 15;

-- Example 6: Complex JSON Structure Analysis
SELECT 'Example 6: Complex JSON Structure Analysis' as example;

-- Analyze film data with complex nested information
SELECT 
    title,
    episode_id,
    director,
    release_date,
    len(characters) as character_count,
    len(planets) as planet_count,
    len(starships) as starship_count,
    len(vehicles) as vehicle_count,
    len(species) as species_count
FROM read_json('data/star-wars/json/films.json')
ORDER BY episode_id;

-- =====================================================
-- JSON DATA TYPE CONVERSION
-- =====================================================

-- Example 7: JSON Data Type Conversion and Cleaning
SELECT 'Example 7: Data Type Conversion' as example;

-- Convert JSON strings to appropriate data types for planets
SELECT 
    name,
    CASE 
        WHEN diameter = 'unknown' OR diameter = '0' THEN NULL 
        ELSE CAST(REPLACE(diameter, ',', '') AS INTEGER) 
    END as diameter_km,
    CASE 
        WHEN population = 'unknown' THEN NULL 
        ELSE CAST(population AS BIGINT) 
    END as population_count,
    climate,
    terrain
FROM read_json('data/star-wars/json/planets.json')
WHERE diameter != 'unknown' AND diameter != '0'
ORDER BY diameter_km DESC NULLS LAST
LIMIT 10;

-- Example 8: Working with Nested JSON Objects
SELECT 'Example 8: Nested JSON Processing' as example;

-- Process starship data with various data types
SELECT 
    name,
    model,
    manufacturer,
    CASE 
        WHEN cost_in_credits = 'unknown' THEN NULL 
        ELSE CAST(cost_in_credits AS BIGINT) 
    END as cost,
    CASE 
        WHEN length = 'unknown' THEN NULL 
        ELSE CAST(REPLACE(REPLACE(length, ',', ''), ' ', '') AS DECIMAL(10,2)) 
    END as length_meters,
    crew,
    passengers,
    starship_class,
    len(films) as film_appearances
FROM read_json('data/star-wars/json/starships.json')
WHERE cost_in_credits != 'unknown'
ORDER BY cost DESC NULLS LAST
LIMIT 10;

-- =====================================================
-- JSON AGGREGATION AND ANALYSIS
-- =====================================================

-- Example 9: JSON Data Aggregation
SELECT 'Example 9: JSON Data Aggregation' as example;

-- Character statistics by species
SELECT 
    CASE 
        WHEN len(species) = 0 THEN 'Human' 
        ELSE 'Non-Human' 
    END as species_type,
    COUNT(*) as character_count,
    AVG(CASE WHEN height != 'unknown' THEN CAST(height AS INTEGER) END) as avg_height,
    AVG(CASE WHEN mass != 'unknown' AND mass != '1,358' THEN CAST(REPLACE(mass, ',', '') AS INTEGER) END) as avg_mass,
    AVG(len(films)) as avg_film_appearances
FROM read_json('data/star-wars/json/characters.json')
GROUP BY species_type
ORDER BY character_count DESC;

-- Example 10: Cross-File JSON Analysis
SELECT 'Example 10: Cross-File JSON Analysis' as example;

-- Analyze film complexity by counting related entities
WITH film_stats AS (
    SELECT 
        title,
        episode_id,
        director,
        CAST(SUBSTR(CAST(release_date AS VARCHAR), 1, 4) AS INTEGER) as release_year,
        len(characters) as character_count,
        len(planets) as planet_count,
        len(starships) as starship_count,
        len(vehicles) as vehicle_count
    FROM read_json('data/star-wars/json/films.json')
)
SELECT 
    title,
    episode_id,
    release_year,
    character_count + planet_count + starship_count + vehicle_count as total_entities,
    character_count,
    planet_count,
    starship_count,
    vehicle_count,
    CASE 
        WHEN character_count + planet_count + starship_count + vehicle_count > 50 THEN 'Complex'
        WHEN character_count + planet_count + starship_count + vehicle_count > 30 THEN 'Moderate'
        ELSE 'Simple'
    END as complexity_level
FROM film_stats
ORDER BY total_entities DESC;

-- =====================================================
-- JSON STRING FUNCTIONS AND MANIPULATION
-- =====================================================

-- Example 11: JSON String Processing
SELECT 'Example 11: JSON String Processing' as example;

-- Process species data with string manipulation
SELECT 
    name,
    classification,
    designation,
    CASE 
        WHEN average_height = 'unknown' OR average_height = 'n/a' THEN NULL 
        ELSE CAST(average_height AS INTEGER) 
    END as avg_height_cm,
    STRING_SPLIT(skin_colors, ', ') as skin_color_list,
    STRING_SPLIT(hair_colors, ', ') as hair_color_list,
    STRING_SPLIT(eye_colors, ', ') as eye_color_list,
    CASE 
        WHEN average_lifespan = 'indefinite' THEN NULL
        WHEN average_lifespan = 'unknown' THEN NULL
        ELSE CAST(average_lifespan AS INTEGER) 
    END as lifespan_years,
    len(people) as known_individuals
FROM read_json('data/star-wars/json/species.json')
WHERE average_height != 'n/a' AND average_height != 'unknown'
ORDER BY avg_height_cm DESC NULLS LAST;

-- =====================================================
-- CREATING TABLES FROM JSON DATA
-- =====================================================

-- Example 12: Creating Structured Tables from JSON
SELECT 'Example 12: Creating Tables from JSON Data' as example;

-- Create a normalized character table
CREATE TEMPORARY TABLE json_characters AS
SELECT 
    name,
    CASE WHEN height = 'unknown' THEN NULL ELSE CAST(height AS INTEGER) END as height,
    CASE 
        WHEN mass = 'unknown' THEN NULL 
        WHEN mass = '1,358' THEN 1358
        ELSE CAST(REPLACE(mass, ',', '') AS INTEGER) 
    END as mass,
    hair_color,
    skin_color,
    eye_color,
    birth_year,
    gender,
    homeworld,
    len(films) as film_count,
    len(vehicles) as vehicle_count,
    len(starships) as starship_count,
    CASE WHEN len(species) = 0 THEN 'Human' ELSE 'Non-Human' END as species_category
FROM read_json('data/star-wars/json/characters.json');

-- Verify the created table
SELECT 'Created table verification:' as info;
SELECT COUNT(*) as total_characters FROM json_characters;
SELECT * FROM json_characters WHERE height IS NOT NULL ORDER BY height DESC LIMIT 5;

-- =====================================================
-- JSON ARRAY OPERATIONS
-- =====================================================

-- Example 13: Advanced JSON Array Operations
SELECT 'Example 13: Advanced JSON Array Operations' as example;

-- Create character-vehicle relationships using a simpler approach
WITH character_vehicles AS (
    SELECT 
        name as character_name,
        UNNEST(vehicles) as vehicle_url
    FROM read_json('data/star-wars/json/characters.json')
    WHERE len(vehicles) > 0
),
vehicle_lookup AS (
    SELECT 
        name as vehicle_name,
        model,
        vehicle_class,
        'https://swapi.info/api/vehicles/' || CAST(ROW_NUMBER() OVER (ORDER BY name) AS VARCHAR) as vehicle_url
    FROM read_json('data/star-wars/json/vehicles.json')
)
SELECT 
    cv.character_name,
    vl.vehicle_name,
    vl.model,
    vl.vehicle_class
FROM character_vehicles cv
JOIN vehicle_lookup vl ON cv.vehicle_url = vl.vehicle_url
ORDER BY cv.character_name, vl.vehicle_name
LIMIT 15;

-- =====================================================
-- JSON PERFORMANCE AND OPTIMIZATION
-- =====================================================

-- Example 14: JSON Query Optimization
SELECT 'Example 14: JSON Query Optimization' as example;

-- Efficient filtering and projection
SELECT 
    name,
    height,
    mass,
    len(films) as film_count
FROM read_json('data/star-wars/json/characters.json')
WHERE height != 'unknown' 
  AND CAST(height AS INTEGER) > 180 
  AND len(films) >= 3
ORDER BY CAST(height AS INTEGER) DESC;

-- Batch processing multiple JSON files
SELECT 'Batch JSON Processing:' as info;
SELECT 
    'Characters' as data_type,
    COUNT(*) as record_count,
    AVG(len(films)) as avg_array_size
FROM read_json('data/star-wars/json/characters.json')
UNION ALL
SELECT 
    'Planets' as data_type,
    COUNT(*) as record_count,
    AVG(len(residents)) as avg_array_size
FROM read_json('data/star-wars/json/planets.json')
UNION ALL
SELECT 
    'Species' as data_type,
    COUNT(*) as record_count,
    AVG(len(people)) as avg_array_size
FROM read_json('data/star-wars/json/species.json');

-- =====================================================
-- CLEANUP AND BEST PRACTICES
-- =====================================================

-- Clean up temporary table
DROP TABLE json_characters;

-- =====================================================
-- COMPLEX JSON HIERARCHY TRAVERSAL
-- =====================================================

-- Example 15: Deep JSON Path Navigation
SELECT 'Example 15: Deep JSON Path Navigation' as example;

-- Navigate through multiple levels of nested JSON
SELECT 
    galaxy.name as galaxy_name,
    sector.name as sector_name,
    system.name as system_name,
    planet.name as planet_name,
    settlement.name as settlement_name
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement);

-- Example 16: Extracting Deeply Nested Objects
SELECT 'Example 16: Extracting Deeply Nested Objects' as example;

-- Extract establishment details from deep hierarchy
SELECT 
    sector.name as sector_name,
    settlement.name as settlement_name,
    district.name as district_name,
    establishment.name as establishment_name,
    establishment.type as establishment_type,
    establishment.owner as owner
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement),
     UNNEST(settlement.districts) as d(district),
     UNNEST(district.establishments) as e(establishment)
WHERE establishment.owner IS NOT NULL;

-- Example 17: Complex Array Processing in Nested JSON
SELECT 'Example 17: Complex Array Processing in Nested JSON' as example;

-- Extract patron information from cantina
SELECT 
    establishment.name as cantina_name,
    patron.name as patron_name,
    patron.species,
    patron.occupation
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement),
     UNNEST(settlement.districts) as d(district),
     UNNEST(district.establishments) as e(establishment),
     UNNEST(establishment.patrons) as pat(patron)
WHERE establishment.type = 'cantina';

-- Example 18: Multi-Level Aggregation on Nested Data
SELECT 'Example 18: Multi-Level Aggregation on Nested Data' as example;

-- Aggregate data across multiple hierarchy levels
SELECT 
    sector.name as sector_name,
    COUNT(DISTINCT system.name) as system_count,
    COUNT(DISTINCT planet.name) as planet_count,
    COUNT(DISTINCT settlement.name) as settlement_count,
    SUM(settlement.population) as total_population
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement)
GROUP BY sector.name
ORDER BY total_population DESC;

-- Example 19: Conditional Navigation Through JSON Hierarchy
SELECT 'Example 19: Conditional Navigation Through JSON Hierarchy' as example;

-- Navigate conditionally based on data presence
SELECT 
    system.name as system_name,
    planet.name as planet_name,
    settlement.name as settlement_name,
    CASE 
        WHEN settlement.type = 'spaceport' THEN 'Major Hub'
        WHEN settlement.population > 10000 THEN 'Large Settlement'
        WHEN settlement.population > 1000 THEN 'Small Settlement'
        ELSE 'Outpost'
    END as settlement_category,
    len(settlement.districts) as district_count
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement)
ORDER BY settlement.population DESC NULLS LAST;

-- Example 20: Extracting Complex Nested Objects with Arrays
SELECT 'Example 20: Extracting Complex Nested Objects with Arrays' as example;

-- Extract Yoda's detailed information from deeply nested structure
SELECT 
    planet.name as planet_name,
    structure.name as structure_name,
    structure.occupant.name as occupant_name,
    structure.occupant.species,
    structure.occupant.age,
    ability.name as ability_name,
    ability.level as ability_level,
    possession.item as possession_item,
    possession.color as item_color
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement),
     UNNEST(settlement.districts) as d(district),
     UNNEST(district.structures) as str(structure),
     UNNEST(structure.occupant.abilities) as ab(ability),
     UNNEST(structure.occupant.possessions) as pos(possession)
WHERE structure.occupant.name IS NOT NULL;

-- Example 21: Battle Analysis from Timeline Data
SELECT 'Example 21: Battle Analysis from Timeline Data' as example;

-- Extract battle information from timeline hierarchy
SELECT 
    event.name as event_name,
    battle.name as battle_name,
    battle.year,
    republic_force.unit as republic_unit,
    republic_force.size as republic_size,
    separatist_force.unit as separatist_unit,
    separatist_force.size as separatist_size,
    battle.outcome.victor as victor,
    battle.outcome.casualties.republic as republic_casualties,
    battle.outcome.casualties.separatists as separatist_casualties
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(timeline.major_events) as ev(event),
     UNNEST(event.battles) as b(battle),
     UNNEST(battle.participants.republic.forces) as rf(republic_force),
     UNNEST(battle.participants.separatists.forces) as sf(separatist_force);

-- Example 22: Senate Voting Analysis
SELECT 'Example 22: Senate Voting Analysis' as example;

-- Analyze senator voting patterns from nested political data
SELECT 
    chamber.name as chamber_name,
    senator.name as senator_name,
    senator.planet as home_planet,
    committee as committee_membership,
    vote.bill as bill_name,
    vote.vote as vote_position
FROM read_json('data/star-wars/complex-hierarchy.json'),
     UNNEST(galaxy.sectors) as t(sector),
     UNNEST(sector.systems) as s(system),
     UNNEST(system.planets) as p(planet),
     UNNEST(planet.settlements) as st(settlement),
     UNNEST(settlement.districts) as d(district),
     UNNEST(district.establishments) as e(establishment),
     UNNEST(establishment.chambers) as ch(chamber),
     UNNEST(chamber.senators) as sen(senator),
     UNNEST(senator.committees) as com(committee),
     UNNEST(senator.voting_record) as v(vote)
WHERE establishment.type = 'government';

-- =====================================================
-- JSON BEST PRACTICES SUMMARY
-- =====================================================

SELECT 'JSON Processing Best Practices:' as summary;
SELECT '1. Use read_json() for direct file reading with automatic schema detection' as practice
UNION ALL SELECT '2. Handle nested arrays with UNNEST() for relational analysis'
UNION ALL SELECT '3. Use len() function to get array lengths for analysis'
UNION ALL SELECT '4. Apply proper data type casting for numeric fields'
UNION ALL SELECT '5. Handle "unknown" and "n/a" values consistently'
UNION ALL SELECT '6. Use STRING_SPLIT() for comma-separated values within JSON strings'
UNION ALL SELECT '7. Create temporary tables for complex multi-step JSON processing'
UNION ALL SELECT '8. Use list_contains() for array membership testing'
UNION ALL SELECT '9. Consider performance when processing large JSON arrays'
UNION ALL SELECT '10. Validate JSON structure before complex operations'
UNION ALL SELECT '11. Use appropriate indexing strategies for JSON queries'
UNION ALL SELECT '12. Document your JSON schema assumptions and transformations'
UNION ALL SELECT '13. Use multiple UNNEST() calls to traverse deep hierarchies'
UNION ALL SELECT '14. Apply conditional logic when navigating optional nested structures'
UNION ALL SELECT '15. Aggregate data across multiple hierarchy levels for insights'
UNION ALL SELECT '16. Extract specific nested objects using precise path navigation';
