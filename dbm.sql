/*
* Inventory Management System Database
* Author: [Your Name]
* Date: May 9, 2025
*
* Description:
* This SQL script creates a comprehensive database for managing inventory in a retail business.
* The system tracks products, suppliers, inventory levels, purchase orders, sales,
* and supports multiple warehouse locations.
*
* Features:
* - Product and category management
* - Supplier relationship tracking
* - Multi-location inventory tracking
* - Purchase order processing
* - Sales order management
* - User management and security
* - Audit logging
*/

-- Create database
CREATE DATABASE inventory_management;

-- Use the database
USE inventory_management;

-- Table: categories
-- Stores product categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: suppliers
-- Stores information about product suppliers
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    website VARCHAR(255),
    payment_terms VARCHAR(100),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: products
-- Stores product information
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity_per_unit VARCHAR(50),
    reorder_level INT DEFAULT 10,
    discontinued BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Table: warehouse_locations
-- Stores information about different warehouse locations
CREATE TABLE warehouse_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    capacity INT,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: inventory
-- Tracks inventory levels for each product at each location
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    location_id INT NOT NULL,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    quantity_available INT GENERATED ALWAYS AS (quantity_in_stock - quantity_reserved) STORED,
    last_stock_check DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES warehouse_locations(location_id) ON DELETE CASCADE,
    UNIQUE KEY (product_id, location_id)
);

-- Table: product_suppliers
-- Many-to-many relationship between products and suppliers
CREATE TABLE product_suppliers (
    product_id INT NOT NULL,
    supplier_id INT NOT NULL,
    supplier_product_code VARCHAR(50),
    supplier_price DECIMAL(10, 2),
    lead_time_days INT,
    is_preferred BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE
);

-- Table: purchase_orders
-- Stores information about purchase orders to suppliers
CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status ENUM('draft', 'submitted', 'approved', 'shipped', 'received', 'cancelled') DEFAULT 'draft',
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    notes TEXT,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT
);

-- Table: purchase_order_items
-- Items within a purchase order
CREATE TABLE purchase_order_items (
    po_item_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity_ordered INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantity_ordered * unit_price) STORED,
    quantity_received INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Table: customers
-- Stores customer information
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: sales_orders
-- Stores information about customer orders
CREATE TABLE sales_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    shipping_address TEXT,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(50),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
);

-- Table: sales_order_items
-- Items within a sales order
CREATE TABLE sales_order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES sales_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Table: inventory_transactions
-- Tracks all inventory movements (increases, decreases)
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    transaction_type ENUM('purchase', 'sale', 'adjustment', 'transfer_in', 'transfer_out', 'return') NOT NULL,
    quantity INT NOT NULL,
    reference_id INT,
    reference_type ENUM('po_item', 'sale_item', 'adjustment', 'transfer'),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE RESTRICT
);

-- Table: inventory_transfers
-- Tracks transfers of inventory between locations
CREATE TABLE inventory_transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    source_location_id INT NOT NULL,
    destination_location_id INT NOT NULL,
    quantity INT NOT NULL,
    status ENUM('pending', 'in_transit', 'completed', 'cancelled') DEFAULT 'pending',
    transfer_date DATE NOT NULL,
    notes TEXT,
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    FOREIGN KEY (source_location_id) REFERENCES warehouse_locations(location_id) ON DELETE RESTRICT,
    FOREIGN KEY (destination_location_id) REFERENCES warehouse_locations(location_id) ON DELETE RESTRICT
);

-- Table: user_roles
-- Defines roles for system users
CREATE TABLE user_roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: users
-- System users who manage inventory
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role_id INT,
    active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES user_roles(role_id) ON DELETE SET NULL
);

-- Table: audit_log
-- Tracks important system activities for auditing purposes
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT,
    description TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Create indexes for performance optimization
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_inventory_location ON inventory(location_id);
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_items_product ON purchase_order_items(product_id);
CREATE INDEX idx_so_customer ON sales_orders(customer_id);
CREATE INDEX idx_so_items_product ON sales_order_items(product_id);
CREATE INDEX idx_transactions_inventory ON inventory_transactions(inventory_id);
CREATE INDEX idx_transfers_product ON inventory_transfers(product_id);
CREATE INDEX idx_users_role ON users(role_id);




