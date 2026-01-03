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
# Start with Section 1 - Introduction (great for beginners!)
poetry run python run_sql.py "exercises/section-1-introduction/sql-fundamentals.sql"
poetry run python run_sql.py "exercises/section-1-introduction/first-steps.sql"
poetry run python run_sql.py "exercises/section-1-introduction/data-types-intro.sql"

# DDL exercises
poetry run python run_sql.py "exercises/section-3-ddl/create.sql"
poetry run python run_sql.py "exercises/section-3-ddl/alter.sql"

# DQL exercises  
poetry run python run_sql.py "exercises/section-5-dql/select-where.sql"
poetry run python run_sql.py "exercises/section-5-dql/aggregate-functions.sql"

# Advanced DQL exercises (requires TPC-H database)
poetry run python run_sql.py "exercises/section-6-dql-intermediate/subqueries.sql"
poetry run python run_sql.py "exercises/section-6-dql-intermediate/join.sql"

# Business Intelligence exercises
poetry run python run_sql.py "exercises/section-9-business-intelligence/kpi-calculations.sql"
poetry run python run_sql.py "exercises/section-9-business-intelligence/time-series-analysis.sql"

# Data Engineering exercises
poetry run python run_sql.py "exercises/section-10-data-engineering/data-quality-validation.sql"
poetry run python run_sql.py "exercises/section-10-data-engineering/etl-transformations.sql"

# Advanced Analytics exercises
poetry run python run_sql.py "exercises/section-11-advanced-analytics/pivot-unpivot-operations.sql"
poetry run python run_sql.py "exercises/section-11-advanced-analytics/cohort-retention-analysis.sql"
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

## Available Exercise Sections

### Section 1: Introduction
- `exercises/section-1-introduction/sql-fundamentals.sql` - Core database concepts and SQL introduction
- `exercises/section-1-introduction/first-steps.sql` - Your first SQL queries and result understanding
- `exercises/section-1-introduction/data-types-intro.sql` - Understanding different data types
- `exercises/section-1-introduction/sql-anatomy.sql` - SQL statement structure and syntax

### Section 2: DDL (Data Definition Language)
- `exercises/section-2-ddl/create.sql` - CREATE statements
- `exercises/section-2-ddl/alter.sql` - ALTER statements  
- `exercises/section-2-ddl/drop.sql` - DROP statements
- `exercises/section-2-ddl/show.sql` - SHOW statements
- `exercises/section-2-ddl/describe.sql` - DESCRIBE statements
- `exercises/section-2-ddl/use.sql` - USE statements

### Section 3: DML (Data Manipulation Language)
- `exercises/section-3-dml/insert.sql` - INSERT operations
- `exercises/section-3-dml/update.sql` - UPDATE operations
- `exercises/section-3-dml/delete.sql` - DELETE operations
- `exercises/section-3-dml/merge.sql` - MERGE operations
- `exercises/section-3-dml/copy-from.sql` - COPY FROM operations
- `exercises/section-3-dml/truncate.sql` - TRUNCATE operations

### Section 4: DQL (Data Query Language)
- `exercises/section-4-dql/select-from.sql` - Basic SELECT
- `exercises/section-4-dql/select-where.sql` - WHERE clauses
- `exercises/section-4-dql/select-order-by.sql` - ORDER BY sorting
- `exercises/section-4-dql/select-group-by.sql` - GROUP BY aggregation
- `exercises/section-4-dql/select-having.sql` - HAVING clauses
- `exercises/section-4-dql/aggregate-functions.sql` - Aggregate functions
- `exercises/section-4-dql/scalar-functions.sql` - Scalar functions

### Section 5: Intermediate DQL
- `exercises/section-5-dql-intermediate/join.sql` - INNER JOINs
- `exercises/section-5-dql-intermediate/outer-join.sql` - OUTER JOINs
- `exercises/section-5-dql-intermediate/subqueries.sql` - Subquery patterns
- `exercises/section-5-dql-intermediate/set-operators.sql` - UNION, INTERSECT, EXCEPT
- `exercises/section-5-dql-intermediate/tpch.sql` - TPC-H database exploration
- `exercises/section-5-dql-intermediate/views.sql` - Basic view creation and usage
- `exercises/section-5-dql-intermediate/views-advanced.sql` - Advanced view patterns and optimization
- `exercises/section-5-dql-intermediate/conditional-expressions.sql` - CASE statements and conditionals
- `exercises/section-5-dql-intermediate/conversions.sql` - Data type conversions

