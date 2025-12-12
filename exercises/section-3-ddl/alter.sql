-- Setup
CREATE SCHEMA demo_schema;
USE demo_schema;

CREATE TABLE employees (
    employee_id NUMERIC NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

DESCRIBE employees;

-- Tables
ALTER TABLE employees ADD COLUMN address STRING;
DESCRIBE employees;

ALTER TABLE employees DROP COLUMN address;
DESCRIBE employees;

ALTER TABLE employees ALTER country_code SET DATA TYPE DECIMAL(10,0);
DESCRIBE employees;

-- Cleanup

DROP TABLE employees;

DROP SCHEMA demo_schema;
