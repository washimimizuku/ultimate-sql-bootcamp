#!/usr/bin/env python3
"""
SWAPI SQL Generator - Creates SQL script to build and populate SWAPI database
This script reads SWAPI JSON data and generates CREATE TABLE and INSERT statements
"""
import json
import os
import re
from pathlib import Path


def extract_id_from_url(url):
    """Extract ID from SWAPI URL"""
    match = re.search(r'/(\d+)/?$', url)
    return int(match.group(1)) if match else None


def sanitize_sql_value(value, column_name=None):
    """Sanitize values for SQL insertion"""
    if value is None or value == 'unknown' or value == 'n/a' or value == 'none':
        return 'NULL'
    elif isinstance(value, str):
        # Handle numeric fields that might have string values
        if column_name and column_name in ['cost_in_credits', 'cargo_capacity', 'length', 'hyperdrive_rating', 
                                          'diameter', 'rotation_period', 'orbital_period', 'surface_water',
                                          'crew', 'passengers', 'max_atmosphering_speed', 'MGLT', 'population', 'episode_id']:
            # Try to convert to number, return NULL if not possible
            try:
                # Remove commas and handle ranges
                clean_value = value.replace(',', '').split('-')[0].strip()
                if clean_value.lower() in ['unknown', 'n/a', 'none', 'indefinite']:
                    return 'NULL'
                # Try to parse as number
                if '.' in clean_value:
                    float(clean_value)
                else:
                    int(clean_value)
                return clean_value
            except (ValueError, AttributeError):
                return 'NULL'
        # Escape single quotes and wrap in quotes
        return f"'{value.replace("'", "''")}'"
    elif isinstance(value, (int, float)):
        return str(value)
    elif isinstance(value, list):
        # Convert list to JSON string
        return f"'{json.dumps(value).replace("'", "''")}'"
    elif isinstance(value, dict):
        # Convert dict to JSON string
        return f"'{json.dumps(value).replace("'", "''")}'"
    else:
        return f"'{str(value).replace("'", "''")}'"


def generate_create_table_sql(table_name, sample_data):
    """Generate CREATE TABLE statement based on sample data"""
    sql = f"CREATE TABLE {table_name} (\n"
    sql += "    id INTEGER PRIMARY KEY,\n"
    
    # Analyze first few records to determine column types
    columns = set()
    for item in sample_data[:5]:  # Look at first 5 items
        columns.update(item.keys())
    
    # Remove 'id' and many-to-many relationship fields
    # Keep one-to-many fields (homeworld) to be handled as foreign keys
    exclude_fields = {
        'id', 'films', 'characters', 'planets', 'species', 'vehicles', 'starships', 
        'pilots', 'residents', 'people'
    }
    columns = {col for col in columns if col not in exclude_fields}
    
    # Always add species_id for characters table
    if table_name == 'characters':
        sql += f"    species_id INTEGER,\n"
    
    for column in sorted(columns):
        # Determine column type based on sample values
        sample_values = [item.get(column) for item in sample_data[:5] if column in item]
        
        # Handle homeworld as foreign key
        if column == 'homeworld':
            sql += f"    homeworld_id INTEGER,\n"
            continue
            
        # Skip species for characters table (already handled above)
        if column == 'species' and table_name == 'characters':
            continue
            
        if any(isinstance(v, list) for v in sample_values):
            col_type = "TEXT"  # Store as JSON
        elif any(isinstance(v, dict) for v in sample_values):
            col_type = "TEXT"  # Store as JSON
        elif column in ['cost_in_credits', 'cargo_capacity']:
            col_type = "BIGINT"
        elif column in ['length', 'hyperdrive_rating', 'diameter', 'rotation_period', 'orbital_period', 'surface_water']:
            col_type = "DECIMAL"
        elif column in ['population']:
            col_type = "BIGINT"
        elif column in ['crew', 'passengers', 'max_atmosphering_speed', 'MGLT', 'episode_id']:
            col_type = "INTEGER"
        else:
            col_type = "VARCHAR(500)"
        
        sql += f"    {column} {col_type},\n"
    
    # Add foreign key constraints at the end
    if table_name == 'characters':
        sql += "    FOREIGN KEY (homeworld_id) REFERENCES planets(id),\n"
        sql += "    FOREIGN KEY (species_id) REFERENCES species(id)\n"
    elif table_name == 'species':
        sql += "    FOREIGN KEY (homeworld_id) REFERENCES planets(id)\n"
    else:
        sql = sql.rstrip(',\n') + "\n"
    
    sql += ");\n\n"
    return sql


