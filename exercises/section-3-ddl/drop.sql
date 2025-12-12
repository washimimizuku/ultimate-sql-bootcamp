-- Create things to be dropped
CREATE SCHEMA demo_schema;
USE demo_schema;

CREATE TABLE employees (
    employee_id NUMERIC NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

SHOW TABLES;
DESCRIBE employees;

-- Drop
DROP TABLE employees;
DROP SCHEMA demo_schema;

-- Verify cleanup
SHOW TABLES;