-- Sample data for testing
-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and components'),
('Clothing', 'Apparel and accessories'),
('Home & Garden', 'Home improvement and gardening supplies'),
('Office Supplies', 'Items for office use'),
('Sports & Outdoors', 'Sports equipment and outdoor gear');

-- Insert sample suppliers
INSERT INTO suppliers (company_name, contact_name, contact_email, contact_phone, address, city, state, postal_code, country) VALUES
('Tech Distributors Inc.', 'John Smith', 'john@techdist.com', '555-123-4567', '123 Tech Blvd', 'San Francisco', 'CA', '94105', 'USA'),
('Fashion Wholesale Co.', 'Sarah Johnson', 'sarah@fashionwholesale.com', '555-234-5678', '456 Style Ave', 'New York', 'NY', '10001', 'USA'),
('Global Home Supplies', 'Mike Brown', 'mike@globalhome.com', '555-345-6789', '789 Home Lane', 'Chicago', 'IL', '60601', 'USA'),
('Office World', 'Lisa Davis', 'lisa@officeworld.com', '555-456-7890', '321 Business Rd', 'Dallas', 'TX', '75201', 'USA'),
('Outdoor Gear Ltd.', 'David Wilson', 'david@outdoorgear.com', '555-567-8901', '654 Adventure St', 'Denver', 'CO', '80202', 'USA');

-- Insert sample products
INSERT INTO products (sku, name, description, category_id, unit_price, quantity_per_unit, reorder_level) VALUES
('ELEC-1001', 'Wireless Mouse', 'Ergonomic wireless mouse with 2.4GHz connectivity', 1, 24.99, '1 per box', 20),
('ELEC-1002', 'Bluetooth Headphones', 'Noise-cancelling over-ear headphones', 1, 129.99, '1 per box', 15),
('CLOTH-2001', 'Men\'s T-Shirt', '100% cotton crew neck t-shirt', 2, 19.99, '1 per piece', 50),
('CLOTH-2002', 'Women\'s Jeans', 'Slim fit denim jeans', 2, 49.99, '1 per piece', 30),
('HOME-3001', 'Gardening Tool Set', '6-piece stainless steel gardening tools', 3, 39.99, '1 set', 25),
('HOME-3002', 'Desk Lamp', 'LED adjustable desk lamp', 3, 29.99, '1 per box', 40),
('OFF-4001', 'Stapler', 'Heavy-duty office stapler', 4, 12.99, '1 per box', 60),
('OFF-4002', 'Notebook', 'A5 size 100-page notebook', 4, 4.99, '1 per piece', 100),
('SPORT-5001', 'Yoga Mat', 'Non-slip eco-friendly yoga mat', 5, 34.99, '1 per roll', 35),
('SPORT-5002', 'Camping Tent', '4-person dome tent', 5, 199.99, '1 per package', 10);

-- Insert sample warehouse locations
INSERT INTO warehouse_locations (name, address, city, state, postal_code, country, capacity) VALUES
('Main Warehouse', '100 Industrial Park', 'Chicago', 'IL', '60601', 'USA', 10000),
('West Coast Distribution', '200 Commerce Ave', 'Los Angeles', 'CA', '90001', 'USA', 8000),
('East Coast Distribution', '300 Logistics Blvd', 'New York', 'NY', '10001', 'USA', 7500),
('Southern Hub', '400 Storage Lane', 'Atlanta', 'GA', '30301', 'USA', 6000),
('Northern Hub', '500 Fulfillment Rd', 'Seattle', 'WA', '98101', 'USA', 5000);