def generate_insert_sql(table_name, data):
    """Generate INSERT statements for table data"""
    if not data:
        return ""
    
    sql = f"-- Insert data into {table_name}\n"
    
    # Define column order based on table creation order
    table_column_order = {
        'films': ['id', 'created', 'director', 'edited', 'episode_id', 'opening_crawl', 'producer', 'release_date', 'title', 'url'],
        'planets': ['id', 'climate', 'created', 'diameter', 'edited', 'gravity', 'name', 'orbital_period', 'population', 'rotation_period', 'surface_water', 'terrain', 'url'],
        'species': ['id', 'average_height', 'average_lifespan', 'classification', 'created', 'designation', 'edited', 'eye_colors', 'hair_colors', 'homeworld_id', 'language', 'name', 'skin_colors', 'url'],
        'characters': ['id', 'species_id', 'birth_year', 'created', 'edited', 'eye_color', 'gender', 'hair_color', 'height', 'homeworld_id', 'mass', 'name', 'skin_color', 'url'],
        'vehicles': ['id', 'cargo_capacity', 'consumables', 'cost_in_credits', 'created', 'crew', 'edited', 'length', 'manufacturer', 'max_atmosphering_speed', 'model', 'name', 'passengers', 'url', 'vehicle_class'],
        'starships': ['id', 'MGLT', 'cargo_capacity', 'consumables', 'cost_in_credits', 'created', 'crew', 'edited', 'hyperdrive_rating', 'length', 'manufacturer', 'max_atmosphering_speed', 'model', 'name', 'passengers', 'starship_class', 'url']
    }
    
    for item in data:
        # Exclude many-to-many relationship fields, but handle homeworld and species as foreign keys
        exclude_fields = {
            'films', 'characters', 'planets', 'vehicles', 'starships', 
            'pilots', 'residents', 'people'
        }
        
        # For characters table, exclude species from many-to-many (now foreign key)
        if table_name == 'characters':
            exclude_fields.add('species')
        
        columns = []
        values = []
        
        # Use predefined column order
        column_order = table_column_order.get(table_name, ['id'] + sorted([k for k in item.keys() if k != 'id']))
        
        for col in column_order:
            if col in exclude_fields:
                continue
            elif col == 'homeworld_id':
                # Handle homeworld as foreign key
                homeworld_id = get_id_from_item(item.get('homeworld'))
                if homeworld_id:
                    columns.append('homeworld_id')
                    values.append(str(homeworld_id))
            elif col == 'species_id' and table_name == 'characters':
                # Handle species as foreign key for characters
                species_list = item.get('species', [])
                if species_list:
                    # Take the first species (most characters have only one)
                    species_id = get_id_from_item(species_list[0])
                    if species_id:
                        columns.append('species_id')
                        values.append(str(species_id))
            elif col in item:
                columns.append(col)
                values.append(sanitize_sql_value(item.get(col), col))
        
        if columns:  # Only insert if we have columns
            column_list = ', '.join(columns)
            value_list = ', '.join(values)
            sql += f"INSERT INTO {table_name} ({column_list}) VALUES ({value_list});\n"
    
    sql += "\n"
    return sql


def get_id_from_item(item):
    """Extract ID from either URL string or enriched object"""
    if isinstance(item, dict) and 'id' in item:
        return item['id']
    elif isinstance(item, str):
        return extract_id_from_url(item)
    return None

