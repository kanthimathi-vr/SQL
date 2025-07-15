import sqlite3
import hashlib
import os
import getpass

DB_NAME = "users.db"

def init_db():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            salt TEXT NOT NULL,
            password_hash TEXT NOT NULL
        )
    """)
    conn.commit()
    conn.close()

def hash_password(password, salt=None):
    if salt is None:
        salt = os.urandom(16).hex()  # generate 16 bytes salt as hex string
    hash_obj = hashlib.sha256()
    hash_obj.update((salt + password).encode('utf-8'))
    return salt, hash_obj.hexdigest()

def register_user():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()

    username = input("Choose a username: ").strip()
    cur.execute("SELECT * FROM users WHERE username = ?", (username,))
    if cur.fetchone():
        print("❌ Username already exists. Try logging in or choose another.")
        conn.close()
        return

    password = getpass.getpass("Choose a password: ")
    confirm = getpass.getpass("Confirm password: ")
    if password != confirm:
        print("❌ Passwords do not match.")
        conn.close()
        return

    salt, password_hash = hash_password(password)
    cur.execute("INSERT INTO users (username, salt, password_hash) VALUES (?, ?, ?)",
                (username, salt, password_hash))
    conn.commit()
    conn.close()
    print("✅ User registered successfully!")

def authenticate_user():
    conn = sqlite3.connect(DB_NAME)
    cur = conn.cursor()

    username = input("Username: ").strip()
    password = getpass.getpass("Password: ")

    cur.execute("SELECT salt, password_hash FROM users WHERE username = ?", (username,))
    record = cur.fetchone()
    conn.close()

    if not record:
        print("❌ User not found.")
        return False

    salt, stored_hash = record
    _, input_hash = hash_password(password, salt)

    if input_hash == stored_hash:
        print(f"✅ Welcome back, {username}!")
        return True
    else:
        print("❌ Incorrect password.")
        return False

def main_menu():
    init_db()
    while True:
        print("\n--- User Login System ---")
        print("1. Register")
        print("2. Login")
        print("3. Exit")

        choice = input("Choose an option [1-3]: ").strip()
        if choice == "1":
            register_user()
        elif choice == "2":
            if authenticate_user():
                # You can add post-login functionality here
                pass
        elif choice == "3":
            print("👋 Goodbye!")
            break
        else:
            print("❗ Invalid option. Please choose 1, 2, or 3.")

if __name__ == "__main__":
    main_menu()