-- Insert sample inventory
INSERT INTO inventory (product_id, location_id, quantity_in_stock, quantity_reserved, last_stock_check) VALUES
(1, 1, 150, 25, '2025-05-01'),
(1, 2, 75, 10, '2025-05-02'),
(2, 1, 80, 15, '2025-05-01'),
(2, 3, 60, 5, '2025-05-03'),
(3, 2, 200, 30, '2025-05-02'),
(3, 4, 150, 20, '2025-05-04'),
(4, 3, 120, 25, '2025-05-03'),
(4, 5, 90, 15, '2025-05-05'),
(5, 1, 70, 10, '2025-05-01'),
(5, 4, 50, 5, '2025-05-04'),
(6, 2, 110, 20, '2025-05-02'),
(6, 5, 80, 10, '2025-05-05'),
(7, 3, 250, 40, '2025-05-03'),
(7, 1, 180, 30, '2025-05-01'),
(8, 4, 300, 50, '2025-05-04'),
(8, 2, 200, 25, '2025-05-02'),
(9, 5, 90, 15, '2025-05-05'),
(9, 3, 70, 10, '2025-05-03'),
(10, 1, 25, 5, '2025-05-01'),
(10, 4, 20, 3, '2025-05-04');

-- Insert product-supplier relationships
INSERT INTO product_suppliers (product_id, supplier_id, supplier_product_code, supplier_price, lead_time_days, is_preferred) VALUES
(1, 1, 'TECH-MOUSE-01', 15.00, 7, TRUE),
(2, 1, 'TECH-HEAD-02', 90.00, 14, TRUE),
(3, 2, 'FASH-TS-101', 12.00, 10, TRUE),
(4, 2, 'FASH-JEAN-202', 30.00, 14, TRUE),
(5, 3, 'HOME-GARDEN-50', 25.00, 5, TRUE),
(6, 3, 'HOME-LAMP-60', 18.00, 7, FALSE),
(6, 1, 'TECH-LAMP-03', 20.00, 5, TRUE),
(7, 4, 'OFF-STAP-701', 8.00, 3, TRUE),
(8, 4, 'OFF-NOTE-801', 3.00, 3, TRUE),
(9, 5, 'SPORT-YOGA-901', 22.00, 10, TRUE),
(10, 5, 'SPORT-TENT-1001', 150.00, 21, TRUE);

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, postal_code, country) VALUES
('Robert', 'Johnson', 'robert.j@email.com', '555-111-2222', '123 Main St', 'Chicago', 'IL', '60601', 'USA'),
('Emily', 'Williams', 'emily.w@email.com', '555-222-3333', '456 Oak Ave', 'New York', 'NY', '10001', 'USA'),
('Michael', 'Brown', 'michael.b@email.com', '555-333-4444', '789 Pine Rd', 'Los Angeles', 'CA', '90001', 'USA'),
('Sarah', 'Jones', 'sarah.j@email.com', '555-444-5555', '321 Elm St', 'Dallas', 'TX', '75201', 'USA'),
('David', 'Garcia', 'david.g@email.com', '555-555-6666', '654 Maple Dr', 'Seattle', 'WA', '98101', 'USA');

-- Insert sample purchase orders
INSERT INTO purchase_orders (supplier_id, order_date, expected_delivery_date, status, total_amount, payment_status, created_by) VALUES
(1, '2025-04-15', '2025-04-25', 'received', 2500.00, 'paid', 'admin'),
(2, '2025-04-20', '2025-05-05', 'shipped', 1800.00, 'partial', 'admin'),
(3, '2025-05-01', '2025-05-10', 'approved', 1200.00, 'unpaid', 'manager'),
(4, '2025-05-05', '2025-05-15', 'submitted', 950.00, 'unpaid', 'staff'),
(5, '2025-05-08', '2025-05-25', 'draft', 3200.00, 'unpaid', 'manager');

-- Insert purchase order items
INSERT INTO purchase_order_items (po_id, product_id, quantity_ordered, unit_price, quantity_received) VALUES
(1, 1, 100, 15.00, 100),
(1, 2, 50, 90.00, 50),
(2, 3, 150, 12.00, 0),
(2, 4, 80, 30.00, 0),
(3, 5, 60, 25.00, 0),
(3, 6, 40, 18.00, 0),
(4, 7, 200, 8.00, 0),
(4, 8, 150, 3.00, 0),
(5, 9, 70, 22.00, 0),
(5, 10, 15, 150.00, 0);