def generate_junction_table_data(all_data):
    """Generate INSERT statements for junction tables"""
    sql = "-- JUNCTION TABLE DATA\n\n"
    
    # Film relationships
    for film in all_data.get('films', []):
        film_id = film.get('id')
        if not film_id:
            continue
            
        # Film-Characters
        for char_item in film.get('characters', []):
            char_id = get_id_from_item(char_item)
            if char_id:
                sql += f"INSERT INTO film_characters (film_id, character_id) VALUES ({film_id}, {char_id});\n"
        
        # Film-Planets
        for planet_item in film.get('planets', []):
            planet_id = get_id_from_item(planet_item)
            if planet_id:
                sql += f"INSERT INTO film_planets (film_id, planet_id) VALUES ({film_id}, {planet_id});\n"
        
        # Film-Starships
        for starship_item in film.get('starships', []):
            starship_id = get_id_from_item(starship_item)
            if starship_id:
                sql += f"INSERT INTO film_starships (film_id, starship_id) VALUES ({film_id}, {starship_id});\n"
        
        # Film-Vehicles
        for vehicle_item in film.get('vehicles', []):
            vehicle_id = get_id_from_item(vehicle_item)
            if vehicle_id:
                sql += f"INSERT INTO film_vehicles (film_id, vehicle_id) VALUES ({film_id}, {vehicle_id});\n"
        
        # Film-Species
        for species_item in film.get('species', []):
            species_id = get_id_from_item(species_item)
            if species_id:
                sql += f"INSERT INTO film_species (film_id, species_id) VALUES ({film_id}, {species_id});\n"
    
    # Character relationships (many-to-many only, homeworld is now a foreign key)
    for character in all_data.get('characters', []):
        char_id = character.get('id')
        if not char_id:
            continue
        
        # REMOVED: Character-Species - now using characters.species_id foreign key
        
        # Character-Vehicles
        for vehicle_item in character.get('vehicles', []):
            vehicle_id = get_id_from_item(vehicle_item)
            if vehicle_id:
                sql += f"INSERT INTO character_vehicles (character_id, vehicle_id) VALUES ({char_id}, {vehicle_id});\n"
        
        # Character-Starships
        for starship_item in character.get('starships', []):
            starship_id = get_id_from_item(starship_item)
            if starship_id:
                sql += f"INSERT INTO character_starships (character_id, starship_id) VALUES ({char_id}, {starship_id});\n"
    
    # REMOVED: Planet relationships - now using characters.homeworld_id foreign key
    
    # REMOVED: Species relationships - now using characters.species_id foreign key
    
    # Vehicle relationships
    for vehicle in all_data.get('vehicles', []):
        vehicle_id = vehicle.get('id')
        if not vehicle_id:
            continue
            
        # Vehicle-Pilots
        for pilot_item in vehicle.get('pilots', []):
            char_id = get_id_from_item(pilot_item)
            if char_id:
                sql += f"INSERT INTO vehicle_pilots (vehicle_id, character_id) VALUES ({vehicle_id}, {char_id});\n"
    
    # Starship relationships
    for starship in all_data.get('starships', []):
        starship_id = starship.get('id')
        if not starship_id:
            continue
            
        # Starship-Pilots
        for pilot_item in starship.get('pilots', []):
            char_id = get_id_from_item(pilot_item)
            if char_id:
                sql += f"INSERT INTO starship_pilots (starship_id, character_id) VALUES ({starship_id}, {char_id});\n"
    
    sql += "\n"
    return sql


