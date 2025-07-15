from werkzeug.security import generate_password_hash, check_password_hash
import getpass

def main():
    print("🔒 Password Hashing Tool")

    # Input password (hidden)
    password = getpass.getpass("Enter password to hash: ")

    # Generate hash (default method: pbkdf2:sha256)
    hashed = generate_password_hash(password)
    print(f"\nHashed password:\n{hashed}\n")

    # Verify password
    verify = getpass.getpass("Re-enter password to verify: ")
    if check_password_hash(hashed, verify):
        print("✅ Password verification successful!")
    else:
        print("❌ Password verification failed!")

if __name__ == "__main__":
    main()