-- Insert sample sales orders
INSERT INTO sales_orders (customer_id, order_date, shipping_address, shipping_city, shipping_state, shipping_postal_code, shipping_country, status, total_amount, payment_status) VALUES
(1, '2025-05-01', '123 Main St', 'Chicago', 'IL', '60601', 'USA', 'delivered', 149.95, 'paid'),
(2, '2025-05-02', '456 Oak Ave', 'New York', 'NY', '10001', 'USA', 'shipped', 229.97, 'paid'),
(3, '2025-05-03', '789 Pine Rd', 'Los Angeles', 'CA', '90001', 'USA', 'processing', 89.97, 'partial'),
(4, '2025-05-04', '321 Elm St', 'Dallas', 'TX', '75201', 'USA', 'pending', 64.98, 'unpaid'),
(5, '2025-05-05', '654 Maple Dr', 'Seattle', 'WA', '98101', 'USA', 'pending', 234.98, 'unpaid');

-- Insert sales order items
INSERT INTO sales_order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 24.99),
(1, 7, 3, 12.99),
(1, 8, 1, 4.99),
(2, 2, 1, 129.99),
(2, 6, 2, 29.99),
(2, 9, 1, 34.99),
(3, 3, 3, 19.99),
(3, 5, 1, 39.99),
(4, 4, 1, 49.99),
(4, 8, 3, 4.99),
(5, 10, 1, 199.99),
(5, 1, 1, 24.99),
(5, 3, 2, 19.99);

-- Insert user roles
INSERT INTO user_roles (role_name, description) VALUES
('admin', 'Full system access'),
('manager', 'Inventory and order management'),
('staff', 'Basic operations and reporting'),
('viewer', 'Read-only access');

-- Insert users
INSERT INTO users (username, password_hash, first_name, last_name, email, role_id) VALUES
('admin', '$2a$10$xJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5', 'System', 'Administrator', 'admin@inventory.com', 1),
('jdoe', '$2a$10$xJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5', 'John', 'Doe', 'jdoe@inventory.com', 2),
('msmith', '$2a$10$xJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5', 'Mary', 'Smith', 'msmith@inventory.com', 3),
('rjones', '$2a$10$xJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5v5zLt2X5ZQ1ZQYJ.ev7XJwL5', 'Robert', 'Jones', 'rjones@inventory.com', 4);

-- Insert inventory transactions
INSERT INTO inventory_transactions (inventory_id, transaction_type, quantity, reference_id, reference_type, notes, created_by) VALUES
(1, 'purchase', 100, 1, 'po_item', 'Initial stock', 'admin'),
(3, 'purchase', 50, 2, 'po_item', 'Initial stock', 'admin'),
(5, 'sale', -2, 1, 'sale_item', 'Customer order #1001', 'jdoe'),
(7, 'sale', -3, 1, 'sale_item', 'Customer order #1001', 'jdoe'),
(9, 'sale', -1, 1, 'sale_item', 'Customer order #1001', 'jdoe'),
(4, 'sale', -1, 2, 'sale_item', 'Customer order #1002', 'msmith'),
(11, 'sale', -2, 2, 'sale_item', 'Customer order #1002', 'msmith'),
(17, 'sale', -1, 2, 'sale_item', 'Customer order #1002', 'msmith');

-- Insert inventory transfers
INSERT INTO inventory_transfers (product_id, source_location_id, destination_location_id, quantity, status, transfer_date, notes, created_by) VALUES
(1, 1, 2, 25, 'completed', '2025-04-10', 'Stock redistribution', 'admin'),
(3, 2, 4, 30, 'completed', '2025-04-15', 'Regional demand', 'jdoe'),
(5, 1, 4, 15, 'in_transit', '2025-05-05', 'Seasonal demand', 'msmith'),
(7, 3, 1, 40, 'pending', '2025-05-08', 'Centralizing stock', 'jdoe');

-- Insert audit log entries
INSERT INTO audit_log (user_id, action, entity_type, entity_id, description, ip_address) VALUES
(1, 'create', 'product', 1, 'Created new product: Wireless Mouse', '192.168.1.100'),
(1, 'create', 'purchase_order', 1, 'Created PO #1001 with Tech Distributors Inc.', '192.168.1.100'),
(2, 'update', 'inventory', 1, 'Adjusted stock quantity for Wireless Mouse', '192.168.1.101'),
(3, 'create', 'sales_order', 1, 'Created sales order #1001 for Robert Johnson', '192.168.1.102'),
(2, 'create', 'transfer', 1, 'Initiated transfer of 25 Wireless Mice to West Coast', '192.168.1.101');