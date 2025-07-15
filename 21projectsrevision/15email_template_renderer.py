from jinja2 import Environment, FileSystemLoader

# Sample user data (could be loaded from a file or database)
users = [
    {"name": "Alice", "email": "alice@example.com", "plan": "Premium"},
    {"name": "Bob", "email": "bob@example.com", "plan": "Free"},
    {"name": "Charlie", "email": "charlie@example.com", "plan": "Enterprise"}
]

# Setup Jinja2 environment with file loader
env = Environment(loader=FileSystemLoader("."))  # Looks for templates in the current directory

# Load the email template file
template = env.get_template("email_template.txt")

def render_emails():
    for user in users:
        email_body = template.render(user)
        print(f"\n📧 Email to: {user['email']}\n")
        print(email_body)
        print("-" * 50)

if __name__ == "__main__":
    render_emails()

