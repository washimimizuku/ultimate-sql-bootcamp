#!/usr/bin/env python3
"""
Simple SQL file runner - Quick execution of SQL files
"""
import sys
import os
from pathlib import Path
import duckdb


def remove_sql_comments(sql_content):
    """Remove SQL comments while preserving quoted strings"""
    lines = sql_content.split('\n')
    clean_lines = []
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('--'):
            continue
        elif '--' in line:
            # Remove comments if not inside quotes
            in_quotes = False
            quote_char = None
            i = 0
            while i < len(line):
                char = line[i]
                if char in ("'", '"') and not in_quotes:
                    in_quotes = True
                    quote_char = char
                elif char == quote_char and in_quotes:
                    # Check for escaped quotes (doubled quotes or backslash-escaped)
                    if i > 0 and line[i - 1] == '\\':
                        pass  # Skip backslash-escaped quote
                    elif i + 1 < len(line) and line[i + 1] == quote_char:
                        i += 1  # Skip doubled quote
                    else:
                        in_quotes = False
                        quote_char = None
                elif not in_quotes and line[i:i+2] == '--':
                    line = line[:i]
                    break
                i += 1
        if line.strip():
            clean_lines.append(line)
    
    return '\n'.join(clean_lines)


def execute_statements(con, statements):
    """Execute SQL statements one by one with result handling"""
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


def execute_sql_file(con, sql_content):
    """Execute SQL file content with fallback to statement-by-statement execution"""
    # Execute the entire SQL file as one block to handle complex statements
    try:
        con.execute(sql_content)
        print(f"  ✅ SQL file executed successfully")
    except Exception as e:
        print(f"  ❌ SQL Error: {e}")
        # If full execution fails, try statement-by-statement as fallback
        print("  🔄 Trying statement-by-statement execution...")
        
        # Remove comments and split by semicolon
        clean_sql = remove_sql_comments(sql_content)
        statements = [stmt.strip() for stmt in clean_sql.split(';') if stmt.strip()]
        
        execute_statements(con, statements)


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <sql_file>")
        print("Example: python run_sql.py exercises/section-3-ddl/create.sql")
        sys.exit(1)
    
    sql_file = sys.argv[1]
    
    # Validate path to prevent path traversal attacks
    try:
        sql_path = Path(sql_file)
        # Resolve and validate resolved path is within current directory
        resolved_path = sql_path.resolve()
        resolved_cwd = Path.cwd().resolve()
        resolved_path.relative_to(resolved_cwd)
        sql_path = resolved_path
    except (ValueError, OSError):
        print(f"❌ Invalid file path: {sql_file}")
        sys.exit(1)
    
    if not sql_path.exists():
        print(f"❌ File not found: {sql_file}")
        sys.exit(1)
    
    con = None
    
    try:
        # Connect to database
        con = duckdb.connect("sample.db")  # Use persistent database with sample data
        
        print(f"📄 Executing: {sql_path}")
        
        # Read and execute SQL file
        with open(sql_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Check for MERGE statements
        if 'MERGE' in sql_content.upper():
            print("  ⚠️  MERGE statements detected. Python DuckDB doesn't support MERGE syntax.")
            print("  💡 Alternative: Use DuckDB CLI instead:")
            print(f"     duckdb sample.db < {sql_file}")
            return
        
        execute_sql_file(con, sql_content)
        
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