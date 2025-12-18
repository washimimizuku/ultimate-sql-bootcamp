# TPC-H Database Schema

The TPC-H (Transaction Processing Performance Council - H) database is a decision support benchmark that represents a business scenario involving sales, orders, and supply chain management.

## Database Overview

The TPC-H database models a wholesale supplier business with the following key entities:
- **Customers** who place orders
- **Orders** containing multiple line items
- **Parts** (products) supplied by suppliers
- **Suppliers** who provide parts
- **Nations** and **Regions** for geographic organization

## Entity Relationship Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   REGION    │    │   NATION    │    │  CUSTOMER   │
│─────────────│    │─────────────│    │─────────────│
│ r_regionkey │◄───┤ n_regionkey │    │ c_custkey   │
│ r_name      │    │ n_nationkey │◄───┤ c_nationkey │
│ r_comment   │    │ n_name      │    │ c_name      │
└─────────────┘    │ n_comment   │    │ c_address   │
                   └─────────────┘    │ c_phone     │
                                      │ c_acctbal   │
                                      │ c_mktsegment│
                                      │ c_comment   │
                                      └─────────────┘
                                             │
                                             │ 1:N
                                             ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  SUPPLIER   │    │   PARTSUPP  │    │   ORDERS    │
│─────────────│    │─────────────│    │─────────────│
│ s_suppkey   │◄───┤ ps_suppkey  │    │ o_orderkey  │
│ s_nationkey │◄─┐ │ ps_partkey  │◄─┐ │ o_custkey   │
│ s_name      │  │ │ ps_availqty │  │ │ o_orderstatus│
│ s_address   │  │ │ ps_supplycost│ │ │ o_totalprice│
│ s_phone     │  │ │ ps_comment  │  │ │ o_orderdate │
│ s_acctbal   │  │ └─────────────┘  │ │ o_orderpriority│
│ s_comment   │  │                  │ │ o_clerk     │
└─────────────┘  │                  │ │ o_shippriority│
                 │                  │ │ o_comment   │
                 │ ┌─────────────┐  │ └─────────────┘
                 │ │    PART     │  │        │
                 │ │─────────────│  │        │ 1:N
                 └─┤ p_partkey   │◄─┘        ▼
                   │ p_name      │    ┌─────────────┐
                   │ p_mfgr      │    │  LINEITEM   │
                   │ p_brand     │    │─────────────│
                   │ p_type      │    │ l_orderkey  │
                   │ p_size      │    │ l_partkey   │
                   │ p_suppkey   │    │ l_linenumber│
                   │ p_container │    │ l_quantity  │
                   │ p_retailprice│   │ l_extendedprice│
                   │ p_comment   │    │ l_discount  │
                   └─────────────┘    │ l_tax       │
                                      │ l_returnflag│
                                      │ l_linestatus│
                                      │ l_shipdate  │
                                      │ l_commitdate│
                                      │ l_receiptdate│
                                      │ l_shipinstruct│
                                      │ l_shipmode  │
                                      │ l_comment   │
                                      └─────────────┘
