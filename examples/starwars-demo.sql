-- Star Wars Database Demo Queries  
-- This file demonstrates engaging queries using the Star Wars database
-- Setup: Database should already be available at data/starwars.db

-- Example 1: Character Analysis - Tallest characters
SELECT name, height, species.name as species_name, planets.name as homeworld
FROM characters
LEFT JOIN species ON characters.species_id = species.id
LEFT JOIN planets ON characters.homeworld_id = planets.id
WHERE height IS NOT NULL AND height != 'unknown'
ORDER BY CAST(height AS INTEGER) DESC
LIMIT 10;

-- Example 2: Film Analysis - Characters per film
SELECT f.title, f.episode_id, COUNT(fc.character_id) as character_count
FROM films f
LEFT JOIN film_characters fc ON f.id = fc.film_id
GROUP BY f.id, f.title, f.episode_id
ORDER BY f.episode_id;

-- Example 3: Planet Analysis - Most populated planets
SELECT name, population, climate, terrain
FROM planets
WHERE population IS NOT NULL 
  AND population != 'unknown'
  AND population != '0'
ORDER BY CAST(population AS BIGINT) DESC
LIMIT 10;

-- Example 4: Starship Analysis - Fastest ships
SELECT name, model, max_atmosphering_speed, starship_class
FROM starships
WHERE max_atmosphering_speed IS NOT NULL 
  AND max_atmosphering_speed != 'unknown'
  AND max_atmosphering_speed != 'n/a'
ORDER BY CAST(max_atmosphering_speed AS INTEGER) DESC
LIMIT 10;

-- Example 5: Species Diversity - Species by film
SELECT f.title, COUNT(DISTINCT fs.species_id) as species_count
FROM films f
LEFT JOIN film_species fs ON f.id = fs.film_id
GROUP BY f.id, f.title
ORDER BY species_count DESC;

-- Example 6: Pilot Analysis - Characters and their vehicles
SELECT c.name as pilot_name,
       s.name as starship_name,
       s.starship_class
FROM characters c
JOIN starship_pilots sp ON c.id = sp.character_id
JOIN starships s ON sp.starship_id = s.id
ORDER BY c.name;