CREATE SCHEMA demo_schema;
USE demo_schema;

CREATE TABLE employee (
    employee_id NUMERIC(3,0) NOT NULL PRIMARY KEY,
    first_name STRING,
    last_name STRING,
    birthdate DATE,
    country_code STRING
);

INSERT INTO employee VALUES (1, 'John', 'Doe', '1990-01-01', 'US');

INSERT INTO employee (employee_id, first_name, last_name, birthdate, country_code)
VALUES (2, 'Jane', 'Smith', '1985-05-15', 'CA');

INSERT INTO employee (employee_id, first_name)
VALUES (3, 'Bob');

SELECT * FROM employee WHERE employee_id = 3;

INSERT INTO employee
VALUES
    (4, 'Alice', 'Johnson', '1992-07-20', 'UK'),
    (5, 'Charlie', 'Brown', '1988-12-30', 'AU'),
    (6, 'Randy', 'Caldwell', '1970-01-02', 'FI');

SELECT * FROM employee;

INSERT INTO employee VALUES (RANDOM() * 1000, 'John', 'Doe', '1990-01-01', 'JP');

INSERT INTO employee
SELECT RANDOM() * 1000, 'Hirota', 'Shigeru', '1990-01-01', 'JP';

SELECT * FROM employee;

DROP TABLE employee;
DROP SCHEMA demo_schema;