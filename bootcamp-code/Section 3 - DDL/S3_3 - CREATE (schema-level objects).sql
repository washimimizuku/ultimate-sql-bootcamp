USE ROLE SYSADMIN;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;
USE WAREHOUSE XSMALL_WAREHOUSE;

-- Method 1: Simple
CREATE TABLE EMPLOYEE (
  EMP_ID NUMERIC NOT NULL, 
  EMP_FIRST_NAME STRING, 
  EMP_LAST_NAME STRING, 
  EMP_DOB DATE COMMENT 'The date of birth for an employee',
  EMP_COUNTRY_CODE STRING
);

-- Method 2: Create table as select (CTAS) syntax
CREATE TABLE EMPLOYEE_US 
AS 
  SELECT 
    * 
  FROM 
    EMPLOYEE 
  WHERE 
    EMP_COUNTRY_CODE = 'US';

-- Method 3: Template
CREATE TABLE EMPLOYEE_TEMPLATE
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    WITHIN GROUP (ORDER BY ORDER_ID)
      FROM TABLE(
        INFER_SCHEMA(
          LOCATION=>'@mystage',
          FILE_FORMAT=>'my_parquet_format'
        )
      ));

-- Method 4: Create table like syntax
CREATE TABLE EMPLOYEE_DEV LIKE EMPLOYEE;


-- Method 5: Create table clone syntax
CREATE TABLE EMPLOYEE_CLONE CLONE EMPLOYEE;
