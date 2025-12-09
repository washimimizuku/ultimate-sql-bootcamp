USE ROLE SYSADMIN;
USE SCHEMA DEMO_DB.DEMO_SCHEMA;
USE WAREHOUSE XSMALL_WAREHOUSE;

-- Set up objects for loading Parquet file
CREATE OR REPLACE FILE FORMAT parquet_file_format
    TYPE = 'PARQUET';

CREATE OR REPLACE STAGE parquet_stage
    FILE_FORMAT = parquet_file_format;

CREATE OR REPLACE TABLE parquet_movies (
    ID STRING, 
    TITLE STRING, 
    RELEASE_DATE DATE, 
    STARS ARRAY, 
    RATINGS OBJECT
);

-- Verify Parquet file has been uploaded to stage
ls @parquet_stage;

SELECT $1 FROM @parquet_stage/imdb_movies.parquet;

SELECT
    $1:id,
    $1:title,
    $1:release_date::date
 FROM 
    @parquet_stage/imdb_movies.parquet;

-- Load Parquet data into table
COPY INTO parquet_movies
FROM 
    (SELECT
        $1:id,
        $1:title,
        $1:release_date::date,
        $1:actors,
        $1:ratings
    FROM 
        @parquet_stage/imdb_movies.parquet);

-- Top 5 movies accoring to Metacritic
SELECT 
    id, 
    title,
    release_date,
    ratings:metacritic_rating_percentage AS metacritic_rating
FROM
    parquet_movies
ORDER BY 
    metacritic_rating DESC
LIMIT 5;