from jinja2 import Template

# Sample invoice data
invoice_data = {
    "invoice_number": "INV-2025-001",
    "company_name": "Vetri Technologies",
    "client_name": "John Doe",
    "date": "2025-07-15",
    "items": [
        {"description": "Web Design", "quantity": 1, "price": 500.00},
        {"description": "Hosting (1 year)", "quantity": 1, "price": 120.00},
        {"description": "Domain (.com)", "quantity": 1, "price": 15.00}
    ],
    "tax_rate": 0.18
}

# HTML template with Jinja2
template_str = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Invoice {{ invoice_number }}</title>
    <style>
        body { font-family: sans-serif; padding: 40px; }
        h1 { border-bottom: 1px solid #ccc; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        td, th { padding: 8px 12px; border: 1px solid #ddd; text-align: left; }
        tfoot td { font-weight: bold; }
    </style>
</head>
<body>
    <h1>Invoice {{ invoice_number }}</h1>
    <p><strong>From:</strong> {{ company_name }}<br>
       <strong>To:</strong> {{ client_name }}<br>
       <strong>Date:</strong> {{ date }}</p>

    <table>
        <thead>
            <tr><th>Description</th><th>Qty</th><th>Unit Price</th><th>Total</th></tr>
        </thead>
        <tbody>
        {% set subtotal = 0 %}
        {% for item in items %}
            {% set line_total = item.quantity * item.price %}
            {% set subtotal = subtotal + line_total %}
            <tr>
                <td>{{ item.description }}</td>
                <td>{{ item.quantity }}</td>
                <td>${{ '%.2f' % item.price }}</td>
                <td>${{ '%.2f' % line_total }}</td>
            </tr>
        {% endfor %}
        </tbody>
        <tfoot>
            <tr><td colspan="3">Subtotal</td><td>${{ '%.2f' % subtotal }}</td></tr>
            <tr><td colspan="3">Tax ({{ tax_rate * 100 }}%)</td><td>${{ '%.2f' % (subtotal * tax_rate) }}</td></tr>
            <tr><td colspan="3">Total</td><td>${{ '%.2f' % (subtotal * (1 + tax_rate)) }}</td></tr>
        </tfoot>
    </table>
</body>
</html>
"""

def generate_invoice(data, output_file="invoice.html"):
    template = Template(template_str)
    html = template.render(data)
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(html)
    
    print(f"✅ Invoice saved to: {output_file}")

if __name__ == "__main__":
    generate_invoice(invoice_data)
