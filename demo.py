#!/usr/bin/env python3
"""
Demo script showing how to use the SQL Runner
"""
from sql_runner import SQLRunner


def main():
    # Initialize the SQL runner
    runner = None
    
    try:
        runner = SQLRunner("sample.db")
        print("🚀 SQL Runner Demo")
        print("=" * 50)
        
        # 1. Setup the database
        print("\n1. Setting up database...")
        runner.setup_database()
        
        # 2. List available tables
        print("\n2. Available tables:")
        runner.list_tables()
        
        # 3. Run some sample queries
        print("\n3. Sample queries:")
        
        # Query 1: Count customers by nation
        print("\n📊 Customers by nation:")
        runner.run_query("""
            SELECT n.n_name, COUNT(*) as customer_count
            FROM customer c
            JOIN nation n ON c.c_nationkey = n.n_nationkey
            GROUP BY n.n_name
            ORDER BY customer_count DESC
        """)
        
        # Query 2: Top customers by account balance
        print("\n💰 Top customers by account balance:")
        runner.run_query("""
            SELECT c_name, c_acctbal, n_name
            FROM customer c
            JOIN nation n ON c.c_nationkey = n.n_nationkey
            ORDER BY c_acctbal DESC
            LIMIT 5
        """)
        
        # 4. Execute an exercise file
        print("\n4. Running exercise file...")
        runner.execute_file("exercises/section-3-ddl/create.sql")
        
        print("\n✅ Demo completed!")
        
    except FileNotFoundError as e:
        print(f"❌ File not found: {e}")
    except ImportError as e:
        print(f"❌ Import error: {e}")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        import traceback
    finally:
        if runner is not None:
            runner.close()
        runner.close()


if __name__ == "__main__":
    main()