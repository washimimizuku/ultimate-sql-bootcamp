# Data Files Reference

This document provides comprehensive information about all CSV, JSON, and Parquet files available in the `data/` folder for use in SQL exercises and data analysis.

## File Structure Overview

```
data/
├── star-wars/          # Star Wars universe data in multiple formats
│   ├── *.csv          # Simplified CSV format for basic exercises
│   ├── *.json         # Raw JSON with API references
│   └── *_enriched.json # JSON with resolved relationships
├── titanic/           # Titanic passenger data
│   └── titanic.parquet # Parquet format for advanced exercises
├── starwars.db        # Star Wars SQLite database
└── tpc-h.db          # TPC-H business database
```

## Star Wars Data Files (`data/star-wars/`)

### CSV Files (Simplified Format)

Perfect for basic SQL exercises and data loading practice.

#### `characters.csv`
**Purpose**: Character information in simple tabular format  
**Records**: ~87 characters  
**Use Cases**: Basic SELECT, WHERE, GROUP BY exercises

**Schema**:
```
name          VARCHAR   # Character name (e.g., "Luke Skywalker")
height        VARCHAR   # Height in cm (e.g., "172")
mass          VARCHAR   # Weight in kg (e.g., "77")
hair_color    VARCHAR   # Hair color (e.g., "blond", "none", "NA")
skin_color    VARCHAR   # Skin color (e.g., "fair", "gold")
eye_color     VARCHAR   # Eye color (e.g., "blue", "yellow")
birth_year    VARCHAR   # Birth year (e.g., "19BBY", "112BBY")
gender        VARCHAR   # Gender (male, female, hermaphrodite, NA)
homeworld     VARCHAR   # Home planet name (e.g., "Tatooine")
species       VARCHAR   # Species name (e.g., "Human", "Droid")
```

**Sample Usage**:
```sql
-- Load and query characters
SELECT * FROM 'data/star-wars/characters.csv';
SELECT name, height FROM 'data/star-wars/characters.csv' WHERE species = 'Human';
```

#### `planets.csv`
**Purpose**: Planet information for geographic analysis  
**Records**: ~61 planets  

**Schema**:
```
name            VARCHAR   # Planet name (e.g., "Tatooine", "Alderaan")
rotation_period VARCHAR   # Hours per day (e.g., "24", "23")
orbital_period  VARCHAR   # Days per year (e.g., "364", "4818")
diameter        VARCHAR   # Planet diameter in km (e.g., "12500")
climate         VARCHAR   # Climate type (e.g., "temperate", "arid")
gravity         VARCHAR   # Gravity (e.g., "1 standard", "1.1 standard")
terrain         VARCHAR   # Terrain types (e.g., "grasslands, mountains")
surface_water   VARCHAR   # Water percentage (e.g., "40", "100")
population      VARCHAR   # Population count (e.g., "2000000000", "NA")
```

#### `species.csv`
**Purpose**: Species classification and characteristics  
**Records**: ~37 species  

**Schema**:
```
name             VARCHAR   # Species name (e.g., "Human", "Wookiee")
classification   VARCHAR   # Biological type (e.g., "mammal", "reptile")
designation      VARCHAR   # Designation (e.g., "sentient")
average_height   VARCHAR   # Average height in cm
average_lifespan VARCHAR   # Lifespan in years
eye_colors       VARCHAR   # Possible eye colors
hair_colors      VARCHAR   # Possible hair colors
skin_colors      VARCHAR   # Possible skin colors
language         VARCHAR   # Native language
homeworld        VARCHAR   # Origin planet name
```

#### `starships.csv`
**Purpose**: Starship specifications and capabilities  
**Records**: ~37 starships  

**Schema**:
```
name                    VARCHAR   # Starship name
model                   VARCHAR   # Model designation
manufacturer            VARCHAR   # Manufacturer name
cost_in_credits         VARCHAR   # Purchase cost
length                  VARCHAR   # Length in meters
max_atmosphering_speed  VARCHAR   # Max atmospheric speed
crew                    VARCHAR   # Required crew size
passengers              VARCHAR   # Passenger capacity
cargo_capacity          VARCHAR   # Cargo capacity in kg
consumables             VARCHAR   # Consumables duration
hyperdrive_rating       VARCHAR   # Hyperdrive class
MGLT                    VARCHAR   # Speed in megalights/hour
starship_class          VARCHAR   # Ship classification
```

#### `vehicles.csv`
**Purpose**: Ground and atmospheric vehicle data  
**Records**: ~39 vehicles  

**Schema**: Similar to starships but with `vehicle_class` instead of starship-specific fields.

### JSON Files (API Format)

#### Regular JSON Files (`*.json`)
**Purpose**: Raw API data with URL references  
**Format**: Array of objects with SWAPI URL references  
**Use Cases**: JSON parsing exercises, API data understanding

**Characteristics**:
- Contains original SWAPI URLs as references
- Relationships stored as URL arrays
- Requires URL parsing to resolve relationships
- Authentic API response format

**Example Structure**:
```json
{
  "name": "Luke Skywalker",
  "homeworld": "https://swapi.info/api/planets/1",
  "films": [
    "https://swapi.info/api/films/1",
    "https://swapi.info/api/films/2"
  ]
}
```

#### Enriched JSON Files (`*_enriched.json`)
**Purpose**: Resolved relationships with embedded objects  
**Format**: Array of objects with resolved nested data  
**Use Cases**: Complex JSON analysis, nested data extraction

**Characteristics**:
- URLs resolved to actual object data
- Nested objects with id and name
- Easier to work with for analysis
- Pre-processed for convenience

