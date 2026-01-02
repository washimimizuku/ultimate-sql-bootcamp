-- FIRST STEPS - Your First SQL Queries
-- This file guides you through writing your very first SQL queries
-- Focus on understanding what happens, not memorizing syntax yet
-- ============================================
-- REQUIRED: This file uses the Star Wars database
-- Run with: duckdb data/databases/starwars.db < exercises/section-1-introduction/first-steps.sql
-- ============================================

-- YOUR FIRST QUERY: See everything in a table
-- The * means "all columns" - it's like saying "show me everything"
SELECT * FROM characters;

-- WHOA! That's a lot of data! Let's make it manageable
-- LIMIT controls how many rows you see (like "show me just the first 5")
SELECT * FROM characters LIMIT 5;

-- Much better! Now you can actually read the results
-- Each row represents one character, each column represents one piece of information

-- Let's try a different table to see the pattern
SELECT * FROM planets LIMIT 3;

-- Notice the pattern:
-- 1. SELECT tells the database what you want to see
-- 2. FROM tells it which table to look in  
-- 3. LIMIT keeps the results manageable

-- UNDERSTANDING RESULT SETS:
-- When you run a query, you get back a "result set" - a table of answers
-- The result set has:
-- - Column headers (showing what each column represents)
-- - Rows of data (the actual answers to your question)
-- - A count of how many rows were returned

-- Let's see just specific information instead of everything
-- This asks: "Show me just the names from the characters table"
SELECT name FROM characters LIMIT 10;

-- We can ask for multiple specific columns
-- This asks: "Show me names and gender from the characters table"
SELECT name, gender FROM characters LIMIT 10;

-- READING ERROR MESSAGES:
-- Let's intentionally make a mistake to see what happens
-- Uncomment the next line to see an error (remove the -- at the beginning)
-- SELECT name FROM character_that_doesnt_exist;

-- When you see an error:
-- 1. Don't panic! Errors are normal and helpful
-- 2. Read the message - it usually tells you what's wrong
-- 3. Check your spelling (table names, column names)
-- 4. Make sure the table exists

-- SAFE EXPLORATION HABITS:
-- Always use LIMIT when exploring new data
-- This prevents accidentally displaying thousands of rows
SELECT * FROM films LIMIT 2;
SELECT * FROM species LIMIT 2;
SELECT * FROM starships LIMIT 2;

-- WHAT WE'VE LEARNED:
-- 1. SELECT * FROM table_name shows all data from a table
-- 2. LIMIT n shows only the first n rows
-- 3. SELECT column1, column2 shows only specific columns
-- 4. Error messages help you fix problems
-- 5. Always use LIMIT when exploring new data

-- PRACTICE EXERCISE:
-- Try modifying these queries:
-- 1. Change the LIMIT numbers to see more or fewer rows
-- 2. Try different table names: characters, planets, films, species, starships
-- 3. Try selecting different column combinations

-- Example practice queries (uncomment to try):
-- SELECT name FROM planets LIMIT 7;
-- SELECT title FROM films LIMIT 3;
-- SELECT name, classification FROM species LIMIT 5;

-- NEXT STEPS:
-- Now that you can write basic queries and understand results,
-- let's learn about the different types of data you'll encounter!