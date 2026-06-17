import requests
import json
import variables
from datetime import datetime
from collections import defaultdict

get_5day_weather_url = f'https://api.openweathermap.org/data/2.5/forecast?lat={variables.lat}&lon={variables.lon}&appid={variables.API_key}&units=metric'
daily_temps = defaultdict(list)
data = requests.get(get_5day_weather_url).json()

for item in data["list"]:
    timestamp = datetime.fromtimestamp(item["dt"]) # converts unix timestamp to system local time
    localdate = timestamp.strftime('%Y-%m-%d')
    daily_temps[localdate].append(item["main"]["temp"])

result = []
for date in list(daily_temps.keys())[1:5]:
    result.append({
        "date": date,
        "min": round(min(daily_temps[date])),
        "max": round(max(daily_temps[date])),
    })
print(json.dumps(result))
