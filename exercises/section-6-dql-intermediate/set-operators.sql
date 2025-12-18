-- SQL SET OPERATORS Examples - Advanced Data Query Language (DQL)
-- This file demonstrates SET OPERATORS for combining results from multiple queries
-- Set operators work with compatible result sets (same number and type of columns)
-- ============================================
-- REQUIRED: This file uses the TPC-H database AND creates temporary tables
-- Setup: duckdb data/tpc-h.db < database/tpc-h.sql
-- Run with: duckdb data/tpc-h.db < exercises/section-6-dql-intermediate/set-operators.sql
-- ============================================

-- SET OPERATOR TYPES:
-- - UNION: Combines unique rows from multiple result sets (removes duplicates)
-- - UNION ALL: Combines all rows from multiple result sets (keeps duplicates)
-- - INTERSECT: Returns rows that exist in both result sets
-- - EXCEPT: Returns rows from first result set that don't exist in second

-- SET OPERATOR SYNTAX:
-- SELECT columns FROM table1 UNION SELECT columns FROM table2;        -- Unique rows only
-- SELECT columns FROM table1 UNION ALL SELECT columns FROM table2;    -- All rows including duplicates
-- SELECT columns FROM table1 INTERSECT SELECT columns FROM table2;    -- Common rows only
-- SELECT columns FROM table1 EXCEPT SELECT columns FROM table2;       -- Rows in first but not second

-- REQUIREMENTS FOR SET OPERATORS:
-- - Same number of columns in each SELECT statement
-- - Compatible data types in corresponding columns
-- - Column names taken from first SELECT statement
-- - ORDER BY can only be used on the final result

-- ============================================
-- DEMO DATA SETUP - Creating Sample Tables
-- ============================================

-- Create Star Wars ships table for demonstration
CREATE TABLE star_wars_ships (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ship_class VARCHAR(50) NOT NULL,
    first_movie VARCHAR(100) NOT NULL,
    release_date DATE NOT NULL
);

-- Create Star Trek ships table for demonstration
CREATE TABLE star_trek_ships (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ship_class VARCHAR(50) NOT NULL,
    first_movie VARCHAR(100) NOT NULL,
    release_date DATE NOT NULL
);

-- Create Battlestar Galactica ships table for demonstration
CREATE TABLE battlestar_ships (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    ship_class VARCHAR(50) NOT NULL,
    first_movie VARCHAR(100) NOT NULL,
    release_date DATE NOT NULL
);

-- Populate Star Wars ships with sample data
INSERT INTO star_wars_ships (id, name, ship_class, first_movie, release_date) VALUES
(1, 'Millennium Falcon', 'Freighter', 'A New Hope', '1977-05-25'),
(2, 'Imperial Star Destroyer', 'Destroyer', 'A New Hope', '1977-05-25'),
(3, 'Death Star', 'Battle Station', 'A New Hope', '1977-05-25'),
(4, 'X-wing Fighter', 'Fighter', 'A New Hope', '1977-05-25'),
(5, 'Slave I', 'Patrol Ship', 'The Empire Strikes Back', '1980-05-21');

-- Populate Star Trek ships with sample data
INSERT INTO star_trek_ships (id, name, ship_class, first_movie, release_date) VALUES
(1, 'USS Enterprise NCC-1701', 'Cruiser', 'Star Trek: The Motion Picture', '1979-12-07'),
(2, 'USS Reliant NCC-1864', 'Destroyer', 'Star Trek II: The Wrath of Khan', '1982-06-04'),
(3, 'Klingon Bird-of-Prey', 'Fighter', 'Star Trek III: The Search for Spock', '1984-06-01'),
(4, 'USS Excelsior NX-2000', 'Cruiser', 'Star Trek III: The Search for Spock', '1984-06-01'),
(5, 'USS Enterprise NCC-1701-A', 'Freighter', 'Star Trek IV: The Voyage Home', '1986-11-26');

-- Populate Battlestar Galactica ships with sample data
INSERT INTO battlestar_ships (id, name, ship_class, first_movie, release_date) VALUES
(1, 'Galactica', 'Battlestar', 'Battlestar Galactica', '1978-09-17'),
(2, 'Colonial Viper', 'Fighter', 'Battlestar Galactica', '1978-09-17'),
(3, 'Cylon Basestar', 'Carrier', 'Battlestar Galactica', '1978-09-17'),
(4, 'Colonial Raptor', 'Patrol Ship', 'Battlestar Galactica', '1978-09-17'),
(5, 'Resurrection Ship', 'Freighter', 'Battlestar Galactica: Razor', '2007-11-24');

-- ============================================
-- BASIC SET OPERATOR EXAMPLES
-- ============================================

-- Example 1: Basic data verification - Show sample data from two tables
SELECT 'Star Wars' as franchise, * FROM star_wars_ships
UNION
SELECT 'Star Trek' as franchise, * FROM star_trek_ships;