**Example Structure**:
```json
{
  "name": "Luke Skywalker",
  "homeworld": {
    "id": 1,
    "name": "Tatooine"
  },
  "films": [
    {
      "id": 1,
      "name": "A New Hope"
    }
  ]
}
```

### Available Files by Entity

| Entity | CSV | JSON | Enriched JSON |
|--------|-----|------|---------------|
| Characters | ✅ | ✅ | ✅ |
| Planets | ✅ | ✅ | ✅ |
| Species | ✅ | ✅ | ✅ |
| Starships | ✅ | ✅ | ✅ |
| Vehicles | ✅ | ✅ | ✅ |
| Films | ❌ | ✅ | ✅ |

## Titanic Dataset (`data/titanic/`)

### `titanic.parquet`
**Purpose**: Historical passenger data for survival analysis  
**Format**: Parquet (columnar storage format)  
**Records**: 891 passengers  
**Use Cases**: Advanced analytics, statistical analysis, Parquet format exercises

**Schema**:
```
PassengerId  BIGINT    # Unique passenger identifier (1-891)
Survived     BIGINT    # Survival (0 = No, 1 = Yes)
Pclass       BIGINT    # Ticket class (1 = 1st, 2 = 2nd, 3 = 3rd)
Name         VARCHAR   # Passenger name
Sex          VARCHAR   # Gender (male, female)
Age          DOUBLE    # Age in years (some missing values)
SibSp        BIGINT    # Number of siblings/spouses aboard
Parch        BIGINT    # Number of parents/children aboard
Ticket       VARCHAR   # Ticket number
Fare         DOUBLE    # Passenger fare
Cabin        VARCHAR   # Cabin number (many missing values)
Embarked     VARCHAR   # Port of embarkation (C=Cherbourg, Q=Queenstown, S=Southampton)
```

**Sample Queries**:
```sql
-- Load Titanic data
SELECT * FROM 'data/titanic/titanic.parquet' LIMIT 10;

-- Survival analysis by class
SELECT Pclass, 
       COUNT(*) as total_passengers,
       SUM(Survived) as survivors,
       AVG(Survived) as survival_rate
FROM 'data/titanic/titanic.parquet'
GROUP BY Pclass
ORDER BY Pclass;

-- Age distribution of survivors
SELECT 
  CASE 
    WHEN Age < 18 THEN 'Child'
    WHEN Age < 65 THEN 'Adult'
    ELSE 'Senior'
  END as age_group,
  AVG(Survived) as survival_rate
FROM 'data/titanic/titanic.parquet'
WHERE Age IS NOT NULL
GROUP BY age_group;
```

## Usage by Exercise Section

### Section 3: DDL (Data Definition Language)
**Recommended Files**: Star Wars CSV files
- Simple, clean structure for CREATE TABLE examples
- Familiar data for understanding table design
- Good for practicing data type selection

### Section 4: DML (Data Manipulation Language)
**Recommended Files**: Star Wars CSV files
- Easy to understand INSERT examples
- Meaningful UPDATE scenarios
- Clear DELETE operations

### Section 5: DQL (Data Query Language)
**Recommended Files**: Star Wars CSV files, Titanic Parquet
- Engaging SELECT queries with familiar characters
- Statistical analysis with Titanic data
- Good variety of data types and patterns

### Section 6: Intermediate DQL
**Recommended Files**: Star Wars JSON files, Titanic Parquet
- Complex JSON parsing and analysis
- Advanced analytics with Titanic survival data
- Nested data structure exercises

## File Format Comparison

| Format | Pros | Cons | Best For |
|--------|------|------|----------|
| **CSV** | Simple, readable, universal | Limited data types, no nesting | Basic exercises, data loading |
| **JSON** | Flexible, nested data, web-standard | Larger files, parsing complexity | API data, nested relationships |
| **Parquet** | Efficient, columnar, fast queries | Binary format, requires tools | Analytics, large datasets |

## Loading Data Examples

### CSV Files
```sql
-- Direct query
SELECT * FROM 'data/star-wars/characters.csv';

-- Create table from CSV
CREATE TABLE characters AS SELECT * FROM 'data/star-wars/characters.csv';

-- Load into existing table
COPY characters FROM 'data/star-wars/characters.csv' (HEADER);
```

### JSON Files
```sql
-- Query JSON directly
SELECT * FROM 'data/star-wars/characters.json';

-- Extract specific fields
SELECT 
  name,
  height::INTEGER as height_cm,
  mass::INTEGER as mass_kg
FROM 'data/star-wars/characters.json'
WHERE height != 'unknown';

-- Work with nested JSON (enriched files)
SELECT 
  name,
  homeworld.name as planet_name,
  len(films) as film_count
FROM 'data/star-wars/characters_enriched.json';
```

### Parquet Files
```sql
-- Query Parquet directly
SELECT * FROM 'data/titanic/titanic.parquet';

-- Efficient columnar queries
SELECT Pclass, AVG(Fare) as avg_fare
FROM 'data/titanic/titanic.parquet'
GROUP BY Pclass;
```

## Data Quality Notes

### Star Wars Data
- **Missing Values**: Represented as "unknown", "n/a", or "NA"
- **Data Types**: All stored as VARCHAR in CSV, requires casting
- **Consistency**: Some inconsistent formatting in original API data

### Titanic Data
- **Missing Values**: NULL values in Age and Cabin columns
- **Data Types**: Properly typed in Parquet format
- **Quality**: High-quality historical dataset, well-cleaned

## Integration with Databases

These files complement the database exercises:
- **CSV files** → Practice loading data into Star Wars database
- **JSON files** → Compare with normalized database structure
- **Parquet files** → Advanced analytics beyond basic database operations

This variety of formats provides comprehensive experience with different data sources and file types commonly encountered in real-world data analysis.