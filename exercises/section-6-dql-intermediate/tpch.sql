-- TPC-H Database Structure Exploration
-- This file demonstrates the structure of the TPC-H benchmark database

-- Show all tables in the database
SHOW TABLES; 

-- Describe table structures
DESCRIBE customer;   -- Customer information
DESCRIBE lineitem;   -- Order line items
DESCRIBE nation;     -- Nations/countries
DESCRIBE orders;     -- Customer orders
DESCRIBE part;       -- Parts catalog
DESCRIBE partsupp;   -- Part-supplier relationships
DESCRIBE region;     -- Geographic regions
DESCRIBE supplier;   -- Supplier information

-- Sample data queries
SELECT * FROM customer;
SELECT * FROM lineitem;
SELECT * FROM orders;
