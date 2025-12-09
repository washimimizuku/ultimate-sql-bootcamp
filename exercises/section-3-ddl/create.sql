CREATE SCHEMA demo_schema;
USE demo_schema;

CREATE TABLE employees (
    employee_id NUMERIC NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

CREATE TABLE employees_us
AS
SELECT * FROM employees WHERE country_code = 'US';

DROP TABLE employees_us;
DROP TABLE employees;

DROP SCHEMA demo_schema;
