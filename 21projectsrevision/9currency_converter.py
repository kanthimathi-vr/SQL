import requests
import json
import os
from datetime import datetime


API_KEY = "fcd38013a8de9380b98170a2"
API_URL = f"https://v6.exchangerate-api.com/v6/{API_KEY}/latest"
HISTORY_FILE = "conversion_history.json"
CACHE_FILE = "rate_cache.json"

def fetch_rates(base):
    url = f"{API_URL}/{base}"
    try:
        response = requests.get(url, timeout=5)
        data = response.json()
        if data.get("result") == "success":
            save_cache(base, data)
            return data["conversion_rates"]
        else:
            print("❌ API error:", data.get("error-type", "Unknown"))
            return load_cache(base)
    except Exception as e:
        print(f"⚠️ No internet or API error: {e}")
        print("👉 Using cached exchange rates if available...")
        return load_cache(base)

def save_cache(base, data):
    cache_data = {
        "base": base,
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "rates": data["conversion_rates"]
    }
    with open(CACHE_FILE, "w") as f:
        json.dump(cache_data, f, indent=2)

def load_cache(base):
    if not os.path.exists(CACHE_FILE):
        print("❌ No cache available.")
        return None
    with open(CACHE_FILE, "r") as f:
        cache = json.load(f)
    if cache["base"] != base:
        print(f"❌ Cache is for base currency {cache['base']}, not {base}")
        return None
    print(f"✅ Loaded cached rates (base: {base}) from {cache['timestamp']}")
    return cache["rates"]

def convert_currency(base, target, amount):
    print("🔄 Fetching exchange rates...")
    rates = fetch_rates(base)
    if not rates or target not in rates:
        print("❌ Conversion failed. Unsupported currency or no data.")
        return

    rate = rates[target]
    converted = round(rate * amount, 2)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"✅ {amount} {base} = {converted} {target} (Rate: {rate})")

    record = {
        "timestamp": timestamp,
        "base": base,
        "target": target,
        "amount": amount,
        "converted": converted,
        "rate": rate
    }
    save_history(record)

def save_history(record):
    history = []
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "r") as f:
            history = json.load(f)
    history.insert(0, record)
    history = history[:5]  # keep only last 5
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)

def show_history():
    if not os.path.exists(HISTORY_FILE):
        print("📄 No history yet.")
        return
    with open(HISTORY_FILE, "r") as f:
        history = json.load(f)
    print("\n📜 Last 5 Conversions:")
    for h in history:
        print(f"- {h['timestamp']}: {h['amount']} {h['base']} → {h['converted']} {h['target']} (Rate: {h['rate']})")

def main():
    while True:
        print("\n💱 Currency Converter CLI (Live + Offline Support)")
        print("1. Convert Currency")
        print("2. View Conversion History")
        print("3. Exit")

        choice = input("Choose an option: ").strip()
        if choice == "1":
            base = input("Enter base currency (e.g. USD): ").strip().upper()
            target = input("Enter target currency (e.g. INR): ").strip().upper()
            try:
                amount = float(input("Enter amount: "))
                convert_currency(base, target, amount)
            except ValueError:
                print("❌ Invalid amount entered.")
        elif choice == "2":
            show_history()
        elif choice == "3":
            print("👋 Exiting. Goodbye!")
            break
        else:
            print("❌ Invalid option.")

if __name__ == "__main__":
    main()
