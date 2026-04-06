WITH orders_filtered AS (
    SELECT 
        user_id,
        order_id,
        order_placed_datetime,
        order_value,
        discount_value
    FROM qb.orders
    WHERE LOWER(TRIM(order_status)) = 'delivered'
),

first_order AS (
    SELECT 
        user_id,
        MIN(order_placed_datetime) AS first_order_datetime
    FROM orders_filtered
    GROUP BY user_id
),

w1_returners AS (
    SELECT DISTINCT o.user_id
    FROM orders_filtered o
    JOIN first_order f ON o.user_id = f.user_id
    WHERE o.order_placed_datetime > f.first_order_datetime
    AND o.order_placed_datetime <= f.first_order_datetime + INTERVAL '7 days'
),

lifetime_stats AS (
    SELECT 
        o.user_id,
        COUNT(*) AS total_orders,
        SUM(o.order_value) AS total_spent,
        SUM(o.order_value - o.discount_value) AS total_net_spent,
        AVG(o.order_value) AS avg_order_value
    FROM orders_filtered o
    GROUP BY o.user_id
)

SELECT 
    CASE WHEN w.user_id IS NOT NULL THEN 'Returned_W1' ELSE 'Not_Returned_W1' END AS segment,
    COUNT(*) AS users,
    ROUND(AVG(l.total_orders)::numeric, 1) AS avg_lifetime_orders,
    ROUND(AVG(l.total_spent)::numeric, 2) AS avg_total_spent,
    ROUND(AVG(l.total_net_spent)::numeric, 2) AS avg_total_net_spent,
    ROUND(AVG(l.avg_order_value)::numeric, 2) AS avg_aov
FROM lifetime_stats l
LEFT JOIN w1_returners w ON l.user_id = w.user_id
GROUP BY CASE WHEN w.user_id IS NOT NULL THEN 'Returned_W1' ELSE 'Not_Returned_W1' END;