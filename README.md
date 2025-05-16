# Inventory Management System

A comprehensive database solution for managing inventory, suppliers, orders, and customers in a multi-warehouse environment.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [Installation](#installation)
- [Relationships](#relationships)
- [ERD](#erd)
- [Database Setup](#database-setup)


## Overview 

The Inventory Management System is a robust solution designed for businesses that need to track products across multiple warehouses, manage supplier relationships, process purchase orders, fulfill customer orders, and maintain detailed audit trails of all inventory movements.

This system provides a complete database structure that forms the foundation for building inventory management applications with comprehensive tracking capabilities.

## Features

- **Complete Product Management**
  - Product categorization
  - Multiple supplier management
  - Detailed product information tracking

- **Advanced Inventory Control**
  - Multi-warehouse inventory tracking
  - Real-time inventory levels
  - Reserved vs. available quantity distinction
  - Inter-warehouse transfers
  - Full transaction history

- **Supply Chain Management**
  - Purchase order processing workflow
  - Supplier performance tracking
  - Order status tracking

- **Sales Order Processing**
  - Customer management
  - Order fulfillment tracking
  - Order history

- **Administration & Security**
  - Role-based access control
  - Comprehensive audit logging
  - User management

## Database Schema

The system's database design consists of the following key components:

### Entity Relationship Diagram

![Inventory Management System ERD](inventory_system_erd.png)

### Main Tables

1. **Product Data**
   - `categories` - Product classification
   - `products` - Core product information
   - `suppliers` - Vendor details
   - `product_suppliers` - Many-to-many relationship between products and suppliers

2. **Inventory Management**
   - `warehouse_locations` - Physical storage locations
   - `inventory` - Current stock levels by product and location
   - `inventory_transactions` - All stock movements
   - `inventory_transfers` - Inter-warehouse transfers

3. **Purchasing**
   - `purchase_orders` - Orders to suppliers
   - `purchase_order_items` - Line items in purchase orders

4. **Sales**
   - `customers` - Customer information
   - `sales_orders` - Customer orders
   - `sales_order_items` - Line items in customer orders

5. **System**
   - `users` - System user accounts
   - `user_roles` - Access control roles
   - `audit_log` - System activity tracking

## Installation

### Prerequisites

- MySQL 5.7+
- 50MB minimum database space (recommended: 500MB+ for production)

### Setup Steps

1. Create the database:
   ```sql
   CREATE DATABASE inventory_management;
   USE inventory_management;

## Relationships

- **One-to-Many**  
  - `categories` to `products`  
  - `suppliers` to `purchase_orders`  
  - `customers` to `sales_orders`  
  - `products` to `inventory_transactions`, `sales_order_items`, `purchase_order_items`

- **Many-to-One**  
  - `inventory` to `warehouse_locations`  
  - `inventory_transactions` to `inventory`  
  - `sales_order_items` to `sales_orders`  
  - `purchase_order_items` to `purchase_orders`

- **Self-Referential**  
  - `categories` table allows nesting with parent-child relationships to support subcategories

---

## ERD

The Entity Relationship Diagram (ERD) was created using **draw.io**. It provides a complete visual representation of the core entities, attributes, and relationships used in the inventory management database system.

**View ERD:**  
![Inventory Management System ERD](DBM%20ERD.png)

---

## Database Setup

### Setup Instructions

1. **Clone the Repository**  
   ```bash
   git clone https://github.com/nessa360/wk-8-nessa360.git
   cd inventory-management-system
   Use a relational database management system ( MySQL workbench).
   Run the database.sql scripts in to create the database and tables
