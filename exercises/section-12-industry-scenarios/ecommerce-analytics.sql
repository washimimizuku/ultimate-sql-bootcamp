-- ECOMMERCE ANALYTICS - Industry-Specific SQL Scenarios
-- This file demonstrates comprehensive ecommerce analytics using SQL
-- with a complete ecommerce data model including products, customers, orders, and web events
-- ============================================
-- REQUIRED: This file creates its own ecommerce database schema
-- Run with: duckdb data/databases/ecommerce_analytics.db < exercises/section-12-industry-scenarios/ecommerce-analytics.sql
-- ============================================

-- ECOMMERCE ANALYTICS CONCEPTS:
-- - Customer Journey Analysis: Tracking user behavior from visit to purchase
-- - Product Performance: Sales, inventory, and recommendation analytics
-- - Cart Abandonment: Understanding why customers don't complete purchases
-- - Sales Funnel: Conversion rates at each stage of the buying process
-- - Inventory Management: Stock levels, turnover, and demand forecasting
-- - Customer Segmentation: RFM analysis and behavioral clustering

-- BUSINESS CONTEXT:
-- Ecommerce analytics drives critical business decisions including inventory planning,
-- marketing optimization, customer retention strategies, and revenue growth.
-- Modern ecommerce requires real-time insights into customer behavior, product performance,
-- and operational efficiency to compete effectively in digital markets.

-- ============================================
-- CLEANUP EXISTING TABLES (for repeated runs)
-- ============================================

DROP TABLE IF EXISTS product_reviews;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS page_views;
DROP TABLE IF EXISTS web_sessions;
DROP TABLE IF EXISTS cart_events;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customer_addresses;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

-- ============================================
-- ECOMMERCE DATA MODEL CREATION
-- ============================================

-- Create comprehensive ecommerce schema with realistic data

-- Products catalog
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price DECIMAL(10,2),
    cost DECIMAL(10,2),
    weight_kg DECIMAL(8,2),
    dimensions VARCHAR(50),
    color VARCHAR(50),
    size VARCHAR(20),
    created_date DATE,
    is_active BOOLEAN DEFAULT true
);

-- Customers
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    email VARCHAR(200),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10),
    registration_date DATE,
    customer_segment VARCHAR(50),
    preferred_language VARCHAR(10),
    marketing_consent BOOLEAN DEFAULT false
);

