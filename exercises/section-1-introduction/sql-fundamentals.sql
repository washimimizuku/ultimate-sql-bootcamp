-- SQL FUNDAMENTALS - Understanding Databases and SQL
-- This file introduces core concepts needed before writing any SQL code
-- ============================================
-- REQUIRED: This file uses the Star Wars database
-- Run with: duckdb data/databases/starwars.db < exercises/section-1-introduction/sql-fundamentals.sql
-- ============================================

-- WHAT IS SQL?
-- SQL (Structured Query Language) is a standardized language for managing data in relational databases
-- Think of it as a way to ask questions about data stored in organized tables

-- DATABASE vs SPREADSHEET THINKING:
-- 
-- SPREADSHEET (Excel/Google Sheets):
-- - Data in cells arranged in rows and columns
-- - You can see all data at once
-- - Manual calculations and formatting
-- - Good for small datasets and analysis
--
-- DATABASE:
-- - Data in tables with defined structure
-- - You query to see specific data
-- - Automated calculations and rules
-- - Designed for large datasets and multiple users

-- BASIC DATABASE TERMINOLOGY:
-- - DATABASE: Collection of related tables (like a filing cabinet)
-- - TABLE: Collection of related data (like a spreadsheet sheet)
-- - ROW/RECORD: Single entry in a table (like a spreadsheet row)
-- - COLUMN/FIELD: Attribute of data (like a spreadsheet column)
-- - QUERY: Question you ask the database using SQL

-- DUCKDB INTRODUCTION:
-- DuckDB is an analytical database that's:
-- - Fast for analysis and reporting
-- - Easy to use (no server setup required)
-- - Great for learning SQL
-- - Compatible with standard SQL

-- Let's see what we're working with - a simple query to understand our data
-- This shows we have a database with information about Star Wars characters
SELECT 'Welcome to SQL!' as greeting;

-- This query shows how many characters are in our database
-- Don't worry about understanding the syntax yet - we'll learn that next
SELECT COUNT(*) as total_characters FROM characters;

-- This gives us a peek at what kind of data we have
-- Again, focus on the results, not the syntax
SELECT name, eye_color, hair_color FROM characters LIMIT 5;

-- KEY TAKEAWAYS:
-- 1. SQL lets us ask specific questions about data
-- 2. We get back exactly what we ask for (no more, no less)
-- 3. Data is organized in tables with rows and columns
-- 4. We can count, filter, and organize data automatically
-- 5. Results are always in a structured format

-- NEXT STEPS:
-- Now that you understand what databases and SQL are for,
-- let's learn how to write your first queries in the next file!