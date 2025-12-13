#!/usr/bin/env python3
"""
SQL Runner - Execute SQL files against DuckDB
"""
import duckdb
import os
import sys
import argparse
from pathlib import Path
from typing import List, Optional


class SQLRunner:
    def __init__(self, db_path: str = "sample.db"):
        """Initialize DuckDB connection"""
        self.db_path = db_path
        self.conn = duckdb.connect(db_path)
        
    def _split_sql_statements(self, sql_content: str) -> List[str]:
        """Split SQL content into individual statements, handling basic cases"""
        statements = []
        current_statement = ""
        in_string = False
        string_char = None
        
        i = 0
        while i < len(sql_content):
            char = sql_content[i]
            
            # Handle string literals
            if char in ("'", '"') and not in_string:
                in_string = True
                string_char = char
            elif char == string_char and in_string:
                in_string = False
                string_char = None
            
            # Handle semicolons
            if char == ';' and not in_string:
                stmt = current_statement.strip()
                if stmt and not stmt.startswith('--'):
                    statements.append(stmt)
                current_statement = ""
            else:
                current_statement += char
            
            i += 1
        
        # Add final statement if exists
        stmt = current_statement.strip()
        if stmt and not stmt.startswith('--'):
            statements.append(stmt)
        
        return statements
    
    def execute_file(self, file_path: str) -> None:
        """Execute SQL commands from a file"""
        # Validate and resolve the file path to prevent path traversal
        try:
            resolved_path = Path(file_path).resolve()
            current_dir = Path.cwd().resolve()
            
            # Check if the resolved path is within the current directory or its subdirectories
            if not str(resolved_path).startswith(str(current_dir)):
                print(f"❌ Access denied: File path outside allowed directory: {file_path}")
                return
                
            if not resolved_path.exists():
                print(f"❌ File not found: {file_path}")
                return
                
            if not resolved_path.is_file():
                print(f"❌ Not a file: {file_path}")
                return
                
        except (OSError, ValueError) as e:
            print(f"❌ Invalid file path: {file_path} - {e}")
            return
            
        print(f"📄 Executing: {resolved_path}")
        
        try:
            with open(resolved_path, 'r') as f:
                sql_content = f.read()
            
            # Split by semicolon and execute each statement
            # Note: This simple splitting may not handle semicolons in string literals correctly
            statements = self._split_sql_statements(sql_content)
            
            for i, statement in enumerate(statements, 1):
                # Skip comments-only statements
                if statement.startswith('--') or not statement:
                    continue
                    
                try:
                    result = self.conn.execute(statement)
                    
                    # If it's a SELECT statement, show results
                    if statement.upper().strip().startswith('SELECT'):
                        rows = result.fetchall()
                        if rows:
                            print(f"  Query {i} results:")
                            for row in rows[:10]:  # Limit to first 10 rows
                                print(f"    {row}")
                            if len(rows) > 10:
                                print(f"    ... ({len(rows) - 10} more rows)")
                        else:
                            print(f"  Query {i}: No results")
                    else:
                        print(f"  ✅ Statement {i} executed successfully")
                        
                except Exception as e:
                    print(f"  ❌ Error in statement {i}: {e}")
                    
        except Exception as e:
            print(f"❌ Error reading file: {e}")
    
    def setup_database(self, setup_file: str = "setup.sql") -> None:
        """Run the setup.sql file to initialize the database"""
        if os.path.exists(setup_file):
            print("🔧 Setting up database...")
            self.execute_file(setup_file)
        else:
            print(f"⚠️  {setup_file} not found, skipping database setup")
    
    def list_tables(self) -> None:
        """List all tables in the database"""
        try:
            result = self.conn.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'main' ORDER BY table_name")
            tables = result.fetchall()
            
            if tables:
                print("📊 Available tables:")
                for table in tables:
                    print(f"  - {table[0]}")
            else:
                print("📊 No tables found")
                
        except Exception as e:
            print(f"❌ Error listing tables: {e}")
    
    def run_query(self, query: str) -> None:
        """Execute a single SQL query"""
        try:
            result = self.conn.execute(query)
            
            if query.upper().strip().startswith('SELECT'):
                rows = result.fetchall()
                columns = [desc[0] for desc in result.description] if hasattr(result, 'description') and result.description else []
                
                if rows:
                    # Print column headers
                    print(" | ".join(columns))
                    print("-" * (len(" | ".join(columns))))
                    
                    # Print rows
                    for row in rows:
                        print(" | ".join(str(val) for val in row))
                else:
                    print("No results")
            else:
                print("✅ Query executed successfully")
                
        except Exception as e:
            print(f"❌ Error executing query: {e}")
    
    def find_sql_files(self, directory: str = ".") -> List[str]:
        """Find all SQL files in directory and subdirectories"""
        sql_files = []
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.sql'):
                    sql_files.append(os.path.join(root, file))
        return sorted(sql_files)
    
    def interactive_mode(self) -> None:
        """Run in interactive mode"""
        print("🚀 SQL Runner - Interactive Mode")
        print("Commands:")
        print("  setup    - Run setup.sql")
        print("  tables   - List all tables")
        print("  files    - List available SQL files")
        print("  run <file> - Execute SQL file")
        print("  query <sql> - Execute SQL query")
        print("  quit     - Exit")
        print()
        
        while True:
            try:
                command = input("sql> ").strip()
                
                if command == "quit":
                    break
                elif command == "setup":
                    self.setup_database()
                elif command == "tables":
                    self.list_tables()
                elif command == "files":
                    files = self.find_sql_files()
                    print("📁 Available SQL files:")
                    for i, file in enumerate(files, 1):
                        print(f"  {i}. {file}")
                elif command.startswith("run "):
                    parts = command.split(maxsplit=1)
                    if len(parts) > 1:
                        self.execute_file(parts[1])
                    else:
                        print("❌ Please specify a file to run")
                elif command.startswith("query "):
                    parts = command.split(maxsplit=1)
                    if len(parts) > 1:
                        self.run_query(parts[1])
                    else:
                        print("❌ Please specify a query to execute")
                elif command == "":
                    continue
                else:
                    print("❌ Unknown command")
                    
            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except EOFError:
                break
    
    def close(self) -> None:
        """Close database connection"""
        self.conn.close()


def main():
    parser = argparse.ArgumentParser(description="SQL Runner for DuckDB")
    parser.add_argument("--db", default="sample.db", help="Database file path")
    parser.add_argument("--setup", action="store_true", help="Run setup.sql first")
    parser.add_argument("--file", help="SQL file to execute")
    parser.add_argument("--query", help="SQL query to execute")
    parser.add_argument("--interactive", "-i", action="store_true", help="Run in interactive mode")
    
    args = parser.parse_args()
    
    try:
        runner = SQLRunner(args.db)
    except Exception as e:
        print(f"❌ Failed to initialize database connection: {e}")
        sys.exit(1)
    
    try:
        if args.setup:
            runner.setup_database()
        
        if args.file:
            runner.execute_file(args.file)
        
        if args.query:
            runner.run_query(args.query)
        
        if args.interactive or (not args.file and not args.query and not args.setup):
            runner.interactive_mode()
            
    finally:
        runner.close()


if __name__ == "__main__":
    main()