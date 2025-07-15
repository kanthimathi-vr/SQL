import requests
import sys


API_KEY = "27bcd20e66321d03615c489ac5cdb54d"
BASE_URL = "http://api.openweathermap.org/data/2.5/weather"

def get_weather(city):
    params = {
        "q": city,
        "appid": API_KEY,
        "units": "metric"  # or 'imperial' for Fahrenheit
    }

    try:
        response = requests.get(BASE_URL, params=params)
        response.raise_for_status()
        data = response.json()

        print("\n--- Current Weather ---")
        print(f"City       : {data['name']}")
        print(f"Temperature: {data['main']['temp']}°C")
        print(f"Condition  : {data['weather'][0]['description'].title()}")
        print(f"Humidity   : {data['main']['humidity']}%")
        print(f"Wind Speed : {data['wind']['speed']} m/s\n")

    except requests.HTTPError as e:
        print("HTTP Error:", e)
    except KeyError:
        print("Error: Could not parse weather data.")
    except Exception as e:
        print("Error:", e)

def main():
    if len(sys.argv) < 2:
        print("Usage: python weather_cli.py <city_name>")
        sys.exit(1)

    city = " ".join(sys.argv[1:])
    get_weather(city)

if __name__ == "__main__":
    main()
