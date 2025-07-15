from werkzeug.datastructures import CallbackDict

def on_session_change(session):
    print("🔄 Session updated:", dict(session))

# Create a session-like dict with a callback
session = CallbackDict(on_update=on_session_change)

def login():
    username = input("👤 Enter username: ").strip()
    session['username'] = username
    session['logged_in'] = True
    print(f"✅ {username} logged in.")

def logout():
    session.clear()
    print("👋 Logged out. Session cleared.")

def view_session():
    if session.get('logged_in'):
        print(f"\n🪪 Session Info:")
        for key, value in session.items():
            print(f"  {key}: {value}")
    else:
        print("⚠️  No active session.")

def main():
    while True:
        print("\n--- CLI Session Emulator ---")
        print("1. Login")
        print("2. View Session")
        print("3. Logout")
        print("4. Exit")

        choice = input("Choose an option [1-4]: ").strip()

        if choice == "1":
            login()
        elif choice == "2":
            view_session()
        elif choice == "3":
            logout()
        elif choice == "4":
            print("🛑 Exiting.")
            break
        else:
            print("❗ Invalid option.")

if __name__ == "__main__":
    main()
