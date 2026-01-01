# Database Schemas Overview

This document provides an overview of the databases available in the Ultimate SQL Bootcamp environment.

## Available Databases

### 1. TPC-H Database (`data/tpc-h.db`)

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

### 2. Star Wars Database (`data/starwars.db`)

**Purpose**: Engaging learning examples with familiar content  
**Use Case**: Basic to intermediate SQL exercises, fun data exploration  
**Schema**: [Star Wars Database Schema](STARWARS_DATABASE_SCHEMA.md)

The Star Wars database contains comprehensive data from the Star Wars universe, making SQL learning more engaging with familiar characters and concepts.

**Key Tables**: characters, films, planets, species, starships, vehicles

**Best For**: Sections 3-5 exercises (DDL, DML, basic DQL)

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

## Quick Database Setup

### TPC-H Database
```bash
# Automatic setup
poetry run python sql_runner.py --setup

# Manual setup
duckdb data/tpc-h.db < examples/tpc-h.sql

# Verify
duckdb data/tpc-h.db -c "SELECT COUNT(*) FROM customer"
```

### Star Wars Database
```bash
# Already available, verify with:
duckdb data/starwars.db -c "SELECT COUNT(*) FROM characters"
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

## Schema Complexity Comparison

| Aspect | Star Wars | TPC-H |
|--------|-----------|-------|
| **Complexity** | Medium | High |
| **Tables** | 17 tables | 8 core tables |
| **Relationships** | Many-to-many via junction tables | Business hierarchy |
| **Data Types** | Mixed (strings, numbers, dates) | Business-focused (decimals, dates) |
| **Query Complexity** | Basic to intermediate | Intermediate to advanced |
| **Real-world Relevance** | Entertainment | Business analytics |

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