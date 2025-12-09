# Setup Instructions

## 1. Install Poetry

If you don't have Poetry installed:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

## 2. Install Dependencies

```bash
poetry install
```

This creates a virtual environment and installs DuckDB.

## 3. Activate Virtual Environment

```bash
poetry shell
```

## 4. Verify Installation

```bash
python -c "import duckdb; print(duckdb.__version__)"
```

## Alternative: Run Without Activating Shell

```bash
poetry run python your_script.py
```

## Deactivate Virtual Environment

```bash
exit
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
