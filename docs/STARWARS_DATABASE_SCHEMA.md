# Star Wars Database Schema

The Star Wars database contains comprehensive data from the Star Wars universe, including characters, films, planets, species, starships, and vehicles. This database is sourced from the Star Wars API (SWAPI).

## Database Overview

The Star Wars database models the Star Wars universe with the following key entities:
- **Characters** (people) from the Star Wars saga
- **Films** in the Star Wars series
- **Planets** where events take place
- **Species** representing different alien races
- **Starships** used for space travel
- **Vehicles** used for ground/air transport

## Entity Relationship Diagram

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   PLANETS   │         │   SPECIES   │         │    FILMS    │
│─────────────│         │─────────────│         │─────────────│
│ id (PK)     │◄───┐    │ id (PK)     │    ┌───►│ id (PK)     │
│ name        │    │    │ name        │    │    │ title       │
│ climate     │    │    │ classification│  │    │ episode_id  │
│ diameter    │    │    │ designation │    │    │ director    │
│ gravity     │    │    │ average_height│  │    │ producer    │
│ terrain     │    │    │ average_lifespan│ │   │ release_date│
│ population  │    │    │ eye_colors  │    │    │ opening_crawl│
│ ...         │    │    │ hair_colors │    │    │ ...         │
└─────────────┘    │    │ skin_colors │    │    └─────────────┘
                   │    │ language    │    │           │
                   │    │ homeworld_id│◄───┘           │
                   │    │ ...         │                │
                   │    └─────────────┘                │
                   │           │                       │
                   │           │                       │
                   │           ▼                       │
                   │    ┌─────────────┐               │
                   └────┤ CHARACTERS  │               │
                        │─────────────│               │
                        │ id (PK)     │               │
                        │ name        │               │
                        │ height      │               │
                        │ mass        │               │
                        │ hair_color  │               │
                        │ skin_color  │               │
                        │ eye_color   │               │
                        │ birth_year  │               │
                        │ gender      │               │
                        │ homeworld_id│◄──────────────┘
                        │ species_id  │◄───────────────┐
                        │ ...         │                │
                        └─────────────┘                │
                               │                       │
                               │                       │
                ┌──────────────┼──────────────┐        │
                │              │              │        │
                ▼              ▼              ▼        │
         ┌─────────────┐┌─────────────┐┌─────────────┐
         │ STARSHIPS   ││  VEHICLES   ││FILM_CHARS   │
         │─────────────││─────────────││─────────────│
         │ id (PK)     ││ id (PK)     ││ film_id     │
         │ name        ││ name        ││ character_id│
         │ model       ││ model       │└─────────────┘
         │ manufacturer││ manufacturer│       │
         │ cost        ││ cost        │       │
         │ length      ││ length      │       │
         │ crew        ││ crew        │       │
         │ passengers  ││ passengers  │       │
         │ cargo_cap   ││ cargo_cap   │       │
         │ hyperdrive  ││ vehicle_class│      │
         │ MGLT        ││ ...         │       │
         │ starship_cls││             │       │
         │ ...         │└─────────────┘       │
         └─────────────┘                      │
                │                             │
                └─────────────────────────────┘
