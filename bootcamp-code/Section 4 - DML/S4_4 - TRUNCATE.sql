USE ROLE SYSADMIN;
USE WAREHOUSE XSMALL_WAREHOUSE;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;


-- Populate EMPLOYEE table

INSERT OVERWRITE INTO EMPLOYEE 
VALUES 
    (1, 'Prakash', 'Das', '1987-01-02', 'IN'),
    (2, 'Madiha', 'Bradford', '1975-10-02', 'GB'),
    (3, 'James', 'Lines', '1999-09-20', 'GB'),
    (4, 'Amar', 'Krishnan', '2002-01-02', 'IN'), 
    (5, 'Inaaya', 'Andrews', '2001-01-02', 'US'), 
    (6, 'Randy', 'Caldwell', '1970-01-02', 'FI');

-- Remove all rows from the EMPLOYEE table

TRUNCATE TABLE IF EXISTS EMPLOYEE;

SELECT *
FROM EMPLOYEE;

SELECT * 
FROM EMPLOYEE AT(STATEMENT => '01b56b68-0000-f2c7-0001-b442000353b2');

-- Restore all rows to the EMPLOYEE table

INSERT INTO EMPLOYEE
SELECT * 
FROM EMPLOYEE AT(STATEMENT => '01b56b68-0000-f2c7-0001-b442000353b2');

SELECT *
FROM EMPLOYEE;