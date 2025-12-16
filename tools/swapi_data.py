import urllib.request
import urllib.error
import json
import os

def fetch_all_data(endpoint):
    url = f"https://swapi.info/api/{endpoint}/"
    try:
        request = urllib.request.Request(url)
        with urllib.request.urlopen(request, timeout=30) as response:
            if response.status != 200:
                raise urllib.error.HTTPError(url, response.status, "HTTP Error", None, None)
            data = json.loads(response.read().decode('utf-8'))
        return data
    except urllib.error.URLError as e:
        print(f"Error fetching {endpoint}: {e}")
        raise

categories = ['films', 'people', 'planets', 'species', 'vehicles', 'starships']
output_dir = "../data/star-wars"

for category in categories:
    print(f"Fetching {category}...")
    data = fetch_all_data(category)
    
    filepath = os.path.join(output_dir, f"{category}.json")
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"Saved {len(data)} {category} to {filepath}")