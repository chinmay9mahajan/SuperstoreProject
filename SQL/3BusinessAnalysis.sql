-- Business Analysis

-- Database Selection

USE superstore_db;

-- 1. REVENUE ANALYSIS: Monthly revenue trends with growth rates

WITH monthly_revenue AS (
    SELECT 
        YEAR(order_date) as year,
        MONTH(order_date) as month,
        DATE_FORMAT(order_date, '%Y-%m') as month_year,
        SUM(sales) as revenue,
        COUNT(DISTINCT order_id) as orders,
        COUNT(DISTINCT customer_id) as customers
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date), DATE_FORMAT(order_date, '%Y-%m')
    ORDER BY year, month
)
SELECT 
    month_year,
    revenue,
    orders,
    customers,
    LAG(revenue) OVER (ORDER BY month_year) as prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month_year)) / 
        LAG(revenue) OVER (ORDER BY month_year) * 100, 2
    ) as revenue_growth_pct
FROM monthly_revenue
ORDER BY month_year;

-- 2. CUSTOMER SEGMENTATION (RFM (Recency, Frequency, Monetary View) Analysis)

WITH customer_metrics AS (
    SELECT 
        customer_id,
        customer_name,
        MAX(order_date) as last_order_date,
        COUNT(DISTINCT order_id) as frequency,
        SUM(sales) as monetary_value,
        DATEDIFF(CURDATE(), MAX(order_date)) as recency_days
    FROM orders
    GROUP BY customer_id, customer_name
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) as recency_score,
        NTILE(5) OVER (ORDER BY frequency) as frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value) as monetary_score
    FROM customer_metrics
)
SELECT 
    customer_id,
    customer_name,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) as monetary_value,
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 THEN 'Champions'
        WHEN recency_score >= 2 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 3 AND frequency_score <= 2 THEN 'Potential Loyalists'
        WHEN recency_score >= 4 AND frequency_score <= 1 THEN 'New Customers'
        WHEN recency_score <= 2 AND frequency_score >= 2 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost Customers'
        ELSE 'Others'
    END as customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC
LIMIT 20;

-- 3A. PRODUCT PERFORMANCE ANALYSIS: Top performing products by multiple metrics

SELECT 
    category,
    sub_category,
    product_name,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(quantity) as total_quantity_sold,
    ROUND(SUM(sales), 2) as total_revenue,
    ROUND(SUM(profit), 2) as total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) as profit_margin_pct,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(AVG(sales), 2) as avg_order_value
FROM orders
GROUP BY category, sub_category, product_name
HAVING SUM(sales) > 1000 
ORDER BY total_revenue DESC
LIMIT 15;

-- 3B. PRODUCT PERFORMANCE ANALYSIS: Category performance comparison

SELECT 
    category,
    COUNT(DISTINCT order_id) as orders,
    SUM(sales) as revenue,
    SUM(profit) as profit,
    ROUND(AVG(sales), 2) as avg_order_value,
    ROUND(SUM(profit)/SUM(sales)*100, 2) as profit_margin_pct,
    ROUND(AVG(discount)*100, 2) as avg_discount_pct
FROM orders
GROUP BY category
ORDER BY revenue DESC;

-- 4. GEOGRAPHIC PERFORMANCE ANALYSIS: Regional performance with rankings

SELECT 
    region,
    state,
    COUNT(DISTINCT order_id) as orders,
    COUNT(DISTINCT customer_id) as customers,
    ROUND(SUM(sales), 2) as revenue,
    ROUND(SUM(profit), 2) as profit,
    ROUND(AVG(sales), 2) as avg_order_value,
    ROUND(SUM(profit)/SUM(sales)*100, 2) as profit_margin_pct,
    RANK() OVER (ORDER BY SUM(sales) DESC) as revenue_rank
FROM orders
GROUP BY region, state
ORDER BY revenue DESC
LIMIT 20;

-- 5A. SHIPPING AND OPERATIONAL ANALYSIS: Shipping mode performance
 
SELECT 
    ship_mode,
    COUNT(*) as order_count,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) as avg_shipping_days,
    SUM(sales) as total_sales,
    ROUND(AVG(sales), 2) as avg_order_value
FROM orders
GROUP BY ship_mode
ORDER BY order_count DESC;

-- 5B. SHIPPING AND OPERATIONAL ANALYSIS: Seasonal analysis
SELECT 
    QUARTER(order_date) as quarter,
    YEAR(order_date) as year,
    COUNT(*) as orders,
    SUM(sales) as revenue,
    SUM(profit) as profit
FROM orders
GROUP BY QUARTER(order_date), YEAR(order_date)
ORDER BY year, quarter;
