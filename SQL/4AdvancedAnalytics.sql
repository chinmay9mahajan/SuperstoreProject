-- Advanced Analytics

-- Database Selection

USE superstore_db;

-- 1. COHORT ANALYSIS - Customer Retention

WITH customer_orders AS (
    SELECT 
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as order_number
    FROM orders
),
first_purchase AS (
    SELECT 
        customer_id,
        order_date as first_purchase_date,
        DATE_FORMAT(order_date, '%Y-%m') as cohort_month
    FROM customer_orders
    WHERE order_number = 1
),
purchase_activity AS (
    SELECT 
        o.customer_id,
        fp.cohort_month,
        DATE_FORMAT(o.order_date, '%Y-%m') as purchase_month,
        TIMESTAMPDIFF(MONTH, fp.first_purchase_date, o.order_date) as months_since_first_purchase
    FROM orders o
    JOIN first_purchase fp ON o.customer_id = fp.customer_id
)
SELECT 
    cohort_month,
    months_since_first_purchase,
    COUNT(DISTINCT customer_id) as customers,
    COUNT(DISTINCT customer_id) * 100.0 / 
        FIRST_VALUE(COUNT(DISTINCT customer_id)) OVER 
        (PARTITION BY cohort_month ORDER BY months_since_first_purchase) as retention_rate
FROM purchase_activity
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;

-- 2. RUNNING TOTALS AND MOVING AVERAGES

WITH daily_sales AS (
    SELECT 
        order_date,
        SUM(sales) as daily_revenue,
        COUNT(DISTINCT order_id) as daily_orders
    FROM orders
    GROUP BY order_date
)
SELECT 
    order_date,
    daily_revenue,
    daily_orders,
    SUM(daily_revenue) OVER (ORDER BY order_date) as running_total_revenue,
    AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7_days,
    LAG(daily_revenue, 1) OVER (ORDER BY order_date) as prev_day_revenue,
    ROUND(
        (daily_revenue - LAG(daily_revenue, 1) OVER (ORDER BY order_date)) /
        LAG(daily_revenue, 1) OVER (ORDER BY order_date) * 100, 2
    ) as daily_growth_pct
FROM daily_sales
ORDER BY order_date;

-- 3. ABC ANALYSIS - Product Classification

WITH product_revenue AS (
    SELECT 
        product_id,
        product_name,
        category,
        SUM(sales) as total_revenue
    FROM orders
    GROUP BY product_id, product_name, category
),
product_with_cumulative AS (
    SELECT 
        *,
        SUM(total_revenue) OVER () as grand_total,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC) as cumulative_revenue,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank
    FROM product_revenue
)
SELECT 
    product_id,
    product_name,
    category,
    ROUND(total_revenue, 2) as revenue,
    revenue_rank,
    ROUND(total_revenue / grand_total * 100, 2) as revenue_percentage,
    ROUND(cumulative_revenue / grand_total * 100, 2) as cumulative_percentage,
    CASE 
        WHEN cumulative_revenue / grand_total <= 0.8 THEN 'A'
        WHEN cumulative_revenue / grand_total <= 0.95 THEN 'B'
        ELSE 'C'
    END as abc_classification
FROM product_with_cumulative
ORDER BY revenue_rank;

-- 4. STATISTICAL ANALYSIS: Sales distribution statistics by category

WITH ordered_sales AS (
    SELECT 
        category,
        sales,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales) AS rn_asc,
        COUNT(*) OVER (PARTITION BY category) AS cnt
    FROM orders
)
SELECT
    category,
    COUNT(*) AS order_count,
    ROUND(MIN(sales), 2) AS min_sales,
    ROUND(MAX(sales), 2) AS max_sales,
    ROUND(AVG(sales), 2) AS mean_sales,
    ROUND(STDDEV_POP(sales), 2) AS std_dev_sales,
    ROUND(
        AVG(CASE
            WHEN rn_asc IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
            THEN sales
            ELSE NULL
        END), 2) AS median_sales
FROM ordered_sales
GROUP BY category;


-- 5. YEAR-OVER-YEAR COMPARISON

WITH yearly_metrics AS (
    SELECT 
        YEAR(order_date) as year,
        category,
        SUM(sales) as annual_sales,
        SUM(profit) as annual_profit,
        COUNT(DISTINCT customer_id) as unique_customers
    FROM orders
    GROUP BY YEAR(order_date), category
)
SELECT 
    year,
    category,
    ROUND(annual_sales, 2) as annual_sales,
    ROUND(annual_profit, 2) as annual_profit,
    unique_customers,
    LAG(annual_sales) OVER (PARTITION BY category ORDER BY year) as prev_year_sales,
    ROUND(
        (annual_sales - LAG(annual_sales) OVER (PARTITION BY category ORDER BY year)) /
        LAG(annual_sales) OVER (PARTITION BY category ORDER BY year) * 100, 2
    ) as yoy_sales_growth_pct
FROM yearly_metrics
ORDER BY category, year;
