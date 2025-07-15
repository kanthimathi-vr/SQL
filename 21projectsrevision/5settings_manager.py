import json
import os

CONFIG_FILE = "user_settings.json"

# Default settings
DEFAULT_SETTINGS = {
    "dark_mode": False,
    "language": "en",
    "notifications": True
}

def load_settings():
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                print("Warning: Corrupted config file. Loading defaults.")
    return DEFAULT_SETTINGS.copy()

def save_settings(settings):
    with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
        json.dump(settings, f, indent=4)
    print("Settings saved.")

def update_setting(settings, key, value):
    if key not in settings:
        print(f"'{key}' is not a valid setting.")
        return settings
    # Type conversion for known fields
    if isinstance(settings[key], bool):
        settings[key] = value.lower() == "true"
    elif isinstance(settings[key], int):
        settings[key] = int(value)
    else:
        settings[key] = value
    print(f"Updated '{key}' to '{settings[key]}'")
    return settings

def show_settings(settings):
    print("\nCurrent Settings:")
    for key, value in settings.items():
        print(f"  {key}: {value}")
    print()

def main():
    settings = load_settings()

    while True:
        show_settings(settings)
        print("Options:")
        print("  1. Update setting")
        print("  2. Save and exit")
        print("  3. Exit without saving")
        choice = input("Choose an option [1-3]: ").strip()

        if choice == "1":
            key = input("Enter setting name: ").strip()
            value = input("Enter new value: ").strip()
            settings = update_setting(settings, key, value)
        elif choice == "2":
            save_settings(settings)
            break
        elif choice == "3":
            print("Exiting without saving.")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