-- Customer addresses
CREATE TABLE customer_addresses (
    address_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    address_type VARCHAR(20), -- 'billing', 'shipping'
    street_address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    is_default BOOLEAN DEFAULT false,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Orders
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TIMESTAMP,
    order_status VARCHAR(50), -- 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled', 'returned'
    payment_method VARCHAR(50),
    shipping_method VARCHAR(50),
    subtotal DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    billing_address_id INTEGER,
    shipping_address_id INTEGER,
    coupon_code VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (billing_address_id) REFERENCES customer_addresses(address_id),
    FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id)
);
-- Order items (line items)
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Shopping cart events
CREATE TABLE cart_events (
    event_id INTEGER PRIMARY KEY,
    session_id VARCHAR(100),
    customer_id INTEGER,
    product_id INTEGER,
    event_type VARCHAR(50), -- 'add_to_cart', 'remove_from_cart', 'update_quantity'
    quantity INTEGER,
    event_timestamp TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Web sessions and page views
CREATE TABLE web_sessions (
    session_id VARCHAR(100) PRIMARY KEY,
    customer_id INTEGER,
    start_timestamp TIMESTAMP,
    end_timestamp TIMESTAMP,
    device_type VARCHAR(50), -- 'desktop', 'mobile', 'tablet'
    browser VARCHAR(50),
    operating_system VARCHAR(50),
    traffic_source VARCHAR(100), -- 'organic', 'paid_search', 'social', 'email', 'direct'
    utm_campaign VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_source VARCHAR(100),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Page views
CREATE TABLE page_views (
    page_view_id INTEGER PRIMARY KEY,
    session_id VARCHAR(100),
    page_url VARCHAR(500),
    page_title VARCHAR(200),
    page_type VARCHAR(50), -- 'home', 'category', 'product', 'cart', 'checkout', 'account'
    view_timestamp TIMESTAMP,
    time_on_page_seconds INTEGER,
    FOREIGN KEY (session_id) REFERENCES web_sessions(session_id)
);

-- Product inventory
CREATE TABLE inventory (
    inventory_id INTEGER PRIMARY KEY,
    product_id INTEGER,
    warehouse_location VARCHAR(100),
    quantity_available INTEGER,
    quantity_reserved INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    last_updated TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Product reviews
CREATE TABLE product_reviews (
    review_id INTEGER PRIMARY KEY,
    product_id INTEGER,
    customer_id INTEGER,
    order_id INTEGER,
    rating INTEGER, -- 1-5 stars
    review_title VARCHAR(200),
    review_text TEXT,
    review_date DATE,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_votes INTEGER DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert sample products
INSERT INTO products VALUES
(1, 'Wireless Bluetooth Headphones', 'Electronics', 'Audio', 'TechSound', 89.99, 35.00, 0.25, '20x18x8 cm', 'Black', 'One Size', '2023-01-15', true),
(2, 'Organic Cotton T-Shirt', 'Clothing', 'Tops', 'EcoWear', 24.99, 8.50, 0.15, 'M', 'White', 'Medium', '2023-02-01', true),
(3, 'Stainless Steel Water Bottle', 'Home & Garden', 'Kitchen', 'HydroLife', 19.99, 7.00, 0.35, '25x7x7 cm', 'Silver', '500ml', '2023-01-20', true),
(4, 'Yoga Mat Premium', 'Sports & Outdoors', 'Fitness', 'ZenFit', 49.99, 18.00, 1.20, '183x61x0.6 cm', 'Purple', 'Standard', '2023-02-10', true),
(5, 'Smartphone Case', 'Electronics', 'Accessories', 'ProtectTech', 14.99, 4.50, 0.05, '15x8x1 cm', 'Blue', 'iPhone 14', '2023-03-01', true),
(6, 'Coffee Maker Deluxe', 'Home & Garden', 'Kitchen', 'BrewMaster', 129.99, 65.00, 3.50, '35x25x40 cm', 'Black', 'Large', '2023-01-10', true),
(7, 'Running Shoes', 'Sports & Outdoors', 'Footwear', 'RunFast', 79.99, 32.00, 0.80, 'Size 10', 'Red', '10', '2023-02-15', true),
(8, 'Desk Lamp LED', 'Home & Garden', 'Lighting', 'BrightSpace', 39.99, 15.00, 1.10, '45x20x15 cm', 'White', 'Adjustable', '2023-03-05', true),
(9, 'Backpack Travel', 'Fashion', 'Bags', 'AdventureGear', 59.99, 22.00, 0.90, '50x35x20 cm', 'Gray', 'Large', '2023-01-25', true),
(10, 'Wireless Mouse', 'Electronics', 'Computer', 'TechPro', 29.99, 12.00, 0.12, '12x6x4 cm', 'Black', 'Standard', '2023-02-20', true);

-- Insert sample customers
INSERT INTO customers VALUES
(1, 'john.doe@email.com', 'John', 'Doe', '+1-555-0101', '1985-03-15', 'Male', '2023-01-10', 'Premium', 'EN', true),
(2, 'jane.smith@email.com', 'Jane', 'Smith', '+1-555-0102', '1990-07-22', 'Female', '2023-01-15', 'Regular', 'EN', true),
(3, 'mike.johnson@email.com', 'Mike', 'Johnson', '+1-555-0103', '1988-11-08', 'Male', '2023-02-01', 'Premium', 'EN', false),
(4, 'sarah.wilson@email.com', 'Sarah', 'Wilson', '+1-555-0104', '1992-05-30', 'Female', '2023-02-10', 'Regular', 'EN', true),
(5, 'david.brown@email.com', 'David', 'Brown', '+1-555-0105', '1987-09-12', 'Male', '2023-02-15', 'VIP', 'EN', true),
(6, 'lisa.davis@email.com', 'Lisa', 'Davis', '+1-555-0106', '1991-12-03', 'Female', '2023-03-01', 'Regular', 'EN', false),
(7, 'tom.miller@email.com', 'Tom', 'Miller', '+1-555-0107', '1989-04-18', 'Male', '2023-03-05', 'Premium', 'EN', true),
(8, 'amy.garcia@email.com', 'Amy', 'Garcia', '+1-555-0108', '1993-08-25', 'Female', '2023-03-10', 'Regular', 'EN', true);
-- Insert sample addresses
INSERT INTO customer_addresses VALUES
(1, 1, 'billing', '123 Main St', 'New York', 'NY', '10001', 'USA', true),
(2, 1, 'shipping', '123 Main St', 'New York', 'NY', '10001', 'USA', true),
(3, 2, 'billing', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA', true),
(4, 2, 'shipping', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'USA', true),
(5, 3, 'billing', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA', true),
(6, 3, 'shipping', '789 Pine Rd', 'Chicago', 'IL', '60601', 'USA', true),
(7, 4, 'billing', '321 Elm St', 'Houston', 'TX', '77001', 'USA', true),
(8, 4, 'shipping', '321 Elm St', 'Houston', 'TX', '77001', 'USA', true);

-- Insert sample orders
INSERT INTO orders VALUES
(1, 1, '2023-03-15 10:30:00', 'delivered', 'credit_card', 'standard', 89.99, 7.20, 5.99, 0.00, 103.18, 1, 2, NULL),
(2, 2, '2023-03-16 14:15:00', 'delivered', 'paypal', 'express', 44.98, 3.60, 9.99, 5.00, 53.57, 3, 4, 'SAVE5'),
(3, 3, '2023-03-17 09:45:00', 'shipped', 'credit_card', 'standard', 129.99, 10.40, 5.99, 0.00, 146.38, 5, 6, NULL),
(4, 1, '2023-03-18 16:20:00', 'delivered', 'credit_card', 'express', 79.99, 6.40, 9.99, 0.00, 96.38, 1, 2, NULL),
(5, 4, '2023-03-19 11:10:00', 'cancelled', 'credit_card', 'standard', 59.99, 4.80, 5.99, 0.00, 70.78, 7, 8, NULL),
(6, 2, '2023-03-20 13:30:00', 'pending', 'paypal', 'standard', 29.99, 2.40, 5.99, 0.00, 38.38, 3, 4, NULL),
(7, 5, '2023-03-21 15:45:00', 'delivered', 'credit_card', 'express', 109.98, 8.80, 9.99, 10.00, 118.77, 1, 2, 'VIP10'),
(8, 3, '2023-03-22 12:00:00', 'delivered', 'credit_card', 'standard', 39.99, 3.20, 5.99, 0.00, 49.18, 5, 6, NULL);

-- Insert order items
INSERT INTO order_items VALUES
(1, 1, 1, 1, 89.99, 0.00, 89.99),
(2, 2, 2, 1, 24.99, 0.00, 24.99),
(3, 2, 3, 1, 19.99, 0.00, 19.99),
(4, 3, 6, 1, 129.99, 0.00, 129.99),
(5, 4, 7, 1, 79.99, 0.00, 79.99),
(6, 5, 9, 1, 59.99, 0.00, 59.99),
(7, 6, 10, 1, 29.99, 0.00, 29.99),
(8, 7, 1, 1, 89.99, 0.00, 89.99),
(9, 7, 3, 1, 19.99, 0.00, 19.99),
(10, 8, 8, 1, 39.99, 0.00, 39.99);

-- Insert web sessions
INSERT INTO web_sessions VALUES
('sess_001', 1, '2023-03-15 10:00:00', '2023-03-15 10:45:00', 'desktop', 'Chrome', 'Windows', 'organic', NULL, NULL, 'google'),
('sess_002', 2, '2023-03-16 14:00:00', '2023-03-16 14:30:00', 'mobile', 'Safari', 'iOS', 'social', 'spring_sale', 'social', 'facebook'),
('sess_003', 3, '2023-03-17 09:30:00', '2023-03-17 10:00:00', 'desktop', 'Firefox', 'macOS', 'direct', NULL, NULL, NULL),
('sess_004', 1, '2023-03-18 16:00:00', '2023-03-18 16:35:00', 'desktop', 'Chrome', 'Windows', 'email', 'newsletter', 'email', 'newsletter'),
('sess_005', 4, '2023-03-19 11:00:00', '2023-03-19 11:25:00', 'tablet', 'Safari', 'iOS', 'paid_search', 'google_ads', 'cpc', 'google'),
('sess_006', 2, '2023-03-20 13:15:00', '2023-03-20 13:45:00', 'mobile', 'Chrome', 'Android', 'organic', NULL, NULL, 'google'),
('sess_007', 5, '2023-03-21 15:30:00', '2023-03-21 16:00:00', 'desktop', 'Edge', 'Windows', 'direct', NULL, NULL, NULL),
('sess_008', 3, '2023-03-22 11:45:00', '2023-03-22 12:15:00', 'desktop', 'Chrome', 'macOS', 'organic', NULL, NULL, 'bing');

-- Insert cart events
INSERT INTO cart_events VALUES
(1, 'sess_001', 1, 1, 'add_to_cart', 1, '2023-03-15 10:25:00'),
(2, 'sess_002', 2, 2, 'add_to_cart', 1, '2023-03-16 14:10:00'),
(3, 'sess_002', 2, 3, 'add_to_cart', 1, '2023-03-16 14:12:00'),
(4, 'sess_003', 3, 6, 'add_to_cart', 1, '2023-03-17 09:40:00'),
(5, 'sess_004', 1, 7, 'add_to_cart', 1, '2023-03-18 16:15:00'),
(6, 'sess_005', 4, 9, 'add_to_cart', 1, '2023-03-19 11:05:00'),
(7, 'sess_006', 2, 10, 'add_to_cart', 1, '2023-03-20 13:25:00'),
(8, 'sess_007', 5, 1, 'add_to_cart', 1, '2023-03-21 15:40:00'),
(9, 'sess_007', 5, 3, 'add_to_cart', 1, '2023-03-21 15:42:00'),
(10, 'sess_008', 3, 8, 'add_to_cart', 1, '2023-03-22 11:55:00');

-- Insert inventory data
INSERT INTO inventory VALUES
(1, 1, 'Warehouse A', 150, 10, 20, 100, '2023-03-22 12:00:00'),
(2, 2, 'Warehouse A', 200, 5, 30, 150, '2023-03-22 12:00:00'),
(3, 3, 'Warehouse B', 300, 15, 50, 200, '2023-03-22 12:00:00'),
(4, 4, 'Warehouse A', 75, 8, 15, 50, '2023-03-22 12:00:00'),
(5, 5, 'Warehouse B', 180, 12, 25, 100, '2023-03-22 12:00:00'),
(6, 6, 'Warehouse A', 45, 3, 10, 30, '2023-03-22 12:00:00'),
(7, 7, 'Warehouse B', 120, 18, 20, 80, '2023-03-22 12:00:00'),
(8, 8, 'Warehouse A', 90, 6, 15, 60, '2023-03-22 12:00:00'),
(9, 9, 'Warehouse B', 65, 4, 12, 40, '2023-03-22 12:00:00'),
(10, 10, 'Warehouse A', 220, 25, 40, 150, '2023-03-22 12:00:00');

-- Insert product reviews
INSERT INTO product_reviews VALUES
(1, 1, 1, 1, 5, 'Excellent sound quality!', 'These headphones exceeded my expectations. Great bass and clear highs.', '2023-03-20', true, 3),
(2, 2, 2, 2, 4, 'Comfortable and soft', 'Nice organic cotton feel, fits well. Color is exactly as shown.', '2023-03-21', true, 1),
(3, 6, 3, 3, 5, 'Perfect coffee maker', 'Makes excellent coffee every morning. Easy to clean and use.', '2023-03-22', true, 2),
(4, 7, 1, 4, 4, 'Great running shoes', 'Comfortable for long runs. Good support and cushioning.', '2023-03-23', true, 1),
(5, 1, 5, 7, 5, 'Amazing headphones', 'Second pair I bought. Quality is consistent and battery life is great.', '2023-03-24', true, 4);
-- ============================================
-- INVENTORY MANAGEMENT ANALYTICS
-- ============================================

-- WHAT IT IS: Inventory management analytics tracks stock levels, turnover rates,
-- and demand patterns to optimize inventory investment and prevent stockouts.
--
-- WHY IT MATTERS: Effective inventory management:
-- - Reduces carrying costs and improves cash flow
-- - Prevents lost sales due to stockouts
-- - Identifies slow-moving and obsolete inventory
-- - Optimizes reorder points and quantities
--
-- KEY METRICS: Inventory turnover, days sales outstanding, stockout rate
-- BENCHMARK: Healthy inventory turnover: 4-6x annually for most categories

-- Example 1: Inventory Performance Analysis
-- Business Question: "Which products need inventory optimization?"

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    i.quantity_available,
    i.quantity_reserved,
    i.reorder_point,
    
    -- Calculate inventory metrics
    (i.quantity_available + i.quantity_reserved) as total_inventory,
    COALESCE(sales_data.units_sold, 0) as units_sold_30_days,
    COALESCE(sales_data.revenue, 0) as revenue_30_days,
    
    -- Inventory turnover calculation (annualized)
    CASE 
        WHEN (i.quantity_available + i.quantity_reserved) > 0 
        THEN ROUND(COALESCE(sales_data.units_sold, 0) * 12.0 / (i.quantity_available + i.quantity_reserved), 2)
        ELSE 0 
    END as inventory_turnover_annual,
    
    -- Days of inventory remaining
    CASE 
        WHEN COALESCE(sales_data.units_sold, 0) > 0 
        THEN ROUND((i.quantity_available + i.quantity_reserved) * 30.0 / sales_data.units_sold, 1)
        ELSE 999 
    END as days_of_inventory,
    
    -- Stock status
    CASE 
        WHEN i.quantity_available <= i.reorder_point THEN 'REORDER_NEEDED'
        WHEN i.quantity_available <= i.reorder_point * 1.5 THEN 'LOW_STOCK'
        WHEN COALESCE(sales_data.units_sold, 0) = 0 THEN 'NO_SALES'
        ELSE 'HEALTHY'
    END as stock_status,
    
    -- Inventory value
    ROUND((i.quantity_available + i.quantity_reserved) * p.cost, 2) as inventory_value

FROM products p
JOIN inventory i ON p.product_id = i.product_id
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) as units_sold,
        SUM(oi.total_price) as revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    AND o.order_status NOT IN ('cancelled', 'returned')
    GROUP BY oi.product_id
) sales_data ON p.product_id = sales_data.product_id
ORDER BY inventory_turnover_annual DESC;

-- Example 2: Category-Level Inventory Analysis
-- Business Question: "How is inventory performing across different categories?"

SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) as product_count,
    SUM(i.quantity_available + i.quantity_reserved) as total_units,
    SUM((i.quantity_available + i.quantity_reserved) * p.cost) as total_inventory_value,
    AVG((i.quantity_available + i.quantity_reserved) * p.cost) as avg_inventory_per_product,
    
    -- Sales performance
    SUM(COALESCE(sales_data.units_sold, 0)) as total_units_sold,
    SUM(COALESCE(sales_data.revenue, 0)) as total_revenue,
    
    -- Category-level turnover
    CASE 
        WHEN SUM(i.quantity_available + i.quantity_reserved) > 0 
        THEN ROUND(SUM(COALESCE(sales_data.units_sold, 0)) * 12.0 / SUM(i.quantity_available + i.quantity_reserved), 2)
        ELSE 0 
    END as category_turnover_annual,
    
    -- Stock status distribution
    COUNT(CASE WHEN i.quantity_available <= i.reorder_point THEN 1 END) as products_needing_reorder,
    COUNT(CASE WHEN COALESCE(sales_data.units_sold, 0) = 0 THEN 1 END) as products_with_no_sales,
    
    -- Performance metrics
    ROUND(SUM(COALESCE(sales_data.revenue, 0)) / NULLIF(SUM((i.quantity_available + i.quantity_reserved) * p.cost), 0) * 100, 2) as revenue_to_inventory_ratio

FROM products p
JOIN inventory i ON p.product_id = i.product_id
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) as units_sold,
        SUM(oi.total_price) as revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    AND o.order_status NOT IN ('cancelled', 'returned')
    GROUP BY oi.product_id
) sales_data ON p.product_id = sales_data.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ============================================
-- CART ABANDONMENT ANALYSIS
-- ============================================

-- WHAT IT IS: Cart abandonment analysis identifies when and why customers
-- add items to their cart but don't complete the purchase.
--
-- WHY IT MATTERS: Cart abandonment insights enable:
-- - Recovery campaigns to convert abandoned carts
-- - UX improvements to reduce friction in checkout
-- - Pricing and promotion optimization
-- - Inventory planning based on purchase intent
--
-- KEY METRICS: Abandonment rate, time to abandonment, recovery rate
-- BENCHMARK: Average ecommerce cart abandonment rate: 60-80%

-- Example 3: Cart Abandonment Analysis
-- Business Question: "What is our cart abandonment rate and what are the patterns?"

WITH cart_sessions AS (
    SELECT 
        ce.session_id,
        ce.customer_id,
        ws.device_type,
        ws.traffic_source,
        COUNT(DISTINCT ce.product_id) as products_added,
        SUM(ce.quantity * p.price) as cart_value,
        MIN(ce.event_timestamp) as first_add_time,
        MAX(ce.event_timestamp) as last_add_time
    FROM cart_events ce
    JOIN products p ON ce.product_id = p.product_id
    JOIN web_sessions ws ON ce.session_id = ws.session_id
    WHERE ce.event_type = 'add_to_cart'
    GROUP BY ce.session_id, ce.customer_id, ws.device_type, ws.traffic_source
),

completed_orders AS (
    SELECT DISTINCT
        ws.session_id,
        o.order_id,
        o.total_amount
    FROM orders o
    JOIN web_sessions ws ON o.customer_id = ws.customer_id
    WHERE o.order_date BETWEEN ws.start_timestamp AND ws.end_timestamp + INTERVAL '1 hour'
    AND o.order_status NOT IN ('cancelled')
)

SELECT 
    cs.device_type,
    cs.traffic_source,
    COUNT(*) as cart_sessions,
    COUNT(co.order_id) as completed_orders,
    COUNT(*) - COUNT(co.order_id) as abandoned_carts,
    
    -- Abandonment rate
    ROUND((COUNT(*) - COUNT(co.order_id)) * 100.0 / COUNT(*), 2) as abandonment_rate_pct,
    
    -- Cart value analysis
    ROUND(AVG(cs.cart_value), 2) as avg_cart_value,
    ROUND(AVG(CASE WHEN co.order_id IS NULL THEN cs.cart_value END), 2) as avg_abandoned_cart_value,
    ROUND(AVG(CASE WHEN co.order_id IS NOT NULL THEN cs.cart_value END), 2) as avg_completed_cart_value,
    
    -- Product analysis
    ROUND(AVG(cs.products_added), 2) as avg_products_per_cart,
    ROUND(AVG(CASE WHEN co.order_id IS NULL THEN cs.products_added END), 2) as avg_products_abandoned,
    
    -- Revenue impact
    ROUND(SUM(CASE WHEN co.order_id IS NULL THEN cs.cart_value ELSE 0 END), 2) as potential_lost_revenue

FROM cart_sessions cs
LEFT JOIN completed_orders co ON cs.session_id = co.session_id
GROUP BY cs.device_type, cs.traffic_source
ORDER BY abandonment_rate_pct DESC;

-- Example 4: Product-Level Cart Abandonment
-- Business Question: "Which products are most frequently abandoned in carts?"

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    
    -- Cart metrics
    COUNT(ce.event_id) as times_added_to_cart,
    COUNT(DISTINCT ce.session_id) as unique_cart_sessions,
    SUM(ce.quantity) as total_quantity_added,
    
    -- Purchase conversion
    COUNT(DISTINCT oi.order_id) as times_purchased,
    COALESCE(SUM(oi.quantity), 0) as total_quantity_purchased,
    
    -- Abandonment analysis
    COUNT(ce.event_id) - COUNT(DISTINCT oi.order_id) as abandonment_instances,
    ROUND((COUNT(ce.event_id) - COUNT(DISTINCT oi.order_id)) * 100.0 / COUNT(ce.event_id), 2) as abandonment_rate_pct,
    
    -- Revenue impact
    ROUND(p.price * (SUM(ce.quantity) - COALESCE(SUM(oi.quantity), 0)), 2) as potential_lost_revenue,
    
    -- Performance score (lower abandonment + higher value = better)
    ROUND((100 - (COUNT(ce.event_id) - COUNT(DISTINCT oi.order_id)) * 100.0 / COUNT(ce.event_id)) * p.price / 100, 2) as performance_score

FROM products p
JOIN cart_events ce ON p.product_id = ce.product_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE ce.event_type = 'add_to_cart'
GROUP BY p.product_id, p.product_name, p.category, p.price
HAVING COUNT(ce.event_id) >= 2  -- Focus on products with meaningful cart activity
ORDER BY potential_lost_revenue DESC;
-- ============================================
-- SALES FUNNEL ANALYSIS
-- ============================================

-- WHAT IT IS: Sales funnel analysis tracks customer progression through
-- the purchase journey from initial visit to completed order.
--
-- WHY IT MATTERS: Funnel analysis reveals:
-- - Conversion bottlenecks in the customer journey
-- - Opportunities to optimize user experience
-- - Impact of marketing campaigns on conversion
-- - Revenue optimization opportunities
--
-- FUNNEL STAGES: Visit → Product View → Add to Cart → Checkout → Purchase
-- BENCHMARK: Typical ecommerce conversion rates: 2-3% visit-to-purchase

-- Example 5: Complete Sales Funnel Analysis
-- Business Question: "What does our sales funnel look like and where are the drop-offs?"

WITH funnel_data AS (
    SELECT 
        ws.session_id,
        ws.customer_id,
        ws.device_type,
        ws.traffic_source,
        
        -- Funnel stage indicators
        1 as visited,
        CASE WHEN product_views.session_id IS NOT NULL THEN 1 ELSE 0 END as viewed_product,
        CASE WHEN cart_adds.session_id IS NOT NULL THEN 1 ELSE 0 END as added_to_cart,
        CASE WHEN orders.session_id IS NOT NULL THEN 1 ELSE 0 END as completed_purchase,
        
        -- Value metrics
        COALESCE(cart_adds.cart_value, 0) as cart_value,
        COALESCE(orders.order_value, 0) as order_value
        
    FROM web_sessions ws
    
    -- Product views
    LEFT JOIN (
        SELECT DISTINCT 
            pv.session_id,
            SUM(pv.time_on_page_seconds) as total_view_time
        FROM page_views pv 
        WHERE pv.page_type = 'product'
        GROUP BY pv.session_id
    ) product_views ON ws.session_id = product_views.session_id
    
    -- Cart additions
    LEFT JOIN (
        SELECT 
            ce.session_id,
            SUM(ce.quantity * p.price) as cart_value
        FROM cart_events ce
        JOIN products p ON ce.product_id = p.product_id
        WHERE ce.event_type = 'add_to_cart'
        GROUP BY ce.session_id
    ) cart_adds ON ws.session_id = cart_adds.session_id
    
    -- Completed orders
    LEFT JOIN (
        SELECT DISTINCT
            ws2.session_id,
            o.total_amount as order_value
        FROM orders o
        JOIN web_sessions ws2 ON o.customer_id = ws2.customer_id
        WHERE o.order_date BETWEEN ws2.start_timestamp AND ws2.end_timestamp + INTERVAL '1 hour'
        AND o.order_status NOT IN ('cancelled')
    ) orders ON ws.session_id = orders.session_id
)

SELECT 
    device_type,
    traffic_source,
    
    -- Funnel volumes
    COUNT(*) as total_sessions,
    SUM(viewed_product) as product_views,
    SUM(added_to_cart) as cart_additions,
    SUM(completed_purchase) as purchases,
    
    -- Conversion rates
    ROUND(SUM(viewed_product) * 100.0 / COUNT(*), 2) as visit_to_view_rate,
    ROUND(SUM(added_to_cart) * 100.0 / NULLIF(SUM(viewed_product), 0), 2) as view_to_cart_rate,
    ROUND(SUM(completed_purchase) * 100.0 / NULLIF(SUM(added_to_cart), 0), 2) as cart_to_purchase_rate,
    ROUND(SUM(completed_purchase) * 100.0 / COUNT(*), 2) as overall_conversion_rate,
    
    -- Value metrics
    ROUND(AVG(CASE WHEN added_to_cart = 1 THEN cart_value END), 2) as avg_cart_value,
    ROUND(AVG(CASE WHEN completed_purchase = 1 THEN order_value END), 2) as avg_order_value,
    ROUND(SUM(order_value), 2) as total_revenue,
    
    -- Revenue per session
    ROUND(SUM(order_value) / COUNT(*), 2) as revenue_per_session

FROM funnel_data
GROUP BY device_type, traffic_source
ORDER BY total_revenue DESC;

-- Example 6: Time-Based Funnel Analysis
-- Business Question: "How does our conversion funnel perform over time?"

WITH daily_funnel AS (
    SELECT 
        DATE(ws.start_timestamp) as session_date,
        COUNT(*) as total_sessions,
        
        -- Funnel metrics
        COUNT(CASE WHEN product_views.session_id IS NOT NULL THEN 1 END) as product_view_sessions,
        COUNT(CASE WHEN cart_adds.session_id IS NOT NULL THEN 1 END) as cart_sessions,
        COUNT(CASE WHEN orders.session_id IS NOT NULL THEN 1 END) as purchase_sessions,
        
        -- Revenue
        SUM(COALESCE(orders.order_value, 0)) as daily_revenue
        
    FROM web_sessions ws
    LEFT JOIN (
        SELECT DISTINCT session_id FROM page_views WHERE page_type = 'product'
    ) product_views ON ws.session_id = product_views.session_id
    LEFT JOIN (
        SELECT DISTINCT session_id FROM cart_events WHERE event_type = 'add_to_cart'
    ) cart_adds ON ws.session_id = cart_adds.session_id
    LEFT JOIN (
        SELECT DISTINCT
            ws2.session_id,
            o.total_amount as order_value
        FROM orders o
        JOIN web_sessions ws2 ON o.customer_id = ws2.customer_id
        WHERE o.order_date BETWEEN ws2.start_timestamp AND ws2.end_timestamp + INTERVAL '1 hour'
        AND o.order_status NOT IN ('cancelled')
    ) orders ON ws.session_id = orders.session_id
    
    GROUP BY DATE(ws.start_timestamp)
)

SELECT 
    session_date,
    total_sessions,
    product_view_sessions,
    cart_sessions,
    purchase_sessions,
    
    -- Daily conversion rates
    ROUND(product_view_sessions * 100.0 / total_sessions, 2) as visit_to_view_rate,
    ROUND(cart_sessions * 100.0 / NULLIF(product_view_sessions, 0), 2) as view_to_cart_rate,
    ROUND(purchase_sessions * 100.0 / NULLIF(cart_sessions, 0), 2) as cart_to_purchase_rate,
    ROUND(purchase_sessions * 100.0 / total_sessions, 2) as overall_conversion_rate,
    
    -- Revenue metrics
    ROUND(daily_revenue, 2) as daily_revenue,
    ROUND(daily_revenue / NULLIF(purchase_sessions, 0), 2) as avg_order_value,
    ROUND(daily_revenue / total_sessions, 2) as revenue_per_session

FROM daily_funnel
ORDER BY session_date;

-- ============================================
-- PRODUCT RECOMMENDATION ANALYTICS
-- ============================================

-- WHAT IT IS: Product recommendation analytics identifies patterns in customer
-- behavior to suggest relevant products and increase cross-selling opportunities.
--
-- WHY IT MATTERS: Effective recommendations drive:
-- - Increased average order value through cross-selling
-- - Improved customer experience and satisfaction
-- - Higher conversion rates and customer retention
-- - Better inventory turnover for slow-moving items
--
-- RECOMMENDATION TYPES: Collaborative filtering, content-based, hybrid approaches
-- BENCHMARK: Good recommendations increase AOV by 10-30%

-- Example 7: Frequently Bought Together Analysis
-- Business Question: "Which products are frequently purchased together?"

WITH product_pairs AS (
    SELECT 
        oi1.product_id as product_a,
        oi2.product_id as product_b,
        COUNT(DISTINCT oi1.order_id) as times_bought_together,
        AVG(oi1.total_price + oi2.total_price) as avg_combined_value
    FROM order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
    GROUP BY oi1.product_id, oi2.product_id
    HAVING COUNT(DISTINCT oi1.order_id) >= 2
)

SELECT 
    pa.product_name as product_a_name,
    pa.category as product_a_category,
    pa.price as product_a_price,
    pb.product_name as product_b_name,
    pb.category as product_b_category,
    pb.price as product_b_price,
    pp.times_bought_together,
    ROUND(pp.avg_combined_value, 2) as avg_combined_value,
    
    -- Calculate lift (how much more likely to buy together vs independently)
    ROUND(
        pp.times_bought_together * 1.0 / 
        (
            (SELECT COUNT(DISTINCT order_id) FROM order_items WHERE product_id = pp.product_a) *
            (SELECT COUNT(DISTINCT order_id) FROM order_items WHERE product_id = pp.product_b) * 1.0 /
            (SELECT COUNT(DISTINCT order_id) FROM orders WHERE order_status NOT IN ('cancelled', 'returned'))
        ), 2
    ) as lift_score,
    
    -- Recommendation strength
    CASE 
        WHEN pp.times_bought_together >= 3 THEN 'Strong'
        WHEN pp.times_bought_together >= 2 THEN 'Moderate'
        ELSE 'Weak'
    END as recommendation_strength

FROM product_pairs pp
JOIN products pa ON pp.product_a = pa.product_id
JOIN products pb ON pp.product_b = pb.product_id
ORDER BY pp.times_bought_together DESC, pp.avg_combined_value DESC;

-- Example 8: Customer Segment Product Preferences
-- Business Question: "What products do different customer segments prefer?"

SELECT 
    c.customer_segment,
    p.category,
    p.product_name,
    COUNT(DISTINCT oi.order_id) as times_purchased,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(oi.unit_price), 2) as avg_price_paid,
    
    -- Segment penetration
    COUNT(DISTINCT c.customer_id) as unique_customers,
    ROUND(COUNT(DISTINCT c.customer_id) * 100.0 / 
          (SELECT COUNT(DISTINCT customer_id) FROM customers WHERE customer_segment = c.customer_segment), 2) as segment_penetration_pct,
    
    -- Product performance within segment
    RANK() OVER (PARTITION BY c.customer_segment ORDER BY SUM(oi.total_price) DESC) as revenue_rank_in_segment

FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status NOT IN ('cancelled', 'returned')
GROUP BY c.customer_segment, p.category, p.product_name, p.product_id
ORDER BY c.customer_segment, total_revenue DESC;

-- ============================================
-- ECOMMERCE ANALYTICS BEST PRACTICES
-- ============================================

-- PERFORMANCE OPTIMIZATION STRATEGIES:
-- 1. Index Strategy for Ecommerce Analytics
--    - Create indexes on frequently queried columns: customer_id, product_id, order_date
--    - Composite indexes for common filter combinations: (customer_id, order_date)
--    - Consider partitioning large tables by date for time-series queries

-- 2. Data Quality Monitoring
--    - Implement data validation rules for critical metrics
--    - Monitor for anomalies in conversion rates and revenue patterns
--    - Set up alerts for significant deviations from baseline performance

-- 3. Real-Time vs Batch Analytics
--    - Use real-time analytics for operational decisions (inventory alerts, fraud detection)
--    - Batch processing for complex analytical queries and reporting
--    - Consider materialized views for frequently accessed aggregations

-- BUSINESS INTELLIGENCE INTEGRATION:
-- 1. KPI Dashboard Requirements
--    - Daily/weekly/monthly revenue trends
--    - Conversion funnel performance by traffic source
--    - Top performing products and categories
--    - Customer acquisition and retention metrics

