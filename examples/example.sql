-- Create a sample table
CREATE TABLE products (
    id INTEGER,
    name VARCHAR,
    category VARCHAR,
    price DECIMAL(10,2)
);

-- Insert sample data
INSERT INTO products VALUES
    (1, 'Laptop', 'Electronics', 999.99),
    (2, 'Mouse', 'Electronics', 29.99),
    (3, 'Desk', 'Furniture', 299.99),
    (4, 'Chair', 'Furniture', 199.99);

-- Query the data
SELECT * FROM products;

SELECT category, COUNT(*) as count, AVG(price) as avg_price
FROM products
GROUP BY category;
