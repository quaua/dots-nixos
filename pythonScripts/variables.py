import requests
import json
import path

def load_config():
    defaults = {'city': '', 'country': ''}
    try:
        with open(path.CONFIG_PATH) as f:
            defaults.update(json.load(f))
    except (FileNotFoundError, json.JSONDecodeError):
        print("Error FileNotFoundError or json.JSONDecodeError")
    return defaults

API_key = ''
city_name = load_config()['city']
country_code = load_config()['country']

get_coords = f'http://api.openweathermap.org/geo/1.0/direct?q={city_name},{country_code}&appid={API_key}'
coords = requests.get(get_coords).json()
lat = coords[0]["lat"]
lon = coords[0]["lon"]