### Section 6: Query Performance Tuning
- `exercises/section-6-query-performance-tuning/explain.sql` - Query execution plan analysis
- `exercises/section-6-query-performance-tuning/join-optimization.sql` - Advanced join techniques
- `exercises/section-6-query-performance-tuning/order-by-optimization.sql` - Sorting performance
- `exercises/section-6-query-performance-tuning/group-by-optimization.sql` - Aggregation optimization
- `exercises/section-6-query-performance-tuning/indexes.sql` - Comprehensive index strategies

### Section 6: Intermediate DQL
- `exercises/section-6-dql-intermediate/join.sql` - INNER JOINs
- `exercises/section-6-dql-intermediate/outer-join.sql` - OUTER JOINs
- `exercises/section-6-dql-intermediate/subqueries.sql` - Subquery patterns
- `exercises/section-6-dql-intermediate/set-operators.sql` - UNION, INTERSECT, EXCEPT
- `exercises/section-6-dql-intermediate/tpch.sql` - TPC-H database exploration

### Section 7: Advanced SQL
- `exercises/section-7-advanced-sql/window-functions.sql` - Window functions and analytics
- `exercises/section-7-advanced-sql/cte.sql` - Common Table Expressions
- `exercises/section-7-advanced-sql/transactions.sql` - Transaction management
- `exercises/section-7-advanced-sql/collations.sql` - Text sorting and comparison rules

### Section 8: Semi-Structured Data
- `exercises/section-8-semi-structured-data/csv-data.sql` - CSV file processing
- `exercises/section-8-semi-structured-data/json-data.sql` - JSON document analysis
- `exercises/section-8-semi-structured-data/parquet-data.sql` - Parquet columnar analytics

### Section 9: Business Intelligence & Analytics
- `exercises/section-9-business-intelligence/data-warehousing-patterns.sql` - Star schema and dimensional modeling
- `exercises/section-9-business-intelligence/kpi-calculations.sql` - Customer metrics and business KPIs
- `exercises/section-9-business-intelligence/time-series-analysis.sql` - Trends, seasonality, and cohort analysis
- `exercises/section-9-business-intelligence/reporting-patterns.sql` - Pivot tables and executive dashboards

### Section 10: Practical Data Engineering
- `exercises/section-10-data-engineering/data-quality-validation.sql` - Data profiling and quality assessment
- `exercises/section-10-data-engineering/etl-transformations.sql` - ETL patterns and data processing
- `exercises/section-10-data-engineering/file-processing-patterns.sql` - Batch processing and file validation
- `exercises/section-10-data-engineering/data-monitoring.sql` - Pipeline monitoring and alerting

### Section 11: Advanced Analytics
- `exercises/section-11-advanced-analytics/pivot-unpivot-operations.sql` - Data reshaping and cross-tabulation analysis
- `exercises/section-11-advanced-analytics/cohort-retention-analysis.sql` - Customer lifecycle and retention patterns

### Section 12: Industry-Specific Scenarios
- `exercises/section-12-industry-scenarios/ecommerce-analytics.sql` - Complete ecommerce analytics with inventory, cart abandonment, and sales funnel analysis (creates `data/databases/ecommerce_analytics.db`)
- `exercises/section-12-industry-scenarios/financial-reporting.sql` - Comprehensive financial reporting with P&L, budget analysis, and cash flow statements (creates `data/databases/financial_reporting.db`)

## Tips

- **Learning Path**: Start with Section 1 for SQL fundamentals, then progress through sections sequentially
- **Beginners**: Section 1 provides essential concepts - don't skip the introduction files!
- **Database Files**: `data/databases/tpc-h.db` (business data), `data/databases/starwars.db` (sample data), and Section 12 databases
- **Setup**: Use `--setup` flag to reinitialize the TPC-H database
- **Execution**: SQL files are executed statement by statement
- **Results**: SELECT results are limited to first 10 rows for readability
- **Comments**: Comments in SQL files are automatically skipped
- **TPC-H Exercises**: Section 6+ exercises require TPC-H database setup
- **Star Wars Exercises**: Section 1-5 exercises use Star Wars database for engaging examples
- **File Requirements**: Each exercise file includes setup instructions in comments