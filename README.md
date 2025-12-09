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

```bash
# Install Poetry
curl -sSL https://install.python-poetry.org | python3 -

# Install dependencies
poetry install

# Install DuckDB CLI
brew install duckdb

# Load sample database
duckdb sample.db < setup.sql

# Start querying
duckdb sample.db
```

See [docs/SETUP.md](docs/SETUP.md) for detailed instructions.

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
