#!/usr/bin/env python3
"""Generate lineitem data for orders 11-100"""
import random
from datetime import datetime, timedelta

def generate_lineitems(start_order=11, end_order=100):
    """Generate lineitem inserts - each order has 1-5 line items"""
    inserts = []
    statuses = ['O', 'F']
    flags = ['N', 'R', 'A']
    instructions = ['DELIVER IN PERSON', 'COLLECT COD', 'NONE', 'TAKE BACK RETURN']
    modes = ['REG AIR', 'AIR', 'RAIL', 'SHIP', 'TRUCK', 'MAIL', 'FOB']
    
    start_date = datetime(1992, 1, 1)
    
    for order_id in range(start_order, end_order + 1):
        num_lines = random.randint(1, 5)
        
        for line_num in range(1, num_lines + 1):
            part_id = random.randint(1, 200)
            supp_id = random.randint(1, 50)
            qty = random.randint(1, 50)
            price = round(random.uniform(900, 2000), 2)
            extended = round(qty * price, 2)
            discount = round(random.uniform(0, 0.10), 2)
            tax = round(random.uniform(0, 0.08), 2)
            flag = random.choice(flags)
            status = random.choice(statuses)
            
            ship_offset = random.randint(0, 2500)
            ship_date = start_date + timedelta(days=ship_offset)
            commit_date = ship_date - timedelta(days=random.randint(1, 30))
            receipt_date = ship_date + timedelta(days=random.randint(1, 30))
            
            instruction = random.choice(instructions)
            mode = random.choice(modes)
            
            inserts.append(
                f"    ({order_id}, {part_id}, {supp_id}, {line_num}, {qty}, {extended}, "
                f"{discount}, {tax}, '{flag}', '{status}', '{ship_date.strftime('%Y-%m-%d')}', "
                f"'{commit_date.strftime('%Y-%m-%d')}', '{receipt_date.strftime('%Y-%m-%d')}', "
                f"'{instruction}', '{mode}', 'lineitem comment')"
            )
    
    return ",\n".join(inserts) + ";"

print("-- Additional LineItem Data")
print("INSERT INTO lineitem VALUES")
print(generate_lineitems())
