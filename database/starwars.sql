-- SWAPI Database Creation Script
-- Generated from Star Wars API data
-- This script creates tables and populates them with SWAPI data

-- FILMS TABLE
CREATE TABLE films (
    id INTEGER PRIMARY KEY,
    created VARCHAR(500),
    director VARCHAR(500),
    edited VARCHAR(500),
    episode_id INTEGER,
    opening_crawl VARCHAR(500),
    producer VARCHAR(500),
    release_date VARCHAR(500),
    title VARCHAR(500),
    url VARCHAR(500)
);

-- PLANETS TABLE
CREATE TABLE planets (
    id INTEGER PRIMARY KEY,
    climate VARCHAR(500),
    created VARCHAR(500),
    diameter DECIMAL,
    edited VARCHAR(500),
    gravity VARCHAR(500),
    name VARCHAR(500),
    orbital_period DECIMAL,
    population BIGINT,
    rotation_period DECIMAL,
    surface_water DECIMAL,
    terrain VARCHAR(500),
    url VARCHAR(500)
);

-- SPECIES TABLE
CREATE TABLE species (
    id INTEGER PRIMARY KEY,
    average_height VARCHAR(500),
    average_lifespan VARCHAR(500),
    classification VARCHAR(500),
    created VARCHAR(500),
    designation VARCHAR(500),
    edited VARCHAR(500),
    eye_colors VARCHAR(500),
    hair_colors VARCHAR(500),
    homeworld_id INTEGER,
    language VARCHAR(500),
    name VARCHAR(500),
    skin_colors VARCHAR(500),
    url VARCHAR(500),
    FOREIGN KEY (homeworld_id) REFERENCES planets(id)
);

-- CHARACTERS TABLE
CREATE TABLE characters (
    id INTEGER PRIMARY KEY,
    species_id INTEGER,
    birth_year VARCHAR(500),
    created VARCHAR(500),
    edited VARCHAR(500),
    eye_color VARCHAR(500),
    gender VARCHAR(500),
    hair_color VARCHAR(500),
    height VARCHAR(500),
    homeworld_id INTEGER,
    mass VARCHAR(500),
    name VARCHAR(500),
    skin_color VARCHAR(500),
    url VARCHAR(500),
    FOREIGN KEY (homeworld_id) REFERENCES planets(id),
    FOREIGN KEY (species_id) REFERENCES species(id)
);

-- VEHICLES TABLE
CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY,
    cargo_capacity BIGINT,
    consumables VARCHAR(500),
    cost_in_credits BIGINT,
    created VARCHAR(500),
    crew INTEGER,
    edited VARCHAR(500),
    length DECIMAL,
    manufacturer VARCHAR(500),
    max_atmosphering_speed INTEGER,
    model VARCHAR(500),
    name VARCHAR(500),
    passengers INTEGER,
    url VARCHAR(500),
    vehicle_class VARCHAR(500)
);

-- STARSHIPS TABLE
CREATE TABLE starships (
    id INTEGER PRIMARY KEY,
    MGLT INTEGER,
    cargo_capacity BIGINT,
    consumables VARCHAR(500),
    cost_in_credits BIGINT,
    created VARCHAR(500),
    crew INTEGER,
    edited VARCHAR(500),
    hyperdrive_rating DECIMAL,
    length DECIMAL,
    manufacturer VARCHAR(500),
    max_atmosphering_speed INTEGER,
    model VARCHAR(500),
    name VARCHAR(500),
    passengers INTEGER,
    starship_class VARCHAR(500),
    url VARCHAR(500)
);

-- JUNCTION TABLES FOR RELATIONSHIPS

-- Film relationships
CREATE TABLE film_characters (
    film_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (film_id, character_id)
);

CREATE TABLE film_planets (
    film_id INTEGER,
    planet_id INTEGER,
    PRIMARY KEY (film_id, planet_id)
);

CREATE TABLE film_starships (
    film_id INTEGER,
    starship_id INTEGER,
    PRIMARY KEY (film_id, starship_id)
);

CREATE TABLE film_vehicles (
    film_id INTEGER,
    vehicle_id INTEGER,
    PRIMARY KEY (film_id, vehicle_id)
);

CREATE TABLE film_species (
    film_id INTEGER,
    species_id INTEGER,
    PRIMARY KEY (film_id, species_id)
);

-- REMOVED: character_species table - now using characters.species_id foreign key

CREATE TABLE character_vehicles (
    character_id INTEGER,
    vehicle_id INTEGER,
    PRIMARY KEY (character_id, vehicle_id)
);

CREATE TABLE character_starships (
    character_id INTEGER,
    starship_id INTEGER,
    PRIMARY KEY (character_id, starship_id)
);

-- REMOVED: planet_residents table - redundant with characters.homeworld_id foreign key

-- REMOVED: species_people table - redundant with characters.species_id foreign key

-- Vehicle relationships
CREATE TABLE vehicle_pilots (
    vehicle_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (vehicle_id, character_id)
);

-- Starship relationships
CREATE TABLE starship_pilots (
    starship_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (starship_id, character_id)
);

-- DATA INSERTION

