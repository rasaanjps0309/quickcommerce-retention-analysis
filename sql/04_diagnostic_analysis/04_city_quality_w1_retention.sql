WITH orders_filtered AS (
    SELECT 
        user_id,
        order_id,
        order_placed_datetime,
        order_value,
        item_count,
        delivery_time_mins,
        discount_value
    FROM qb.orders
    WHERE LOWER(TRIM(order_status)) = 'delivered'
),

-- Step 1: First order
first_order AS (
    SELECT
        user_id,
        MIN(order_placed_datetime) AS first_order_datetime
    FROM orders_filtered
    GROUP BY user_id
),

-- Step 2: Orders within first 7 days
orders_7d AS (
    SELECT
        o.*,
        f.first_order_datetime
    FROM orders_filtered o
    JOIN first_order f
        ON o.user_id = f.user_id
    WHERE o.order_placed_datetime <= f.first_order_datetime + INTERVAL '7 days'
),

-- Step 3: User-level metrics
user_metrics AS (
    SELECT
        user_id,
        COUNT(*) AS orders_7d,
        AVG(order_value) AS avg_aov,
        AVG(
            CASE 
                WHEN order_value > 0 
                THEN discount_value::numeric / order_value
                ELSE 0 
            END
        ) AS avg_discount_pct,
        AVG(item_count) AS avg_item_count,
        AVG(delivery_time_mins) AS avg_delivery_time
    FROM orders_7d
    GROUP BY user_id
),

-- Step 4: Retention flag
user_retention AS (
    SELECT
        f.user_id,
        MAX(
            CASE 
                WHEN o.order_placed_datetime > f.first_order_datetime
                 AND o.order_placed_datetime <= f.first_order_datetime + INTERVAL '7 days'
                THEN 1 ELSE 0 
            END
        ) AS retained_w1
    FROM first_order f
    LEFT JOIN orders_filtered o
        ON f.user_id = o.user_id
    GROUP BY f.user_id
),

-- Step 5: Combine with city
base AS (
    SELECT
        u.city,
        r.user_id,
        r.retained_w1,
        m.orders_7d,
        m.avg_aov,
        m.avg_discount_pct,
        m.avg_item_count,
        m.avg_delivery_time
    FROM user_retention r
    LEFT JOIN user_metrics m
        ON r.user_id = m.user_id
    LEFT JOIN qb.users u
        ON r.user_id = u.user_id
),

-- Step 6: City-level retention
city_retention AS (
    SELECT
        city,
        ROUND(SUM(retained_w1)*1.0 / COUNT(*), 4) AS w1_retention_rate
    FROM base
    GROUP BY city
)

-- Step 7: Final output
SELECT
    b.city,

    CASE 
        WHEN b.retained_w1 = 1 THEN 'Returned'
        ELSE 'Not_Returned'
    END AS user_segment,

    COUNT(*) AS users,

    cr.w1_retention_rate,

    ROUND(AVG(b.orders_7d), 2) AS avg_orders_7d,
    ROUND(AVG(b.avg_aov), 2) AS avg_aov,
    ROUND(AVG(b.avg_discount_pct), 4) AS avg_discount_pct,
    ROUND(AVG(b.avg_item_count), 2) AS avg_item_count,
    ROUND(AVG(b.avg_delivery_time), 2) AS avg_delivery_time

FROM base b
LEFT JOIN city_retention cr
    ON b.city = cr.city

GROUP BY b.city, user_segment, cr.w1_retention_rate
ORDER BY b.city, user_segment;