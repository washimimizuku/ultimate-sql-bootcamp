import requests
import json
import os
import re

def extract_id_from_url(url):
    """Extract ID from SWAPI URL"""
    match = re.search(r'/(\d+)/?$', url)
    return int(match.group(1)) if match else None

def fetch_all_data(endpoint):
    url = f"https://swapi.info/api/{endpoint}/"
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        # Add id field to each record based on URL
        for item in data:
            if 'url' in item:
                item_id = extract_id_from_url(item['url'])
                if item_id:
                    item['id'] = item_id
        
        return data
    except requests.RequestException as e:
        print(f"Error fetching {endpoint}: {e}")
        raise

categories = ['films', 'characters', 'planets', 'species', 'vehicles', 'starships']
output_dir = "data/star-wars"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

for category in categories:
    print(f"Fetching {category}...")
    # Map characters to people for API endpoint
    api_endpoint = 'people' if category == 'characters' else category
    data = fetch_all_data(api_endpoint)
    
    # Ensure json subdirectory exists
    json_dir = os.path.join(output_dir, "json")
    os.makedirs(json_dir, exist_ok=True)
    filepath = os.path.join(json_dir, f"{category}.json")
    try:
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Saved {len(data)} {category} to {filepath}")
    except (IOError, PermissionError, OSError) as e:
        print(f"Error saving {filepath}: {e}")