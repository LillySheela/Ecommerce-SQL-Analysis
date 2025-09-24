-- ========================================
-- Order Costs, Freight & Delivery Analysis
-- ========================================

-- 1. % increase in cost of orders from 2017 to 2018 (Jan-Aug)
WITH order_cost AS (
    SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
           SUM(p.payment_value) AS cost_of_orders
    FROM `Target.payments` p
    JOIN `Target.orders` o
        ON p.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY EXTRACT(YEAR FROM o.order_purchase_timestamp)
)
SELECT ROUND(((MAX(cost_of_orders) - MIN(cost_of_orders)) / MAX(cost_of_orders)) * 100, 2) AS cost_increase_percentage
FROM order_cost;

-- 2. Total & Average order price by state
SELECT c.customer_state,
       ROUND(SUM(oi.price),2) AS total_price,
       ROUND(AVG(oi.price),2) AS avg_price
FROM `Target.customers` c
LEFT JOIN `Target.orders` o
    ON c.customer_id = o.customer_id
LEFT JOIN `Target.order_items` oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_price DESC, avg_price DESC;

-- 3. Total & Average freight value by state
SELECT c.customer_state,
       ROUND(SUM(oi.freight_value),2) AS total_freight,
       ROUND(AVG(oi.freight_value),2) AS avg_freight
FROM `Target.customers` c
LEFT JOIN `Target.orders` o
    ON c.customer_id = o.customer_id
LEFT JOIN `Target.order_items` oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_freight DESC, avg_freight DESC;
