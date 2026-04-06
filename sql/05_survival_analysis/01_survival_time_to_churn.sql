WITH orders_filtered AS (
    SELECT 
        user_id,
        order_placed_datetime::date AS order_date
    FROM qb.orders
    WHERE LOWER(TRIM(order_status)) = 'delivered'
),

first_order AS (
    SELECT 
        user_id,
        MIN(order_date) AS first_order_date
    FROM orders_filtered
    GROUP BY user_id
),

last_order AS (
    SELECT 
        user_id,
        MAX(order_date) AS last_order_date
    FROM orders_filtered
    GROUP BY user_id
),

final_base AS(
SELECT 
    f.user_id,
    
    CASE 
        WHEN ('2025-04-04'::date - l.last_order_date) >= 14 
        THEN (l.last_order_date + 14 - f.first_order_date)
        ELSE ('2025-04-04'::date - f.first_order_date)
    END AS tenure_days,
    
    CASE 
        WHEN ('2025-04-04'::date - l.last_order_date) >= 14 
        THEN 1 ELSE 0 
    END AS is_churned

FROM first_order f
JOIN last_order l ON f.user_id = l.user_id
)

SELECT 
    is_churned, 
    COUNT(*) AS users 
FROM final_base 
GROUP BY is_churned;