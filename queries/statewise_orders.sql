-- ========================================
-- Month-on-Month Orders by State
-- ========================================

SELECT c.customer_state,
       FORMAT_DATE('%b %Y', o.order_purchase_timestamp) AS month_ordered,
       COUNT(o.order_id) AS orders_placed
FROM `Target.customers` c
JOIN `Target.orders` o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state, FORMAT_DATE('%b %Y', o.order_purchase_timestamp)
ORDER BY c.customer_state, month_ordered;