```

## Table Descriptions

### REGION
Geographic regions for organizing nations.
- **r_regionkey** (PK): Unique identifier for region
- **r_name**: Region name (e.g., 'AMERICA', 'EUROPE', 'ASIA', 'AFRICA', 'MIDDLE EAST')
- **r_comment**: Additional comments about the region

### NATION  
Countries within regions.
- **n_nationkey** (PK): Unique identifier for nation
- **n_name**: Nation name (e.g., 'UNITED STATES', 'GERMANY', 'JAPAN')
- **n_regionkey** (FK): References REGION.r_regionkey
- **n_comment**: Additional comments about the nation

### CUSTOMER
Customers who place orders.
- **c_custkey** (PK): Unique customer identifier
- **c_name**: Customer name
- **c_address**: Customer address
- **c_nationkey** (FK): References NATION.n_nationkey
- **c_phone**: Customer phone number
- **c_acctbal**: Customer account balance
- **c_mktsegment**: Market segment (e.g., 'BUILDING', 'AUTOMOBILE', 'MACHINERY')
- **c_comment**: Additional comments about the customer

### ORDERS
Customer orders containing multiple line items.
- **o_orderkey** (PK): Unique order identifier
- **o_custkey** (FK): References CUSTOMER.c_custkey
- **o_orderstatus**: Order status ('O'=Open, 'F'=Filled, 'P'=Pending)
- **o_totalprice**: Total order price
- **o_orderdate**: Date order was placed
- **o_orderpriority**: Order priority (1-URGENT to 5-LOW)
- **o_clerk**: Clerk who processed the order
- **o_shippriority**: Shipping priority
- **o_comment**: Additional comments about the order

### LINEITEM
Individual items within orders.
- **l_orderkey** (PK, FK): References ORDERS.o_orderkey
- **l_partkey** (FK): References PART.p_partkey
- **l_suppkey** (FK): References SUPPLIER.s_suppkey
- **l_linenumber** (PK): Line number within the order
- **l_quantity**: Quantity ordered
- **l_extendedprice**: Extended price (quantity × unit price)
- **l_discount**: Discount percentage
- **l_tax**: Tax percentage
- **l_returnflag**: Return flag ('R'=Returned, 'A'=Accepted, 'N'=No return)
- **l_linestatus**: Line status ('O'=Open, 'F'=Filled)
- **l_shipdate**: Date item was shipped
- **l_commitdate**: Committed delivery date
- **l_receiptdate**: Date item was received
- **l_shipinstruct**: Shipping instructions
- **l_shipmode**: Shipping mode (e.g., 'TRUCK', 'MAIL', 'SHIP')
- **l_comment**: Additional comments about the line item

### PART
Parts (products) available for purchase.
- **p_partkey** (PK): Unique part identifier
- **p_name**: Part name
- **p_mfgr**: Manufacturer
- **p_brand**: Brand name
- **p_type**: Part type (e.g., 'STANDARD POLISHED BRASS')
- **p_size**: Part size
- **p_container**: Container type (e.g., 'SM CASE', 'LG BOX')
- **p_retailprice**: Retail price
- **p_comment**: Additional comments about the part

### SUPPLIER
Suppliers who provide parts.
- **s_suppkey** (PK): Unique supplier identifier
- **s_name**: Supplier name
- **s_address**: Supplier address
- **s_nationkey** (FK): References NATION.n_nationkey
- **s_phone**: Supplier phone number
- **s_acctbal**: Supplier account balance
- **s_comment**: Additional comments about the supplier

### PARTSUPP
Relationship between parts and their suppliers with supply information.
- **ps_partkey** (PK, FK): References PART.p_partkey
- **ps_suppkey** (PK, FK): References SUPPLIER.s_suppkey
- **ps_availqty**: Available quantity from this supplier
- **ps_supplycost**: Cost to supply this part from this supplier
- **ps_comment**: Additional comments about this supply relationship

## Key Relationships

1. **Region → Nation** (1:N): Each region contains multiple nations
2. **Nation → Customer** (1:N): Each nation has multiple customers
3. **Nation → Supplier** (1:N): Each nation has multiple suppliers
4. **Customer → Orders** (1:N): Each customer can place multiple orders
5. **Orders → LineItem** (1:N): Each order contains multiple line items
6. **Part → LineItem** (1:N): Each part can appear in multiple line items
7. **Supplier → LineItem** (1:N): Each supplier can supply multiple line items
8. **Part ↔ Supplier** (N:N): Many-to-many relationship through PARTSUPP

## Business Queries

The TPC-H schema supports complex business analytics queries such as:
- Customer order analysis and segmentation
- Supplier performance evaluation
- Regional sales analysis
- Product profitability analysis
- Supply chain optimization
- Market trend analysis

## Sample Data Scale

- 8 regions
- 25 nations
- Variable number of customers, suppliers, parts based on scale factor
- Realistic business relationships and data distributions

This schema is designed to represent realistic business scenarios for testing SQL query performance and analytical capabilities.