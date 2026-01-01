-- SQL USE Examples - Switching database and schema context
-- This file demonstrates how to navigate between databases and schemas

-- USE COMMAND SYNTAX:
-- USE DATABASE <database_name>;  -- Switch to a specific database
-- USE SCHEMA <schema_name>;      -- Switch to a specific schema
-- USE <database_or_schema>;      -- Switch to database or schema (context-dependent)

-- DATABASE CONTEXT EXAMPLES
-- Check which database we're currently using
SELECT current_database();

-- Example: Creating and using a new database (commented out)
-- CREATE DATABASE DEMO_DB
-- USE DATABASE DEMO_DB;

-- Switch back to the sample database
USE sample;

-- SCHEMA CONTEXT EXAMPLES
-- Check which schema we're currently using
SELECT current_schema();

-- Create a new schema within the current database
CREATE SCHEMA demo_schema;

-- Switch to the newly created schema
USE demo_schema;
SELECT current_schema(); -- Verify we're now in demo_schema

-- Switch back to the main schema
USE main;
SELECT current_schema(); -- Verify we're back in main

-- Clean up - Remove the demo schema
DROP SCHEMA demo_schema;
