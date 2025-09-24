-- ========================================
-- Payments Analysis
-- ========================================

-- 1. Orders by payment type
SELECT FORMAT_DATE('%b %Y', o.order_purchase_timestamp) AS month_ordered,
       p.payment_type,
       COUNT(o.order_id) AS orders_placed
FROM `Target.orders` o
JOIN `Target.payments` p
    ON o.order_id = p.order_id
GROUP BY month_ordered, payment_type
ORDER BY month_ordered DESC;

-- 2. Orders by payment installments
SELECT p.payment_installments,
       COUNT(o.order_id) AS orders_placed
FROM `Target.orders` o
JOIN `Target.payments` p
    ON o.order_id = p.order_id
GROUP BY payment_installments
ORDER BY orders_placed DESC;
