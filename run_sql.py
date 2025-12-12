#!/usr/bin/env python3
"""
Simple SQL file runner - Quick execution of SQL files
"""
import sys
from sql_runner import SQLRunner


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <sql_file>")
        print("Example: python run_sql.py exercises/section-3-ddl/create.sql")
        sys.exit(1)
    
    sql_file = sys.argv[1]
    runner = SQLRunner()
    
    try:
        # Setup database if it doesn't exist
        runner.setup_database()
        runner.execute_file(sql_file)
    finally:
        runner.close()


if __name__ == "__main__":
    main()