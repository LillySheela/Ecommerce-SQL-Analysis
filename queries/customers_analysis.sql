-- ========================================
-- Exploratory Analysis: Customers Table
-- ========================================

-- 1. Data type of all columns in the "customers" table
SELECT column_name, data_type
FROM `Target.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'customers';

-- 2. Count of Cities & States of customers who ordered
SELECT COUNT(DISTINCT customer_city) AS city_count,
       COUNT(DISTINCT customer_state) AS state_count
FROM `Target.customers`
WHERE customer_id IN (
    SELECT customer_id
    FROM `Target.orders`
)
ORDER BY state_count DESC, city_count DESC;

-- 3. Distribution of customers across states
SELECT customer_state, COUNT(customer_id) AS customer_distribution
FROM `Target.customers`
GROUP BY customer_state
ORDER BY customer_distribution DESC;
