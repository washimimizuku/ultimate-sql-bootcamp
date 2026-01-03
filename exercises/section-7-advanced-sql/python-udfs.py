#!/usr/bin/env python3
"""
Section 7: Advanced SQL - Python User-Defined Functions (UDFs)
==============================================================
This file demonstrates creating Python UDFs for DuckDB
UDFs allow using Python libraries and complex logic in SQL queries
Based on Tom Bailey's SQL course, adapted for DuckDB
==============================================================
"""

import duckdb
import math
import re
import json
from datetime import datetime, timedelta
from typing import List, Optional
import pandas as pd
import numpy as np

def main():
    """Main function to register all UDFs and demonstrate basic usage"""
    
    # Connect to TPC-H database
    conn = duckdb.connect('data/databases/tpc-h.db')
    
    print("=" * 60)
    print("Python UDFs for DuckDB - Registration and Setup")
    print("=" * 60)
    
    # =============================================
    # 1. BASIC SCALAR UDFs
    # =============================================
    
    print("\n1. Registering Basic Scalar UDFs...")
    
    def calculate_compound_interest(principal: float, rate: float, years: int, compounds_per_year: int = 12) -> float:
        """Calculate compound interest with flexible compounding periods"""
        if principal <= 0 or rate < 0 or years < 0 or compounds_per_year <= 0:
            return 0.0
        return principal * (1 + rate / compounds_per_year) ** (compounds_per_year * years)
    
    def celsius_to_fahrenheit(celsius: float) -> float:
        """Convert Celsius to Fahrenheit"""
        return (celsius * 9/5) + 32
    
    def calculate_bmi(weight_kg: float, height_m: float) -> float:
        """Calculate Body Mass Index"""
        if height_m <= 0:
            return 0.0
        return weight_kg / (height_m ** 2)
    
    # Register basic scalar UDFs
    conn.create_function("py_compound_interest", calculate_compound_interest, 
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.INTEGER, duckdb.typing.INTEGER], 
                        duckdb.typing.DOUBLE)
    
    conn.create_function("py_celsius_to_fahrenheit", celsius_to_fahrenheit,
                        [duckdb.typing.DOUBLE], duckdb.typing.DOUBLE)
    
    conn.create_function("py_calculate_bmi", calculate_bmi,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], duckdb.typing.DOUBLE)
    
    # =============================================
    # 2. STRING PROCESSING UDFs
    # =============================================
    
    print("2. Registering String Processing UDFs...")
    
    def extract_email_domain(email: str) -> str:
        """Extract domain from email address with validation"""
        if not email or '@' not in email:
            return ''
        parts = email.split('@')
        if len(parts) != 2:
            return ''
        return parts[1].lower()
    
    def validate_phone_number(phone: str) -> bool:
        """Validate US phone number format"""
        if not phone:
            return False
        # Remove all non-digits
        digits = re.sub(r'\D', '', phone)
        # Check if it's 10 or 11 digits (with country code)
        return len(digits) in [10, 11]
    
    def clean_text(text: str) -> str:
        """Clean text by removing extra whitespace and special characters"""
        if not text:
            return ''
        # Remove extra whitespace and normalize
        cleaned = re.sub(r'\s+', ' ', text.strip())
        # Remove special characters except basic punctuation
        cleaned = re.sub(r'[^\w\s\-\.\,\!\?]', '', cleaned)
        return cleaned
    
    def extract_numbers(text: str) -> str:
        """Extract all numbers from text and return as comma-separated string"""
        if not text:
            return ''
        numbers = re.findall(r'\d+\.?\d*', text)
        return ','.join(numbers)
    
    # Register string processing UDFs
    conn.create_function("py_extract_email_domain", extract_email_domain,
                        [duckdb.typing.VARCHAR], duckdb.typing.VARCHAR)
    
    conn.create_function("py_validate_phone", validate_phone_number,
                        [duckdb.typing.VARCHAR], duckdb.typing.BOOLEAN)
    
    conn.create_function("py_clean_text", clean_text,
                        [duckdb.typing.VARCHAR], duckdb.typing.VARCHAR)
    
    conn.create_function("py_extract_numbers", extract_numbers,
                        [duckdb.typing.VARCHAR], duckdb.typing.VARCHAR)
    
    # =============================================
    # 3. MATHEMATICAL AND STATISTICAL UDFs
    # =============================================
    
    print("3. Registering Mathematical and Statistical UDFs...")
    
    def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula (in km)"""
        if any(coord is None for coord in [lat1, lon1, lat2, lon2]):
            return 0.0
        
        # Convert to radians
        lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
        
        # Haversine formula
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        r = 6371  # Earth's radius in kilometers
        return c * r
    
    def calculate_percentile(value: float, mean: float, std_dev: float) -> float:
        """Calculate percentile rank using normal distribution approximation"""
        if std_dev <= 0:
            return 50.0  # Return median if no variation
        z_score = (value - mean) / std_dev
        # Approximate percentile using error function
        return 50 * (1 + math.erf(z_score / math.sqrt(2)))
    
    def fibonacci(n: int) -> int:
        """Calculate nth Fibonacci number"""
        if n <= 0:
            return 0
        elif n == 1:
            return 1
        else:
            a, b = 0, 1
            for _ in range(2, n + 1):
                a, b = b, a + b
            return b
    
    def is_prime(n: int) -> bool:
        """Check if a number is prime"""
        if n < 2:
            return False
        if n == 2:
            return True
        if n % 2 == 0:
            return False
        for i in range(3, int(math.sqrt(n)) + 1, 2):
            if n % i == 0:
                return False
        return True
    
    # Register mathematical UDFs
    conn.create_function("py_calculate_distance", calculate_distance,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], 
                        duckdb.typing.DOUBLE)
    
    conn.create_function("py_calculate_percentile", calculate_percentile,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], 
                        duckdb.typing.DOUBLE)
    
    conn.create_function("py_fibonacci", fibonacci,
                        [duckdb.typing.INTEGER], duckdb.typing.BIGINT)
    
    conn.create_function("py_is_prime", is_prime,
                        [duckdb.typing.INTEGER], duckdb.typing.BOOLEAN)
    
    # =============================================
    # 4. DATE AND TIME UDFs
    # =============================================
    
    print("4. Registering Date and Time UDFs...")
    
    def business_days_between(start_date: str, end_date: str) -> int:
        """Calculate business days between two dates (excluding weekends)"""
        try:
            start = datetime.strptime(start_date, '%Y-%m-%d')
            end = datetime.strptime(end_date, '%Y-%m-%d')
            
            if start > end:
                return 0
            
            business_days = 0
            current = start
            while current <= end:
                if current.weekday() < 5:  # Monday = 0, Sunday = 6
                    business_days += 1
                current += timedelta(days=1)
            return business_days
        except:
            return 0
    
    def get_quarter_name(date_str: str) -> str:
        """Get quarter name from date (Q1 2023, etc.)"""
        try:
            date = datetime.strptime(date_str, '%Y-%m-%d')
            quarter = (date.month - 1) // 3 + 1
            return f"Q{quarter} {date.year}"
        except:
            return ''
    
    def days_until_weekend(date_str: str) -> int:
        """Calculate days until next weekend"""
        try:
            date = datetime.strptime(date_str, '%Y-%m-%d')
            days_until_saturday = (5 - date.weekday()) % 7
            return days_until_saturday if days_until_saturday > 0 else 0
        except:
            return 0
    
    # Register date/time UDFs
    conn.create_function("py_business_days_between", business_days_between,
                        [duckdb.typing.VARCHAR, duckdb.typing.VARCHAR], duckdb.typing.INTEGER)
    
    conn.create_function("py_get_quarter_name", get_quarter_name,
                        [duckdb.typing.VARCHAR], duckdb.typing.VARCHAR)
    
    conn.create_function("py_days_until_weekend", days_until_weekend,
                        [duckdb.typing.VARCHAR], duckdb.typing.INTEGER)
    
    # =============================================
    # 5. JSON AND DATA PROCESSING UDFs
    # =============================================
    
    print("5. Registering JSON and Data Processing UDFs...")
    
    def parse_json_field(json_str: str, field_name: str) -> str:
        """Extract field from JSON string"""
        try:
            data = json.loads(json_str)
            return str(data.get(field_name, ''))
        except:
            return ''
    
    def create_json_object(key1: str, value1: str, key2: str = None, value2: str = None) -> str:
        """Create JSON object from key-value pairs"""
        try:
            obj = {key1: value1}
            if key2 and value2:
                obj[key2] = value2
            return json.dumps(obj)
        except:
            return '{}'
    
    def validate_json(json_str: str) -> bool:
        """Validate if string is valid JSON"""
        try:
            json.loads(json_str)
            return True
        except:
            return False
    
    # Register JSON processing UDFs
    conn.create_function("py_parse_json_field", parse_json_field,
                        [duckdb.typing.VARCHAR, duckdb.typing.VARCHAR], duckdb.typing.VARCHAR)
    
    conn.create_function("py_create_json_object", create_json_object,
                        [duckdb.typing.VARCHAR, duckdb.typing.VARCHAR, duckdb.typing.VARCHAR, duckdb.typing.VARCHAR], 
                        duckdb.typing.VARCHAR)
    
    conn.create_function("py_validate_json", validate_json,
                        [duckdb.typing.VARCHAR], duckdb.typing.BOOLEAN)
    
    # =============================================
    # 6. BUSINESS LOGIC UDFs
    # =============================================
    
    print("6. Registering Business Logic UDFs...")
    
    def calculate_shipping_cost(weight: float, distance: float, is_express: bool, customer_tier: str) -> float:
        """Calculate shipping cost based on multiple factors"""
        if weight <= 0 or distance <= 0:
            return 0.0
        
        base_cost = weight * 0.5 + distance * 0.1
        
        # Express shipping multiplier
        if is_express:
            base_cost *= 1.5
        
        # Customer tier discounts
        tier_multipliers = {
            'VIP': 0.0,      # Free shipping
            'Premium': 0.5,   # 50% discount
            'Standard': 0.8,  # 20% discount
            'Basic': 1.0      # No discount
        }
        
        multiplier = tier_multipliers.get(customer_tier, 1.0)
        return base_cost * multiplier
    
    def assess_credit_risk(account_balance: float, payment_history_score: int, order_count: int) -> str:
        """Assess customer credit risk based on multiple factors"""
        risk_score = 0
        
        # Account balance factor
        if account_balance < 0:
            risk_score += 30
        elif account_balance < 1000:
            risk_score += 15
        
        # Payment history factor (0-100 scale)
        if payment_history_score < 50:
            risk_score += 25
        elif payment_history_score < 75:
            risk_score += 10
        
        # Order count factor
        if order_count < 5:
            risk_score += 10
        
        # Determine risk level
        if risk_score >= 40:
            return 'HIGH'
        elif risk_score >= 20:
            return 'MEDIUM'
        else:
            return 'LOW'
    
    def calculate_customer_ltv(avg_order_value: float, orders_per_year: float, 
                              customer_lifespan_years: float, profit_margin: float = 0.2) -> float:
        """Calculate Customer Lifetime Value"""
        if any(val <= 0 for val in [avg_order_value, orders_per_year, customer_lifespan_years]):
            return 0.0
        return avg_order_value * orders_per_year * customer_lifespan_years * profit_margin
    
    # Register business logic UDFs
    conn.create_function("py_calculate_shipping_cost", calculate_shipping_cost,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.BOOLEAN, duckdb.typing.VARCHAR], 
                        duckdb.typing.DOUBLE)
    
    conn.create_function("py_assess_credit_risk", assess_credit_risk,
                        [duckdb.typing.DOUBLE, duckdb.typing.INTEGER, duckdb.typing.INTEGER], 
                        duckdb.typing.VARCHAR)
    
    conn.create_function("py_calculate_customer_ltv", calculate_customer_ltv,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], 
                        duckdb.typing.DOUBLE)
    
    # =============================================
    # 7. PANDAS-BASED UDFs (VECTORIZED)
    # =============================================
    
    print("7. Registering Pandas-based Vectorized UDFs...")
    
    def calculate_moving_average_pandas(values: pd.Series, window: int = 3) -> pd.Series:
        """Calculate moving average using pandas (vectorized)"""
        return values.rolling(window=window, min_periods=1).mean()
    
    def detect_outliers_pandas(values: pd.Series, threshold: float = 2.0) -> pd.Series:
        """Detect outliers using z-score method (vectorized)"""
        mean_val = values.mean()
        std_val = values.std()
        if std_val == 0:
            return pd.Series([False] * len(values))
        z_scores = abs((values - mean_val) / std_val)
        return z_scores > threshold
    
    # Register pandas UDFs (Arrow type for vectorized operations)
    conn.create_function("py_moving_average", calculate_moving_average_pandas,
                        [duckdb.typing.DOUBLE, duckdb.typing.INTEGER], duckdb.typing.DOUBLE,
                        type='arrow')
    
    conn.create_function("py_detect_outliers", detect_outliers_pandas,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], duckdb.typing.BOOLEAN,
                        type='arrow')
    
    # =============================================
    # 8. ERROR HANDLING AND VALIDATION UDFs
    # =============================================
    
    print("8. Registering Error Handling and Validation UDFs...")
    
    def safe_divide(numerator: float, denominator: float, default_value: float = 0.0) -> float:
        """Safe division with error handling"""
        try:
            if denominator == 0:
                return default_value
            return numerator / denominator
        except:
            return default_value
    
    def validate_email(email: str) -> bool:
        """Validate email format using regex"""
        if not email:
            return False
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))
    
    def parse_number_safe(text: str, default_value: float = 0.0) -> float:
        """Safely parse number from text"""
        try:
            # Remove common non-numeric characters
            cleaned = re.sub(r'[^\d\.\-]', '', str(text))
            return float(cleaned) if cleaned else default_value
        except:
            return default_value
    
    # Register error handling UDFs
    conn.create_function("py_safe_divide", safe_divide,
                        [duckdb.typing.DOUBLE, duckdb.typing.DOUBLE, duckdb.typing.DOUBLE], 
                        duckdb.typing.DOUBLE)
    
    conn.create_function("py_validate_email", validate_email,
                        [duckdb.typing.VARCHAR], duckdb.typing.BOOLEAN)
    
    conn.create_function("py_parse_number_safe", parse_number_safe,
                        [duckdb.typing.VARCHAR, duckdb.typing.DOUBLE], duckdb.typing.DOUBLE)
    
    # =============================================
    # DEMONSTRATION QUERIES
    # =============================================
    
    print("\n" + "=" * 60)
    print("Testing Python UDFs with Sample Data")
    print("=" * 60)
    
    # Test basic UDFs
    print("\n1. Testing Basic Mathematical UDFs:")
    result = conn.execute("""
        SELECT 
            py_compound_interest(1000, 0.05, 10, 12) as compound_interest,
            py_celsius_to_fahrenheit(25) as fahrenheit,
            py_calculate_bmi(70, 1.75) as bmi
    """).fetchall()
    print(f"Compound Interest: ${result[0][0]:.2f}")
    print(f"25°C in Fahrenheit: {result[0][1]:.1f}°F")
    print(f"BMI (70kg, 1.75m): {result[0][2]:.1f}")
    
    # Test string processing
    print("\n2. Testing String Processing UDFs:")
    result = conn.execute("""
        SELECT 
            py_extract_email_domain('user@example.com') as domain,
            py_validate_phone('555-123-4567') as valid_phone,
            py_clean_text('  Hello,   World!!!  ') as cleaned_text
    """).fetchall()
    print(f"Email domain: {result[0][0]}")
    print(f"Phone valid: {result[0][1]}")
    print(f"Cleaned text: '{result[0][2]}'")
    
    # Test with TPC-H data
    print("\n3. Testing with TPC-H Customer Data:")
    result = conn.execute("""
        SELECT 
            c_custkey,
            c_name,
            c_acctbal,
            py_assess_credit_risk(c_acctbal, 75, 10) as risk_level,
            py_calculate_customer_ltv(500, 4, 3, 0.2) as estimated_ltv
        FROM customer 
        LIMIT 5
    """).fetchall()
    
    for row in result:
        print(f"Customer {row[0]}: Balance=${row[2]:.2f}, Risk={row[3]}, LTV=${row[4]:.2f}")
    
    print("\n" + "=" * 60)
    print("Python UDF Registration Complete!")
    print("Run 'python-udfs-demo.sql' to see more examples.")
    print("=" * 60)
    
    # Close connection
    conn.close()

if __name__ == "__main__":
    main()