-- ========================================
-- Delivery Time Analysis
-- ========================================

-- 1. Delivery time & difference from estimated
SELECT order_id,
       Actual_delivery_time,
       Estimated_delivery_time,
       Estimated_delivery_time - Actual_delivery_time AS delivery_time_diff
FROM (
    SELECT order_id, order_status, order_purchase_timestamp, order_estimated_delivery_date, order_delivered_customer_date,
           DATE_DIFF(order_estimated_delivery_date, order_purchase_timestamp, DAY) AS Estimated_delivery_time,
           DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS Actual_delivery_time
    FROM `Target.orders`
    WHERE LOWER(order_status) = 'delivered'
) tbl
ORDER BY order_id;

-- 2. Top 5 states with highest & lowest average freight value
WITH avg_freight AS (
    SELECT c.customer_state,
           ROUND(AVG(oi.freight_value),2) AS avg_freight_
    FROM `Target.order_items` oi
    JOIN `Target.orders` o
        ON oi.order_id = o.order_id
    JOIN `Target.customers` c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
),
freight_rank_asc AS (
    SELECT customer_state, avg_freight_, DENSE_RANK() OVER(ORDER BY avg_freight_) AS rank_
    FROM avg_freight
),
freight_rank_desc AS (
    SELECT customer_state, avg_freight_, DENSE_RANK() OVER(ORDER BY avg_freight_ DESC) AS rank_
    FROM avg_freight
)
SELECT customer_state, avg_freight_ 
FROM freight_rank_desc WHERE rank_ <= 5
UNION ALL
SELECT customer_state, avg_freight_
FROM freight_rank_asc WHERE rank_ <= 5
ORDER BY avg_freight_ DESC;

-- 3. Top 5 states with highest & lowest average delivery time
WITH avg_delivery AS (
    SELECT c.customer_state,
           AVG(DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY)) AS avg_delivery_time
    FROM `Target.orders` o
    JOIN `Target.customers` c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
),
del_rank_asc AS (
    SELECT customer_state, avg_delivery_time,
           DENSE_RANK() OVER(ORDER BY avg_delivery_time) AS rank_
    FROM avg_delivery
),
del_rank_desc AS (
    SELECT customer_state, avg_delivery_time,
           DENSE_RANK() OVER(ORDER BY avg_delivery_time DESC) AS rank_
    FROM avg_delivery
)
SELECT customer_state, ROUND(avg_delivery_time,2) AS avg_delivery_time
FROM del_rank_desc WHERE rank_ <= 5
UNION ALL
SELECT customer_state, ROUND(avg_delivery_time,2) AS avg_delivery_time
FROM del_rank_asc WHERE rank_ <= 5
ORDER BY avg_delivery_time DESC;

-- 4. Top 5 states where delivery was faster than estimated
WITH cte AS (
    SELECT order_id, customer_id, order_estimated_delivery_date, order_delivered_customer_date,
           DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) AS delivery_diff
    FROM `Target.orders`
    WHERE DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, DAY) > 0
),
avg_cte AS (
    SELECT c.customer_state, AVG(cte.delivery_diff) AS avg_delivery_diff
    FROM cte
    JOIN `Target.customers` c
        ON cte.customer_id = c.customer_id
    GROUP BY c.customer_state
),
rank_del AS (
    SELECT customer_state, avg_delivery_diff,
           DENSE_RANK() OVER(ORDER BY avg_delivery_diff) AS del_rank
    FROM avg_cte
)
SELECT customer_state, ROUND(avg_delivery_diff) AS del_diff_days
FROM rank_del
WHERE del_rank <= 5;
