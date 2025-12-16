import requests
import json
import os

def fetch_all_data(endpoint):
    url = f"https://swapi.info/api/{endpoint}/"
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching {endpoint}: {e}")
        raise

categories = ['films', 'people', 'planets', 'species', 'vehicles', 'starships']
output_dir = "../data/star-wars"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

for category in categories:
    print(f"Fetching {category}...")
    data = fetch_all_data(category)
    
    filepath = os.path.join(output_dir, f"{category}.json")
    try:
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Saved {len(data)} {category} to {filepath}")
    except (IOError, PermissionError, OSError) as e:
        print(f"Error saving {filepath}: {e}")