-- 2. Automated Reporting
--    - Schedule regular reports for stakeholders
--    - Set up exception reporting for unusual patterns
--    - Create executive summaries with key insights

-- 3. Predictive Analytics Opportunities
--    - Customer lifetime value prediction
--    - Demand forecasting for inventory planning
--    - Churn prediction and prevention
--    - Price optimization modeling

-- SCALABILITY CONSIDERATIONS:
-- 1. Data Architecture
--    - Separate OLTP (transactional) from OLAP (analytical) systems
--    - Use data warehousing for historical analysis
--    - Implement proper data governance and lineage tracking

-- 2. Query Optimization
--    - Use appropriate aggregation levels for different use cases
--    - Implement caching for frequently accessed results
--    - Consider columnar storage for analytical workloads

-- 3. Privacy and Compliance
--    - Implement data anonymization for customer analytics
--    - Ensure GDPR/CCPA compliance in data collection and processing
--    - Maintain audit trails for data access and modifications

-- ACTIONABLE INSIGHTS FRAMEWORK:
-- 1. Inventory Management
--    - Set up automated reorder alerts based on turnover rates
--    - Identify slow-moving inventory for promotional campaigns
--    - Optimize warehouse allocation based on regional demand

-- 2. Marketing Optimization
--    - Use funnel analysis to optimize ad spend allocation
--    - Implement personalized product recommendations
--    - Create targeted campaigns based on customer segments