def main():
    """Generate complete SQL script for SWAPI database"""
    data_dir = Path("data/star-wars")
    output_file = Path("examples/swapi_database.sql")
    
    # Order matters for foreign key constraints
    categories = ['films', 'planets', 'species', 'characters', 'vehicles', 'starships']
    
    print("🚀 Generating SWAPI SQL database script...")
    
    # Start building SQL script
    sql_script = """-- SWAPI Database Creation Script
-- Generated from Star Wars API data
-- This script creates tables and populates them with SWAPI data

"""
    
    # Load data and generate SQL for each category
    all_data = {}
    
    for category in categories:
        json_file = data_dir / f"{category}.json"
        
        if json_file.exists():
            print(f"📄 Processing {category}...")
            
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                all_data[category] = data
                
                # Generate CREATE TABLE
                sql_script += f"-- {category.upper()} TABLE\n"
                sql_script += generate_create_table_sql(category, data)
                
            except Exception as e:
                print(f"❌ Error processing {category}: {e}")
                continue
        else:
            print(f"⚠️  File not found: {json_file}")
    
    # Add junction tables BEFORE data insertion
    sql_script += """-- JUNCTION TABLES FOR RELATIONSHIPS

-- Film relationships
CREATE TABLE film_characters (
    film_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (film_id, character_id)
);

CREATE TABLE film_planets (
    film_id INTEGER,
    planet_id INTEGER,
    PRIMARY KEY (film_id, planet_id)
);

CREATE TABLE film_starships (
    film_id INTEGER,
    starship_id INTEGER,
    PRIMARY KEY (film_id, starship_id)
);

CREATE TABLE film_vehicles (
    film_id INTEGER,
    vehicle_id INTEGER,
    PRIMARY KEY (film_id, vehicle_id)
);

CREATE TABLE film_species (
    film_id INTEGER,
    species_id INTEGER,
    PRIMARY KEY (film_id, species_id)
);

-- REMOVED: character_species table - now using characters.species_id foreign key

CREATE TABLE character_vehicles (
    character_id INTEGER,
    vehicle_id INTEGER,
    PRIMARY KEY (character_id, vehicle_id)
);

CREATE TABLE character_starships (
    character_id INTEGER,
    starship_id INTEGER,
    PRIMARY KEY (character_id, starship_id)
);

-- REMOVED: planet_residents table - redundant with characters.homeworld_id foreign key

-- REMOVED: species_people table - redundant with characters.species_id foreign key

-- Vehicle relationships
CREATE TABLE vehicle_pilots (
    vehicle_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (vehicle_id, character_id)
);

-- Starship relationships
CREATE TABLE starship_pilots (
    starship_id INTEGER,
    character_id INTEGER,
    PRIMARY KEY (starship_id, character_id)
);

"""
    
    # Generate INSERT statements
    sql_script += "-- DATA INSERTION\n\n"
    
    for category in categories:
        if category in all_data:
            print(f"📝 Generating INSERT statements for {category}...")
            sql_script += generate_insert_sql(category, all_data[category])
    
    # Generate junction table data
    print("📝 Generating junction table data...")
    sql_script += generate_junction_table_data(all_data)
    
    # Add useful views and queries
    sql_script += """-- USEFUL VIEWS AND QUERIES

-- USEFUL VIEWS

-- View: Expensive starships with details
CREATE VIEW expensive_starships AS
SELECT 
    name,
    model,
    starship_class,
    cost_in_credits,
    manufacturer
FROM starships 
WHERE cost_in_credits IS NOT NULL 
  AND cost_in_credits != 'unknown'
  AND CAST(cost_in_credits AS BIGINT) > 1000000
ORDER BY CAST(cost_in_credits AS BIGINT) DESC;

-- View: Film statistics
CREATE VIEW film_stats AS
SELECT 
    title,
    episode_id,
    release_date,
    director,
    producer,
    LENGTH(opening_crawl) as opening_crawl_length
FROM films
ORDER BY episode_id;

"""
    
    # Write SQL script to file
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(sql_script)
        
        print(f"✅ SQL script generated successfully: {output_file}")
        print(f"📊 Tables created: {len(all_data)}")
        print(f"📝 Total records: {sum(len(data) for data in all_data.values())}")
        
    except Exception as e:
        print(f"❌ Error writing SQL file: {e}")


if __name__ == "__main__":
    main()