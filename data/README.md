# Data Directory

This directory contains all data sources used in the Ultimate SQL Bootcamp, organized by type and format.

## Directory Structure

```
data/
├── databases/           # Database files (.db)
│   ├── tpc-h.db        # TPC-H business analytics database
│   └── starwars.db     # Star Wars universe database
├── star-wars/          # Star Wars data in multiple formats
│   ├── csv/            # CSV files for basic exercises
│   ├── json/           # Raw JSON from SWAPI API
│   └── enriched/       # JSON with resolved relationships
└── titanic/            # Titanic passenger dataset
    └── titanic.parquet # Parquet format for advanced analytics
```

## Database Files (`databases/`)

### `tpc-h.db`
- **Purpose**: Business analytics and decision support
- **Size**: ~50MB with sample data
- **Tables**: 8 core business tables
- **Use**: Advanced SQL exercises (Section 6)
- **Setup**: `duckdb data/databases/tpc-h.db < database/tpc-h.sql`

### `starwars.db`
- **Purpose**: Engaging learning with familiar content
- **Size**: ~5MB
- **Tables**: 17 tables covering Star Wars universe
- **Use**: Basic to intermediate exercises (Sections 3-5)
- **Setup**: Usually pre-created, or `duckdb data/databases/starwars.db < database/starwars.sql`

## Star Wars Data Files (`star-wars/`)

### CSV Files (`csv/`)
**Format**: Simple tabular data  
**Use Case**: Basic SQL exercises, data loading practice  
**Files**: characters.csv, planets.csv, species.csv, starships.csv, vehicles.csv

**Example**:
```sql
SELECT name, height, species FROM 'data/star-wars/csv/characters.csv';
```

### JSON Files (`json/`)
**Format**: Raw SWAPI API responses  
**Use Case**: JSON parsing, API data understanding  
**Files**: characters.json, films.json, planets.json, species.json, starships.json, vehicles.json

**Example**:
```sql
SELECT name, height::INTEGER as height_cm FROM 'data/star-wars/json/characters.json';
```

### Enriched JSON Files (`enriched/`)
**Format**: JSON with resolved relationships  
**Use Case**: Complex nested data analysis  
**Files**: *_enriched.json versions of all entities

**Example**:
```sql
SELECT name, homeworld.name as planet FROM 'data/star-wars/enriched/characters_enriched.json';
```

## Titanic Dataset (`titanic/`)

### `titanic.parquet`
- **Format**: Parquet (columnar storage)
- **Records**: 891 passengers
- **Use Case**: Statistical analysis, survival modeling
- **Columns**: PassengerId, Survived, Pclass, Name, Sex, Age, etc.

**Example**:
```sql
SELECT Pclass, AVG(Survived) as survival_rate FROM 'data/titanic/titanic.parquet' GROUP BY Pclass;
```

## Data Generation Pipeline

The Star Wars data is generated using tools in the `tools/` directory:

1. **`swapi_data.py`** - Fetches data from SWAPI → `json/` folder
2. **`resolve_references.py`** - Creates enriched versions → `enriched/` folder  
3. **`generate_swapi_sql.py`** - Creates database script → `database/starwars.sql`

## Usage by Section

- **Section 3-4 (DDL/DML)**: Use CSV files for simple, understandable examples
- **Section 5 (Basic DQL)**: Use CSV files and Star Wars database
- **Section 6 (Advanced DQL)**: Use TPC-H database for complex business scenarios
- **Advanced Topics**: Use JSON files and Parquet for format-specific exercises

## File Sizes

| File/Folder | Size | Records |
|-------------|------|---------|
| `databases/tpc-h.db` | ~50MB | Thousands |
| `databases/starwars.db` | ~5MB | Hundreds |
| `star-wars/csv/` | ~100KB | ~300 total |
| `star-wars/json/` | ~500KB | ~300 total |
| `star-wars/enriched/` | ~800KB | ~300 total |
| `titanic/titanic.parquet` | ~60KB | 891 |

## Documentation

For detailed schema information:
- [Database Schemas](../docs/DATABASE_SCHEMAS.md)
- [Data Files Reference](../docs/DATA_FILES_REFERENCE.md)
- [TPC-H Schema](../docs/TPC-H_DATABASE_SCHEMA.md)
- [Star Wars Schema](../docs/STARWARS_DATABASE_SCHEMA.md)