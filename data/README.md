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
│   ├── json/           # Raw JSON from SWAPI API + complex hierarchies
│   ├── enriched/       # JSON with resolved relationships
│   └── parquet/        # Parquet files with nested data structures
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
**Format**: Raw SWAPI API responses + complex hierarchical data  
**Use Case**: JSON parsing, API data understanding, nested data traversal  
**Files**: characters.json, films.json, planets.json, species.json, starships.json, vehicles.json, complex-hierarchy.json

**Example**:
```sql
SELECT name, height::INTEGER as height_cm FROM 'data/star-wars/json/characters.json';
```

**Complex Hierarchy Example**:
```sql
-- Traverse multi-level nested JSON structures
SELECT 
    galaxy.name as galaxy_name,
    sector.name as sector_name,
    system.name as system_name,
    planet.name as planet_name
FROM 'data/star-wars/json/complex-hierarchy.json'
UNNEST(galaxy.sectors) as t(sector)
UNNEST(sector.systems) as s(system)  
UNNEST(system.planets) as p(planet);
```

### Enriched JSON Files (`enriched/`)
**Format**: JSON with resolved relationships  
**Use Case**: Complex nested data analysis  
**Files**: *_enriched.json versions of all entities

**Example**:
```sql
SELECT name, homeworld.name as planet FROM 'data/star-wars/enriched/characters_enriched.json';
```

### Parquet Files (`parquet/`)
**Format**: Parquet with nested data structures (STRUCT, ARRAY, MAP)  
**Use Case**: Advanced columnar analytics, nested data processing  
**Files**: characters_nested.parquet, films_nested.parquet

**Features**:
- STRUCT types for complex objects
- ARRAY types for collections
- MAP types for key-value pairs
- Optimized columnar storage

**Example**:
```sql
-- Access nested STRUCT fields
SELECT 
    name,
    physical_attributes.height,
    physical_attributes.mass,
    homeworld.name as planet_name
FROM 'data/star-wars/parquet/characters_nested.parquet';

-- Work with ARRAY fields
SELECT 
    title,
    UNNEST(characters) as character_name
FROM 'data/star-wars/parquet/films_nested.parquet';
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

## Data Format Comparison

| Format | Best For | Advantages | Use Cases |
|--------|----------|------------|-----------|
| **CSV** | Learning basics | Simple, readable, universal | Basic SQL operations, data loading |
| **JSON** | Document data | Flexible schema, nested structures | API responses, hierarchical data |
| **Parquet** | Analytics | Columnar storage, compression, types | Large datasets, complex analytics |
| **Database** | Production queries | ACID compliance, indexing, joins | Multi-table operations, transactions |

### When to Use Each Format

- **Start with CSV** for basic SELECT, WHERE, GROUP BY operations
- **Move to JSON** when learning document parsing and nested data
- **Use Parquet** for advanced analytics with complex data types
- **Use Database** for multi-table joins and transaction examples

## Usage by Section

- **Section 3-4 (DDL/DML)**: Use CSV files for simple, understandable examples
- **Section 5 (Basic DQL)**: Use CSV files and Star Wars database
- **Section 6 (Advanced DQL)**: Use TPC-H database for complex business scenarios
- **Section 7 (Advanced SQL)**: Use all databases for window functions, CTEs, transactions
- **Section 8 (Semi-structured Data)**: 
  - CSV files for basic tabular data processing
  - JSON files for document parsing and complex hierarchies
  - Parquet files for nested data structures and columnar analytics

## File Sizes

| File/Folder | Size | Records | Description |
|-------------|------|---------|-------------|
| `databases/tpc-h.db` | ~50MB | Thousands | Business analytics database |
| `databases/starwars.db` | ~5MB | Hundreds | Star Wars universe database |
| `star-wars/csv/` | ~100KB | ~300 total | 5 CSV files (87 characters, 61 planets, 37 species, etc.) |
| `star-wars/json/` | ~500KB | ~300 total | 6 SWAPI files + 1 complex hierarchy |
| `star-wars/enriched/` | ~800KB | ~300 total | 6 enriched JSON files with relationships |
| `star-wars/parquet/` | ~150KB | ~150 total | 2 nested Parquet files with STRUCT/ARRAY/MAP |
| `titanic/titanic.parquet` | ~60KB | 891 | Titanic passenger dataset |

## Documentation

For detailed schema information:
- [Database Schemas](../docs/DATABASE_SCHEMAS.md)
- [Data Files Reference](../docs/DATA_FILES_REFERENCE.md)
- [TPC-H Schema](../docs/TPC-H_DATABASE_SCHEMA.md)
- [Star Wars Schema](../docs/STARWARS_DATABASE_SCHEMA.md)