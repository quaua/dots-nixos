import requests
import json
import variables

get_current_weather_url = f'https://api.openweathermap.org/data/2.5/weather?lat={variables.lat}&lon={variables.lon}&appid={variables.API_key}&units=metric'

if requests.get(get_current_weather_url).status_code == 200:
    data = requests.get(get_current_weather_url).json()
    print(json.dumps(data))
else:
    print("Not Connected" , requests.get(get_current_weather_url).status_code)
