#!/usr/bin/env python3
"""
Generate additional TPC-H data inserts
Creates: 50 customers, 50 suppliers, 200 parts, 100 orders with 1-5 line items each
"""
import random
from datetime import datetime, timedelta

# Already have 25 nations (0-24), keep them
# Already have 5 regions (0-4), keep them

def generate_customers(start_id=11, count=40):
    """Generate customer inserts (already have 10, need 40 more for 50 total)"""
    segments = ['AUTOMOBILE', 'BUILDING', 'FURNITURE', 'MACHINERY', 'HOUSEHOLD']
    inserts = []
    
    for i in range(start_id, start_id + count):
        nation = random.randint(0, 24)
        segment = random.choice(segments)
        balance = round(random.uniform(-999.99, 9999.99), 2)
        inserts.append(
            f"    ({i}, 'Customer#{i:09d}', 'Address{i}', {nation}, "
            f"'{random.randint(10,30)}-{random.randint(100,999)}-{random.randint(100,999)}-{random.randint(1000,9999)}', "
            f"{balance}, '{segment}', 'comment {i}')"
        )
    
    return ",\n".join(inserts) + ";"

def generate_suppliers(start_id=6, count=45):
    """Generate supplier inserts (already have 5, need 45 more for 50 total)"""
    inserts = []
    
    for i in range(start_id, start_id + count):
        nation = random.randint(0, 24)
        balance = round(random.uniform(-999.99, 9999.99), 2)
        inserts.append(
            f"    ({i}, 'Supplier#{i:09d}', 'SupplierAddr{i}', {nation}, "
            f"'{random.randint(10,30)}-{random.randint(100,999)}-{random.randint(100,999)}-{random.randint(1000,9999)}', "
            f"{balance}, 'supplier comment {i}')"
        )
    
    return ",\n".join(inserts) + ";"

def generate_parts(start_id=6, count=195):
    """Generate part inserts (already have 5, need 195 more for 200 total)"""
    manufacturers = [f'Manufacturer#{i}' for i in range(1, 6)]
    brands = [f'Brand#{i}{j}' for i in range(1, 6) for j in range(1, 6)]
    types = ['STANDARD POLISHED', 'SMALL PLATED', 'MEDIUM BURNISHED', 'LARGE BRUSHED', 'PROMO ANODIZED']
    materials = ['BRASS', 'COPPER', 'NICKEL', 'STEEL', 'TIN']
    containers = ['SM CASE', 'SM BOX', 'SM PACK', 'SM PKG', 'MED BAG', 'MED BOX', 'MED PKG', 'LG CASE', 'LG BOX', 'LG PACK']
    
    inserts = []
    for i in range(start_id, start_id + count):
        mfgr = random.choice(manufacturers)
        brand = random.choice(brands)
        ptype = f"{random.choice(types)} {random.choice(materials)}"
        size = random.randint(1, 50)
        container = random.choice(containers)
        price = round(random.uniform(900, 2000), 2)
        inserts.append(
            f"    ({i}, 'part name {i}', '{mfgr}', '{brand}', '{ptype}', "
            f"{size}, '{container}', {price}, 'part comment {i}')"
        )
    
    return ",\n".join(inserts) + ";"

def generate_orders(start_id=35, count=66):
    """Generate order inserts (already have 34, need 66 more for 100 total)"""
    statuses = ['O', 'F', 'P']
    priorities = ['1-URGENT', '2-HIGH', '3-MEDIUM', '4-NOT SPECIFIED', '5-LOW']
    
    inserts = []
    start_date = datetime(1992, 1, 1)
    
    for i in range(start_id, start_id + count):
        customer = random.randint(1, 50)
        status = random.choice(statuses)
        price = round(random.uniform(10000, 500000), 2)
        days_offset = random.randint(0, 2500)
        order_date = start_date + timedelta(days=days_offset)
        priority = random.choice(priorities)
        clerk = f"Clerk#{random.randint(1, 1000):09d}"
        
        inserts.append(
            f"    ({i}, {customer}, '{status}', {price}, '{order_date.strftime('%Y-%m-%d')}', "
            f"'{priority}', '{clerk}', 0, 'order comment {i}')"
        )
    
    return ",\n".join(inserts) + ";"

def generate_partsupp(parts=200, suppliers=50):
    """Generate partsupp inserts - each part supplied by 2-4 suppliers"""
    inserts = []
    
    for part_id in range(1, parts + 1):
        num_suppliers = random.randint(2, 4)
        supplier_ids = random.sample(range(1, suppliers + 1), num_suppliers)
        
        for supp_id in supplier_ids:
            qty = random.randint(100, 10000)
            cost = round(random.uniform(10, 1000), 2)
            inserts.append(
                f"    ({part_id}, {supp_id}, {qty}, {cost}, 'partsupp comment')"
            )
    
    return ",\n".join(inserts) + ";"

def generate_lineitems(start_order=1, end_order=100):
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

def main():
    print("-- Additional Customer Data")
    print("INSERT INTO customer VALUES")
    print(generate_customers())
    print()
    
    print("-- Additional Supplier Data")
    print("INSERT INTO supplier VALUES")
    print(generate_suppliers())
    print()
    
    print("-- Additional Part Data")
    print("INSERT INTO part VALUES")
    print(generate_parts())
    print()
    
    print("-- Additional Order Data")
    print("INSERT INTO orders VALUES")
    print(generate_orders())
    print()
    
    print("-- Additional PartSupp Data")
    print("INSERT INTO partsupp VALUES")
    print(generate_partsupp())
    print()
    
    print("-- Additional LineItem Data")
    print("INSERT INTO lineitem VALUES")
    print(generate_lineitems())

if __name__ == "__main__":
    main()
