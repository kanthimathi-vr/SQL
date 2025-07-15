import re

def validate_password(password):
    # Define validation rules
    rules = {
        "At least 8 characters": len(password) >= 8,
        "Contains an uppercase letter": bool(re.search(r"[A-Z]", password)),
        "Contains a lowercase letter": bool(re.search(r"[a-z]", password)),
        "Contains a digit": bool(re.search(r"\d", password)),
        "Contains a special character": bool(re.search(r"[!@#$%^&*(),.?\":{}|<>]", password))
    }

    passed = all(rules.values())

    print("\n🔎 Password Validation Result:")
    for rule, passed_rule in rules.items():
        print(f"  {'✅' if passed_rule else '❌'} {rule}")

    if passed:
        print("\n🎉 Strong password! All requirements met.\n")
    else:
        print("\n⚠️ Password is weak. Please fix the issues above.\n")

def main():
    print("=== Password Validator ===")
    password = input("Enter a password to validate: ").strip()
    validate_password(password)

if __name__ == "__main__":
    main()
