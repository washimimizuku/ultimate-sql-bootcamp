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
    def __init__(self, db_path: str = "data/tpc-h.db"):
        """Initialize DuckDB connection"""
        # Ensure data directory exists
        data_dir = Path("data")
        data_dir.mkdir(exist_ok=True)
        
        # Validate database path to prevent path traversal
        try:
            db_path_obj = Path(db_path).resolve()
            current_dir = Path.cwd().resolve()
            data_dir_resolved = (current_dir / "data").resolve()
            
            # Allow database files in current directory or data subdirectory
            if not (db_path_obj.parent == current_dir or db_path_obj.parent == data_dir_resolved):
                raise ValueError(f"Database must be in current directory or data/ subdirectory: {db_path}")
            self.db_path = str(db_path_obj)
        except Exception as e:
            print(f"❌ Invalid database path: {e}")
            raise
            
        try:
            self.conn = duckdb.connect(self.db_path)
        except Exception as e:
            print(f"❌ Failed to connect to database: {e}")
            raise
        
    def _split_sql_statements(self, sql_content: str) -> List[str]:
        """Split SQL content into individual statements, handling basic cases"""
        try:
            if not isinstance(sql_content, str):
                raise TypeError("SQL content must be a string")
            
            # Remove comment-only lines first
            lines = sql_content.split('\n')
            clean_lines = []
            for line in lines:
                stripped = line.strip()
                if stripped.startswith('--'):
                    continue  # Skip comment-only lines
                elif '--' in line:
                    # Keep part before inline comment
                    line = line[:line.index('--')]
                if line.strip():
                    clean_lines.append(line)
            
            clean_sql = '\n'.join(clean_lines)
            
            # Split by semicolon using more efficient approach
            statements = []
            start = 0
            in_string = False
            string_char = None
            
            i = 0
            while i < len(clean_sql):
                char = clean_sql[i]
                # Handle string literals
                if char in ("'", '"') and not in_string:
                    in_string = True
                    string_char = char
                elif char == string_char and in_string:
                    # Check for escaped quotes (doubled quotes)
                    if i + 1 < len(clean_sql) and clean_sql[i + 1] == string_char:
                        i += 1  # Skip the escaped quote
                    else:
                        in_string = False
                        string_char = None
                
                # Handle semicolons
                elif char == ';' and not in_string:
                    stmt = clean_sql[start:i].strip()
                    if stmt:
                        statements.append(stmt)
                    start = i + 1
                
                i += 1
            
            # Add final statement if exists
            stmt = clean_sql[start:].strip()
            if stmt:
                statements.append(stmt)
            
            return statements
        except (TypeError, ValueError) as e:
            print(f"❌ Error parsing SQL statements: {e}")
            raise  # Propagate error to caller
    
    def _validate_file_path(self, file_path: str) -> Optional[Path]:
        """Validate and resolve file path to prevent path traversal"""
        try:
            # Resolve the path to its canonical form
            file_path_obj = Path(file_path).resolve()
            
            # Define allowed base directories (current working directory and subdirectories)
            allowed_base = Path.cwd().resolve()
            
            # Check if the resolved path is within the allowed directory
            try:
                file_path_obj.relative_to(allowed_base)
            except ValueError:
                print(f"❌ Access denied: {file_path} (outside allowed directory)")
                return None
                
            if not file_path_obj.exists():
                print(f"❌ File not found: {file_path}")
                return None
                
            if not file_path_obj.is_file():
                print(f"❌ Not a file: {file_path}")
                return None
                
            return file_path_obj
                
        except Exception as e:
            print(f"❌ Invalid file path: {file_path} - {e}")
            return None
    
    def execute_file(self, file_path: str) -> None:
        """Execute SQL commands from a file"""
        resolved_path = self._validate_file_path(file_path)
        if not resolved_path:
            return
            
        print(f"📄 Executing: {resolved_path}")
        
        try:
            with resolved_path.open('r', encoding='utf-8') as f:
                sql_content = f.read()
            
            # Split by semicolon and execute each statement
            statements = self._split_sql_statements(sql_content)
            
            for i, statement in enumerate(statements, 1):
                try:
                    result = self.conn.execute(statement)
                    
                    # If it's a SELECT statement, show results
                    if statement.upper().strip().startswith('SELECT'):
                        rows = result.fetchmany(10)  # Fetch exactly 10 rows
                        if rows:
                            # Use efficient string formatting with single print
                            row_output = [f"  Query {i} results:"] + [f"    {row}" for row in rows]
                            if len(rows) == 10:
                                row_output.append("    ... (more rows may be available)")
                            print("\n".join(row_output))
                        else:
                            print(f"  Query {i}: No results")
                    else:
                        print(f"  ✅ Statement {i} executed successfully")
                        
                except duckdb.Error as e:
                    print(f"  ❌ SQL Error in statement {i}: {e}")
                    continue
                except Exception as e:
                    print(f"  ❌ Unexpected error in statement {i}: {type(e).__name__}: {e}")
                    continue
                    
        except Exception as e:
            print(f"❌ Error reading file: {e}")
    
    def setup_database(self, setup_file: str = "examples/tpc-h.sql") -> None:
        """Run the tpc-h.sql file to initialize the database"""
        print("🔧 Setting up database...")
        # Validate the setup file path before execution
        validated_path = self._validate_file_path(setup_file)
        if not validated_path:
            print("❌ Database setup failed: Invalid setup file path")
            return
        self.execute_file(str(validated_path))
    
    def setup_starwars(self) -> None:
        """Create the Star Wars database using swapi_database.sql"""
        print("🌟 Creating Star Wars database...")
        try:
            # Ensure data directory exists
            data_dir = Path("data")
            data_dir.mkdir(exist_ok=True)
            
            # Create a separate connection for the Star Wars database
            starwars_conn = duckdb.connect("data/starwars.db")
            
            # Temporarily switch to the Star Wars database
            original_conn = self.conn
            self.conn = starwars_conn
            
            # Execute the Star Wars database script
            self.execute_file("examples/swapi_database.sql")
            
            # Close the Star Wars connection and restore original
            starwars_conn.close()
            self.conn = original_conn
            
            print("✅ Star Wars database created as data/starwars.db")
            
        except Exception as e:
            print(f"❌ Error creating Star Wars database: {e}")
            # Restore original connection if something went wrong
            self.conn = original_conn if 'original_conn' in locals() else self.conn
    
    def list_tables(self) -> None:
        """List all tables in the database"""
        try:
            query = (
                "SELECT table_name FROM information_schema.tables "
                "WHERE table_schema = 'main' ORDER BY table_name"
            )
            result = self.conn.execute(query)
            tables = result.fetchall()
            
            if tables:
                print("📊 Available tables:")
                for table in tables:
                    print(f"  - {table[0]}")
            else:
                print("📊 No tables found")
                
        except Exception as e:
            print(f"❌ Error listing tables: {e}")
    
    def clean_database(self) -> None:
        """Drop all tables to clean the database"""
        try:
            print("🧹 Cleaning database...")
            
            # Get all tables
            query = (
                "SELECT table_name FROM information_schema.tables "
                "WHERE table_schema = 'main' ORDER BY table_name"
            )
            result = self.conn.execute(query)
            tables = result.fetchall()
            
            if not tables:
                print("📊 Database is already clean (no tables found)")
                return
            
            # Drop each table
            for table in tables:
                table_name = table[0]
                try:
                    # Use identifier quoting to prevent SQL injection
                    self.conn.execute(f'DROP TABLE IF EXISTS "{table_name}"')
                    print(f"  ✅ Dropped table: {table_name}")
                except Exception as e:
                    print(f"  ❌ Error dropping table {table_name}: {e}")
            
            print("✅ Database cleaned successfully")
                
        except Exception as e:
            print(f"❌ Error cleaning database: {e}")
    
    def run_query(self, query: str) -> None:
        """Execute a single SQL query"""
        try:
            if not isinstance(query, str):
                raise TypeError("Query must be a string")
            
            if not query.strip():
                raise ValueError("Query cannot be empty")
            
            # Enhanced SQL injection protection
            query_upper = query.upper().strip()
            
            # Check for multiple statements (semicolon not in quotes)
            statements = self._split_sql_statements(query)
            if len(statements) > 1:
                print("❌ Multiple SQL statements not allowed in query mode. Use file execution instead.")
                return
            
            # Only allow SELECT statements in query mode
            if not query_upper.startswith('SELECT'):
                print("❌ Only SELECT statements allowed in query mode. Use file execution for other commands.")
                return
            
            # Additional validation: ensure no SQL keywords that could be dangerous
            dangerous_keywords = ['UNION', 'INTO', 'OUTFILE', 'DUMPFILE', 'LOAD_FILE']
            if any(keyword in query_upper for keyword in dangerous_keywords):
                print("❌ Query contains restricted keywords. Use file execution instead.")
                return
            
            result = self.conn.execute(query)
            
            # Since we only allow SELECT, we know this is a query
            columns = []
            if hasattr(result, 'description') and result.description:
                columns = [desc[0] for desc in result.description]
            
            # Fetch rows and format efficiently
            rows = result.fetchmany(10000)
            if rows:
                # Use list comprehension and join for better performance
                formatted_rows = [" | ".join(str(val) for val in row) for row in rows]
                print("\n".join(formatted_rows))
            else:
                print("No results")
                
        except (TypeError, ValueError) as e:
            print(f"❌ Invalid query: {e}")
        except Exception as e:
            print(f"❌ Error executing query: {e}")
    
    def find_sql_files(self, directory: str = ".") -> List[str]:
        """Find all SQL files in directory and subdirectories"""
        try:
            resolved_dir = Path(directory).resolve()
            current_dir = Path.cwd().resolve()
            
            # Validate directory is within current working directory
            resolved_dir.relative_to(current_dir)  # Raises ValueError if outside
                
        except ValueError:
            print(f"❌ Access denied: Directory path outside allowed directory: {directory}")
            return []
        except (OSError, TypeError) as e:
            print(f"❌ Invalid directory path: {directory} - {e}")
            return []
            
        sql_files = []
        for root, dirs, files in os.walk(resolved_dir, followlinks=False):
            for file in files:
                if file.endswith('.sql'):
                    file_path = Path(root) / file
                    try:
                        # Ensure each file is within the allowed directory
                        resolved_file = file_path.resolve()
                        resolved_file.relative_to(current_dir)
                        # Store relative path for user-friendly display
                        relative_path = resolved_file.relative_to(current_dir)
                        sql_files.append(str(relative_path))
                    except ValueError:
                        # Skip files outside allowed directory
                        continue
        return sorted(sql_files)
    
    def _show_help(self) -> None:
        """Show help message"""
        print("Commands:")
        print("  setup    - Run tpc-h.sql")
        print("  starwars - Create Star Wars database")
        print("  clean    - Drop all tables")
        print("  tables   - List all tables")
        print("  files    - List available SQL files")
        print("  run <file> - Execute SQL file")
        print("  query <sql> - Execute SQL query")
        print("  help     - Show this help message")
        print("  quit/exit - Exit")
    
    def _handle_run_command(self, command: str) -> None:
        """Handle run command"""
        parts = command.split(maxsplit=1)
        if len(parts) > 1:
            file_input = parts[1].strip()
            if not file_input:
                print("❌ Please specify a file to run")
            else:
                self.execute_file(file_input)
        else:
            print("❌ Please specify a file to run")
    
    def _handle_query_command(self, command: str) -> None:
        """Handle query command"""
        parts = command.split(maxsplit=1)
        if len(parts) > 1:
            query_input = parts[1].strip()
            if not query_input:
                print("❌ Please specify a query to execute")
            else:
                self.run_query(query_input)
        else:
            print("❌ Please specify a query to execute")
    
    def interactive_mode(self) -> None:
        """Run in interactive mode"""
        print("🚀 SQL Runner - Interactive Mode")
        self._show_help()
        print()
        
        while True:
            try:
                command = input("sql> ").strip()
                
                if command in ("quit", "exit"):
                    break
                elif command == "setup":
                    self.setup_database()
                elif command == "starwars":
                    self.setup_starwars()
                elif command == "clean":
                    self.clean_database()
                elif command == "tables":
                    self.list_tables()
                elif command == "files":
                    files = self.find_sql_files()
                    print("📁 Available SQL files:")
                    for i, file in enumerate(files, 1):
                        print(f"  {i}. {file}")
                elif command == "help":
                    self._show_help()
                elif command.startswith("run "):
                    self._handle_run_command(command)
                elif command.startswith("query "):
                    self._handle_query_command(command)
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
        try:
            if self.conn:
                self.conn.close()
        except Exception as e:
            print(f"❌ Error closing database connection: {e}")


def main():
    parser = argparse.ArgumentParser(description="SQL Runner for DuckDB")
    parser.add_argument("--db", default="data/tpc-h.db", help="Database file path")
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