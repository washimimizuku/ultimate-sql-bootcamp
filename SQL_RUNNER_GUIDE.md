# SQL Runner Guide

## Overview
Three Python scripts to help you work with SQL files and DuckDB:

1. **`sql_runner.py`** - Full-featured SQL runner with interactive mode
2. **`run_sql.py`** - Simple script to run a single SQL file
3. **`demo.py`** - Demonstration of features

## Quick Start

### Run a single SQL file:
```bash
poetry run python run_sql.py exercises/section-3-ddl/create.sql
```

### Interactive mode:
```bash
poetry run python sql_runner.py -i
```

### Run demo:
```bash
poetry run python demo.py
```

## Interactive Commands

When in interactive mode (`-i`), you can use:

- `setup` - Initialize database with tpc-h.sql
- `tables` - List all tables
- `files` - Show available SQL files
- `run <file>` - Execute a SQL file
- `query <sql>` - Run a SQL query directly
- `quit` - Exit

## Command Line Options

```bash
# Setup database first
poetry run python sql_runner.py --setup

# Run specific file
poetry run python sql_runner.py --file exercises/section-3-ddl/create.sql

# Execute query directly
poetry run python sql_runner.py --query "SELECT * FROM customer LIMIT 5"

# Use different database
poetry run python sql_runner.py --db my_database.db --setup
```

## Examples

### Basic Usage:
```bash
# Setup and run interactively
poetry run python sql_runner.py --setup -i
```

### Run Exercise Files:
```bash
poetry run python run_sql.py "exercises/section-3-ddl/use.sql"
poetry run python run_sql.py "exercises/section-3-ddl/create.sql"
```

### Quick Queries:
```bash
poetry run python sql_runner.py --query "SELECT n_name, COUNT(*) FROM customer c JOIN nation n ON c.c_nationkey = n.n_nationkey GROUP BY n_name"
```

## Features

✅ **Automatic Setup** - Runs tpc-h.sql to initialize database  
✅ **Error Handling** - Shows clear error messages  
✅ **Result Display** - Formats SELECT query results nicely  
✅ **File Discovery** - Finds all SQL files in project  
✅ **Interactive Mode** - Command-line interface for exploration  
✅ **Batch Execution** - Run multiple statements from files  

## Tips

- The database file `sample.db` is created automatically
- Use `--setup` flag to reinitialize the database
- SQL files are executed statement by statement
- SELECT results are limited to first 10 rows for readability
- Comments in SQL files are automatically skipped