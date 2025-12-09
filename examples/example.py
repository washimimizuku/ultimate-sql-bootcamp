import duckdb

# Create an in-memory database
con = duckdb.connect(':memory:')

# Create a sample table
con.execute("""
    CREATE TABLE employees (
        id INTEGER,
        name VARCHAR,
        department VARCHAR,
        salary INTEGER
    )
""")

# Insert sample data
con.execute("""
    INSERT INTO employees VALUES
    (1, 'Alice', 'Engineering', 90000),
    (2, 'Bob', 'Sales', 75000),
    (3, 'Charlie', 'Engineering', 95000),
    (4, 'Diana', 'HR', 70000)
""")

# Query the data
result = con.execute("SELECT * FROM employees WHERE department = 'Engineering'").fetchall()
print("Engineers:")
for row in result:
    print(row)

con.close()
