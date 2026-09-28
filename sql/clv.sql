USE Olist_ecommerce;
GO

-- 1. Lấy mốc thời gian để tính Recency
WITH analysis_date AS (
    SELECT MAX(order_purchase_timestamp) AS ref_date
    FROM orders
),

Order_Totals AS (
    SELECT 
        order_id,
        SUM(payment_value) AS order_total_value
    FROM order_payments
    GROUP BY order_id
),

-- 3. Tính toán các chỉ số cốt lõi (Bổ sung Recency)
customer_stats AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF(day, MAX(o.order_purchase_timestamp), (SELECT ref_date FROM analysis_date)) AS recency,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(ot.order_total_value) AS total_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN Order_Totals ot ON o.order_id = ot.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

-- 4. Tính AOV
customer_aov AS (
    SELECT
        customer_unique_id,
        recency,
        total_orders,
        total_revenue,
        ROUND(total_revenue / total_orders, 2) AS avg_order_value
    FROM customer_stats
),

scoring AS (
    SELECT 
        customer_unique_id,
        recency,
        total_orders,
        total_revenue,
        avg_order_value,
        5 - NTILE(4) OVER (ORDER BY recency ASC) AS r_score,
        CASE 
            WHEN total_orders >= 3 THEN 4
            WHEN total_orders = 2 THEN 3
            ELSE 1 
        END AS f_score
    FROM customer_aov
)

SELECT
    customer_unique_id,
    avg_order_value, 
    total_orders AS purchase_frequency,
    ROUND(total_revenue, 2) AS historical_clv, 
    CASE
        WHEN f_score >= 3 THEN 'Champions'
        WHEN r_score >= 3 THEN 'Potential'
        WHEN r_score = 2 THEN 'At Risk'
        ELSE 'Hibernating'
    END AS customer_segment
FROM scoring
ORDER BY historical_clv DESC;