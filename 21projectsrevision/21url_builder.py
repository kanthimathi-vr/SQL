from urllib.parse import urlencode, urljoin

def build_url():
    base = input("🌐 Enter base URL (e.g. https://example.com/api/users): ").strip()

    print("🔧 Add query parameters (key=value). Type 'done' to finish.")
    params = {}
    while True:
        entry = input("> ").strip()
        if entry.lower() == "done":
            break
        if "=" in entry:
            key, value = entry.split("=", 1)
            params[key.strip()] = value.strip()
        else:
            print("❗ Use key=value format.")

    query_string = urlencode(params)
    final_url = f"{base}?{query_string}" if query_string else base
    print(f"\n✅ Final URL: {final_url}")

def quick_encode():
    print("💡 Quick URL Encode")
    params = {}
    while True:
        entry = input("Param (key=value or 'done'): ").strip()
        if entry.lower() == "done":
            break
        if "=" in entry:
            k, v = entry.split("=", 1)
            params[k.strip()] = v.strip()
        else:
            print("❗ Invalid format.")
    encoded = urlencode(params)
    print(f"🔗 Encoded query string: ?{encoded}")

def main():
    while True:
        print("\n--- URL Builder Tool ---")
        print("1. Build URL with base and params")
        print("2. Quick URL encode")
        print("3. Exit")

        choice = input("Choose [1-3]: ").strip()

        if choice == "1":
            build_url()
        elif choice == "2":
            quick_encode()
        elif choice == "3":
            print("👋 Bye!")
            break
        else:
            print("❗ Invalid choice.")

if __name__ == "__main__":
    main()
