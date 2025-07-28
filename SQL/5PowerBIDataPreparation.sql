-- Preparing Data for PowerBI

-- Use your database
USE superstore_db;

-- 1. MAIN DASHBOARD DATA VIEW


CREATE OR REPLACE VIEW powerbi_main_data AS
SELECT 
    o.*,
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    QUARTER(o.order_date) AS order_quarter,
    DAYOFWEEK(o.order_date) AS order_day_of_week,
    DAYNAME(o.order_date) AS order_day_name,
    DATEDIFF(o.ship_date, o.order_date) AS shipping_days,
    CASE 
        WHEN DATEDIFF(o.ship_date, o.order_date) <= 3 THEN 'Fast'
        WHEN DATEDIFF(o.ship_date, o.order_date) <= 7 THEN 'Standard'
        ELSE 'Slow'
    END AS shipping_speed,
    o.sales - (o.sales * o.discount) AS net_sales,
    CASE WHEN o.sales = 0 THEN 0 ELSE o.profit / o.sales END AS profit_margin,
    CASE 
        WHEN o.profit > 0 THEN 'Profitable'
        ELSE 'Loss'
    END AS profit_status
FROM orders o;


-- 2. CUSTOMER ANALYTICS DATA VIEW

CREATE OR REPLACE VIEW powerbi_customer_data AS
WITH customer_summary AS (
    SELECT 
        customer_id,
        customer_name,
        segment,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(sales) AS total_spent,
        SUM(profit) AS total_profit_generated,
        AVG(sales) AS avg_order_value,
        MIN(order_date) AS first_purchase_date,
        MAX(order_date) AS last_purchase_date,
        DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_lifetime_days
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
    END AS customer_tier,
    ROUND(
        CASE 
          WHEN customer_lifetime_days = 0 THEN total_spent
          ELSE total_spent / customer_lifetime_days * 365
        END, 2) AS estimated_annual_value
FROM customer_summary;


-- 3. PRODUCT PERFORMANCE DATA VIEW

CREATE OR REPLACE VIEW powerbi_product_data AS
WITH product_metrics AS (
    SELECT 
        product_id,
        product_name,
        category,
        sub_category,
        COUNT(DISTINCT order_id) AS order_frequency,
        SUM(quantity) AS total_quantity_sold,
        SUM(sales) AS total_revenue,
        SUM(profit) AS total_profit,
        AVG(discount) AS avg_discount,
        COUNT(DISTINCT customer_id) AS unique_buyers
    FROM orders
    GROUP BY product_id, product_name, category, sub_category
)
SELECT 
    *,
    CASE 
        WHEN total_revenue = 0 THEN 0
        ELSE ROUND(total_profit / total_revenue * 100, 2)
    END AS profit_margin_pct,
    ROUND(
        CASE 
            WHEN order_frequency = 0 THEN 0
            ELSE total_revenue / order_frequency
        END, 2) AS avg_revenue_per_order,
    CASE 
        WHEN total_revenue >= 10000 THEN 'Star Product'
        WHEN total_revenue >= 5000 THEN 'High Performer'
        WHEN total_revenue >= 1000 THEN 'Standard'
        ELSE 'Low Performer'
    END AS product_performance_tier
FROM product_metrics;


-- 4. GEOGRAPHIC PERFORMANCE DATA VIEW

CREATE OR REPLACE VIEW powerbi_geographic_data AS
SELECT 
    region,
    state,
    city,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    AVG(sales) AS avg_order_value,
    SUM(quantity) AS total_quantity,
    CASE 
        WHEN SUM(sales) = 0 THEN 0
        ELSE ROUND(SUM(profit) / SUM(sales) * 100, 2)
    END AS profit_margin_pct,
    CASE 
        WHEN COUNT(DISTINCT customer_id) = 0 THEN 0
        ELSE ROUND(SUM(sales) / COUNT(DISTINCT customer_id), 2)
    END AS revenue_per_customer
FROM orders
GROUP BY region, state, city;


-- 5. TIME SERIES DATA VIEW FOR FORECASTING AND TRENDS

CREATE OR REPLACE VIEW powerbi_time_series AS
SELECT 
    DATE(order_date) AS order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    QUARTER(order_date) AS quarter,
    DAYOFWEEK(order_date) AS day_of_week,
    DAYNAME(order_date) AS day_name,
    category,
    region,
    SUM(sales) AS daily_sales,
    SUM(profit) AS daily_profit,
    COUNT(DISTINCT order_id) AS daily_orders,
    COUNT(DISTINCT customer_id) AS daily_customers,
    AVG(sales) AS avg_order_value
FROM orders
GROUP BY DATE(order_date), YEAR(order_date), MONTH(order_date), 
         QUARTER(order_date), DAYOFWEEK(order_date), DAYNAME(order_date),
         category, region
ORDER BY order_date;

-- Commands to confirm creation for Power BI use
SELECT 'Data views created successfully for Power BI integration' AS status;
SELECT 'powerbi_main_data, powerbi_customer_data, powerbi_product_data, powerbi_geographic_data, powerbi_time_series' AS view_names;