-- 3. Customer Experience Enhancement
--    - Reduce cart abandonment through UX improvements
--    - Optimize product catalog based on search and browse patterns
--    - Implement dynamic pricing based on demand patterns

-- SAMPLE EXECUTIVE SUMMARY QUERY:
-- Business Question: "What are our key ecommerce performance metrics this month?"

WITH monthly_metrics AS (
    SELECT 
        -- Revenue metrics
        COUNT(DISTINCT o.order_id) as total_orders,
        COUNT(DISTINCT o.customer_id) as unique_customers,
        SUM(o.total_amount) as total_revenue,
        AVG(o.total_amount) as avg_order_value,
        
        -- Conversion metrics
        COUNT(DISTINCT ws.session_id) as total_sessions,
        COUNT(DISTINCT CASE WHEN ce.session_id IS NOT NULL THEN ws.session_id END) as cart_sessions,
        
        -- Product metrics
        COUNT(DISTINCT oi.product_id) as products_sold,
        SUM(oi.quantity) as total_units_sold
        
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN web_sessions ws ON o.customer_id = ws.customer_id 
        AND o.order_date BETWEEN ws.start_timestamp AND ws.end_timestamp + INTERVAL '1 hour'
    LEFT JOIN cart_events ce ON ws.session_id = ce.session_id
    WHERE o.order_date >= DATE_TRUNC('month', CURRENT_DATE)
    AND o.order_status NOT IN ('cancelled', 'returned')
)

SELECT 
    'ECOMMERCE PERFORMANCE SUMMARY - ' || STRFTIME(CURRENT_DATE, '%B %Y') as report_title,
    total_orders || ' orders generating $' || ROUND(total_revenue, 0) || ' revenue' as revenue_summary,
    unique_customers || ' customers with $' || ROUND(avg_order_value, 2) || ' AOV' as customer_summary,
    ROUND(total_orders * 100.0 / NULLIF(total_sessions, 0), 2) || '% conversion rate' as conversion_summary,
    products_sold || ' different products sold (' || total_units_sold || ' units)' as product_summary,
    ROUND(cart_sessions * 100.0 / NULLIF(total_sessions, 0), 2) || '% cart engagement rate' as engagement_summary
FROM monthly_metrics;

-- ============================================
-- CLEANUP AND MAINTENANCE
-- ============================================

-- Note: In production environments, consider implementing:
-- 1. Regular data archiving for old transactional data
-- 2. Automated data quality checks and monitoring
-- 3. Performance monitoring for analytical queries
-- 4. Regular index maintenance and statistics updates

-- ============================================
-- END OF ECOMMERCE ANALYTICS EXAMPLES
-- ============================================