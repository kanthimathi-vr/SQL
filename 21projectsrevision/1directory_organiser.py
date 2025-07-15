import os

def organize_directory(directory):
    # Get all files in the directory
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)

        # Skip directories
        if os.path.isdir(filepath):
            continue

        # Get the file extension (without the dot)
        _, ext = os.path.splitext(filename)
        ext = ext[1:].lower()  # remove dot and convert to lowercase

        if not ext:  # skip files with no extension
            continue

        # Create a folder for the extension if it doesn't exist
        folder_path = os.path.join(directory, ext)
        if not os.path.exists(folder_path):
            os.mkdir(folder_path)

        # Move the file into the appropriate folder
        new_path = os.path.join(folder_path, filename)
        os.rename(filepath, new_path)
        print(f"Moved: {filename} → {folder_path}/")

organize_directory("C:\\vetri\\python")



