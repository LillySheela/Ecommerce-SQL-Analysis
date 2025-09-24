-- ========================================
-- Order Trends & Time Range
-- ========================================

-- 1. Time range of orders placed
SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS recent_order
FROM `Target.orders`;

-- 2. Growth of orders over the years
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
       COUNT(order_id) AS orders_placed
FROM `Target.orders`
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY year;

-- 3. Monthly seasonality of orders
SELECT FORMAT_DATE('%b %Y', order_purchase_timestamp) AS year_month,
       COUNT(order_id) AS orders_placed
FROM `Target.orders`
GROUP BY FORMAT_DATE('%b %Y', order_purchase_timestamp),
         EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY EXTRACT(YEAR FROM order_purchase_timestamp),
         EXTRACT(YEAR FROM order_purchase_timestamp);

-- 4. Time of day orders are placed
WITH pur_time AS (
    SELECT order_id, customer_id, EXTRACT(TIME FROM order_purchase_timestamp) AS purchase_time
    FROM `Target.orders`
), time_bkt AS (
    SELECT order_id, customer_id, purchase_time,
           CASE
               WHEN purchase_time BETWEEN '00:00:00' AND '06:59:59' THEN 'Dawn'
               WHEN purchase_time BETWEEN '07:00:00' AND '12:59:59' THEN 'Mornings'
               WHEN purchase_time BETWEEN '13:00:00' AND '18:59:59' THEN 'Afternoon'
               ELSE 'Night'
           END AS Time_of_Day
    FROM pur_time
)
SELECT Time_of_Day, COUNT(order_id) AS orders_placed
FROM time_bkt
GROUP BY Time_of_Day
ORDER BY orders_placed DESC;
