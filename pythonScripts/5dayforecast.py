import requests
import json
import variables
from datetime import datetime
from collections import defaultdict
import statistics

f5day_weather_url = f'https://api.openweathermap.org/data/2.5/forecast?lat={variables.lat}&lon={variables.lon}&appid={variables.API_key}&units=metric'
daily_temps = defaultdict(list)
daily_cond = defaultdict(list)
daysOfForecast = []
result = []
i = 0
data = requests.get(f5day_weather_url).json()

for item in data["list"]:
    unixtimestamp = item["dt"]
    localdate = datetime.fromtimestamp(unixtimestamp) # converts unix timestamp to system local time
    dayOfWeek = localdate.strftime("%a").upper()
    timestamp = localdate.strftime('%Y-%m-%d')

    daily_temps[timestamp].append(item["main"]["temp"])

    daily_cond[timestamp].append(item["weather"][0]["id"])
    
    if not daysOfForecast or dayOfWeek != daysOfForecast[-1]:
        daysOfForecast.append(dayOfWeek)
    else:
        pass

for date in list(daily_temps.keys())[0:5]:
    if statistics.mode(daily_cond[date]) == 800: # Sun
        iconName = "\ue81a" # sun icon
    elif statistics.mode(daily_cond[date]) == 500: # Light rain
        iconName = "\uf61e" # rainy light icon
    elif statistics.mode(daily_cond[date]) == 501: # Moderate rain
        iconName = "\uf176" # rainy icon
    elif statistics.mode(daily_cond[date]) == 502 or statistics.mode(daily_cond[date]) == 503 or statistics.mode(daily_cond[date]) == 504: # heavy intensity and very heavy and extreme rains
        iconName = "\uf61f" # rainy heavy icon
    elif statistics.mode(daily_cond[date]) == 801 or statistics.mode(daily_cond[date]) == 802 or statistics.mode(daily_cond[date]) == 803 or statistics.mode(daily_cond[date]) == 804: # Clouds
        iconName = "\ue2bd" # cloud icon
    else:
        iconName = statistics.mode(daily_cond[date])

    result.append({
        "date": date,
        "min": round(min(daily_temps[date])),
        "max": round(max(daily_temps[date])),
        "day_of_week": daysOfForecast[i],
        "icon": iconName
    })
    i += 1

print(json.dumps(result))