import re
import sys
import os

EMAIL_REGEX = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"

def extract_emails_from_file(file_path):
    if not os.path.isfile(file_path):
        print(f"❌ File not found: {file_path}")
        return

    with open(file_path, 'r', encoding='utf-8') as file:
        text = file.read()
        emails = re.findall(EMAIL_REGEX, text)

        if emails:
            unique_emails = sorted(set(emails))
            print(f"\n📬 Found {len(unique_emails)} unique email address(es):\n")
            for email in unique_emails:
                print(f"  ✅ {email}")
        else:
            print("🔍 No email addresses found in the file.")

def main():
    if len(sys.argv) < 2:
        print("Usage: python email_extractor.py <filename.txt>")
        sys.exit(1)

    file_path = sys.argv[1]
    extract_emails_from_file(file_path)

if __name__ == "__main__":
    main()
