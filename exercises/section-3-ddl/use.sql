-- Databases

SELECT current_database();
-- CREATE DATABASE DEMO_DB
-- USE DATABASE DEMO_DB;
USE sample; -- Switch back to sample database

--Schemas
SELECT current_schema();
CREATE SCHEMA demo_schema; -- Create a new schema
USE demo_schema; -- Switch to the new schema
SELECT current_schema();
USE main; -- Switch back to main schema
SELECT current_schema();
DROP SCHEMA demo_schema; -- Drop the schema
