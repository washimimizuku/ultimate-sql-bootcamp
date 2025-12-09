# SQL Practice Environment with DuckDB

A lightweight SQL practice environment using DuckDB and Python.

## Features

- DuckDB for fast, in-process SQL queries
- Poetry for dependency management
- Isolated virtual environment

## Prerequisites

- Python 3.8 or higher
- Poetry (install from https://python-poetry.org/docs/#installation)

## Quick Start

See [SETUP.md](SETUP.md) for installation instructions.

## Usage

```python
import duckdb

# Create an in-memory database
con = duckdb.connect(':memory:')

# Run SQL queries
con.execute("CREATE TABLE users (id INTEGER, name VARCHAR)")
con.execute("INSERT INTO users VALUES (1, 'Alice'), (2, 'Bob')")
result = con.execute("SELECT * FROM users").fetchall()
print(result)

con.close()
```

## Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [DuckDB SQL Reference](https://duckdb.org/docs/sql/introduction)
