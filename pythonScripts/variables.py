import requests

API_key = ''
city_name = 'Almaty'
country_code = 'KZ'

get_coords = f'http://api.openweathermap.org/geo/1.0/direct?q={city_name},{country_code}&appid={API_key}'
coords = requests.get(get_coords).json()
lat = coords[0]["lat"]
lon = coords[0]["lon"]
