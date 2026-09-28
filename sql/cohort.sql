USE Olist_ecommerce;
GO

-- 1. Lọc đơn hàng thành công và lấy ngày mua
WITH BaseData AS (
    SELECT 
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),

-- 2. Tìm tháng mua hàng đầu tiên (Đưa về ngày mùng 1 của tháng đó)
FirstPurchase AS (
    SELECT 
        customer_unique_id,
        DATEFROMPARTS(YEAR(MIN(order_purchase_timestamp)), MONTH(MIN(order_purchase_timestamp)), 1) AS cohort_month
    FROM BaseData
    GROUP BY customer_unique_id
),

-- 3. Gắn tháng đầu tiên vào từng đơn hàng và tính khoảng cách tháng (Period Index)
CohortIndices AS (
    SELECT 
        b.customer_unique_id,
        f.cohort_month,
        DATEDIFF(month, f.cohort_month, b.order_purchase_timestamp) AS period_index
    FROM BaseData b
    JOIN FirstPurchase f ON b.customer_unique_id = f.customer_unique_id
),

-- 4. Đếm số lượng khách hàng quay lại theo từng chu kỳ
CohortCounts AS (
    SELECT 
        cohort_month, 
        period_index,
        COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM CohortIndices
    GROUP BY cohort_month, period_index
),

-- 5. Đếm tổng số lượng khách hàng mới thu nhận của tháng đó (Cohort Size)
CohortSizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM FirstPurchase
    GROUP BY cohort_month
)

-- 6. Kết xuất dữ liệu với Tỷ lệ % Giữ chân
SELECT 
    c.cohort_month,      
    s.cohort_size,        -- Quy mô khách hàng ban đầu
    c.period_index,       -- Khoảng cách tháng (0, 1, 2...)
    c.retained_customers, -- Số người quay lại
    -- Tính tỷ lệ phần trăm 
    ROUND((c.retained_customers * 100.0) / s.cohort_size, 2) AS retention_rate_pct
FROM CohortCounts c
JOIN CohortSizes s ON c.cohort_month = s.cohort_month
ORDER BY c.cohort_month, c.period_index;