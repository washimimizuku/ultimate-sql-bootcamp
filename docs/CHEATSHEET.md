# SQL Cheatsheet

## Basic Queries

```sql
SELECT * FROM table_name;
SELECT column1, column2 FROM table_name;
SELECT DISTINCT column FROM table_name;
```

## Filtering

```sql
WHERE column = value
WHERE column IN (value1, value2)
WHERE column BETWEEN value1 AND value2
WHERE column LIKE '%pattern%'
WHERE column IS NULL
WHERE column > 10 AND column < 20
```

## Sorting & Limiting

```sql
ORDER BY column ASC;
ORDER BY column DESC;
LIMIT 10;
OFFSET 5;
```

## Aggregations

```sql
COUNT(*), COUNT(column)
SUM(column)
AVG(column)
MIN(column), MAX(column)
GROUP BY column
HAVING COUNT(*) > 5
```

## Joins

```sql
INNER JOIN table2 ON table1.id = table2.id
LEFT JOIN table2 ON table1.id = table2.id
RIGHT JOIN table2 ON table1.id = table2.id
FULL OUTER JOIN table2 ON table1.id = table2.id
```

## Table Operations

```sql
CREATE TABLE name (id INTEGER, name VARCHAR);
DROP TABLE name;
ALTER TABLE name ADD COLUMN new_col VARCHAR;
INSERT INTO name VALUES (1, 'value');
UPDATE name SET column = value WHERE condition;
DELETE FROM name WHERE condition;
```

## Common Functions

```sql
UPPER(column), LOWER(column)
LENGTH(column)
ROUND(column, 2)
COALESCE(column, default_value)
CAST(column AS INTEGER)
CURRENT_DATE, CURRENT_TIMESTAMP
```

## Subqueries

```sql
SELECT * FROM table WHERE id IN (SELECT id FROM other_table);
SELECT *, (SELECT COUNT(*) FROM other) AS count FROM table;
```

## Window Functions

```sql
ROW_NUMBER() OVER (ORDER BY column)
RANK() OVER (PARTITION BY category ORDER BY value)
LAG(column) OVER (ORDER BY date)
LEAD(column) OVER (ORDER BY date)
```
