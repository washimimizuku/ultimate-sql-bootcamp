#!/usr/bin/env python3
"""
Simple SQL file runner - Quick execution of SQL files
"""
import sys
import os
from sql_runner import SQLRunner


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <sql_file>")
        print("Example: python run_sql.py exercises/section-3-ddl/create.sql")
        sys.exit(1)
    
    sql_file = sys.argv[1]
    
    # Validate file exists
    if not os.path.exists(sql_file):
        print(f"❌ Error: File '{sql_file}' not found")
        sys.exit(1)
    
    runner = SQLRunner()
    
    try:
        # Setup database if it doesn't exist
        runner.setup_database()
        runner.execute_file(sql_file)
    except Exception as e:
        print(f"❌ Error executing SQL file: {e}")
        sys.exit(1)
    finally:
        runner.close()


if __name__ == "__main__":
    main()