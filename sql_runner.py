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
        current_chars = []
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
                # Check for escaped quotes (doubled quotes)
                if i + 1 < len(sql_content) and sql_content[i + 1] == string_char:
                    # Add both quotes for escaped quote
                    current_chars.append(char)
                    current_chars.append(char)
                    i += 1  # Skip the second quote
                    continue
                else:
                    in_string = False
                    string_char = None
            
            # Handle semicolons
            if char == ';' and not in_string:
                stmt = ''.join(current_chars).strip()
                if stmt and not stmt.startswith('--'):
                    statements.append(stmt)
                current_chars = []
            else:
                current_chars.append(char)
            
            i += 1
        
        # Add final statement if exists
        stmt = ''.join(current_chars).strip()
        if stmt and not stmt.startswith('--'):
            statements.append(stmt)
        
        return statements
    
    def _validate_file_path(self, file_path: str) -> Optional[Path]:
        """Validate and resolve file path to prevent path traversal"""
        # Sanitize input to prevent path traversal
        normalized_path = os.path.normpath(file_path)
        if '..' in normalized_path or file_path.startswith('/'):
            print(f"❌ Invalid file path: {file_path}")
            return None
            
        try:
            resolved_path = Path(file_path).resolve()
            current_dir = Path.cwd().resolve()
            
            # Check if the resolved path is within the current directory or its subdirectories
            try:
                resolved_path.relative_to(current_dir)
            except ValueError:
                print(f"❌ Access denied: File path outside allowed directory: {file_path}")
                return None
                
            if not resolved_path.exists():
                print(f"❌ File not found: {file_path}")
                return None
                
            if not resolved_path.is_file():
                print(f"❌ Not a file: {file_path}")
                return None
                
            return resolved_path
                
        except (OSError, ValueError) as e:
            print(f"❌ Invalid file path: {file_path} - {e}")
            return None
    
    def execute_file(self, file_path: str) -> None:
        """Execute SQL commands from a file"""
        resolved_path = self._validate_file_path(file_path)
        if not resolved_path:
            return
            
        print(f"📄 Executing: {resolved_path}")
        
        try:
            with open(resolved_path, 'r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # Split by semicolon and execute each statement
            statements = self._split_sql_statements(sql_content)
            
            for i, statement in enumerate(statements, 1):
                try:
                    result = self.conn.execute(statement)
                    
                    # If it's a SELECT statement, show results
                    if statement.upper().strip().startswith('SELECT'):
                        rows = result.fetchall()
                        if rows:
                            print(f"  Query {i} results:")
                            for row in rows[:10]:  # Show first 10 rows
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
        print("🔧 Setting up database...")
        validated_path = self._validate_file_path(setup_file)
        if not validated_path:
            print(f"⚠️ {setup_file} not found or invalid, skipping database setup")
            return
        self.execute_file(str(validated_path))
    
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
                columns = []
                if hasattr(result, 'description') and result.description:
                    columns = [desc[0] for desc in result.description]
                
                if rows:
                    # Print rows with consistent formatting
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
        try:
            resolved_dir = Path(directory).resolve()
            current_dir = Path.cwd().resolve()
            
            # Check if directory is within current working directory
            try:
                resolved_dir.relative_to(current_dir)
            except ValueError:
                print(f"❌ Access denied: Directory path outside allowed directory: {directory}")
                return []
                
        except (OSError, ValueError) as e:
            print(f"❌ Invalid directory path: {directory} - {e}")
            return []
            
        sql_files = []
        for root, dirs, files in os.walk(resolved_dir, followlinks=False):
            for file in files:
                if file.endswith('.sql'):
                    sql_files.append(str(Path(root) / file))
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
    
    runner = None
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
        if runner is not None:
            runner.close()


if __name__ == "__main__":
    main()