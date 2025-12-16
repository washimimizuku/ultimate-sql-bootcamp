#!/usr/bin/env python3
"""
Demo script showing basic DuckDB usage
"""
import duckdb


def main():
    # Initialize connection
    con = None
    
    try:
        con = duckdb.connect("sample.db")
        print("🚀 DuckDB Demo")
        print("=" * 50)
        
        # 1. Check if database needs setup
        print("\n1. Checking database...")
        tables = con.execute("SHOW TABLES").fetchall()
        
        if not tables:
            print("Setting up database...")
            with open("setup.sql", "r") as f:
                setup_sql = f.read()
            con.execute(setup_sql)
        else:
            print("Database already exists, skipping setup.")
        
        # 2. List available tables
        print("\n2. Available tables:")
        tables = con.execute("SHOW TABLES").fetchall()
        for table in tables:
            print(f"  - {table[0]}")
        
        # 3. Run some sample queries
        print("\n3. Sample queries:")
        
        # Query 1: Count customers by nation
        print("\n📊 Customers by nation:")
        result = con.execute("""
            SELECT n.n_name, COUNT(*) as customer_count
            FROM customer c
            JOIN nation n ON c.c_nationkey = n.n_nationkey
            GROUP BY n.n_name
            ORDER BY customer_count DESC
        """).fetchall()
        
        for row in result:
            print(f"  {row[0]}: {row[1]} customers")
        
        # Query 2: Top customers by account balance
        print("\n💰 Top customers by account balance:")
        result = con.execute("""
            SELECT c_name, c_acctbal, n_name
            FROM customer c
            JOIN nation n ON c.c_nationkey = n.n_nationkey
            ORDER BY c_acctbal DESC
            LIMIT 5
        """).fetchall()
        
        for row in result:
            print(f"  {row[0]}: ${row[1]:.2f} ({row[2]})")
        
        print("\n✅ Demo completed!")
        
    except FileNotFoundError as e:
        print(f"❌ File not found: {e}")
    except Exception as e:
        print(f"❌ Error: {e}")
    finally:
        if con is not None:
            con.close()


if __name__ == "__main__":
    main()