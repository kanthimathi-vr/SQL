import re
import sys
import os

# IPv4 regex pattern
IP_REGEX = r"\b\d{1,3}(?:\.\d{1,3}){3}\b"

def extract_ips_from_file(file_path):
    if not os.path.isfile(file_path):
        print(f"❌ File not found: {file_path}")
        return

    with open(file_path, 'r', encoding='utf-8', errors='ignore') as file:
        text = file.read()

        # Find all matches
        ips = re.findall(IP_REGEX, text)
        unique_ips = sorted(set(ips))

        if unique_ips:
            print(f"\n🌐 Found {len(unique_ips)} unique IP address(es):\n")
            for ip in unique_ips:
                print(f"  🔹 {ip}")
        else:
            print("🔍 No IP addresses found in the file.")

def main():
    if len(sys.argv) < 2:
        print("Usage: python ip_extractor.py <logfile.txt>")
        sys.exit(1)

    file_path = sys.argv[1]
    extract_ips_from_file(file_path)

if __name__ == "__main__":
    main()
