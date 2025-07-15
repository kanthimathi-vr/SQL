import os
import sys

def get_size(start_path):
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            try:
                if not os.path.islink(fp):  # Skip symbolic links
                    total_size += os.stat(fp).st_size
            except FileNotFoundError:
                # Skip files that vanish or are inaccessible
                pass
    return total_size

def scan_directory(base_path):
    folder_sizes = {}
    for dirpath, dirnames, filenames in os.walk(base_path):
        folder_size = get_size(dirpath)
        folder_sizes[dirpath] = folder_size

    return folder_sizes

def format_size(bytes_size):
    for unit in ['B','KB','MB','GB','TB']:
        if bytes_size < 1024.0:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024.0

def main():
    if len(sys.argv) < 2:
        print("Usage: python disk_usage_analyzer.py <directory_path>")
        sys.exit(1)

    base_path = sys.argv[1]
    if not os.path.isdir(base_path):
        print("Invalid directory path.")
        sys.exit(1)

    print(f"Scanning '{base_path}'...\n")
    folder_sizes = scan_directory(base_path)

    for folder, size in sorted(folder_sizes.items(), key=lambda x: x[1], reverse=True):
        print(f"{format_size(size):>10}  {folder}")

if __name__ == "__main__":
    main()
