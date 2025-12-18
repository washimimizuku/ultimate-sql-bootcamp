# Ultimate SQL Bootcamp - Setup Instructions

## Prerequisites

- Python 3.8 or higher
- Git (for cloning the repository)

## 1. Install Poetry

If you don't have Poetry installed:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

## 2. Clone Repository and Install Dependencies

```bash
git clone <repository-url>
cd ultimate-sql-bootcamp
poetry install
```

This creates a virtual environment and installs all required dependencies including DuckDB.

## 3. Setup Databases

### Option A: Using SQL Runner (Recommended)
```bash
# Setup TPC-H database automatically
poetry run python sql_runner.py --setup

# Start interactive mode
poetry run python sql_runner.py -i
```

### Option B: Manual Setup
```bash
# Create TPC-H database
poetry run python -c "import duckdb; duckdb.connect('data/tpc-h.db').execute(open('examples/tpc-h.sql').read())"
```

## 4. Verify Installation

```bash
# Test Python DuckDB integration
python -c "import duckdb; print(f'DuckDB version: {duckdb.__version__}')"

# Test TPC-H database
poetry run python sql_runner.py --query "SELECT COUNT(*) as customers FROM customer"

# Test Star Wars database  
poetry run python sql_runner.py --db data/starwars.db --query "SELECT COUNT(*) as characters FROM people"
```

## 5. Environment Options

### Option A: Activate Virtual Environment
```bash
poetry shell
# Now you can run commands directly
python sql_runner.py --setup
```

### Option B: Run Without Activating Shell
```bash
poetry run python sql_runner.py --setup
poetry run python run_sql.py exercises/section-5-dql/select-where.sql
```

### Deactivate Virtual Environment
```bash
exit  # or Ctrl+D
```

## DuckDB Command Line Interface

### Install DuckDB CLI

**macOS (Homebrew):**
```bash
brew install duckdb
```

**Direct Download:**
```bash
wget https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-osx-universal.zip
unzip duckdb_cli-osx-universal.zip
chmod +x duckdb
sudo mv duckdb /usr/local/bin/
```

### Using DuckDB CLI

**Start interactive session:**
```bash
duckdb
```

**Open/create a database file:**
```bash
duckdb mydata.db
```

**Run SQL directly:**
```bash
duckdb -c "SELECT 42 AS answer"
```

**Run SQL files:**
```bash
duckdb < script.sql
duckdb mydata.db < script.sql
```

**Read SQL file in interactive mode:**
```sql
.read script.sql
```

**Common CLI commands:**
```sql
.help          -- Show help
.tables        -- List tables
.schema        -- Show schema
.quit          -- Exit
```

## Working with Databases

### TPC-H Database (Business Analytics)
```bash
# Setup TPC-H database
duckdb data/tpc-h.db < examples/tpc-h.sql

# Query TPC-H data
duckdb data/tpc-h.db -c "SELECT c_name, c_nationkey FROM customer LIMIT 5"

# Run TPC-H exercises
duckdb data/tpc-h.db < exercises/section-6-dql-intermediate/subqueries.sql
```

### Star Wars Database (Learning Examples)
```bash
# Query Star Wars data
duckdb data/starwars.db -c "SELECT name, height FROM people LIMIT 5"

# Run Star Wars exercises
duckdb data/starwars.db < exercises/section-5-dql/select-where.sql
```

### Available Exercise Sections

1. **Section 2: Introduction** - SQL basics and syntax
2. **Section 3: DDL** - CREATE, ALTER, DROP operations
3. **Section 4: DML** - INSERT, UPDATE, DELETE operations  
4. **Section 5: DQL** - SELECT queries and functions
5. **Section 6: Intermediate DQL** - JOINs, subqueries, set operations

## Quick Start Examples

```bash
# Run a basic exercise
poetry run python run_sql.py exercises/section-3-ddl/create.sql

# Explore TPC-H data interactively
poetry run python sql_runner.py --db data/tpc-h.db -i

# Run advanced exercises
poetry run python run_sql.py exercises/section-6-dql-intermediate/join.sql
```

## Troubleshooting

### Common Issues

**Poetry not found:**
```bash
# Add Poetry to PATH (restart terminal after)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

**Database not found:**
```bash
# Ensure you're in the project root directory
ls data/  # Should show tpc-h.db and starwars.db

# Re-setup if needed
poetry run python sql_runner.py --setup
```

**Permission errors:**
```bash
# On macOS/Linux, ensure execute permissions
chmod +x sql_runner.py run_sql.py
```
