import requests
import sys

GITHUB_API_URL = "https://api.github.com/users/"

def fetch_profile(username):
    url = GITHUB_API_URL + username

    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise error for bad responses
        data = response.json()

        print("\n--- GitHub Profile Info ---")
        print(f"Name        : {data.get('name') or 'N/A'}")
        print(f"Username    : {data['login']}")
        print(f"Public Repos: {data['public_repos']}")
        print(f"Followers   : {data['followers']}")
        print(f"Following   : {data['following']}")
        print(f"Location    : {data.get('location') or 'N/A'}")
        print(f"Bio         : {data.get('bio') or 'N/A'}")
        print(f"Profile URL : {data['html_url']}")
        print("------------------------------\n")

    except requests.HTTPError as err:
        if response.status_code == 404:
            print("Error: User not found.")
        else:
            print(f"HTTP Error: {err}")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python github_profile_fetcher.py <github_username>")
        sys.exit(1)

    username = sys.argv[1]
    fetch_profile(username)

if __name__ == "__main__":
    main()
