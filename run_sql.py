#!/usr/bin/env python3
"""
Simple SQL file runner - Quick execution of SQL files
"""
import sys
import os
import duckdb


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <sql_file>")
        print("Example: python run_sql.py exercises/section-3-ddl/create.sql")
        sys.exit(1)
    
    sql_file = sys.argv[1]
    
    if not os.path.exists(sql_file):
        print(f"❌ File not found: {sql_file}")
        sys.exit(1)
    
    con = None
    
    try:
        # Connect to database
        con = duckdb.connect("sample.db")  # Use persistent database with sample data
        
        print(f"📄 Executing: {os.path.abspath(sql_file)}")
        
        # Read and execute SQL file
        with open(sql_file, 'r') as f:
            sql_content = f.read()
        
        # Check for MERGE statements
        if 'MERGE' in sql_content.upper():
            print("  ⚠️  MERGE statements detected. Python DuckDB doesn't support MERGE syntax.")
            print("  💡 Alternative: Use DuckDB CLI instead:")
            print(f"     duckdb sample.db < {sql_file}")
            return
        
        # Execute the entire SQL file as one block to handle complex statements
        try:
            con.execute(sql_content)
            print(f"  ✅ SQL file executed successfully")
        except Exception as e:
            print(f"  ❌ SQL Error: {e}")
            # If full execution fails, try statement-by-statement as fallback
            print("  🔄 Trying statement-by-statement execution...")
            
            # Remove comment-only lines and split by semicolon
            lines = sql_content.split('\n')
            clean_lines = []
            for line in lines:
                stripped = line.strip()
                if stripped.startswith('--'):
                    continue
                elif '--' in line:
                    line = line[:line.index('--')]
                if line.strip():
                    clean_lines.append(line)
            
            clean_sql = '\n'.join(clean_lines)
            statements = [stmt.strip() for stmt in clean_sql.split(';') if stmt.strip()]
            
            for i, statement in enumerate(statements, 1):
                try:
                    cursor = con.execute(statement)
                    if statement.strip().upper().startswith(('SELECT', 'DESCRIBE', 'SHOW')):
                        result = cursor.fetchall()
                        print(f"  ✅ Statement {i}: {len(result)} rows")
                        for row in result[:5]:
                            print(f"    {row}")
                        if len(result) > 5:
                            print(f"    ... and {len(result) - 5} more rows")
                    else:
                        print(f"  ✅ Statement {i}: Executed successfully")
                except Exception as stmt_e:
                    print(f"  ❌ SQL Error in statement {i}: {stmt_e}")
        
        print("✅ File execution completed!")
        
    except FileNotFoundError as e:
        print(f"❌ File not found: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)
    finally:
        if con is not None:
            con.close()


if __name__ == "__main__":
    main()