-- Example 2: UNION - Combines unique rows from both result sets
-- Shows id and ship_class combinations, removing any duplicates
SELECT id, ship_class FROM star_wars_ships
UNION
SELECT id, ship_class FROM star_trek_ships;

-- Example 3: UNION ALL - Combines all rows including duplicates
-- Shows all id and ship_class combinations, keeping duplicates if they exist
SELECT id, ship_class FROM star_wars_ships
UNION ALL
SELECT id, ship_class FROM star_trek_ships;

-- Example 4: INTERSECT - Finds common rows between both result sets
-- Shows only id and ship_class combinations that exist in both tables
SELECT id, ship_class FROM star_wars_ships
INTERSECT
SELECT id, ship_class FROM star_trek_ships;

-- Example 5: EXCEPT - Returns rows from first set not in second set
-- Shows id and ship_class combinations from Star Wars that don't exist in Star Trek
SELECT id, ship_class FROM star_wars_ships
EXCEPT
SELECT id, ship_class FROM star_trek_ships;

-- ============================================
-- MULTI-TABLE SET OPERATIONS
-- ============================================

-- Example 6: UNION with three tables - All franchises with unique rows
-- Combines data from all three franchises, removing duplicates
SELECT 'Star Wars' as franchise, * FROM star_wars_ships
UNION
SELECT 'Star Trek' as franchise, * FROM star_trek_ships
UNION
SELECT 'Battlestar Galactica' as franchise, * FROM battlestar_ships
ORDER BY franchise, id;

-- Example 7: UNION ALL with three tables - All franchises with all rows
-- Combines data from all three franchises, keeping all rows including duplicates
SELECT 'Star Wars' as franchise, * FROM star_wars_ships
UNION ALL
SELECT 'Star Trek' as franchise, * FROM star_trek_ships
UNION ALL
SELECT 'Battlestar Galactica' as franchise, * FROM battlestar_ships
ORDER BY franchise, id;

-- Example 8: Complex set operations - Combining UNION ALL and INTERSECT
-- Shows ship classes that appear in Battlestar Galactica and also in the combined Star Wars/Star Trek data
SELECT id, ship_class FROM star_wars_ships
UNION ALL
SELECT id, ship_class FROM star_trek_ships
INTERSECT
SELECT id, ship_class FROM battlestar_ships
ORDER BY id;

-- ============================================
-- CLEANUP - Remove temporary tables
-- ============================================
DROP TABLE star_wars_ships;
DROP TABLE star_trek_ships;
DROP TABLE battlestar_ships;

-- ============================================
-- REAL-WORLD EXAMPLES USING TPC-H DATA
-- ============================================

-- Example 9: UNION with TPC-H data - Find all entities (customers and suppliers) from GERMANY
-- Business question: "Get a unified list of all business entities (customers and suppliers) from Germany"
SELECT c.c_custkey as entity_id, c.c_name as entity_name, 'CUSTOMER' as entity_type, n.n_name as nation
FROM customer c
JOIN nation n ON c.c_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY'
UNION
SELECT s.s_suppkey as entity_id, s.s_name as entity_name, 'SUPPLIER' as entity_type, n.n_name as nation
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
WHERE n.n_name = 'GERMANY'
ORDER BY entity_type, entity_id;

-- Example 10: UNION ALL with TPC-H data - Combine suppliers from different regions
-- Business question: "Get a complete list of suppliers from AMERICA and EUROPE regions"
SELECT s.s_suppkey, s.s_name, n.n_name as nation, 'AMERICA' as region_type
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'AMERICA'
UNION ALL
SELECT s.s_suppkey, s.s_name, n.n_name as nation, 'EUROPE' as region_type
FROM supplier s
JOIN nation n ON s.s_nationkey = n.n_nationkey
JOIN region r ON n.n_regionkey = r.r_regionkey
WHERE r.r_name = 'EUROPE'
ORDER BY region_type, s_suppkey;

-- Example 11: INTERSECT with TPC-H data - Find customers with both urgent and low priority orders
-- Business question: "Which customers place both urgent and low priority orders?"
SELECT c.c_custkey, c.c_name
FROM customer AS c
JOIN orders AS o ON c.c_custkey = o.o_custkey
WHERE o.o_orderpriority = '1-URGENT'
INTERSECT
SELECT c.c_custkey, c.c_name
FROM customer AS c
JOIN orders AS o ON c.c_custkey = o.o_custkey
WHERE o.o_orderpriority = '5-LOW';

-- Example 12: EXCEPT with TPC-H data - Find parts that have never been ordered
-- Business question: "Which parts in our catalog have never been ordered by customers?"
SELECT p.p_partkey, p.p_name, p.p_type
FROM part p
EXCEPT
SELECT DISTINCT p.p_partkey, p.p_name, p.p_type
FROM part p
JOIN lineitem l ON p.p_partkey = l.l_partkey
ORDER BY p_partkey;
