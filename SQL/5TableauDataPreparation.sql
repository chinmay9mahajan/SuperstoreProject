-- Tableau Data Preparation


-- Database Selection

USE superstore_db;

-- ====================================================
-- 1. MAIN DASHBOARD DATA EXTRACT
-- ====================================================

-- Create comprehensive view for Tableau dashboards
CREATE OR REPLACE VIEW tableau_main_data AS
SELECT 
    o.*,
    YEAR(o.order_date) as order_year,
    MONTH(o.order_date) as order_month,
    QUARTER(o.order_date) as order_quarter,
    DAYOFWEEK(o.order_date) as order_day_of_week,
    DAYNAME(o.order_date) as order_day_name,
    DATEDIFF(o.ship_date, o.order_date) as shipping_days,
    CASE 
        WHEN DATEDIFF(o.ship_date, o.order_date) <= 3 THEN 'Fast'
        WHEN DATEDIFF(o.ship_date, o.order_date) <= 7 THEN 'Standard'
        ELSE 'Slow'
    END as shipping_speed,
    o.sales - (o.sales * o.discount) as net_sales,
    o.profit / o.sales as profit_margin,
    CASE 
        WHEN o.profit > 0 THEN 'Profitable'
        ELSE 'Loss'
    END as profit_status
FROM orders o;

-- ====================================================
-- 2. CUSTOMER ANALYTICS DATA
-- ====================================================

CREATE OR REPLACE VIEW tableau_customer_data AS
WITH customer_summary AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(sales) as total_spent,
        SUM(profit) as total_profit_generated,
        AVG(sales) as avg_order_value,
        MIN(order_date) as first_purchase_date,
        MAX(order_date) as last_purchase_date,
        DATEDIFF(MAX(order_date), MIN(order_date)) as customer_lifetime_days
    FROM orders
    GROUP BY customer_id, customer_name, segment
)
SELECT 
    *,
    CASE 
        WHEN total_orders >= 10 AND total_spent >= 5000 THEN 'VIP'
        WHEN total_orders >= 5 AND total_spent >= 2000 THEN 'High Value'
        WHEN total_orders >= 3 AND total_spent >= 1000 THEN 'Regular'
        ELSE 'New/Low Value'
    END as customer_tier,
    ROUND(total_spent / NULLIF(customer_lifetime_days, 0) * 365, 2) as estimated_annual_value
FROM customer_summary;

-- ====================================================
-- 3. PRODUCT PERFORMANCE DATA
-- ====================================================

CREATE OR REPLACE VIEW tableau_product_data AS
WITH product_metrics AS (
    SELECT 
        product_id,
        product_name,
        category,
        sub_category,
        COUNT(DISTINCT order_id) as order_frequency,
        SUM(quantity) as total_quantity_sold,
        SUM(sales) as total_revenue,
        SUM(profit) as total_profit,
        AVG(discount) as avg_discount,
        COUNT(DISTINCT customer_id) as unique_buyers
    FROM orders
    GROUP BY product_id, product_name, category, sub_category
)
SELECT 
    *,
    ROUND(total_profit / total_revenue * 100, 2) as profit_margin_pct,
    ROUND(total_revenue / order_frequency, 2) as avg_revenue_per_order,
    CASE 
        WHEN total_revenue >= 10000 THEN 'Star Product'
        WHEN total_revenue >= 5000 THEN 'High Performer'
        WHEN total_revenue >= 1000 THEN 'Standard'
        ELSE 'Low Performer'
    END as product_performance_tier
FROM product_metrics;

-- ====================================================
-- 4. GEOGRAPHIC PERFORMANCE DATA
-- ====================================================

CREATE OR REPLACE VIEW tableau_geographic_data AS
SELECT 
    region,
    state,
    city,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(sales) as total_sales,
    SUM(profit) as total_profit,
    AVG(sales) as avg_order_value,
    SUM(quantity) as total_quantity,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) as profit_margin_pct,
    ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2) as revenue_per_customer
FROM orders
GROUP BY region, state, city;

-- ====================================================
-- 5. TIME SERIES DATA FOR FORECASTING
-- ====================================================

CREATE OR REPLACE VIEW tableau_time_series AS
SELECT 
    DATE(order_date) as order_date,
    YEAR(order_date) as year,
    MONTH(order_date) as month,
    QUARTER(order_date) as quarter,
    DAYOFWEEK(order_date) as day_of_week,
    DAYNAME(order_date) as day_name,
    category,
    region,
    SUM(sales) as daily_sales,
    SUM(profit) as daily_profit,
    COUNT(DISTINCT order_id) as daily_orders,
    COUNT(DISTINCT customer_id) as daily_customers,
    AVG(sales) as avg_order_value
FROM orders
GROUP BY DATE(order_date), YEAR(order_date), MONTH(order_date), 
         QUARTER(order_date), DAYOFWEEK(order_date), DAYNAME(order_date),
         category, region
ORDER BY order_date;

-- Export commands for Tableau
SELECT 'Data views created successfully for Tableau integration' as status;
SELECT 'Use these views as data sources in Tableau:' as instruction;
SELECT 'tableau_main_data, tableau_customer_data, tableau_product_data, tableau_geographic_data, tableau_time_series' as view_names;
