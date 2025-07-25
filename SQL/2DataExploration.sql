-- Data Exploration

-- Database selection
USE superstore_db;

-- Basic data overview: Total records and date range
SELECT 'Dataset Overview' as analysis_type;
SELECT 
    COUNT(*) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT product_id) as unique_products,
    MIN(order_date) as earliest_order,
    MAX(order_date) as latest_order,
    SUM(sales) as total_revenue,
    SUM(profit) as total_profit,
    AVG(sales) as avg_order_value
FROM orders;

-- Data quality checks: Checking for missing values
SELECT 'Data Quality Check' as check_type;
SELECT 
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(customer_id) as missing_customers,
    COUNT(*) - COUNT(product_name) as missing_products,
    COUNT(*) - COUNT(sales) as missing_sales,
    COUNT(*) - COUNT(profit) as missing_profit
FROM orders;

-- Check for negative sales/quantities: Checking for negative values
SELECT 'Negative Values Check' as check_type;
SELECT 
    COUNT(CASE WHEN sales < 0 THEN 1 END) as negative_sales_count,
    COUNT(CASE WHEN quantity < 0 THEN 1 END) as negative_quantity_count,
    COUNT(CASE WHEN discount < 0 OR discount > 1 THEN 1 END) as invalid_discount_count
FROM orders;

-- Distribution by key dimensions: Region, Category and Customer Segment
SELECT 'Dimension Distribution' as analysis_type;

-- 1. Region
SELECT region, COUNT(*) as order_count, 
       SUM(sales) as total_sales, 
       ROUND(AVG(sales), 2) as avg_sales
FROM orders 
GROUP BY region 
ORDER BY total_sales DESC;

-- 2. Category
SELECT category, COUNT(*) as order_count, 
       SUM(sales) as total_sales, 
       SUM(profit) as total_profit,
       ROUND(SUM(profit)/SUM(sales)*100, 2) as profit_margin_pct
FROM orders 
GROUP BY category 
ORDER BY total_sales DESC;

-- 3. Customer Segment
SELECT segment, COUNT(*) as order_count, 
       SUM(sales) as total_sales,
       COUNT(DISTINCT customer_id) as unique_customers
FROM orders 
GROUP BY segment 
ORDER BY total_sales DESC;
