import json
import os
import re

def extract_id_from_url(url):
    """Extract ID from SWAPI URL"""
    match = re.search(r'/(\d+)/?$', url)
    return int(match.group(1)) if match else None

def find_item_by_id(item_id, data_list):
    """Find item in data list by ID (1-based index)"""
    if 1 <= item_id <= len(data_list):
        return data_list[item_id - 1]  # Convert to 0-based index
    return None

def resolve_references(data, all_data):
    """Replace URL references with {id, name} objects"""
    if isinstance(data, dict):
        resolved = {}
        for key, value in data.items():
            if isinstance(value, list) and value and isinstance(value[0], str) and value[0].startswith('https://swapi'):
                # This is a list of URLs - resolve them
                resolved_refs = []
                successful_resolutions = 0
                
                for url in value:
                    ref_id = extract_id_from_url(url)
                    url_type = url.split('/')[-2]  # Extract type from URL (people, planets, etc.)
                    
                    if url_type in all_data and ref_id:
                        # Find the referenced item by ID
                        ref_item = find_item_by_id(ref_id, all_data[url_type])
                        if ref_item:
                            resolved_refs.append({
                                'id': ref_id,
                                'name': ref_item.get('name', ref_item.get('title', f"Unknown {url_type}"))
                            })
                            successful_resolutions += 1
                        else:
                            resolved_refs.append({'id': ref_id, 'name': f"Unknown {url_type} {ref_id}"})
                
                # Only replace if we had some successful resolutions
                if successful_resolutions > 0:
                    resolved[key] = resolved_refs
                    print(f"  Resolved {successful_resolutions}/{len(value)} URLs in {key}")
                else:
                    # Keep original URLs if no resolutions were successful
                    resolved[key] = value
                    print(f"  Kept original URLs in {key} (no successful resolutions)")
                    
            elif isinstance(value, str) and value.startswith('https://swapi'):
                # Single URL reference
                ref_id = extract_id_from_url(value)
                url_type = value.split('/')[-2]
                
                if url_type in all_data and ref_id:
                    ref_item = find_item_by_id(ref_id, all_data[url_type])
                    if ref_item:
                        resolved[key] = {
                            'id': ref_id,
                            'name': ref_item.get('name', ref_item.get('title', f"Unknown {url_type}"))
                        }
                        print(f"  Resolved single URL in {key}")
                    else:
                        # Keep original URL if resolution failed
                        resolved[key] = value
                        print(f"  Kept original URL in {key} (no match found)")
                else:
                    resolved[key] = value
            else:
                resolved[key] = resolve_references(value, all_data)
        return resolved
    elif isinstance(data, list):
        return [resolve_references(item, all_data) for item in data]
    else:
        return data

def main():
    data_dir = "../data/star-wars"
    categories = ['films', 'people', 'planets', 'species', 'vehicles', 'starships']
    
    # Load all existing JSON files
    print("Loading existing JSON files...")
    all_data = {}
    for category in categories:
        filepath = os.path.join(data_dir, f"{category}.json")
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                all_data[category] = json.load(f)
            print(f"Loaded {len(all_data[category])} {category}")
        else:
            print(f"Warning: {filepath} not found")
            all_data[category] = []
    
    # Process each file and resolve references
    print("\nResolving references...")
    for category in categories:
        if all_data[category]:
            print(f"Processing {category}...")
            resolved_data = resolve_references(all_data[category], all_data)
            
            # Save resolved data
            filepath = os.path.join(data_dir, f"{category}.json")
            with open(filepath, 'w') as f:
                json.dump(resolved_data, f, indent=2)
            
            print(f"Saved resolved {category} to {filepath}")
    
    print("\nReference resolution completed!")

if __name__ == "__main__":
    main()