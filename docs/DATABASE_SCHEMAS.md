# Database Schemas Overview

This document provides an overview of the databases available in the Ultimate SQL Bootcamp environment.

## Available Databases

### 1. TPC-H Database (`data/databases/tpc-h.db`)

**Purpose**: Business analytics and decision support  
**Use Case**: Advanced SQL exercises, complex joins, business intelligence queries  
**Schema**: [TPC-H Database Schema](TPC-H_DATABASE_SCHEMA.md)

The TPC-H database represents a wholesale supplier business scenario with customers, orders, suppliers, and parts. It's designed for:
- Complex analytical queries
- Performance testing
- Business intelligence scenarios
- Advanced SQL pattern learning

**Key Tables**: customer, orders, lineitem, part, supplier, nation, region, partsupp

**Best For**: Section 6 exercises (JOINs, subqueries, set operators)

### 2. Star Wars Database (`data/databases/starwars.db`)

**Purpose**: Engaging learning examples with familiar content  
**Use Case**: Basic to intermediate SQL exercises, fun data exploration  
**Schema**: [Star Wars Database Schema](STARWARS_DATABASE_SCHEMA.md)

The Star Wars database contains comprehensive data from the Star Wars universe, making SQL learning more engaging with familiar characters and concepts.

**Key Tables**: characters, films, planets, species, starships, vehicles

**Best For**: Sections 3-5 exercises (DDL, DML, basic DQL)

### 3. Ecommerce Analytics Database (`data/databases/ecommerce_analytics.db`)

**Purpose**: Industry-specific ecommerce analytics scenarios  
**Use Case**: Section 12 - Comprehensive ecommerce business analysis  
**Schema**: Complete ecommerce data model with 10 tables

The ecommerce database represents a modern online retail business with products, customers, orders, cart events, web sessions, inventory, and reviews. It's designed for:
- Inventory management analytics
- Cart abandonment analysis
- Sales funnel optimization
- Product recommendation systems
- Customer behavior analysis

**Key Tables**: products, customers, orders, cart_events, web_sessions, inventory, product_reviews

**Best For**: Section 12 - Industry-specific ecommerce scenarios

### 4. Financial Reporting Database (`data/databases/financial_reporting.db`)

**Purpose**: Industry-specific financial reporting and analysis  
**Use Case**: Section 12 - Comprehensive financial business analysis  
**Schema**: Complete financial data model with 6 tables

The financial database represents a complete accounting system with chart of accounts, general ledger, budgets, cost centers, and fiscal periods. It's designed for:
- Profit & Loss statement generation
- Budget vs actual variance analysis
- Balance sheet reporting
- Cash flow analysis
- Financial ratio calculations

**Key Tables**: chart_of_accounts, general_ledger, budget, cost_centers, fiscal_periods

**Best For**: Section 12 - Industry-specific financial scenarios

## Database Usage by Section

### Section 2: Introduction
- Either database for basic syntax examples

### Section 3: DDL (Data Definition Language)
- Star Wars database for CREATE, ALTER, DROP examples
- Simple, understandable table structures

### Section 4: DML (Data Manipulation Language)
- Star Wars database for INSERT, UPDATE, DELETE examples
- Familiar data makes operations more intuitive

### Section 5: DQL (Data Query Language)
- Star Wars database for SELECT, WHERE, GROUP BY examples
- Engaging content keeps students interested

### Section 6: Intermediate DQL
- **TPC-H database** for complex business scenarios
- Realistic data relationships for advanced patterns
- JOINs across multiple business entities
- Complex subqueries for analytics
- Set operations for data comparison

### Section 7: Advanced SQL
- **Both databases** for window functions and CTEs
- TPC-H for complex analytical queries
- Star Wars for transaction examples
- Advanced SQL patterns and optimization

### Section 8: Semi-Structured Data
- **Star Wars CSV files** for basic tabular data processing
- **Star Wars JSON files** for document parsing and hierarchies
- **Star Wars Parquet files** for nested data structures
- **Titanic Parquet** for advanced analytics

