from jinja2 import Template
import os

# Example data to render into the template
data = {
    "site_title": "My Static Site",
    "author": "Vetri",
    "pages": [
        {"title": "Home", "content": "Welcome to the homepage!"},
        {"title": "About", "content": "This is a static site generator using Jinja2."},
        {"title": "Contact", "content": "Reach me at contact@example.com."}
    ]
}

# HTML template string with Jinja2 logic
template_str = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ site_title }}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        header { border-bottom: 1px solid #ccc; margin-bottom: 20px; }
        section { margin-bottom: 30px; }
    </style>
</head>
<body>
    <header>
        <h1>{{ site_title }}</h1>
        <p>Created by {{ author }}</p>
    </header>

    {% for page in pages %}
    <section>
        <h2>{{ page.title }}</h2>
        <p>{{ page.content }}</p>
    </section>
    {% endfor %}
</body>
</html>
"""

def generate_html(data, output_file="index.html"):
    template = Template(template_str)
    rendered_html = template.render(data)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(rendered_html)

    print(f"✅ Website generated: {output_file}")

if __name__ == "__main__":
    generate_html(data)
