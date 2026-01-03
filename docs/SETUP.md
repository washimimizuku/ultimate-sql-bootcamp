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

This creates a virtual environment and installs all required dependencies including:
- **DuckDB** - Fast in-process analytical database
- **Pandas** - Data manipulation and analysis library (for Python UDFs)
- **NumPy** - Numerical computing library (for Python UDFs)
- **Requests** - HTTP library for data fetching

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
poetry run python -c "import duckdb; duckdb.connect('data/databases/tpc-h.db').execute(open('database/tpc-h.sql').read())"
```

## 4. Verify Installation

```bash
# Test Python DuckDB integration
python -c "import duckdb; print(f'DuckDB version: {duckdb.__version__}')"

# Test TPC-H database
poetry run python sql_runner.py --query "SELECT COUNT(*) as customers FROM customer"

# Test Star Wars database  
poetry run python sql_runner.py --db data/databases/starwars.db --query "SELECT COUNT(*) as characters FROM characters"
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

### Python UDFs (User-Defined Functions)
Section 7 includes Python UDF examples that extend SQL with Python libraries:

```bash
# Register Python UDFs (run this first)
poetry run python exercises/section-7-advanced-sql/python-udfs.py

# Then run SQL demonstrations
poetry run python sql_runner.py --file exercises/section-7-advanced-sql/python-udfs-demo.sql
```

**Note**: Python UDFs must be registered in each session before use. The registration script (`python-udfs.py`) creates 25+ functions for mathematical calculations, string processing, business logic, and data validation.

### TPC-H Database (Business Analytics)
```bash
# Setup TPC-H database
duckdb data/databases/tpc-h.db < database/tpc-h.sql

# Query TPC-H data
duckdb data/databases/tpc-h.db -c "SELECT c_name, c_nationkey FROM customer LIMIT 5"

# Run TPC-H exercises
duckdb data/databases/tpc-h.db < exercises/section-5-dql-intermediate/subqueries.sql
```

### Star Wars Database (Learning Examples)
```bash
# Query Star Wars data
duckdb data/databases/starwars.db -c "SELECT name, height FROM characters LIMIT 5"

# Run Star Wars exercises
duckdb data/databases/starwars.db < exercises/section-4-dql/select-where.sql
```

### Available Exercise Sections

1. **Section 1: Introduction** - SQL basics and syntax
2. **Section 2: DDL** - CREATE, ALTER, DROP operations
3. **Section 3: DML** - INSERT, UPDATE, DELETE operations  
4. **Section 4: DQL** - SELECT queries and functions
5. **Section 5: Intermediate DQL** - JOINs, subqueries, set operations
6. **Section 6: Query Performance Tuning** - EXPLAIN, optimization techniques
7. **Section 7: Advanced SQL** - Window functions, CTEs, transactions
8. **Section 8: Semi-Structured Data** - CSV, JSON, Parquet processing
9. **Section 9: Business Intelligence** - Data warehousing, KPIs, reporting
10. **Section 10: Data Engineering** - ETL, data quality, monitoring
11. **Section 11: Advanced Analytics** - Pivot operations, cohort analysis
12. **Section 12: Industry Scenarios** - Ecommerce and financial analytics

## Quick Start Examples

```bash
# Run a basic exercise
poetry run python run_sql.py exercises/section-2-ddl/create.sql

# Explore TPC-H data interactively
poetry run python sql_runner.py --db data/databases/tpc-h.db -i

# Run advanced exercises
poetry run python run_sql.py exercises/section-5-dql-intermediate/joins.sql
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
ls data/databases/  # Should show tpc-h.db, starwars.db, and Section 12 databases

# Re-setup if needed
poetry run python sql_runner.py --setup
```

**Permission errors:**
```bash
# On macOS/Linux, ensure execute permissions
chmod +x sql_runner.py run_sql.py
```