### Section 9-11: Business Intelligence & Advanced Analytics
- **TPC-H database** for comprehensive business intelligence scenarios
- Dimensional modeling with realistic business relationships
- KPI calculations using customer and order data
- Time series analysis with date-based order patterns
- Executive reporting and dashboard creation
- Advanced analytics with pivot operations and cohort analysis

### Section 12: Industry-Specific Scenarios
- **Ecommerce Analytics database** for retail and online business scenarios
- **Financial Reporting database** for accounting and financial analysis
- Complete industry-specific data models with realistic business relationships
- Advanced analytical queries for specialized business domains

## Quick Database Setup

### TPC-H Database
```bash
# Automatic setup
poetry run python sql_runner.py --setup

# Manual setup
duckdb data/databases/tpc-h.db < database/tpc-h.sql

# Verify
duckdb data/databases/tpc-h.db -c "SELECT COUNT(*) FROM customer"
```

### Star Wars Database
```bash
# Already available, verify with:
duckdb data/databases/starwars.db -c "SELECT COUNT(*) FROM characters"

### Ecommerce Analytics Database
```bash
# Create database
duckdb data/databases/ecommerce_analytics.db < exercises/section-12-industry-scenarios/ecommerce-analytics.sql

# Verify
duckdb data/databases/ecommerce_analytics.db -c "SELECT COUNT(*) FROM products"
```

### Financial Reporting Database
```bash
# Create database
duckdb data/databases/financial_reporting.db < exercises/section-12-industry-scenarios/financial-reporting.sql

# Verify
duckdb data/databases/financial_reporting.db -c "SELECT COUNT(*) FROM chart_of_accounts"
```

## Choosing the Right Database

**Use TPC-H when:**
- Teaching complex business scenarios
- Demonstrating realistic data relationships
- Working with large datasets
- Teaching performance optimization
- Showing real-world analytics patterns

**Use Star Wars when:**
- Introducing SQL concepts
- Making learning more engaging
- Working with simpler relationships
- Teaching basic to intermediate concepts
- Students need familiar context

**Use Section 12 Databases when:**
- Teaching industry-specific scenarios
- Demonstrating complete business data models
- Advanced analytical use cases
- Real-world business intelligence applications
- Specialized domain knowledge (ecommerce, finance)

## Schema Complexity Comparison

| Aspect | Star Wars | TPC-H | Section 12 |
|--------|-----------|-------|------------|
| **Complexity** | Medium | High | High |
| **Tables** | 17 tables | 8 core tables | 6-10 tables each |
| **Relationships** | Many-to-many via junction tables | Business hierarchy | Industry-specific models |
| **Data Types** | Mixed (strings, numbers, dates) | Business-focused (decimals, dates) | Domain-specific (financial, ecommerce) |
| **Query Complexity** | Basic to intermediate | Intermediate to advanced | Advanced analytical |
| **Real-world Relevance** | Entertainment | Business analytics | Industry scenarios |

## Data Files

In addition to the databases, the project includes various data files in different formats:

### Star Wars Data Files (`data/star-wars/`)
- **CSV files**: Simplified tabular format for basic exercises
- **JSON files**: Raw API format and enriched versions with resolved relationships
- **Use cases**: Data loading, JSON parsing, format comparison

### Titanic Dataset (`data/titanic/`)
- **Parquet file**: Historical passenger data for survival analysis
- **Use cases**: Advanced analytics, statistical analysis, columnar data format

**Complete Reference**: [Data Files Reference](DATA_FILES_REFERENCE.md)

## Additional Resources

- [Setup Instructions](SETUP.md)
- [SQL Cheatsheet](CHEATSHEET.md)
- [SQL Runner Guide](SQL_RUNNER_GUIDE.md)
- [Data Files Reference](DATA_FILES_REFERENCE.md)

The combination of databases and data files provides comprehensive learning experiences at different skill levels, ensuring students can progress from basic concepts to advanced analytical queries while working with various data formats commonly encountered in real-world scenarios.