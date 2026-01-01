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

## Features

- **DuckDB** for fast, in-process SQL queries
- **Poetry** for dependency management and isolated virtual environment
- **Structured Learning Path** with 6 progressive sections
- **TPC-H Database** for realistic business scenarios
- **Star Wars Database** for engaging practice examples
- **Interactive SQL Runner** with command-line interface
- **Comprehensive Exercises** covering DDL, DML, DQL, and advanced topics

## Course Structure

*Adapted from the original Udemy course with DuckDB-specific examples and enhanced exercises*

### Section 2: SQL Introduction
- SQL anatomy and basic syntax

### Section 3: Data Definition Language (DDL)
- CREATE, ALTER, DROP statements
- Database and schema management
- Table structure operations

### Section 4: Data Manipulation Language (DML)
- INSERT, UPDATE, DELETE operations
- COPY FROM for data loading
- MERGE statements
- TRUNCATE operations

### Section 5: Data Query Language (DQL)
- SELECT statements and filtering
- Aggregate and scalar functions
- GROUP BY and HAVING clauses
- ORDER BY sorting

### Section 6: Intermediate DQL
- **JOINs** - Inner, outer, and cross joins
- **Subqueries** - Correlated and uncorrelated
- **Set Operators** - UNION, INTERSECT, EXCEPT
- **TPC-H Analysis** - Real-world business scenarios

### Section 7: Query Performance Tuning *(Enhanced)*
- **EXPLAIN** - Query execution plan analysis
- **JOIN Optimization** - Advanced join techniques and CTEs
- **ORDER BY Optimization** - Sorting performance and LIMIT strategies
- **GROUP BY Optimization** - Aggregation and cardinality considerations

### Section 8: Advanced SQL Concepts *(In Progress)*
- **Window Functions** - Analytical functions and partitioning ✅
- **CTEs** - Common Table Expressions and recursive queries ✅
- **Transactions** - ACID properties and transaction management

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

*See [data/README.md](data/README.md) for detailed information about all data sources, including CSV, JSON, and Parquet files.*

## Running Exercises

### Using the SQL Runner (Recommended)
```bash
# Run a specific exercise
poetry run python run_sql.py exercises/section-5-dql/select-where.sql

# Interactive exploration
poetry run python sql_runner.py -i
```

### Using DuckDB CLI Directly
```bash
# TPC-H exercises
duckdb data/tpc-h.db < exercises/section-6-dql-intermediate/subqueries.sql

# Star Wars exercises  
duckdb data/starwars.db < exercises/section-5-dql/select-where.sql
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

## Learning Path

1. **Start with Section 2** - Learn SQL basics and syntax
2. **Master DDL (Section 3)** - Understand database structure
3. **Practice DML (Section 4)** - Learn data manipulation
4. **Explore DQL (Section 5)** - Master data querying
5. **Advanced DQL (Section 6)** - JOINs, subqueries, and set operations
6. **Performance Tuning (Section 7)** - Query optimization and EXPLAIN analysis
7. **Advanced Concepts (Section 8)** - Window functions, CTEs, and transactions

## Course Progress

- ✅ **Sections 2-7**: Complete with enhanced DuckDB examples
- 🔄 **Section 8**: Window Functions ✅, CTEs ✅, Transactions (in progress)
- 📋 **Section 9**: Semi-structured data (upcoming)

## Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [DuckDB SQL Reference](https://duckdb.org/docs/sql/introduction)
- [TPC-H Benchmark Specification](http://www.tpc.org/tpch/)
- [SQL Runner Guide](docs/SQL_RUNNER_GUIDE.md)
- [The Ultimate SQL Bootcamp (Udemy)](https://www.udemy.com/course/the-ultimate-sql-bootcamp/) - **Original course by Tom Bailey** (Highly Recommended!)

## Repository Structure

- **`exercises/`** - DuckDB-adapted practice exercises organized by section
- **`data/`** - All data sources (databases, CSV, JSON, Parquet files)
- **`docs/`** - Documentation and setup guides
- **`tools/`** - Data generation and utility scripts
