# Ultimate SQL Bootcamp - Practice Environment

A comprehensive SQL learning environment using DuckDB and Python, featuring structured exercises from basic to advanced SQL concepts.

## Features

- **DuckDB** for fast, in-process SQL queries
- **Poetry** for dependency management and isolated virtual environment
- **Structured Learning Path** with 6 progressive sections
- **TPC-H Database** for realistic business scenarios
- **Star Wars Database** for engaging practice examples
- **Interactive SQL Runner** with command-line interface
- **Comprehensive Exercises** covering DDL, DML, DQL, and advanced topics

## Course Structure

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
5. **Advanced Topics (Section 6)** - JOINs, subqueries, and set operations

## Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [DuckDB SQL Reference](https://duckdb.org/docs/sql/introduction)
- [TPC-H Benchmark Specification](http://www.tpc.org/tpch/)
- [SQL Runner Guide](docs/SQL_RUNNER_GUIDE.md)
