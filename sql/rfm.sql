CREATE database Olist_ecommerce 
use Olist_ecommerce;
GO 
;
USE Olist_ecommerce;
GO

-- 1. Lấy mốc thời gian gần nhất để tính Recency
WITH analysis_date AS (
    SELECT MAX(order_purchase_timestamp) AS ref_date
    FROM orders
),

-- 2. Gom tổng tiền TỪNG ĐƠN HÀNG trước để tránh trùng lặp khi JOIN
Order_Totals AS (
    SELECT 
        order_id,
        SUM(payment_value) AS order_total_value
    FROM order_payments
    GROUP BY order_id
),

-- 3. Tính toán R, F, M thô cho từng khách hàng
rfm_base AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF(day, MAX(o.order_purchase_timestamp), (SELECT ref_date FROM analysis_date)) AS recency,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(ot.order_total_value), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN Order_Totals ot ON o.order_id = ot.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

-- 4. Chấm điểm R, F, M (Scale từ 1 đến 4 dựa trên K-Means k=4)
rfm_scores AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        -- Recency: Ngày càng nhỏ điểm càng cao (4, 3, 2, 1)
        5 - NTILE(4) OVER (ORDER BY recency ASC) AS r_score, 
        
        -- Frequency: 
        CASE 
            WHEN frequency >= 3 THEN 4
            WHEN frequency = 2 THEN 3
            ELSE 1 
        END AS f_score,
        
        -- Monetary: Tiền càng nhiều điểm càng cao (1, 2, 3, 4)
        NTILE(4) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

-- 5. Phân khúc 4 nhóm 
SELECT 
    customer_unique_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN f_score >= 3 THEN 'Champions' -- Khách mua từ 2 đơn trở lên
        WHEN r_score >= 3 THEN 'Potential' -- Khách mua 1 lần nhưng mua gần đây
        WHEN r_score = 2 THEN 'At Risk'    -- Khách mua 1 lần, đang có dấu hiệu nguội lạnh
        ELSE 'Hibernating'                 -- Khách mua 1 lần từ rất lâu, đã bỏ đi
    END AS customer_segment
FROM rfm_scores;

USE Olist_ecommerce;
GO


