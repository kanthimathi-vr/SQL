import os
import sys

def search_files(base_path, query):
    matches = []

    for dirpath, dirnames, filenames in os.walk(base_path):
        for filename in filenames:
            if query.lower() in filename.lower():  # Case-insensitive substring match
                full_path = os.path.join(dirpath, filename)
                matches.append(full_path)

    return matches

def main():
    if len(sys.argv) < 3:
        print("Usage: python file_searcher.py <directory> <search_query>")
        print("Example: python file_searcher.py /home/user .txt")
        sys.exit(1)

    base_path = sys.argv[1]
    query = sys.argv[2]

    if not os.path.isdir(base_path):
        print("Invalid directory path.")
        sys.exit(1)

    print(f"Searching in '{base_path}' for '{query}'...\n")

    results = search_files(base_path, query)

    if results:
        print(f"Found {len(results)} matching file(s):\n")
        for path in results:
            print(path)
    else:
        print("No matching files found.")

if __name__ == "__main__":
    main()