-- Insert data into films
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (1, '2014-12-10T14:23:31.880000Z', 'George Lucas', '2014-12-20T19:49:45.256000Z', 4, 'It is a period of civil war.
Rebel spaceships, striking
from a hidden base, have won
their first victory against
the evil Galactic Empire.

During the battle, Rebel
spies managed to steal secret
plans to the Empire''s
ultimate weapon, the DEATH
STAR, an armored space
station with enough power
to destroy an entire planet.

Pursued by the Empire''s
sinister agents, Princess
Leia races home aboard her
starship, custodian of the
stolen plans that can save her
people and restore
freedom to the galaxy....', 'Gary Kurtz, Rick McCallum', '1977-05-25', 'A New Hope', 'https://swapi.info/api/films/1');
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (2, '2014-12-12T11:26:24.656000Z', 'Irvin Kershner', '2014-12-15T13:07:53.386000Z', 5, 'It is a dark time for the
Rebellion. Although the Death
Star has been destroyed,
Imperial troops have driven the
Rebel forces from their hidden
base and pursued them across
the galaxy.

Evading the dreaded Imperial
Starfleet, a group of freedom
fighters led by Luke Skywalker
has established a new secret
base on the remote ice world
of Hoth.

The evil lord Darth Vader,
obsessed with finding young
Skywalker, has dispatched
thousands of remote probes into
the far reaches of space....', 'Gary Kurtz, Rick McCallum', '1980-05-17', 'The Empire Strikes Back', 'https://swapi.info/api/films/2');
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (3, '2014-12-18T10:39:33.255000Z', 'Richard Marquand', '2014-12-20T09:48:37.462000Z', 6, 'Luke Skywalker has returned to
his home planet of Tatooine in
an attempt to rescue his
friend Han Solo from the
clutches of the vile gangster
Jabba the Hutt.

Little does Luke know that the
GALACTIC EMPIRE has secretly
begun construction on a new
armored space station even
more powerful than the first
dreaded Death Star.

When completed, this ultimate
weapon will spell certain doom
for the small band of rebels
struggling to restore freedom
to the galaxy...', 'Howard G. Kazanjian, George Lucas, Rick McCallum', '1983-05-25', 'Return of the Jedi', 'https://swapi.info/api/films/3');
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (4, '2014-12-19T16:52:55.740000Z', 'George Lucas', '2014-12-20T10:54:07.216000Z', 1, 'Turmoil has engulfed the
Galactic Republic. The taxation
of trade routes to outlying star
systems is in dispute.

Hoping to resolve the matter
with a blockade of deadly
battleships, the greedy Trade
Federation has stopped all
shipping to the small planet
of Naboo.

While the Congress of the
Republic endlessly debates
this alarming chain of events,
the Supreme Chancellor has
secretly dispatched two Jedi
Knights, the guardians of
peace and justice in the
galaxy, to settle the conflict....', 'Rick McCallum', '1999-05-19', 'The Phantom Menace', 'https://swapi.info/api/films/4');
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (5, '2014-12-20T10:57:57.886000Z', 'George Lucas', '2014-12-20T20:18:48.516000Z', 2, 'There is unrest in the Galactic
Senate. Several thousand solar
systems have declared their
intentions to leave the Republic.

This separatist movement,
under the leadership of the
mysterious Count Dooku, has
made it difficult for the limited
number of Jedi Knights to maintain 
peace and order in the galaxy.

Senator Amidala, the former
Queen of Naboo, is returning
to the Galactic Senate to vote
on the critical issue of creating
an ARMY OF THE REPUBLIC
to assist the overwhelmed
Jedi....', 'Rick McCallum', '2002-05-16', 'Attack of the Clones', 'https://swapi.info/api/films/5');
INSERT INTO films (id, created, director, edited, episode_id, opening_crawl, producer, release_date, title, url) VALUES (6, '2014-12-20T18:49:38.403000Z', 'George Lucas', '2014-12-20T20:47:52.073000Z', 3, 'War! The Republic is crumbling
under attacks by the ruthless
Sith Lord, Count Dooku.
There are heroes on both sides.
Evil is everywhere.

In a stunning move, the
fiendish droid leader, General
Grievous, has swept into the
Republic capital and kidnapped
Chancellor Palpatine, leader of
the Galactic Senate.

As the Separatist Droid Army
attempts to flee the besieged
capital with their valuable
hostage, two Jedi Knights lead a
desperate mission to rescue the
captive Chancellor....', 'Rick McCallum', '2005-05-19', 'Revenge of the Sith', 'https://swapi.info/api/films/6');

-- Insert data into planets
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (1, 'arid', '2014-12-09T13:50:49.641000Z', 10465, '2014-12-20T20:58:18.411000Z', '1 standard', 'Tatooine', 304, 200000, 23, 1, 'desert', 'https://swapi.info/api/planets/1');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (2, 'temperate', '2014-12-10T11:35:48.479000Z', 12500, '2014-12-20T20:58:18.420000Z', '1 standard', 'Alderaan', 364, 2000000000, 24, 40, 'grasslands, mountains', 'https://swapi.info/api/planets/2');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (3, 'temperate, tropical', '2014-12-10T11:37:19.144000Z', 10200, '2014-12-20T20:58:18.421000Z', '1 standard', 'Yavin IV', 4818, 1000, 24, 8, 'jungle, rainforests', 'https://swapi.info/api/planets/3');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (4, 'frozen', '2014-12-10T11:39:13.934000Z', 7200, '2014-12-20T20:58:18.423000Z', '1.1 standard', 'Hoth', 549, NULL, 23, 100, 'tundra, ice caves, mountain ranges', 'https://swapi.info/api/planets/4');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (5, 'murky', '2014-12-10T11:42:22.590000Z', 8900, '2014-12-20T20:58:18.425000Z', 'N/A', 'Dagobah', 341, NULL, 23, 8, 'swamp, jungles', 'https://swapi.info/api/planets/5');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (6, 'temperate', '2014-12-10T11:43:55.240000Z', 118000, '2014-12-20T20:58:18.427000Z', '1.5 (surface), 1 standard (Cloud City)', 'Bespin', 5110, 6000000, 12, 0, 'gas giant', 'https://swapi.info/api/planets/6');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (7, 'temperate', '2014-12-10T11:50:29.349000Z', 4900, '2014-12-20T20:58:18.429000Z', '0.85 standard', 'Endor', 402, 30000000, 18, 8, 'forests, mountains, lakes', 'https://swapi.info/api/planets/7');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (8, 'temperate', '2014-12-10T11:52:31.066000Z', 12120, '2014-12-20T20:58:18.430000Z', '1 standard', 'Naboo', 312, 4500000000, 26, 12, 'grassy hills, swamps, forests, mountains', 'https://swapi.info/api/planets/8');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (9, 'temperate', '2014-12-10T11:54:13.921000Z', 12240, '2014-12-20T20:58:18.432000Z', '1 standard', 'Coruscant', 368, 1000000000000, 24, NULL, 'cityscape, mountains', 'https://swapi.info/api/planets/9');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (10, 'temperate', '2014-12-10T12:45:06.577000Z', 19720, '2014-12-20T20:58:18.434000Z', '1 standard', 'Kamino', 463, 1000000000, 27, 100, 'ocean', 'https://swapi.info/api/planets/10');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (11, 'temperate, arid', '2014-12-10T12:47:22.350000Z', 11370, '2014-12-20T20:58:18.437000Z', '0.9 standard', 'Geonosis', 256, 100000000000, 30, 5, 'rock, desert, mountain, barren', 'https://swapi.info/api/planets/11');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (12, 'temperate, arid, windy', '2014-12-10T12:49:01.491000Z', 12900, '2014-12-20T20:58:18.439000Z', '1 standard', 'Utapau', 351, 95000000, 27, 0.9, 'scrublands, savanna, canyons, sinkholes', 'https://swapi.info/api/planets/12');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (13, 'hot', '2014-12-10T12:50:16.526000Z', 4200, '2014-12-20T20:58:18.440000Z', '1 standard', 'Mustafar', 412, 20000, 36, 0, 'volcanoes, lava rivers, mountains, caves', 'https://swapi.info/api/planets/13');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (14, 'tropical', '2014-12-10T13:32:00.124000Z', 12765, '2014-12-20T20:58:18.442000Z', '1 standard', 'Kashyyyk', 381, 45000000, 26, 60, 'jungle, forests, lakes, rivers', 'https://swapi.info/api/planets/14');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (15, 'artificial temperate ', '2014-12-10T13:33:46.405000Z', 0, '2014-12-20T20:58:18.444000Z', '0.56 standard', 'Polis Massa', 590, 1000000, 24, 0, 'airless asteroid', 'https://swapi.info/api/planets/15');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (16, 'frigid', '2014-12-10T13:43:39.139000Z', 10088, '2014-12-20T20:58:18.446000Z', '1 standard', 'Mygeeto', 167, 19000000, 12, NULL, 'glaciers, mountains, ice canyons', 'https://swapi.info/api/planets/16');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (17, 'hot, humid', '2014-12-10T13:44:50.397000Z', 9100, '2014-12-20T20:58:18.447000Z', '0.75 standard', 'Felucia', 231, 8500000, 34, NULL, 'fungus forests', 'https://swapi.info/api/planets/17');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (18, 'temperate, moist', '2014-12-10T13:46:28.704000Z', 0, '2014-12-20T20:58:18.449000Z', '1 standard', 'Cato Neimoidia', 278, 10000000, 25, NULL, 'mountains, fields, forests, rock arches', 'https://swapi.info/api/planets/18');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (19, 'hot', '2014-12-10T13:47:46.874000Z', 14920, '2014-12-20T20:58:18.450000Z', NULL, 'Saleucami', 392, 1400000000, 26, NULL, 'caves, desert, mountains, volcanoes', 'https://swapi.info/api/planets/19');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (20, 'temperate', '2014-12-10T16:16:26.566000Z', 0, '2014-12-20T20:58:18.452000Z', '1 standard', 'Stewjon', NULL, NULL, NULL, NULL, 'grass', 'https://swapi.info/api/planets/20');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (21, 'polluted', '2014-12-10T16:26:54.384000Z', 13490, '2014-12-20T20:58:18.454000Z', '1 standard', 'Eriadu', 360, 22000000000, 24, NULL, 'cityscape', 'https://swapi.info/api/planets/21');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (22, 'temperate', '2014-12-10T16:49:12.453000Z', 11000, '2014-12-20T20:58:18.456000Z', '1 standard', 'Corellia', 329, 3000000000, 25, 70, 'plains, urban, hills, forests', 'https://swapi.info/api/planets/22');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (23, 'hot', '2014-12-10T17:03:28.110000Z', 7549, '2014-12-20T20:58:18.458000Z', '1 standard', 'Rodia', 305, 1300000000, 29, 60, 'jungles, oceans, urban, swamps', 'https://swapi.info/api/planets/23');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (24, 'temperate', '2014-12-10T17:11:29.452000Z', 12150, '2014-12-20T20:58:18.460000Z', '1 standard', 'Nal Hutta', 413, 7000000000, 87, NULL, 'urban, oceans, swamps, bogs', 'https://swapi.info/api/planets/24');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (25, 'temperate', '2014-12-10T17:23:29.896000Z', 9830, '2014-12-20T20:58:18.461000Z', '1 standard', 'Dantooine', 378, 1000, 25, NULL, 'oceans, savannas, mountains, grasslands', 'https://swapi.info/api/planets/25');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (26, 'temperate', '2014-12-12T11:16:55.078000Z', 6400, '2014-12-20T20:58:18.463000Z', NULL, 'Bestine IV', 680, 62000000, 26, 98, 'rocky islands, oceans', 'https://swapi.info/api/planets/26');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (27, 'temperate', '2014-12-15T12:23:41.661000Z', 14050, '2014-12-20T20:58:18.464000Z', '1 standard', 'Ord Mantell', 334, 4000000000, 26, 10, 'plains, seas, mesas', 'https://swapi.info/api/planets/27');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (28, NULL, '2014-12-15T12:25:59.569000Z', 0, '2014-12-20T20:58:18.466000Z', NULL, NULL, 0, NULL, 0, NULL, NULL, 'https://swapi.info/api/planets/28');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (29, 'arid', '2014-12-15T12:53:47.695000Z', 0, '2014-12-20T20:58:18.468000Z', '0.62 standard', 'Trandosha', 371, 42000000, 25, NULL, 'mountains, seas, grasslands, deserts', 'https://swapi.info/api/planets/29');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (30, 'arid', '2014-12-15T12:56:31.121000Z', 0, '2014-12-20T20:58:18.469000Z', '1 standard', 'Socorro', 326, 300000000, 20, NULL, 'deserts, mountains', 'https://swapi.info/api/planets/30');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (31, 'temperate', '2014-12-18T11:07:01.792000Z', 11030, '2014-12-20T20:58:18.471000Z', '1', 'Mon Cala', 398, 27000000000, 21, 100, 'oceans, reefs, islands', 'https://swapi.info/api/planets/31');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (32, 'temperate', '2014-12-18T11:11:51.872000Z', 13500, '2014-12-20T20:58:18.472000Z', '1', 'Chandrila', 368, 1200000000, 20, 40, 'plains, forests', 'https://swapi.info/api/planets/32');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (33, 'superheated', '2014-12-18T11:25:40.243000Z', 12780, '2014-12-20T20:58:18.474000Z', '1', 'Sullust', 263, 18500000000, 20, 5, 'mountains, volcanoes, rocky deserts', 'https://swapi.info/api/planets/33');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (34, 'temperate', '2014-12-19T17:47:54.403000Z', 7900, '2014-12-20T20:58:18.476000Z', '1', 'Toydaria', 184, 11000000, 21, NULL, 'swamps, lakes', 'https://swapi.info/api/planets/34');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (35, 'arid, temperate, tropical', '2014-12-19T17:52:13.106000Z', 18880, '2014-12-20T20:58:18.478000Z', '1.56', 'Malastare', 201, 2000000000, 26, NULL, 'swamps, deserts, jungles, mountains', 'https://swapi.info/api/planets/35');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (36, 'temperate', '2014-12-19T18:00:40.142000Z', 10480, '2014-12-20T20:58:18.480000Z', '0.9', 'Dathomir', 491, 5200, 24, NULL, 'forests, deserts, savannas', 'https://swapi.info/api/planets/36');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (37, 'temperate, arid, subartic', '2014-12-20T09:46:25.740000Z', 10600, '2014-12-20T20:58:18.481000Z', '1', 'Ryloth', 305, 1500000000, 30, 5, 'mountains, valleys, deserts, tundra', 'https://swapi.info/api/planets/37');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (38, NULL, '2014-12-20T09:52:23.452000Z', NULL, '2014-12-20T20:58:18.483000Z', NULL, 'Aleen Minor', NULL, NULL, NULL, NULL, NULL, 'https://swapi.info/api/planets/38');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (39, 'temperate, artic', '2014-12-20T09:56:58.874000Z', 14900, '2014-12-20T20:58:18.485000Z', '1', 'Vulpter', 391, 421000000, 22, NULL, 'urban, barren', 'https://swapi.info/api/planets/39');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (40, NULL, '2014-12-20T10:01:37.395000Z', NULL, '2014-12-20T20:58:18.487000Z', NULL, 'Troiken', NULL, NULL, NULL, NULL, 'desert, tundra, rainforests, mountains', 'https://swapi.info/api/planets/40');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (41, NULL, '2014-12-20T10:07:29.578000Z', 12190, '2014-12-20T20:58:18.489000Z', NULL, 'Tund', 1770, 0, 48, NULL, 'barren, ash', 'https://swapi.info/api/planets/41');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (42, 'temperate', '2014-12-20T10:12:28.980000Z', 10120, '2014-12-20T20:58:18.491000Z', '0.98', 'Haruun Kal', 383, 705300, 25, NULL, 'toxic cloudsea, plateaus, volcanoes', 'https://swapi.info/api/planets/42');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (43, 'temperate', '2014-12-20T10:14:48.178000Z', NULL, '2014-12-20T20:58:18.493000Z', '1', 'Cerea', 386, 450000000, 27, 20, 'verdant', 'https://swapi.info/api/planets/43');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (44, 'tropical, temperate', '2014-12-20T10:18:26.110000Z', 15600, '2014-12-20T20:58:18.495000Z', '1', 'Glee Anselm', 206, 500000000, 33, 80, 'lakes, islands, swamps, seas', 'https://swapi.info/api/planets/44');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (45, NULL, '2014-12-20T10:26:05.788000Z', NULL, '2014-12-20T20:58:18.497000Z', NULL, 'Iridonia', 413, NULL, 29, NULL, 'rocky canyons, acid pools', 'https://swapi.info/api/planets/45');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (46, NULL, '2014-12-20T10:28:31.117000Z', NULL, '2014-12-20T20:58:18.498000Z', NULL, 'Tholoth', NULL, NULL, NULL, NULL, NULL, 'https://swapi.info/api/planets/46');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (47, 'arid, rocky, windy', '2014-12-20T10:31:32.413000Z', NULL, '2014-12-20T20:58:18.500000Z', '1', 'Iktotch', 481, NULL, 22, NULL, 'rocky', 'https://swapi.info/api/planets/47');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (48, NULL, '2014-12-20T10:34:08.249000Z', NULL, '2014-12-20T20:58:18.502000Z', NULL, 'Quermia', NULL, NULL, NULL, NULL, NULL, 'https://swapi.info/api/planets/48');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (49, 'temperate', '2014-12-20T10:48:36.141000Z', 13400, '2014-12-20T20:58:18.504000Z', '1', 'Dorin', 409, NULL, 22, NULL, NULL, 'https://swapi.info/api/planets/49');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (50, 'temperate', '2014-12-20T10:52:51.524000Z', NULL, '2014-12-20T20:58:18.506000Z', '1', 'Champala', 318, 3500000000, 27, NULL, 'oceans, rainforests, plateaus', 'https://swapi.info/api/planets/50');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (51, NULL, '2014-12-20T16:44:46.318000Z', NULL, '2014-12-20T20:58:18.508000Z', NULL, 'Mirial', NULL, NULL, NULL, NULL, 'deserts', 'https://swapi.info/api/planets/51');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (52, NULL, '2014-12-20T16:52:13.357000Z', NULL, '2014-12-20T20:58:18.510000Z', NULL, 'Serenno', NULL, NULL, NULL, NULL, 'rainforests, rivers, mountains', 'https://swapi.info/api/planets/52');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (53, NULL, '2014-12-20T16:54:39.909000Z', NULL, '2014-12-20T20:58:18.512000Z', NULL, 'Concord Dawn', NULL, NULL, NULL, NULL, 'jungles, forests, deserts', 'https://swapi.info/api/planets/53');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (54, NULL, '2014-12-20T16:56:37.250000Z', NULL, '2014-12-20T20:58:18.514000Z', NULL, 'Zolan', NULL, NULL, NULL, NULL, NULL, 'https://swapi.info/api/planets/54');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (55, 'frigid', '2014-12-20T17:27:41.286000Z', NULL, '2014-12-20T20:58:18.516000Z', NULL, 'Ojom', NULL, 500000000, NULL, 100, 'oceans, glaciers', 'https://swapi.info/api/planets/55');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (56, 'temperate', '2014-12-20T17:50:47.864000Z', NULL, '2014-12-20T20:58:18.517000Z', '1', 'Skako', 384, 500000000000, 27, NULL, 'urban, vines', 'https://swapi.info/api/planets/56');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (57, 'temperate', '2014-12-20T17:57:47.420000Z', 13800, '2014-12-20T20:58:18.519000Z', '1', 'Muunilinst', 412, 5000000000, 28, 25, 'plains, forests, hills, mountains', 'https://swapi.info/api/planets/57');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (58, 'temperate', '2014-12-20T18:43:14.049000Z', NULL, '2014-12-20T20:58:18.521000Z', '1', 'Shili', NULL, NULL, NULL, NULL, 'cities, savannahs, seas, plains', 'https://swapi.info/api/planets/58');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (59, 'arid, temperate, tropical', '2014-12-20T19:43:51.278000Z', 13850, '2014-12-20T20:58:18.523000Z', '1', 'Kalee', 378, 4000000000, 23, NULL, 'rainforests, cliffs, canyons, seas', 'https://swapi.info/api/planets/59');
INSERT INTO planets (id, climate, created, diameter, edited, gravity, name, orbital_period, population, rotation_period, surface_water, terrain, url) VALUES (60, NULL, '2014-12-20T20:18:36.256000Z', NULL, '2014-12-20T20:58:18.525000Z', NULL, 'Umbara', NULL, NULL, NULL, NULL, NULL, 'https://swapi.info/api/planets/60');

-- Insert data into species
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (1, '180', '120', 'mammal', '2014-12-10T13:52:11.567000Z', 'sentient', '2014-12-20T21:36:42.136000Z', 'brown, blue, green, hazel, grey, amber', 'blonde, brown, black, red', 9, 'Galactic Basic', 'Human', 'caucasian, black, asian, hispanic', 'https://swapi.info/api/species/1');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, language, name, skin_colors, url) VALUES (2, NULL, 'indefinite', 'artificial', '2014-12-10T15:16:16.259000Z', 'sentient', '2014-12-20T21:36:42.139000Z', NULL, NULL, NULL, 'Droid', NULL, 'https://swapi.info/api/species/2');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (3, '210', '400', 'mammal', '2014-12-10T16:44:31.486000Z', 'sentient', '2014-12-20T21:36:42.142000Z', 'blue, green, yellow, brown, golden, red', 'black, brown', 14, 'Shyriiwook', 'Wookie', 'gray', 'https://swapi.info/api/species/3');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (4, '170', NULL, 'sentient', '2014-12-10T17:05:26.471000Z', 'reptilian', '2014-12-20T21:36:42.144000Z', 'black', NULL, 23, 'Galatic Basic', 'Rodian', 'green, blue', 'https://swapi.info/api/species/4');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (5, '300', '1000', 'gastropod', '2014-12-10T17:12:50.410000Z', 'sentient', '2014-12-20T21:36:42.146000Z', 'yellow, red', NULL, 24, 'Huttese', 'Hutt', 'green, brown, tan', 'https://swapi.info/api/species/5');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (6, '66', '900', 'mammal', '2014-12-15T12:27:22.877000Z', 'sentient', '2014-12-20T21:36:42.148000Z', 'brown, green, yellow', 'brown, white', 28, 'Galactic basic', 'Yoda''s species', 'green, yellow', 'https://swapi.info/api/species/6');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (7, '200', NULL, 'reptile', '2014-12-15T13:07:47.704000Z', 'sentient', '2014-12-20T21:36:42.151000Z', 'yellow, orange', NULL, 29, 'Dosh', 'Trandoshan', 'brown, green', 'https://swapi.info/api/species/7');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (8, '160', NULL, 'amphibian', '2014-12-18T11:09:52.263000Z', 'sentient', '2014-12-20T21:36:42.153000Z', 'yellow', NULL, 31, 'Mon Calamarian', 'Mon Calamari', 'red, blue, brown, magenta', 'https://swapi.info/api/species/8');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (9, '100', NULL, 'mammal', '2014-12-18T11:22:00.285000Z', 'sentient', '2014-12-20T21:36:42.155000Z', 'orange, brown', 'white, brown, black', 7, 'Ewokese', 'Ewok', 'brown', 'https://swapi.info/api/species/9');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (10, '180', NULL, 'mammal', '2014-12-18T11:26:20.103000Z', 'sentient', '2014-12-20T21:36:42.157000Z', 'black', NULL, 33, 'Sullutese', 'Sullustan', 'pale', 'https://swapi.info/api/species/10');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (11, '180', NULL, NULL, '2014-12-19T17:07:31.319000Z', 'sentient', '2014-12-20T21:36:42.160000Z', 'red, pink', NULL, 18, 'Neimoidia', 'Neimodian', 'grey, green', 'https://swapi.info/api/species/11');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (12, '190', NULL, 'amphibian', '2014-12-19T17:30:37.341000Z', 'sentient', '2014-12-20T21:36:42.163000Z', 'orange', NULL, 8, 'Gungan basic', 'Gungan', 'brown, green', 'https://swapi.info/api/species/12');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (13, '120', '91', 'mammal', '2014-12-19T17:48:56.893000Z', 'sentient', '2014-12-20T21:36:42.165000Z', 'yellow', NULL, 34, 'Toydarian', 'Toydarian', 'blue, green, grey', 'https://swapi.info/api/species/13');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (14, '100', NULL, 'mammal', '2014-12-19T17:53:11.214000Z', 'sentient', '2014-12-20T21:36:42.167000Z', 'yellow, blue', NULL, 35, 'Dugese', 'Dug', 'brown, purple, grey, red', 'https://swapi.info/api/species/14');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (15, '200', NULL, 'mammals', '2014-12-20T09:48:02.406000Z', 'sentient', '2014-12-20T21:36:42.169000Z', 'blue, brown, orange, pink', NULL, 37, 'Twi''leki', 'Twi''lek', 'orange, yellow, blue, green, pink, purple, tan', 'https://swapi.info/api/species/15');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (16, '80', '79', 'reptile', '2014-12-20T09:53:16.481000Z', 'sentient', '2014-12-20T21:36:42.171000Z', NULL, NULL, 38, 'Aleena', 'Aleena', 'blue, gray', 'https://swapi.info/api/species/16');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (17, '100', NULL, NULL, '2014-12-20T09:57:33.128000Z', 'sentient', '2014-12-20T21:36:42.173000Z', 'yellow', NULL, 39, 'vulpterish', 'Vulptereen', 'grey', 'https://swapi.info/api/species/17');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (18, '125', NULL, NULL, '2014-12-20T10:02:13.915000Z', 'sentient', '2014-12-20T21:36:42.175000Z', 'black', NULL, 40, 'Xextese', 'Xexto', 'grey, yellow, purple', 'https://swapi.info/api/species/18');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (19, '200', NULL, NULL, '2014-12-20T10:08:36.795000Z', 'sentient', '2014-12-20T21:36:42.177000Z', 'orange', NULL, 41, 'Tundan', 'Toong', 'grey, green, yellow', 'https://swapi.info/api/species/19');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (20, '200', NULL, 'mammal', '2014-12-20T10:15:33.765000Z', 'sentient', '2014-12-20T21:36:42.179000Z', 'hazel', 'red, blond, black, white', 43, 'Cerean', 'Cerean', 'pale pink', 'https://swapi.info/api/species/20');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (21, '180', '70', 'amphibian', '2014-12-20T10:18:58.610000Z', 'sentient', '2014-12-20T21:36:42.181000Z', 'black', NULL, 44, 'Nautila', 'Nautolan', 'green, blue, brown, red', 'https://swapi.info/api/species/21');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (22, '180', NULL, 'mammal', '2014-12-20T10:26:59.894000Z', 'sentient', '2014-12-20T21:36:42.183000Z', 'brown, orange', 'black', 45, 'Zabraki', 'Zabrak', 'pale, brown, red, orange, yellow', 'https://swapi.info/api/species/22');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (23, NULL, NULL, 'mammal', '2014-12-20T10:29:13.798000Z', 'sentient', '2014-12-20T21:36:42.186000Z', 'blue, indigo', NULL, 46, NULL, 'Tholothian', 'dark', 'https://swapi.info/api/species/23');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (24, '180', NULL, NULL, '2014-12-20T10:32:13.046000Z', 'sentient', '2014-12-20T21:36:42.188000Z', 'orange', NULL, 47, 'Iktotchese', 'Iktotchi', 'pink', 'https://swapi.info/api/species/24');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (25, '240', '86', 'mammal', '2014-12-20T10:34:50.827000Z', 'sentient', '2014-12-20T21:36:42.189000Z', 'yellow', NULL, 48, 'Quermian', 'Quermian', 'white', 'https://swapi.info/api/species/25');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (26, '180', '70', NULL, '2014-12-20T10:49:21.692000Z', 'sentient', '2014-12-20T21:36:42.191000Z', 'black, silver', NULL, 49, 'Kel Dor', 'Kel Dor', 'peach, orange, red', 'https://swapi.info/api/species/26');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (27, '190', NULL, 'amphibian', '2014-12-20T10:53:28.795000Z', 'sentient', '2014-12-20T21:36:42.193000Z', 'blue', NULL, 50, 'Chagria', 'Chagrian', 'blue', 'https://swapi.info/api/species/27');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (28, '178', NULL, 'insectoid', '2014-12-20T16:40:45.618000Z', 'sentient', '2014-12-20T21:36:42.195000Z', 'green, hazel', NULL, 11, 'Geonosian', 'Geonosian', 'green, brown', 'https://swapi.info/api/species/28');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (29, '180', NULL, 'mammal', '2014-12-20T16:46:48.290000Z', 'sentient', '2014-12-20T21:36:42.197000Z', 'blue, green, red, yellow, brown, orange', 'black, brown', 51, 'Mirialan', 'Mirialan', 'yellow, green', 'https://swapi.info/api/species/29');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (30, '180', '70', 'reptilian', '2014-12-20T16:57:46.171000Z', 'sentient', '2014-12-20T21:36:42.199000Z', 'yellow', NULL, 54, 'Clawdite', 'Clawdite', 'green, yellow', 'https://swapi.info/api/species/30');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (31, '178', '75', 'amphibian', '2014-12-20T17:28:28.821000Z', 'sentient', '2014-12-20T21:36:42.200000Z', 'yellow', NULL, 55, 'besalisk', 'Besalisk', 'brown', 'https://swapi.info/api/species/31');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (32, '220', '80', 'amphibian', '2014-12-20T17:31:24.838000Z', 'sentient', '2014-12-20T21:36:42.202000Z', 'black', NULL, 10, 'Kaminoan', 'Kaminoan', 'grey, blue', 'https://swapi.info/api/species/32');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (33, NULL, NULL, 'mammal', '2014-12-20T17:53:54.515000Z', 'sentient', '2014-12-20T21:36:42.204000Z', NULL, NULL, 56, 'Skakoan', 'Skakoan', 'grey, green', 'https://swapi.info/api/species/33');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (34, '190', '100', 'mammal', '2014-12-20T17:58:19.088000Z', 'sentient', '2014-12-20T21:36:42.207000Z', 'black', NULL, 57, 'Muun', 'Muun', 'grey, white', 'https://swapi.info/api/species/34');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (35, '180', '94', 'mammal', '2014-12-20T18:44:03.246000Z', 'sentient', '2014-12-20T21:36:42.209000Z', 'red, orange, yellow, green, blue, black', NULL, 58, 'Togruti', 'Togruta', 'red, white, orange, yellow, green, blue', 'https://swapi.info/api/species/35');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (36, '170', '80', 'reptile', '2014-12-20T19:45:42.537000Z', 'sentient', '2014-12-20T21:36:42.210000Z', 'yellow', NULL, 59, 'Kaleesh', 'Kaleesh', 'brown, orange, tan', 'https://swapi.info/api/species/36');
INSERT INTO species (id, average_height, average_lifespan, classification, created, designation, edited, eye_colors, hair_colors, homeworld_id, language, name, skin_colors, url) VALUES (37, '190', '700', 'mammal', '2014-12-20T20:35:06.777000Z', 'sentient', '2014-12-20T21:36:42.212000Z', 'black', NULL, 12, 'Utapese', 'Pau''an', 'grey', 'https://swapi.info/api/species/37');

-- Insert data into characters
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (1, '19BBY', '2014-12-09T13:50:51.644000Z', '2014-12-20T21:17:56.891000Z', 'blue', 'male', 'blond', '172', 1, '77', 'Luke Skywalker', 'fair', 'https://swapi.info/api/people/1');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (2, 2, '112BBY', '2014-12-10T15:10:51.357000Z', '2014-12-20T21:17:50.309000Z', 'yellow', NULL, NULL, '167', 1, '75', 'C-3PO', 'gold', 'https://swapi.info/api/people/2');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (3, 2, '33BBY', '2014-12-10T15:11:50.376000Z', '2014-12-20T21:17:50.311000Z', 'red', NULL, NULL, '96', 8, '32', 'R2-D2', 'white, blue', 'https://swapi.info/api/people/3');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (4, '41.9BBY', '2014-12-10T15:18:20.704000Z', '2014-12-20T21:17:50.313000Z', 'yellow', 'male', NULL, '202', 1, '136', 'Darth Vader', 'white', 'https://swapi.info/api/people/4');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (5, '19BBY', '2014-12-10T15:20:09.791000Z', '2014-12-20T21:17:50.315000Z', 'brown', 'female', 'brown', '150', 2, '49', 'Leia Organa', 'light', 'https://swapi.info/api/people/5');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (6, '52BBY', '2014-12-10T15:52:14.024000Z', '2014-12-20T21:17:50.317000Z', 'blue', 'male', 'brown, grey', '178', 1, '120', 'Owen Lars', 'light', 'https://swapi.info/api/people/6');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (7, '47BBY', '2014-12-10T15:53:41.121000Z', '2014-12-20T21:17:50.319000Z', 'blue', 'female', 'brown', '165', 1, '75', 'Beru Whitesun lars', 'light', 'https://swapi.info/api/people/7');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (8, 2, NULL, '2014-12-10T15:57:50.959000Z', '2014-12-20T21:17:50.321000Z', 'red', NULL, NULL, '97', 1, '32', 'R5-D4', 'white, red', 'https://swapi.info/api/people/8');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (9, '24BBY', '2014-12-10T15:59:50.509000Z', '2014-12-20T21:17:50.323000Z', 'brown', 'male', 'black', '183', 1, '84', 'Biggs Darklighter', 'light', 'https://swapi.info/api/people/9');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (10, '57BBY', '2014-12-10T16:16:29.192000Z', '2014-12-20T21:17:50.325000Z', 'blue-gray', 'male', 'auburn, white', '182', 20, '77', 'Obi-Wan Kenobi', 'fair', 'https://swapi.info/api/people/10');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (11, '41.9BBY', '2014-12-10T16:20:44.310000Z', '2014-12-20T21:17:50.327000Z', 'blue', 'male', 'blond', '188', 1, '84', 'Anakin Skywalker', 'fair', 'https://swapi.info/api/people/11');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (12, '64BBY', '2014-12-10T16:26:56.138000Z', '2014-12-20T21:17:50.330000Z', 'blue', 'male', 'auburn, grey', '180', 21, NULL, 'Wilhuff Tarkin', 'fair', 'https://swapi.info/api/people/12');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (13, 3, '200BBY', '2014-12-10T16:42:45.066000Z', '2014-12-20T21:17:50.332000Z', 'blue', 'male', 'brown', '228', 14, '112', 'Chewbacca', NULL, 'https://swapi.info/api/people/13');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (14, '29BBY', '2014-12-10T16:49:14.582000Z', '2014-12-20T21:17:50.334000Z', 'brown', 'male', 'brown', '180', 22, '80', 'Han Solo', 'fair', 'https://swapi.info/api/people/14');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (15, 4, '44BBY', '2014-12-10T17:03:30.334000Z', '2014-12-20T21:17:50.336000Z', 'black', 'male', NULL, '173', 23, '74', 'Greedo', 'green', 'https://swapi.info/api/people/15');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (16, 5, '600BBY', '2014-12-10T17:11:31.638000Z', '2014-12-20T21:17:50.338000Z', 'orange', 'hermaphrodite', NULL, '175', 24, '1,358', 'Jabba Desilijic Tiure', 'green-tan, brown', 'https://swapi.info/api/people/16');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (18, '21BBY', '2014-12-12T11:08:06.469000Z', '2014-12-20T21:17:50.341000Z', 'hazel', 'male', 'brown', '170', 22, '77', 'Wedge Antilles', 'fair', 'https://swapi.info/api/people/18');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (19, NULL, '2014-12-12T11:16:56.569000Z', '2014-12-20T21:17:50.343000Z', 'blue', 'male', 'brown', '180', 26, '110', 'Jek Tono Porkins', 'fair', 'https://swapi.info/api/people/19');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (20, 6, '896BBY', '2014-12-15T12:26:01.042000Z', '2014-12-20T21:17:50.345000Z', 'brown', 'male', 'white', '66', 28, '17', 'Yoda', 'green', 'https://swapi.info/api/people/20');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (21, '82BBY', '2014-12-15T12:48:05.971000Z', '2014-12-20T21:17:50.347000Z', 'yellow', 'male', 'grey', '170', 8, '75', 'Palpatine', 'pale', 'https://swapi.info/api/people/21');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (22, '31.5BBY', '2014-12-15T12:49:32.457000Z', '2014-12-20T21:17:50.349000Z', 'brown', 'male', 'black', '183', 10, '78.2', 'Boba Fett', 'fair', 'https://swapi.info/api/people/22');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (23, 2, '15BBY', '2014-12-15T12:51:10.076000Z', '2014-12-20T21:17:50.351000Z', 'red', NULL, NULL, '200', 28, '140', 'IG-88', 'metal', 'https://swapi.info/api/people/23');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (24, 7, '53BBY', '2014-12-15T12:53:49.297000Z', '2014-12-20T21:17:50.355000Z', 'red', 'male', NULL, '190', 29, '113', 'Bossk', 'green', 'https://swapi.info/api/people/24');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (25, '31BBY', '2014-12-15T12:56:32.683000Z', '2014-12-20T21:17:50.357000Z', 'brown', 'male', 'black', '177', 30, '79', 'Lando Calrissian', 'dark', 'https://swapi.info/api/people/25');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (26, '37BBY', '2014-12-15T13:01:57.178000Z', '2014-12-20T21:17:50.359000Z', 'blue', 'male', NULL, '175', 6, '79', 'Lobot', 'light', 'https://swapi.info/api/people/26');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (27, 8, '41BBY', '2014-12-18T11:07:50.584000Z', '2014-12-20T21:17:50.362000Z', 'orange', 'male', NULL, '180', 31, '83', 'Ackbar', 'brown mottle', 'https://swapi.info/api/people/27');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (28, '48BBY', '2014-12-18T11:12:38.895000Z', '2014-12-20T21:17:50.364000Z', 'blue', 'female', 'auburn', '150', 32, NULL, 'Mon Mothma', 'fair', 'https://swapi.info/api/people/28');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (29, NULL, '2014-12-18T11:16:33.020000Z', '2014-12-20T21:17:50.367000Z', 'brown', 'male', 'brown', NULL, 28, NULL, 'Arvel Crynyd', 'fair', 'https://swapi.info/api/people/29');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (30, 9, '8BBY', '2014-12-18T11:21:58.954000Z', '2014-12-20T21:17:50.369000Z', 'brown', 'male', 'brown', '88', 7, '20', 'Wicket Systri Warrick', 'brown', 'https://swapi.info/api/people/30');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (31, 10, NULL, '2014-12-18T11:26:18.541000Z', '2014-12-20T21:17:50.371000Z', 'black', 'male', NULL, '160', 33, '68', 'Nien Nunb', 'grey', 'https://swapi.info/api/people/31');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (32, '92BBY', '2014-12-19T16:54:53.618000Z', '2014-12-20T21:17:50.375000Z', 'blue', 'male', 'brown', '193', 28, '89', 'Qui-Gon Jinn', 'fair', 'https://swapi.info/api/people/32');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (33, 11, NULL, '2014-12-19T17:05:57.357000Z', '2014-12-20T21:17:50.377000Z', 'red', 'male', NULL, '191', 18, '90', 'Nute Gunray', 'mottled green', 'https://swapi.info/api/people/33');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (34, '91BBY', '2014-12-19T17:21:45.915000Z', '2014-12-20T21:17:50.379000Z', 'blue', 'male', 'blond', '170', 9, NULL, 'Finis Valorum', 'fair', 'https://swapi.info/api/people/34');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (35, '46BBY', '2014-12-19T17:28:26.926000Z', '2014-12-20T21:17:50.381000Z', 'brown', 'female', 'brown', '185', 8, '45', 'Padmé Amidala', 'light', 'https://swapi.info/api/people/35');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (36, 12, '52BBY', '2014-12-19T17:29:32.489000Z', '2014-12-20T21:17:50.383000Z', 'orange', 'male', NULL, '196', 8, '66', 'Jar Jar Binks', 'orange', 'https://swapi.info/api/people/36');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (37, 12, NULL, '2014-12-19T17:32:56.741000Z', '2014-12-20T21:17:50.385000Z', 'orange', 'male', NULL, '224', 8, '82', 'Roos Tarpals', 'grey', 'https://swapi.info/api/people/37');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (38, 12, NULL, '2014-12-19T17:33:38.909000Z', '2014-12-20T21:17:50.388000Z', 'orange', 'male', NULL, '206', 8, NULL, 'Rugor Nass', 'green', 'https://swapi.info/api/people/38');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (39, NULL, '2014-12-19T17:45:01.522000Z', '2014-12-20T21:17:50.392000Z', 'blue', 'male', 'brown', '183', 8, NULL, 'Ric Olié', 'fair', 'https://swapi.info/api/people/39');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (40, 13, NULL, '2014-12-19T17:48:54.647000Z', '2014-12-20T21:17:50.395000Z', 'yellow', 'male', 'black', '137', 34, NULL, 'Watto', 'blue, grey', 'https://swapi.info/api/people/40');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (41, 14, NULL, '2014-12-19T17:53:02.586000Z', '2014-12-20T21:17:50.397000Z', 'orange', 'male', NULL, '112', 35, '40', 'Sebulba', 'grey, red', 'https://swapi.info/api/people/41');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (42, '62BBY', '2014-12-19T17:55:43.348000Z', '2014-12-20T21:17:50.399000Z', 'brown', 'male', 'black', '183', 8, NULL, 'Quarsh Panaka', 'dark', 'https://swapi.info/api/people/42');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (43, '72BBY', '2014-12-19T17:57:41.191000Z', '2014-12-20T21:17:50.401000Z', 'brown', 'female', 'black', '163', 1, NULL, 'Shmi Skywalker', 'fair', 'https://swapi.info/api/people/43');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (44, 22, '54BBY', '2014-12-19T18:00:41.929000Z', '2014-12-20T21:17:50.403000Z', 'yellow', 'male', NULL, '175', 36, '80', 'Darth Maul', 'red', 'https://swapi.info/api/people/44');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (45, 15, NULL, '2014-12-20T09:47:02.512000Z', '2014-12-20T21:17:50.407000Z', 'pink', 'male', NULL, '180', 37, NULL, 'Bib Fortuna', 'pale', 'https://swapi.info/api/people/45');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (46, 15, '48BBY', '2014-12-20T09:48:01.172000Z', '2014-12-20T21:17:50.409000Z', 'hazel', 'female', NULL, '178', 37, '55', 'Ayla Secura', 'blue', 'https://swapi.info/api/people/46');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (47, 16, NULL, '2014-12-20T09:53:15.086000Z', '2014-12-20T21:17:50.410000Z', NULL, 'male', NULL, '79', 38, '15', 'Ratts Tyerel', 'grey, blue', 'https://swapi.info/api/people/47');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (48, 17, NULL, '2014-12-20T09:57:31.858000Z', '2014-12-20T21:17:50.414000Z', 'yellow', 'male', NULL, '94', 39, '45', 'Dud Bolt', 'blue, grey', 'https://swapi.info/api/people/48');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (49, 18, NULL, '2014-12-20T10:02:12.223000Z', '2014-12-20T21:17:50.416000Z', 'black', 'male', NULL, '122', 40, NULL, 'Gasgano', 'white, blue', 'https://swapi.info/api/people/49');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (50, 19, NULL, '2014-12-20T10:08:33.777000Z', '2014-12-20T21:17:50.417000Z', 'orange', 'male', NULL, '163', 41, '65', 'Ben Quadinaros', 'grey, green, yellow', 'https://swapi.info/api/people/50');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (51, '72BBY', '2014-12-20T10:12:30.846000Z', '2014-12-20T21:17:50.420000Z', 'brown', 'male', NULL, '188', 42, '84', 'Mace Windu', 'dark', 'https://swapi.info/api/people/51');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (52, 20, '92BBY', '2014-12-20T10:15:32.293000Z', '2014-12-20T21:17:50.422000Z', 'yellow', 'male', 'white', '198', 43, '82', 'Ki-Adi-Mundi', 'pale', 'https://swapi.info/api/people/52');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (53, 21, NULL, '2014-12-20T10:18:57.202000Z', '2014-12-20T21:17:50.424000Z', 'black', 'male', NULL, '196', 44, '87', 'Kit Fisto', 'green', 'https://swapi.info/api/people/53');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (54, 22, NULL, '2014-12-20T10:26:47.902000Z', '2014-12-20T21:17:50.427000Z', 'brown', 'male', 'black', '171', 45, NULL, 'Eeth Koth', 'brown', 'https://swapi.info/api/people/54');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (55, 23, NULL, '2014-12-20T10:29:11.661000Z', '2014-12-20T21:17:50.432000Z', 'blue', 'female', NULL, '184', 9, '50', 'Adi Gallia', 'dark', 'https://swapi.info/api/people/55');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (56, 24, NULL, '2014-12-20T10:32:11.669000Z', '2014-12-20T21:17:50.434000Z', 'orange', 'male', NULL, '188', 47, NULL, 'Saesee Tiin', 'pale', 'https://swapi.info/api/people/56');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (57, 25, NULL, '2014-12-20T10:34:48.725000Z', '2014-12-20T21:17:50.437000Z', 'yellow', 'male', NULL, '264', 48, NULL, 'Yarael Poof', 'white', 'https://swapi.info/api/people/57');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (58, 26, '22BBY', '2014-12-20T10:49:19.859000Z', '2014-12-20T21:17:50.439000Z', 'black', 'male', NULL, '188', 49, '80', 'Plo Koon', 'orange', 'https://swapi.info/api/people/58');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (59, 27, NULL, '2014-12-20T10:53:26.457000Z', '2014-12-20T21:17:50.442000Z', 'blue', 'male', NULL, '196', 50, NULL, 'Mas Amedda', 'blue', 'https://swapi.info/api/people/59');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (60, NULL, '2014-12-20T11:10:10.381000Z', '2014-12-20T21:17:50.445000Z', 'brown', 'male', 'black', '185', 8, '85', 'Gregar Typho', 'dark', 'https://swapi.info/api/people/60');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (61, NULL, '2014-12-20T11:11:39.630000Z', '2014-12-20T21:17:50.449000Z', 'brown', 'female', 'brown', '157', 8, NULL, 'Cordé', 'light', 'https://swapi.info/api/people/61');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (62, '82BBY', '2014-12-20T15:59:03.958000Z', '2014-12-20T21:17:50.451000Z', 'blue', 'male', 'brown', '183', 1, NULL, 'Cliegg Lars', 'fair', 'https://swapi.info/api/people/62');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (63, 28, NULL, '2014-12-20T16:40:43.977000Z', '2014-12-20T21:17:50.453000Z', 'yellow', 'male', NULL, '183', 11, '80', 'Poggle the Lesser', 'green', 'https://swapi.info/api/people/63');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (64, 29, '58BBY', '2014-12-20T16:45:53.668000Z', '2014-12-20T21:17:50.455000Z', 'blue', 'female', 'black', '170', 51, '56.2', 'Luminara Unduli', 'yellow', 'https://swapi.info/api/people/64');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (65, 29, '40BBY', '2014-12-20T16:46:40.440000Z', '2014-12-20T21:17:50.457000Z', 'blue', 'female', 'black', '166', 51, '50', 'Barriss Offee', 'yellow', 'https://swapi.info/api/people/65');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (66, 1, NULL, '2014-12-20T16:49:14.640000Z', '2014-12-20T21:17:50.460000Z', 'brown', 'female', 'brown', '165', 8, NULL, 'Dormé', 'light', 'https://swapi.info/api/people/66');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (67, 1, '102BBY', '2014-12-20T16:52:14.726000Z', '2014-12-20T21:17:50.462000Z', 'brown', 'male', 'white', '193', 52, '80', 'Dooku', 'fair', 'https://swapi.info/api/people/67');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (68, 1, '67BBY', '2014-12-20T16:53:08.575000Z', '2014-12-20T21:17:50.463000Z', 'brown', 'male', 'black', '191', 2, NULL, 'Bail Prestor Organa', 'tan', 'https://swapi.info/api/people/68');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (69, '66BBY', '2014-12-20T16:54:41.620000Z', '2014-12-20T21:17:50.465000Z', 'brown', 'male', 'black', '183', 53, '79', 'Jango Fett', 'tan', 'https://swapi.info/api/people/69');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (70, 30, NULL, '2014-12-20T16:57:44.471000Z', '2014-12-20T21:17:50.468000Z', 'yellow', 'female', 'blonde', '168', 54, '55', 'Zam Wesell', 'fair, green, yellow', 'https://swapi.info/api/people/70');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (71, 31, NULL, '2014-12-20T17:28:27.248000Z', '2014-12-20T21:17:50.470000Z', 'yellow', 'male', NULL, '198', 55, '102', 'Dexter Jettster', 'brown', 'https://swapi.info/api/people/71');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (72, 32, NULL, '2014-12-20T17:30:50.416000Z', '2014-12-20T21:17:50.473000Z', 'black', 'male', NULL, '229', 10, '88', 'Lama Su', 'grey', 'https://swapi.info/api/people/72');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (73, 32, NULL, '2014-12-20T17:31:21.195000Z', '2014-12-20T21:17:50.474000Z', 'black', 'female', NULL, '213', 10, NULL, 'Taun We', 'grey', 'https://swapi.info/api/people/73');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (74, 1, NULL, '2014-12-20T17:32:51.996000Z', '2014-12-20T21:17:50.476000Z', 'blue', 'female', 'white', '167', 9, NULL, 'Jocasta Nu', 'fair', 'https://swapi.info/api/people/74');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (75, NULL, '2014-12-20T17:43:36.409000Z', '2014-12-20T21:17:50.478000Z', 'red, blue', 'female', NULL, '96', 28, NULL, 'R4-P17', 'silver, red', 'https://swapi.info/api/people/75');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (76, 33, NULL, '2014-12-20T17:53:52.607000Z', '2014-12-20T21:17:50.481000Z', NULL, 'male', NULL, '193', 56, '48', 'Wat Tambor', 'green, grey', 'https://swapi.info/api/people/76');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (77, 34, NULL, '2014-12-20T17:58:17.049000Z', '2014-12-20T21:17:50.484000Z', 'gold', 'male', NULL, '191', 57, NULL, 'San Hill', 'grey', 'https://swapi.info/api/people/77');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (78, 35, NULL, '2014-12-20T18:44:01.103000Z', '2014-12-20T21:17:50.486000Z', 'black', 'female', NULL, '178', 58, '57', 'Shaak Ti', 'red, blue, white', 'https://swapi.info/api/people/78');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (79, 36, NULL, '2014-12-20T19:43:53.348000Z', '2014-12-20T21:17:50.488000Z', 'green, yellow', 'male', NULL, '216', 59, '159', 'Grievous', 'brown, white', 'https://swapi.info/api/people/79');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (80, 3, NULL, '2014-12-20T19:46:34.209000Z', '2014-12-20T21:17:50.491000Z', 'blue', 'male', 'brown', '234', 14, '136', 'Tarfful', 'brown', 'https://swapi.info/api/people/80');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (81, NULL, '2014-12-20T19:49:35.583000Z', '2014-12-20T21:17:50.493000Z', 'brown', 'male', 'brown', '188', 2, '79', 'Raymus Antilles', 'light', 'https://swapi.info/api/people/81');
INSERT INTO characters (id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (82, NULL, '2014-12-20T20:18:37.619000Z', '2014-12-20T21:17:50.496000Z', 'white', 'female', NULL, '178', 60, '48', 'Sly Moore', 'pale', 'https://swapi.info/api/people/82');
INSERT INTO characters (id, species_id, birth_year, created, edited, eye_color, gender, hair_color, height, homeworld_id, mass, name, skin_color, url) VALUES (83, 37, NULL, '2014-12-20T20:35:04.260000Z', '2014-12-20T21:17:50.498000Z', 'black', 'male', NULL, '206', 12, '80', 'Tion Medon', 'grey', 'https://swapi.info/api/people/83');

-- Insert data into vehicles
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (4, 50000, '2 months', 150000, '2014-12-10T15:36:25.724000Z', 46, '2014-12-20T21:30:21.661000Z', 36.8, 'Corellia Mining Corporation', 30, 'Digger Crawler', 'Sand Crawler', 30, 'https://swapi.info/api/vehicles/4', 'wheeled');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (6, 50, '0', 14500, '2014-12-10T16:01:52.434000Z', 1, '2014-12-20T21:30:21.665000Z', 10.4, 'Incom Corporation', 1200, 'T-16 skyhopper', 'T-16 skyhopper', 1, 'https://swapi.info/api/vehicles/6', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (7, 5, NULL, 10550, '2014-12-10T16:13:52.586000Z', 1, '2014-12-20T21:30:21.668000Z', 3.4, 'SoroSuub Corporation', 250, 'X-34 landspeeder', 'X-34 landspeeder', 1, 'https://swapi.info/api/vehicles/7', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (8, 65, '2 days', NULL, '2014-12-10T16:33:52.860000Z', 1, '2014-12-20T21:30:21.670000Z', 6.4, 'Sienar Fleet Systems', 1200, 'Twin Ion Engine/Ln Starfighter', 'TIE/LN starfighter', 0, 'https://swapi.info/api/vehicles/8', 'starfighter');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (14, 10, NULL, NULL, '2014-12-15T12:22:12Z', 2, '2014-12-20T21:30:21.672000Z', 4.5, 'Incom corporation', 650, 't-47 airspeeder', 'Snowspeeder', 0, 'https://swapi.info/api/vehicles/14', 'airspeeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (16, NULL, '2 days', NULL, '2014-12-15T12:33:15.838000Z', 1, '2014-12-20T21:30:21.675000Z', 7.8, 'Sienar Fleet Systems', 850, 'TIE/sa bomber', 'TIE bomber', 0, 'https://swapi.info/api/vehicles/16', 'space/planetary bomber');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (18, 1000, NULL, NULL, '2014-12-15T12:38:25.937000Z', 5, '2014-12-20T21:30:21.677000Z', 20, 'Kuat Drive Yards, Imperial Department of Military Research', 60, 'All Terrain Armored Transport', 'AT-AT', 40, 'https://swapi.info/api/vehicles/18', 'assault walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (19, 200, NULL, NULL, '2014-12-15T12:46:42.384000Z', 2, '2014-12-20T21:30:21.679000Z', 2, 'Kuat Drive Yards, Imperial Department of Military Research', 90, 'All Terrain Scout Transport', 'AT-ST', 0, 'https://swapi.info/api/vehicles/19', 'walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (20, 10, '1 day', 75000, '2014-12-15T12:58:50.530000Z', 2, '2014-12-20T21:30:21.681000Z', 7, 'Bespin Motors', 1500, 'Storm IV Twin-Pod', 'Storm IV Twin-Pod cloud car', 0, 'https://swapi.info/api/vehicles/20', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (24, 2000000, 'Live food tanks', 285000, '2014-12-18T10:44:14.217000Z', 26, '2014-12-20T21:30:21.684000Z', 30, 'Ubrikkian Industries Custom Vehicle Division', 100, 'Modified Luxury Sail Barge', 'Sail barge', 500, 'https://swapi.info/api/vehicles/24', 'sail barge');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (25, 135000, '1 day', 8000, '2014-12-18T10:48:03.208000Z', 5, '2014-12-20T21:30:21.688000Z', 9.5, 'Ubrikkian Industries', 250, 'Bantha-II', 'Bantha-II cargo skiff', 16, 'https://swapi.info/api/vehicles/25', 'repulsorcraft cargo skiff');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (26, 75, '2 days', NULL, '2014-12-18T10:50:28.225000Z', 1, '2014-12-20T21:30:21.691000Z', 9.6, 'Sienar Fleet Systems', 1250, 'Twin Ion Engine Interceptor', 'TIE/IN interceptor', 0, 'https://swapi.info/api/vehicles/26', 'starfighter');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (30, 4, '1 day', 8000, '2014-12-18T11:20:04.625000Z', 1, '2014-12-20T21:30:21.693000Z', 3, 'Aratech Repulsor Company', 360, '74-Z speeder bike', 'Imperial Speeder Bike', 1, 'https://swapi.info/api/vehicles/30', 'speeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (33, 0, NULL, NULL, '2014-12-19T17:09:53.584000Z', 0, '2014-12-20T21:30:21.697000Z', 3.5, 'Haor Chall Engineering, Baktoid Armor Workshop', 1200, 'Vulture-class droid starfighter', 'Vulture Droid', 0, 'https://swapi.info/api/vehicles/33', 'starfighter');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (34, 12000, NULL, 138000, '2014-12-19T17:12:04.400000Z', 4, '2014-12-20T21:30:21.700000Z', 31, 'Baktoid Armor Workshop', 35, 'Multi-Troop Transport', 'Multi-Troop Transport', 112, 'https://swapi.info/api/vehicles/34', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (35, NULL, NULL, NULL, '2014-12-19T17:13:29.799000Z', 4, '2014-12-20T21:30:21.703000Z', 9.75, 'Baktoid Armor Workshop', 55, 'Armoured Assault Tank', 'Armored Assault Tank', 6, 'https://swapi.info/api/vehicles/35', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (36, NULL, NULL, 2500, '2014-12-19T17:15:09.511000Z', 1, '2014-12-20T21:30:21.705000Z', 2, 'Baktoid Armor Workshop', 400, 'Single Trooper Aerial Platform', 'Single Trooper Aerial Platform', 0, 'https://swapi.info/api/vehicles/36', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (37, 1800000, '1 day', 200000, '2014-12-19T17:20:36.373000Z', 140, '2014-12-20T21:30:21.707000Z', 210, 'Haor Chall Engineering', 587, 'C-9979 landing craft', 'C-9979 landing craft', 284, 'https://swapi.info/api/vehicles/37', 'landing craft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (38, 1600, NULL, NULL, '2014-12-19T17:37:37.924000Z', 1, '2014-12-20T21:30:21.710000Z', 15, 'Otoh Gunga Bongameken Cooperative', 85, 'Tribubble bongo', 'Tribubble bongo', 2, 'https://swapi.info/api/vehicles/38', 'submarine');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (42, 2, NULL, 4000, '2014-12-20T10:09:56.095000Z', 1, '2014-12-20T21:30:21.712000Z', 1.5, 'Razalon', 180, 'FC-20 speeder bike', 'Sith speeder', 0, 'https://swapi.info/api/vehicles/42', 'speeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (44, 200, NULL, 5750, '2014-12-20T16:24:16.026000Z', 1, '2014-12-20T21:30:21.714000Z', 3.68, 'Mobquet Swoops and Speeders', 350, 'Zephyr-G swoop bike', 'Zephyr-G swoop bike', 1, 'https://swapi.info/api/vehicles/44', 'repulsorcraft');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (45, 80, NULL, NULL, '2014-12-20T17:17:33.526000Z', 1, '2014-12-20T21:30:21.716000Z', 6.6, 'Desler Gizh Outworld Mobility Corporation', 800, 'Koro-2 Exodrive airspeeder', 'Koro-2 Exodrive airspeeder', 1, 'https://swapi.info/api/vehicles/45', 'airspeeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (46, NULL, NULL, NULL, '2014-12-20T17:19:19.991000Z', 1, '2014-12-20T21:30:21.719000Z', 6.23, 'Narglatch AirTech prefabricated kit', 720, 'XJ-6 airspeeder', 'XJ-6 airspeeder', 1, 'https://swapi.info/api/vehicles/46', 'airspeeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (50, 170, NULL, NULL, '2014-12-20T18:01:21.014000Z', 6, '2014-12-20T21:30:21.723000Z', 17.4, 'Rothana Heavy Engineering', 620, 'Low Altitude Assault Transport/infrantry', 'LAAT/i', 30, 'https://swapi.info/api/vehicles/50', 'gunship');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (51, 40000, NULL, NULL, '2014-12-20T18:02:46.802000Z', 1, '2014-12-20T21:30:21.725000Z', 28.82, 'Rothana Heavy Engineering', 620, 'Low Altitude Assault Transport/carrier', 'LAAT/c', 0, 'https://swapi.info/api/vehicles/51', 'gunship');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (53, 10000, '21 days', NULL, '2014-12-20T18:10:07.560000Z', 6, '2014-12-20T21:30:21.728000Z', 13.2, 'Rothana Heavy Engineering, Kuat Drive Yards', 60, 'All Terrain Tactical Enforcer', 'AT-TE', 36, 'https://swapi.info/api/vehicles/53', 'walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (54, 500, '7 days', NULL, '2014-12-20T18:12:32.315000Z', 25, '2014-12-20T21:30:21.731000Z', 140, 'Rothana Heavy Engineering', 35, 'Self-Propelled Heavy Artillery', 'SPHA', 30, 'https://swapi.info/api/vehicles/54', 'walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (55, NULL, NULL, 8000, '2014-12-20T18:15:20.312000Z', 1, '2014-12-20T21:30:21.735000Z', 2, 'Huppla Pasa Tisc Shipwrights Collective', 634, 'Flitknot speeder', 'Flitknot speeder', 0, 'https://swapi.info/api/vehicles/55', 'speeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (56, 1000, '7 days', NULL, '2014-12-20T18:25:44.912000Z', 2, '2014-12-20T21:30:21.739000Z', 20, 'Haor Chall Engineering', 880, 'Sheathipede-class transport shuttle', 'Neimoidian shuttle', 6, 'https://swapi.info/api/vehicles/56', 'transport');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (57, NULL, NULL, NULL, '2014-12-20T18:34:12.541000Z', 1, '2014-12-20T21:30:21.742000Z', 9.8, 'Huppla Pasa Tisc Shipwrights Collective', 20000, 'Nantex-class territorial defense', 'Geonosian starfighter', 0, 'https://swapi.info/api/vehicles/57', 'starfighter');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (60, 10, NULL, 15000, '2014-12-20T19:43:54.870000Z', 1, '2014-12-20T21:30:21.745000Z', 3.5, 'Z-Gomot Ternbuell Guppat Corporation', 330, 'Tsmeu-6 personal wheel bike', 'Tsmeu-6 personal wheel bike', 1, 'https://swapi.info/api/vehicles/60', 'wheeled walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (62, NULL, NULL, NULL, '2014-12-20T19:50:58.559000Z', 2, '2014-12-20T21:30:21.749000Z', NULL, NULL, NULL, 'Fire suppression speeder', 'Emergency Firespeeder', NULL, 'https://swapi.info/api/vehicles/62', 'fire suppression ship');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (67, 0, NULL, 20000, '2014-12-20T20:05:19.992000Z', 1, '2014-12-20T21:30:21.752000Z', 5.4, 'Colla Designs, Phlac-Arphocc Automata Industries', 1180, 'tri-fighter', 'Droid tri-fighter', 0, 'https://swapi.info/api/vehicles/67', 'droid starfighter');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (69, 50, '3 days', 12125, '2014-12-20T20:20:53.931000Z', 2, '2014-12-20T21:30:21.756000Z', 15.1, 'Appazanna Engineering Works', 420, 'Oevvaor jet catamaran', 'Oevvaor jet catamaran', 2, 'https://swapi.info/api/vehicles/69', 'airspeeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (70, 20, NULL, 14750, '2014-12-20T20:21:55.648000Z', 2, '2014-12-20T21:30:21.759000Z', 7, 'Appazanna Engineering Works', 310, 'Raddaugh Gnasp fluttercraft', 'Raddaugh Gnasp fluttercraft', 0, 'https://swapi.info/api/vehicles/70', 'air speeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (71, 30000, '20 days', 350000, '2014-12-20T20:24:45.587000Z', 20, '2014-12-20T21:30:21.762000Z', 49.4, 'Kuat Drive Yards', 160, 'HAVw A6 Juggernaut', 'Clone turbo tank', 300, 'https://swapi.info/api/vehicles/71', 'wheeled walker');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (72, NULL, NULL, 49000, '2014-12-20T20:26:55.522000Z', 0, '2014-12-20T21:30:21.765000Z', 10.96, 'Techno Union', 100, 'NR-N99 Persuader-class droid enforcer', 'Corporate Alliance tank droid', 4, 'https://swapi.info/api/vehicles/72', 'droid tank');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (73, 0, NULL, 60000, '2014-12-20T20:32:05.687000Z', 0, '2014-12-20T21:30:21.768000Z', 12.3, 'Baktoid Fleet Ordnance, Haor Chall Engineering', 820, 'HMP droid gunship', 'Droid gunship', 0, 'https://swapi.info/api/vehicles/73', 'airspeeder');
INSERT INTO vehicles (id, cargo_capacity, consumables, cost_in_credits, created, crew, edited, length, manufacturer, max_atmosphering_speed, model, name, passengers, url, vehicle_class) VALUES (76, 20, '1 day', 40000, '2014-12-20T20:47:49.189000Z', 1, '2014-12-20T21:30:21.772000Z', 3.2, 'Kuat Drive Yards', 90, 'All Terrain Recon Transport', 'AT-RT', 0, 'https://swapi.info/api/vehicles/76', 'walker');

-- Insert data into starships
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (2, 60, 3000000, '1 year', 3500000, '2014-12-10T14:20:33.369000Z', 30, '2014-12-20T21:23:49.867000Z', 2.0, 150, 'Corellian Engineering Corporation', 950, 'CR90 corvette', 'CR90 corvette', 600, 'corvette', 'https://swapi.info/api/starships/2');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (3, 60, 36000000, '2 years', 150000000, '2014-12-10T15:08:19.848000Z', 47060, '2014-12-20T21:23:49.870000Z', 2.0, 1600, 'Kuat Drive Yards', 975, 'Imperial I-class Star Destroyer', 'Star Destroyer', NULL, 'Star Destroyer', 'https://swapi.info/api/starships/3');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (5, 70, 180000, '1 month', 240000, '2014-12-10T15:48:00.586000Z', 5, '2014-12-20T21:23:49.873000Z', 1.0, 38, 'Sienar Fleet Systems, Cygnus Spaceworks', 1000, 'Sentinel-class landing craft', 'Sentinel-class landing craft', 75, 'landing craft', 'https://swapi.info/api/starships/5');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (9, 10, 1000000000000, '3 years', 1000000000000, '2014-12-10T16:36:50.509000Z', 342953, '2014-12-20T21:26:24.783000Z', 4.0, 120000, 'Imperial Department of Military Research, Sienar Fleet Systems', NULL, 'DS-1 Orbital Battle Station', 'Death Star', 843342, 'Deep Space Mobile Battlestation', 'https://swapi.info/api/starships/9');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (10, 75, 100000, '2 months', 100000, '2014-12-10T16:59:45.094000Z', 4, '2014-12-20T21:23:49.880000Z', 0.5, 34.37, 'Corellian Engineering Corporation', 1050, 'YT-1300 light freighter', 'Millennium Falcon', 6, 'Light freighter', 'https://swapi.info/api/starships/10');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (11, 80, 110, '1 week', 134999, '2014-12-12T11:00:39.817000Z', 2, '2014-12-20T21:23:49.883000Z', 1.0, 14, 'Koensayr Manufacturing', NULL, 'BTL Y-wing', 'Y-wing', 0, 'assault starfighter', 'https://swapi.info/api/starships/11');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (12, 100, 110, '1 week', 149999, '2014-12-12T11:19:05.340000Z', 1, '2014-12-20T21:23:49.886000Z', 1.0, 12.5, 'Incom Corporation', 1050, 'T-65 X-wing', 'X-wing', 0, 'Starfighter', 'https://swapi.info/api/starships/12');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (13, 105, 150, '5 days', NULL, '2014-12-12T11:21:32.991000Z', 1, '2014-12-20T21:23:49.889000Z', 1.0, 9.2, 'Sienar Fleet Systems', 1200, 'Twin Ion Engine Advanced x1', 'TIE Advanced x1', 0, 'Starfighter', 'https://swapi.info/api/starships/13');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (15, 40, 250000000, '6 years', 1143350000, '2014-12-15T12:31:42.547000Z', 279144, '2014-12-20T21:23:49.893000Z', 2.0, 19000, 'Kuat Drive Yards, Fondor Shipyards', NULL, 'Executor-class star dreadnought', 'Executor', 38000, 'Star dreadnought', 'https://swapi.info/api/starships/15');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (17, 20, 19000000, '6 months', NULL, '2014-12-15T12:34:52.264000Z', 6, '2014-12-20T21:23:49.895000Z', 4.0, 90, 'Gallofree Yards, Inc.', 650, 'GR-75 medium transport', 'Rebel transport', 90, 'Medium transport', 'https://swapi.info/api/starships/17');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (21, 70, 70000, '1 month', NULL, '2014-12-15T13:00:56.332000Z', 1, '2014-12-20T21:23:49.897000Z', 3.0, 21.5, 'Kuat Systems Engineering', 1000, 'Firespray-31-class patrol and attack', 'Slave 1', 6, 'Patrol craft', 'https://swapi.info/api/starships/21');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (22, 50, 80000, '2 months', 240000, '2014-12-15T13:04:47.235000Z', 6, '2014-12-20T21:23:49.900000Z', 1.0, 20, 'Sienar Fleet Systems', 850, 'Lambda-class T-4a shuttle', 'Imperial shuttle', 20, 'Armed government transport', 'https://swapi.info/api/starships/22');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (23, 40, 6000000, '2 years', 8500000, '2014-12-15T13:06:30.813000Z', 854, '2014-12-20T21:23:49.902000Z', 2.0, 300, 'Kuat Drive Yards', 800, 'EF76 Nebulon-B escort frigate', 'EF76 Nebulon-B escort frigate', 75, 'Escort ship', 'https://swapi.info/api/starships/23');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (27, 60, NULL, '2 years', 104000000, '2014-12-18T10:54:57.804000Z', 5400, '2014-12-20T21:23:49.904000Z', 1.0, 1200, 'Mon Calamari shipyards', NULL, 'MC80 Liberty type Star Cruiser', 'Calamari Cruiser', 1200, 'Star Cruiser', 'https://swapi.info/api/starships/27');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (28, 120, 40, '1 week', 175000, '2014-12-18T11:16:34.542000Z', 1, '2014-12-20T21:23:49.907000Z', 1.0, 9.6, 'Alliance Underground Engineering, Incom Corporation', 1300, 'RZ-1 A-wing Interceptor', 'A-wing', 0, 'Starfighter', 'https://swapi.info/api/starships/28');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (29, 91, 45, '1 week', 220000, '2014-12-18T11:18:04.763000Z', 1, '2014-12-20T21:23:49.909000Z', 2.0, 16.9, 'Slayn & Korpil', 950, 'A/SF-01 B-wing starfighter', 'B-wing', 0, 'Assault Starfighter', 'https://swapi.info/api/starships/29');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (31, NULL, NULL, NULL, NULL, '2014-12-19T17:01:31.488000Z', 9, '2014-12-20T21:23:49.912000Z', 2.0, 115, 'Corellian Engineering Corporation', 900, 'Consular-class cruiser', 'Republic Cruiser', 16, 'Space cruiser', 'https://swapi.info/api/starships/31');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (32, NULL, 4000000000, '500 days', NULL, '2014-12-19T17:04:06.323000Z', 175, '2014-12-20T21:23:49.915000Z', 2.0, 3170, 'Hoersch-Kessel Drive, Inc.', NULL, 'Lucrehulk-class Droid Control Ship', 'Droid control ship', 139000, 'Droid control ship', 'https://swapi.info/api/starships/32');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (39, NULL, 65, '7 days', 200000, '2014-12-19T17:39:17.582000Z', 1, '2014-12-20T21:23:49.917000Z', 1.0, 11, 'Theed Palace Space Vessel Engineering Corps', 1100, 'N-1 starfighter', 'Naboo fighter', 0, 'Starfighter', 'https://swapi.info/api/starships/39');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (40, NULL, NULL, NULL, NULL, '2014-12-19T17:45:03.506000Z', 8, '2014-12-20T21:23:49.919000Z', 1.8, 76, 'Theed Palace Space Vessel Engineering Corps, Nubia Star Drives', 920, 'J-type 327 Nubian royal starship', 'Naboo Royal Starship', NULL, 'yacht', 'https://swapi.info/api/starships/40');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (41, NULL, 2500000, '30 days', 55000000, '2014-12-20T09:39:56.116000Z', 1, '2014-12-20T21:23:49.922000Z', 1.5, 26.5, 'Republic Sienar Systems', 1180, 'Star Courier', 'Scimitar', 6, 'Space Transport', 'https://swapi.info/api/starships/41');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (43, NULL, NULL, '1 year', 2000000, '2014-12-20T11:05:51.237000Z', 5, '2014-12-20T21:23:49.925000Z', 0.7, 39, 'Theed Palace Space Vessel Engineering Corps, Nubia Star Drives', 2000, 'J-type diplomatic barge', 'J-type diplomatic barge', 10, 'Diplomatic barge', 'https://swapi.info/api/starships/43');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (47, NULL, NULL, NULL, NULL, '2014-12-20T17:24:23.509000Z', NULL, '2014-12-20T21:23:49.928000Z', NULL, 390, 'Botajef Shipyards', NULL, 'Botajef AA-9 Freighter-Liner', 'AA-9 Coruscant freighter', 30000, 'freighter', 'https://swapi.info/api/starships/47');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (48, NULL, 60, '7 days', 180000, '2014-12-20T17:35:23.906000Z', 1, '2014-12-20T21:23:49.930000Z', 1.0, 8, 'Kuat Systems Engineering', 1150, 'Delta-7 Aethersprite-class interceptor', 'Jedi starfighter', 0, 'Starfighter', 'https://swapi.info/api/starships/48');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (49, NULL, NULL, NULL, NULL, '2014-12-20T17:46:46.847000Z', 4, '2014-12-20T21:23:49.932000Z', 0.9, 47.9, 'Theed Palace Space Vessel Engineering Corps', 8000, 'H-type Nubian yacht', 'H-type Nubian yacht', NULL, 'yacht', 'https://swapi.info/api/starships/49');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (52, NULL, 11250000, '2 years', NULL, '2014-12-20T18:08:42.926000Z', 700, '2014-12-20T21:23:49.935000Z', 0.6, 752, 'Rothana Heavy Engineering', NULL, 'Acclamator I-class assault ship', 'Republic Assault ship', 16000, 'assault ship', 'https://swapi.info/api/starships/52');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (58, NULL, 240, '7 days', 35700, '2014-12-20T18:37:56.969000Z', 3, '2014-12-20T21:23:49.937000Z', 1.5, 15.2, 'Huppla Pasa Tisc Shipwrights Collective', 1600, 'Punworcca 116-class interstellar sloop', 'Solar Sailer', 11, 'yacht', 'https://swapi.info/api/starships/58');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (59, NULL, 50000000, '4 years', 125000000, '2014-12-20T19:40:21.902000Z', 600, '2014-12-20T21:23:49.941000Z', 1.5, 1088, 'Rendili StarDrive, Free Dac Volunteers Engineering corps.', 1050, 'Providence-class carrier/destroyer', 'Trade Federation cruiser', 48247, 'capital ship', 'https://swapi.info/api/starships/59');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (61, NULL, 50000, '56 days', 1000000, '2014-12-20T19:48:40.409000Z', 5, '2014-12-20T21:23:49.944000Z', 1.0, 18.5, 'Cygnus Spaceworks', 2000, 'Theta-class T-2c shuttle', 'Theta-class T-2c shuttle', 16, 'transport', 'https://swapi.info/api/starships/61');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (63, NULL, 20000000, '2 years', 59000000, '2014-12-20T19:52:56.232000Z', 7400, '2014-12-20T21:23:49.946000Z', 1.0, 1137, 'Kuat Drive Yards, Allanteen Six shipyards', 975, 'Senator-class Star Destroyer', 'Republic attack cruiser', 2000, 'star destroyer', 'https://swapi.info/api/starships/63');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (64, NULL, NULL, NULL, NULL, '2014-12-20T19:55:15.396000Z', 3, '2014-12-20T21:23:49.948000Z', 0.5, 29.2, 'Theed Palace Space Vessel Engineering Corps/Nubia Star Drives, Incorporated', 1050, 'J-type star skiff', 'Naboo star skiff', 3, 'yacht', 'https://swapi.info/api/starships/64');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (65, NULL, 60, '2 days', 320000, '2014-12-20T19:56:57.468000Z', 1, '2014-12-20T21:23:49.951000Z', 1.0, 5.47, 'Kuat Systems Engineering', 1500, 'Eta-2 Actis-class light interceptor', 'Jedi Interceptor', 0, 'starfighter', 'https://swapi.info/api/starships/65');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (66, 100, 110, '5 days', 155000, '2014-12-20T20:03:48.603000Z', 3, '2014-12-20T21:23:49.953000Z', 1.0, 14.5, 'Incom Corporation, Subpro Corporation', 1000, 'Aggressive Reconnaissance-170 starfighte', 'arc-170', 0, 'starfighter', 'https://swapi.info/api/starships/66');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (68, NULL, 40000000, '2 years', 57000000, '2014-12-20T20:07:11.538000Z', 200, '2014-12-20T21:23:49.956000Z', 1.0, 825, 'Hoersch-Kessel Drive, Inc, Gwori Revolutionary Industries', NULL, 'Munificent-class star frigate', 'Banking clan frigte', NULL, 'cruiser', 'https://swapi.info/api/starships/68');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (74, NULL, 140, '7 days', 168000, '2014-12-20T20:38:05.031000Z', 1, '2014-12-20T21:23:49.959000Z', 6, 6.71, 'Feethan Ottraw Scalable Assemblies', 1100, 'Belbullab-22 starfighter', 'Belbullab-22 starfighter', 0, 'starfighter', 'https://swapi.info/api/starships/74');
INSERT INTO starships (id, MGLT, cargo_capacity, consumables, cost_in_credits, created, crew, edited, hyperdrive_rating, length, manufacturer, max_atmosphering_speed, model, name, passengers, starship_class, url) VALUES (75, NULL, 60, '15 hours', 102500, '2014-12-20T20:43:04.349000Z', 1, '2014-12-20T21:23:49.961000Z', 1.0, 7.9, 'Kuat Systems Engineering', 1050, 'Alpha-3 Nimbus-class V-wing starfighter', 'V-wing', 0, 'starfighter', 'https://swapi.info/api/starships/75');

-- JUNCTION TABLE DATA

INSERT INTO film_characters (film_id, character_id) VALUES (1, 1);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 4);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 5);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 6);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 7);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 8);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 9);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 12);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 13);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 14);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 15);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 16);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 18);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 19);
INSERT INTO film_characters (film_id, character_id) VALUES (1, 81);
INSERT INTO film_planets (film_id, planet_id) VALUES (1, 1);
INSERT INTO film_planets (film_id, planet_id) VALUES (1, 2);
INSERT INTO film_planets (film_id, planet_id) VALUES (1, 3);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 2);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 3);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 5);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 9);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 10);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 11);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 12);
INSERT INTO film_starships (film_id, starship_id) VALUES (1, 13);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (1, 4);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (1, 6);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (1, 7);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (1, 8);
INSERT INTO film_species (film_id, species_id) VALUES (1, 1);
INSERT INTO film_species (film_id, species_id) VALUES (1, 2);
INSERT INTO film_species (film_id, species_id) VALUES (1, 3);
INSERT INTO film_species (film_id, species_id) VALUES (1, 4);
INSERT INTO film_species (film_id, species_id) VALUES (1, 5);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 1);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 4);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 5);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 13);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 14);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 18);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 20);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 21);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 22);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 23);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 24);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 25);
INSERT INTO film_characters (film_id, character_id) VALUES (2, 26);
INSERT INTO film_planets (film_id, planet_id) VALUES (2, 4);
INSERT INTO film_planets (film_id, planet_id) VALUES (2, 5);
INSERT INTO film_planets (film_id, planet_id) VALUES (2, 6);
INSERT INTO film_planets (film_id, planet_id) VALUES (2, 27);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 3);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 10);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 11);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 12);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 15);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 17);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 21);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 22);
INSERT INTO film_starships (film_id, starship_id) VALUES (2, 23);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 8);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 14);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 16);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 18);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 19);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (2, 20);
INSERT INTO film_species (film_id, species_id) VALUES (2, 1);
INSERT INTO film_species (film_id, species_id) VALUES (2, 2);
INSERT INTO film_species (film_id, species_id) VALUES (2, 3);
INSERT INTO film_species (film_id, species_id) VALUES (2, 6);
INSERT INTO film_species (film_id, species_id) VALUES (2, 7);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 1);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 4);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 5);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 13);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 14);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 16);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 18);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 20);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 21);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 22);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 25);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 27);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 28);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 29);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 30);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 31);
INSERT INTO film_characters (film_id, character_id) VALUES (3, 45);
INSERT INTO film_planets (film_id, planet_id) VALUES (3, 1);
INSERT INTO film_planets (film_id, planet_id) VALUES (3, 5);
INSERT INTO film_planets (film_id, planet_id) VALUES (3, 7);
INSERT INTO film_planets (film_id, planet_id) VALUES (3, 8);
INSERT INTO film_planets (film_id, planet_id) VALUES (3, 9);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 2);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 3);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 10);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 11);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 12);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 15);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 17);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 22);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 23);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 27);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 28);
INSERT INTO film_starships (film_id, starship_id) VALUES (3, 29);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 8);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 16);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 18);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 19);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 24);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 25);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 26);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (3, 30);
INSERT INTO film_species (film_id, species_id) VALUES (3, 1);
INSERT INTO film_species (film_id, species_id) VALUES (3, 2);
INSERT INTO film_species (film_id, species_id) VALUES (3, 3);
INSERT INTO film_species (film_id, species_id) VALUES (3, 5);
INSERT INTO film_species (film_id, species_id) VALUES (3, 6);
INSERT INTO film_species (film_id, species_id) VALUES (3, 8);
INSERT INTO film_species (film_id, species_id) VALUES (3, 9);
INSERT INTO film_species (film_id, species_id) VALUES (3, 10);
INSERT INTO film_species (film_id, species_id) VALUES (3, 15);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 11);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 16);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 20);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 21);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 32);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 33);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 34);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 35);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 36);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 37);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 38);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 39);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 40);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 41);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 42);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 43);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 44);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 46);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 47);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 48);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 49);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 50);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 51);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 52);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 53);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 54);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 55);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 56);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 57);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 58);
INSERT INTO film_characters (film_id, character_id) VALUES (4, 59);
INSERT INTO film_planets (film_id, planet_id) VALUES (4, 1);
INSERT INTO film_planets (film_id, planet_id) VALUES (4, 8);
INSERT INTO film_planets (film_id, planet_id) VALUES (4, 9);
INSERT INTO film_starships (film_id, starship_id) VALUES (4, 31);
INSERT INTO film_starships (film_id, starship_id) VALUES (4, 32);
INSERT INTO film_starships (film_id, starship_id) VALUES (4, 39);
INSERT INTO film_starships (film_id, starship_id) VALUES (4, 40);
INSERT INTO film_starships (film_id, starship_id) VALUES (4, 41);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 33);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 34);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 35);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 36);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 37);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 38);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (4, 42);
INSERT INTO film_species (film_id, species_id) VALUES (4, 1);
INSERT INTO film_species (film_id, species_id) VALUES (4, 2);
INSERT INTO film_species (film_id, species_id) VALUES (4, 6);
INSERT INTO film_species (film_id, species_id) VALUES (4, 11);
INSERT INTO film_species (film_id, species_id) VALUES (4, 12);
INSERT INTO film_species (film_id, species_id) VALUES (4, 13);
INSERT INTO film_species (film_id, species_id) VALUES (4, 14);
INSERT INTO film_species (film_id, species_id) VALUES (4, 15);
INSERT INTO film_species (film_id, species_id) VALUES (4, 16);
INSERT INTO film_species (film_id, species_id) VALUES (4, 17);
INSERT INTO film_species (film_id, species_id) VALUES (4, 18);
INSERT INTO film_species (film_id, species_id) VALUES (4, 19);
INSERT INTO film_species (film_id, species_id) VALUES (4, 20);
INSERT INTO film_species (film_id, species_id) VALUES (4, 21);
INSERT INTO film_species (film_id, species_id) VALUES (4, 22);
INSERT INTO film_species (film_id, species_id) VALUES (4, 23);
INSERT INTO film_species (film_id, species_id) VALUES (4, 24);
INSERT INTO film_species (film_id, species_id) VALUES (4, 25);
INSERT INTO film_species (film_id, species_id) VALUES (4, 26);
INSERT INTO film_species (film_id, species_id) VALUES (4, 27);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 6);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 7);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 11);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 20);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 21);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 22);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 33);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 35);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 36);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 40);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 43);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 46);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 51);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 52);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 53);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 58);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 59);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 60);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 61);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 62);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 63);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 64);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 65);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 66);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 67);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 68);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 69);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 70);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 71);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 72);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 73);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 74);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 75);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 76);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 77);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 78);
INSERT INTO film_characters (film_id, character_id) VALUES (5, 82);
INSERT INTO film_planets (film_id, planet_id) VALUES (5, 1);
INSERT INTO film_planets (film_id, planet_id) VALUES (5, 8);
INSERT INTO film_planets (film_id, planet_id) VALUES (5, 9);
INSERT INTO film_planets (film_id, planet_id) VALUES (5, 10);
INSERT INTO film_planets (film_id, planet_id) VALUES (5, 11);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 21);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 32);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 39);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 43);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 47);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 48);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 49);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 52);
INSERT INTO film_starships (film_id, starship_id) VALUES (5, 58);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 4);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 44);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 45);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 46);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 50);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 51);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 53);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 54);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 55);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 56);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (5, 57);
INSERT INTO film_species (film_id, species_id) VALUES (5, 1);
INSERT INTO film_species (film_id, species_id) VALUES (5, 2);
INSERT INTO film_species (film_id, species_id) VALUES (5, 6);
INSERT INTO film_species (film_id, species_id) VALUES (5, 12);
INSERT INTO film_species (film_id, species_id) VALUES (5, 13);
INSERT INTO film_species (film_id, species_id) VALUES (5, 15);
INSERT INTO film_species (film_id, species_id) VALUES (5, 28);
INSERT INTO film_species (film_id, species_id) VALUES (5, 29);
INSERT INTO film_species (film_id, species_id) VALUES (5, 30);
INSERT INTO film_species (film_id, species_id) VALUES (5, 31);
INSERT INTO film_species (film_id, species_id) VALUES (5, 32);
INSERT INTO film_species (film_id, species_id) VALUES (5, 33);
INSERT INTO film_species (film_id, species_id) VALUES (5, 34);
INSERT INTO film_species (film_id, species_id) VALUES (5, 35);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 1);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 2);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 3);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 4);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 5);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 6);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 7);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 10);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 11);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 12);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 13);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 20);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 21);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 33);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 35);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 46);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 51);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 52);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 53);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 54);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 55);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 56);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 58);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 63);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 64);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 67);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 68);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 75);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 78);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 79);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 80);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 81);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 82);
INSERT INTO film_characters (film_id, character_id) VALUES (6, 83);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 1);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 2);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 5);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 8);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 9);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 12);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 13);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 14);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 15);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 16);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 17);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 18);
INSERT INTO film_planets (film_id, planet_id) VALUES (6, 19);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 2);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 32);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 48);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 59);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 61);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 63);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 64);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 65);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 66);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 68);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 74);
INSERT INTO film_starships (film_id, starship_id) VALUES (6, 75);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 33);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 50);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 53);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 56);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 60);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 62);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 67);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 69);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 70);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 71);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 72);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 73);
INSERT INTO film_vehicles (film_id, vehicle_id) VALUES (6, 76);
INSERT INTO film_species (film_id, species_id) VALUES (6, 1);
INSERT INTO film_species (film_id, species_id) VALUES (6, 2);
INSERT INTO film_species (film_id, species_id) VALUES (6, 3);
INSERT INTO film_species (film_id, species_id) VALUES (6, 6);
INSERT INTO film_species (film_id, species_id) VALUES (6, 15);
INSERT INTO film_species (film_id, species_id) VALUES (6, 19);
INSERT INTO film_species (film_id, species_id) VALUES (6, 20);
INSERT INTO film_species (film_id, species_id) VALUES (6, 23);
INSERT INTO film_species (film_id, species_id) VALUES (6, 24);
INSERT INTO film_species (film_id, species_id) VALUES (6, 25);
INSERT INTO film_species (film_id, species_id) VALUES (6, 26);
INSERT INTO film_species (film_id, species_id) VALUES (6, 27);
INSERT INTO film_species (film_id, species_id) VALUES (6, 28);
INSERT INTO film_species (film_id, species_id) VALUES (6, 29);
INSERT INTO film_species (film_id, species_id) VALUES (6, 30);
INSERT INTO film_species (film_id, species_id) VALUES (6, 33);
INSERT INTO film_species (film_id, species_id) VALUES (6, 34);
INSERT INTO film_species (film_id, species_id) VALUES (6, 35);
INSERT INTO film_species (film_id, species_id) VALUES (6, 36);
INSERT INTO film_species (film_id, species_id) VALUES (6, 37);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (1, 14);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (1, 30);
INSERT INTO character_starships (character_id, starship_id) VALUES (1, 12);
INSERT INTO character_starships (character_id, starship_id) VALUES (1, 22);
INSERT INTO character_starships (character_id, starship_id) VALUES (4, 13);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (5, 30);
INSERT INTO character_starships (character_id, starship_id) VALUES (9, 12);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (10, 38);
INSERT INTO character_starships (character_id, starship_id) VALUES (10, 48);
INSERT INTO character_starships (character_id, starship_id) VALUES (10, 59);
INSERT INTO character_starships (character_id, starship_id) VALUES (10, 64);
INSERT INTO character_starships (character_id, starship_id) VALUES (10, 65);
INSERT INTO character_starships (character_id, starship_id) VALUES (10, 74);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (11, 44);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (11, 46);
INSERT INTO character_starships (character_id, starship_id) VALUES (11, 39);
INSERT INTO character_starships (character_id, starship_id) VALUES (11, 59);
INSERT INTO character_starships (character_id, starship_id) VALUES (11, 65);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (13, 19);
INSERT INTO character_starships (character_id, starship_id) VALUES (13, 10);
INSERT INTO character_starships (character_id, starship_id) VALUES (13, 22);
INSERT INTO character_starships (character_id, starship_id) VALUES (14, 10);
INSERT INTO character_starships (character_id, starship_id) VALUES (14, 22);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (18, 14);
INSERT INTO character_starships (character_id, starship_id) VALUES (18, 12);
INSERT INTO character_starships (character_id, starship_id) VALUES (19, 12);
INSERT INTO character_starships (character_id, starship_id) VALUES (22, 21);
INSERT INTO character_starships (character_id, starship_id) VALUES (25, 10);
INSERT INTO character_starships (character_id, starship_id) VALUES (29, 28);
INSERT INTO character_starships (character_id, starship_id) VALUES (31, 10);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (32, 38);
INSERT INTO character_starships (character_id, starship_id) VALUES (35, 39);
INSERT INTO character_starships (character_id, starship_id) VALUES (35, 49);
INSERT INTO character_starships (character_id, starship_id) VALUES (35, 64);
INSERT INTO character_starships (character_id, starship_id) VALUES (39, 40);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (44, 42);
INSERT INTO character_starships (character_id, starship_id) VALUES (44, 41);
INSERT INTO character_starships (character_id, starship_id) VALUES (58, 48);
INSERT INTO character_starships (character_id, starship_id) VALUES (60, 39);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (67, 55);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (70, 45);
INSERT INTO character_vehicles (character_id, vehicle_id) VALUES (79, 60);
INSERT INTO character_starships (character_id, starship_id) VALUES (79, 74);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (14, 1);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (14, 18);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (19, 13);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (30, 1);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (30, 5);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (38, 10);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (38, 32);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (42, 44);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (44, 11);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (45, 70);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (46, 11);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (55, 67);
INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES (60, 79);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (10, 13);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (10, 14);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (10, 25);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (10, 31);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (12, 1);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (12, 9);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (12, 18);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (12, 19);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (13, 4);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (21, 22);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (22, 1);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (22, 13);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (22, 14);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (28, 29);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (39, 11);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (39, 35);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (39, 60);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (40, 39);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (41, 44);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (48, 10);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (48, 58);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (49, 35);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (59, 10);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (59, 11);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (64, 10);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (64, 35);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (65, 10);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (65, 11);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (74, 10);
INSERT INTO starship_pilots (starship_id, character_id) VALUES (74, 79);

-- USEFUL VIEWS AND QUERIES

-- USEFUL VIEWS

-- View: Expensive starships with details
CREATE VIEW expensive_starships AS
SELECT 
    name,
    model,
    starship_class,
    cost_in_credits,
    manufacturer
FROM starships 
WHERE cost_in_credits IS NOT NULL 
  AND cost_in_credits != 'unknown'
  AND CAST(cost_in_credits AS BIGINT) > 1000000
ORDER BY CAST(cost_in_credits AS BIGINT) DESC;

-- View: Film statistics
CREATE VIEW film_stats AS
SELECT 
    title,
    episode_id,
    release_date,
    director,
    producer,
    LENGTH(opening_crawl) as opening_crawl_length
FROM films
ORDER BY episode_id;

