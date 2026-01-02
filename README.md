# Ultimate SQL Bootcamp - Practice Environment

A comprehensive SQL learning environment using DuckDB and Python, featuring structured exercises from basic to advanced SQL concepts.

**Based on**: [The Ultimate SQL Bootcamp](https://www.udemy.com/course/the-ultimate-sql-bootcamp/) by **Tom Bailey** on Udemy, adapted for DuckDB with enhanced examples and additional practice exercises.

## About This Course & Adaptation

### Original Course Recommendation

**I highly recommend taking Tom Bailey's original course on Udemy** - it's an excellent resource for learning SQL, especially if you're working with **Snowflake**. Tom's teaching style is clear, practical, and covers real-world scenarios that you'll encounter in data analytics and engineering roles.

### This Adaptation

This repository adapts Tom Bailey's Snowflake-focused course content to work with **DuckDB**, providing:

- **Local Development**: No cloud setup required - everything runs locally
- **Enhanced Examples**: Additional practice exercises and real-world scenarios  
- **Multiple Data Sources**: TPC-H business data, Star Wars universe, and Titanic dataset
- **Extended Coverage**: Query optimization techniques and performance analysis
- **Open Source**: Free alternative to expensive cloud data warehouses

## Key Features

- **DuckDB** for fast, in-process SQL queries
- **Poetry** for dependency management and isolated virtual environment
- **Structured Learning Path** with 8 progressive sections
- **Multiple Data Formats** - SQL databases, CSV, JSON, and Parquet files
- **TPC-H Database** for realistic business scenarios
- **Star Wars Database** for engaging practice examples
- **Semi-Structured Data** - Comprehensive examples for modern data formats
- **Interactive SQL Runner** with command-line interface
- **Comprehensive Exercises** covering DDL, DML, DQL, and advanced topics
- **Performance Optimization** - Query tuning and EXPLAIN analysis
- **Complex Data Structures** - Nested JSON hierarchies and Parquet STRUCT/ARRAY/MAP types

## Course Structure

*Adapted from the original Udemy course with DuckDB-specific examples and enhanced exercises*

### Section 1: SQL Introduction
- SQL anatomy and basic syntax

### Section 2: Data Definition Language (DDL)
- CREATE, ALTER, DROP statements
- Database and schema management
- Table structure operations

### Section 3: Data Manipulation Language (DML)
- INSERT, UPDATE, DELETE operations
- COPY FROM for data loading
- MERGE statements
- TRUNCATE operations

### Section 4: Data Query Language (DQL)
- SELECT statements and filtering
- Aggregate and scalar functions
- GROUP BY and HAVING clauses
- ORDER BY sorting

### Section 5: Intermediate DQL
- **JOINs** - Inner, outer, and cross joins
- **Subqueries** - Correlated and uncorrelated
- **Set Operators** - UNION, INTERSECT, EXCEPT
- **TPC-H Analysis** - Real-world business scenarios

### Section 6: Query Performance Tuning *(Enhanced)*
- **EXPLAIN** - Query execution plan analysis
- **JOIN Optimization** - Advanced join techniques and CTEs
- **ORDER BY Optimization** - Sorting performance and LIMIT strategies
- **GROUP BY Optimization** - Aggregation and cardinality considerations

### Section 7: Advanced SQL Concepts *(Complete)*
- **Window Functions** - Analytical functions and partitioning ✅
- **CTEs** - Common Table Expressions and recursive queries ✅
- **Transactions** - ACID properties and transaction management ✅

### Section 8: Semi-Structured Data *(Complete)*
- **CSV Data** - Reading, processing, and analyzing CSV files ✅
- **JSON Data** - Complex JSON structures and hierarchy traversal ✅
- **Parquet Data** - Columnar storage with nested data structures ✅

## Prerequisites

- Python 3.8 or higher
- Poetry (install from https://python-poetry.org/docs/#installation)

## Quick Start

```bash
# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies
poetry install

# Install DuckDB CLI (optional, for direct database access)
brew install duckdb

# Setup TPC-H database
poetry run python sql_runner.py --setup

# Start interactive mode
poetry run python sql_runner.py -i
```

See [docs/SETUP.md](docs/SETUP.md) for detailed setup instructions and [docs/SQL_RUNNER_GUIDE.md](docs/SQL_RUNNER_GUIDE.md) for usage examples.

## Available Databases

- **`data/tpc-h.db`** - TPC-H benchmark database for business analytics
- **`data/starwars.db`** - Star Wars universe data for engaging examples

## Available Data Sources

*See [data/README.md](data/README.md) for detailed information about all data sources.*

### Structured Data
- **TPC-H Database** - Business analytics with customers, orders, suppliers
- **Star Wars Database** - Characters, planets, species, starships, vehicles

### Semi-Structured Data
- **CSV Files** - Star Wars data in `data/star-wars/csv/` (5 files, 261 total records)
- **JSON Files** - Star Wars data in `data/star-wars/json/` (7 files including complex hierarchies)
- **Parquet Files** - Nested structures in `data/star-wars/parquet/` (columnar with STRUCT/ARRAY/MAP)
- **Titanic Dataset** - `data/titanic/titanic.parquet` (891 passenger records)

## Running Exercises

### Using the SQL Runner (Recommended)
```bash
# Run a specific exercise
poetry run python run_sql.py exercises/section-4-dql/select-where.sql

# Interactive exploration
poetry run python sql_runner.py -i
```

### Using DuckDB CLI Directly
```bash
# TPC-H exercises
duckdb data/tpc-h.db < exercises/section-5-dql-intermediate/subqueries.sql

# Star Wars exercises  
duckdb data/starwars.db < exercises/section-4-dql/select-where.sql
```

### Programmatic Usage
```python
import duckdb

# Connect to TPC-H database
con = duckdb.connect('data/tpc-h.db')

# Run business analytics queries
result = con.execute("""
    SELECT c.c_name, COUNT(*) as order_count
    FROM customer c
    JOIN orders o ON c.c_custkey = o.o_custkey
    GROUP BY c.c_name
    ORDER BY order_count DESC
    LIMIT 5
""").fetchall()

print(result)
con.close()
```

### Semi-Structured Data Examples
```python
# Process CSV data
result = con.execute("""
    SELECT species, COUNT(*) as character_count
    FROM read_csv('data/star-wars/csv/characters.csv')
    GROUP BY species ORDER BY character_count DESC
""").fetchall()

# Process JSON with nested structures
result = con.execute("""
    SELECT name, len(films) as film_count
    FROM read_json('data/star-wars/json/characters.json')
    WHERE len(films) > 3
""").fetchall()

# Process Parquet with complex nested data
result = con.execute("""
    SELECT name, appearance.hair_color, len(films) as films
    FROM read_parquet('data/star-wars/parquet/characters_nested.parquet')
    WHERE appearance.hair_color != 'n/a'
""").fetchall()
```

## Learning Path

1. **Start with Section 1** - Learn SQL basics and syntax
2. **Master DDL (Section 2)** - Understand database structure
3. **Practice DML (Section 3)** - Learn data manipulation
4. **Explore DQL (Section 4)** - Master data querying
5. **Advanced DQL (Section 5)** - JOINs, subqueries, and set operations
6. **Performance Tuning (Section 6)** - Query optimization and EXPLAIN analysis
7. **Advanced Concepts (Section 7)** - Window functions, CTEs, and transactions
8. **Semi-Structured Data (Section 8)** - CSV, JSON, and Parquet processing
9. **Business Intelligence (Section 9)** - Data warehousing, KPIs, time series, and reporting

## Course Progress

- ✅ **Sections 1-6**: Complete with enhanced DuckDB examples
- ✅ **Section 7**: Window Functions, CTEs, and Transactions - Complete
- ✅ **Section 8**: Semi-structured data (CSV, JSON, Parquet) - Complete
- ✅ **Section 9**: Business Intelligence & Analytics - Complete
- 📋 **Future Sections**: Additional advanced topics (as needed)

## Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [DuckDB SQL Reference](https://duckdb.org/docs/sql/introduction)
- [TPC-H Benchmark Specification](http://www.tpc.org/tpch/)
- [SQL Runner Guide](docs/SQL_RUNNER_GUIDE.md)
- [The Ultimate SQL Bootcamp (Udemy)](https://www.udemy.com/course/the-ultimate-sql-bootcamp/) - **Original course by Tom Bailey** (Highly Recommended!)

## Repository Structure

- **`exercises/`** - DuckDB-adapted practice exercises organized by section
- **`data/`** - All data sources (databases, CSV, JSON, Parquet files)
  - **`databases/`** - SQLite database files
  - **`star-wars/`** - Star Wars data in multiple formats (CSV, JSON, Parquet)
  - **`titanic/`** - Titanic dataset in Parquet format
- **`docs/`** - Documentation and setup guides
- **`tools/`** - Data generation and utility scripts
