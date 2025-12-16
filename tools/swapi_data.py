import urllib.request
import json
import os

def fetch_all_data(endpoint):
    url = f"https://swapi.info/api/{endpoint}/"
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read())
    return data

categories = ['films', 'people', 'planets', 'species', 'vehicles', 'starships']
output_dir = "../data/star-wars"

for category in categories:
    print(f"Fetching {category}...")
    data = fetch_all_data(category)
    
    filepath = os.path.join(output_dir, f"{category}.json")
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"Saved {len(data)} {category} to {filepath}")