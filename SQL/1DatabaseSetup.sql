-- Create database
CREATE DATABASE IF NOT EXISTS superstore_db;
USE superstore_db;


-- Create main orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(50) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10),
    region VARCHAR(50) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    sales DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0,
    profit DECIMAL(10,2) NOT NULL,
    INDEX idx_order_date (order_date),
    INDEX idx_customer (customer_id),
    INDEX idx_product (product_id),
    INDEX idx_region (region),
    INDEX idx_category (category)
);

-- Load data from CSV
LOAD DATA INFILE '/home/chinmay/SuperstoreProject/Data/SuperstoreCleanData.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify data load
SELECT COUNT(*) as total_records FROM orders;
SELECT 'Data loaded' as status;