```

## Core Tables

### CHARACTERS (people)
Main characters from the Star Wars universe.
- **id** (PK): Unique character identifier
- **name**: Character name (e.g., 'Luke Skywalker', 'Darth Vader')
- **height**: Height in centimeters
- **mass**: Weight in kilograms
- **hair_color**: Hair color
- **skin_color**: Skin color
- **eye_color**: Eye color
- **birth_year**: Birth year (e.g., '19BBY' = 19 years Before Battle of Yavin)
- **gender**: Gender (male, female, n/a)
- **homeworld_id** (FK): References PLANETS.id
- **species_id** (FK): References SPECIES.id
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this character

### FILMS
Star Wars films in the saga.
- **id** (PK): Unique film identifier
- **title**: Film title (e.g., 'A New Hope', 'The Empire Strikes Back')
- **episode_id**: Episode number (1-9)
- **opening_crawl**: Opening text crawl
- **director**: Film director
- **producer**: Film producer(s)
- **release_date**: Film release date
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this film

### PLANETS
Planets in the Star Wars universe.
- **id** (PK): Unique planet identifier
- **name**: Planet name (e.g., 'Tatooine', 'Alderaan', 'Hoth')
- **rotation_period**: Hours per day
- **orbital_period**: Days per year
- **diameter**: Planet diameter in kilometers
- **climate**: Climate type (e.g., 'arid', 'temperate', 'frozen')
- **gravity**: Gravity relative to Earth (e.g., '1 standard')
- **terrain**: Terrain types (e.g., 'desert', 'grasslands', 'mountains')
- **surface_water**: Percentage of surface covered by water
- **population**: Planet population
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this planet

### SPECIES
Alien species in the Star Wars universe.
- **id** (PK): Unique species identifier
- **name**: Species name (e.g., 'Human', 'Wookiee', 'Droid')
- **classification**: Biological classification (e.g., 'mammal', 'reptile', 'artificial')
- **designation**: Designation (e.g., 'sentient')
- **average_height**: Average height in centimeters
- **average_lifespan**: Average lifespan in years
- **eye_colors**: Possible eye colors
- **hair_colors**: Possible hair colors
- **skin_colors**: Possible skin colors
- **language**: Native language
- **homeworld_id** (FK): References PLANETS.id (species origin planet)
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this species

### STARSHIPS
Starships used for space travel.
- **id** (PK): Unique starship identifier
- **name**: Starship name (e.g., 'Millennium Falcon', 'X-wing', 'Death Star')
- **model**: Starship model
- **manufacturer**: Manufacturer name
- **cost_in_credits**: Purchase cost
- **length**: Length in meters
- **max_atmosphering_speed**: Maximum speed in atmosphere
- **crew**: Required crew size
- **passengers**: Passenger capacity
- **cargo_capacity**: Cargo capacity in kilograms
- **consumables**: Duration of consumables (e.g., '2 months')
- **hyperdrive_rating**: Hyperdrive class rating (lower is faster)
- **MGLT**: Speed in megalights per hour
- **starship_class**: Starship class (e.g., 'Starfighter', 'Deep Space Mobile Battlestation')
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this starship

### VEHICLES
Ground and atmospheric vehicles.
- **id** (PK): Unique vehicle identifier
- **name**: Vehicle name (e.g., 'Sand Crawler', 'AT-AT', 'Speeder bike')
- **model**: Vehicle model
- **manufacturer**: Manufacturer name
- **cost_in_credits**: Purchase cost
- **length**: Length in meters
- **max_atmosphering_speed**: Maximum speed
- **crew**: Required crew size
- **passengers**: Passenger capacity
- **cargo_capacity**: Cargo capacity in kilograms
- **consumables**: Duration of consumables
- **vehicle_class**: Vehicle class (e.g., 'wheeled', 'repulsorcraft', 'walker')
- **created**: Record creation timestamp
- **edited**: Record last edit timestamp
- **url**: API URL for this vehicle

## Junction Tables (Many-to-Many Relationships)

### FILM_CHARACTERS
Links films to characters appearing in them.
- **film_id** (FK): References FILMS.id
- **character_id** (FK): References CHARACTERS.id

### FILM_PLANETS
Links films to planets featured in them.
- **film_id** (FK): References FILMS.id
- **planet_id** (FK): References PLANETS.id

### FILM_SPECIES
Links films to species appearing in them.
- **film_id** (FK): References FILMS.id
- **species_id** (FK): References SPECIES.id

### FILM_STARSHIPS
Links films to starships featured in them.
- **film_id** (FK): References FILMS.id
- **starship_id** (FK): References STARSHIPS.id

### FILM_VEHICLES
Links films to vehicles featured in them.
- **film_id** (FK): References FILMS.id
- **vehicle_id** (FK): References VEHICLES.id

### CHARACTER_STARSHIPS (starship_pilots)
Links characters to starships they pilot.
- **character_id** (FK): References CHARACTERS.id
- **starship_id** (FK): References STARSHIPS.id

### CHARACTER_VEHICLES (vehicle_pilots)
Links characters to vehicles they operate.
- **character_id** (FK): References CHARACTERS.id
- **vehicle_id** (FK): References VEHICLES.id

## Key Relationships

1. **Planets → Characters** (1:N): Each planet is home to multiple characters
2. **Planets → Species** (1:N): Each planet is the homeworld of species
3. **Species → Characters** (1:N): Each species has multiple characters
4. **Films ↔ Characters** (N:N): Films feature multiple characters, characters appear in multiple films
5. **Films ↔ Planets** (N:N): Films feature multiple planets, planets appear in multiple films
6. **Films ↔ Species** (N:N): Films feature multiple species, species appear in multiple films
7. **Films ↔ Starships** (N:N): Films feature multiple starships, starships appear in multiple films
8. **Films ↔ Vehicles** (N:N): Films feature multiple vehicles, vehicles appear in multiple films
9. **Characters ↔ Starships** (N:N): Characters pilot multiple starships, starships have multiple pilots
10. **Characters ↔ Vehicles** (N:N): Characters operate multiple vehicles, vehicles have multiple operators

## Sample Queries

The Star Wars schema supports interesting queries such as:
- Find all characters from a specific planet
- List all starships piloted by a character
- Show all species that appear in a specific film
- Find the most expensive starships
- List characters by height or mass
- Show planets with specific climate types
- Find all droids in the database
- List films in chronological order by episode

## Data Source

This database is populated from the Star Wars API (SWAPI - https://swapi.dev/), which provides comprehensive data about the Star Wars universe from the films.

## Views

### FILM_STATS
Aggregated statistics about films.

### EXPENSIVE_STARSHIPS
Starships sorted by cost for quick reference.

### STARSHIP_PILOTS
Denormalized view of characters and their starships.

### VEHICLE_PILOTS
Denormalized view of characters and their vehicles.

This schema provides a rich dataset for learning SQL queries, joins, and data analysis using familiar Star Wars content.