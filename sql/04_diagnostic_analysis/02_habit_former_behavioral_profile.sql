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

-- Only users with 4 full weeks of observation
eligible_users AS (
    SELECT user_id, first_order_datetime
    FROM first_order
    WHERE first_order_datetime::date <= '2025-03-07'
),

user_weeks AS (
    SELECT
        o.user_id,
        FLOOR(
            (o.order_placed_datetime::date - e.first_order_datetime::date) / 7
        )::int AS week_number,
        o.order_value,
        o.discount_value
    FROM orders_filtered o
    INNER JOIN eligible_users e
        ON o.user_id = e.user_id
    WHERE FLOOR(
            (o.order_placed_datetime::date - e.first_order_datetime::date) / 7
        )::int BETWEEN 0 AND 3
),

weekly_metrics AS (
    SELECT
        user_id,
        week_number,
        COUNT(*) AS orders,
        AVG(order_value) AS avg_aov,
        AVG(
            CASE 
                WHEN order_value > 0 
                THEN discount_value::numeric / order_value
                ELSE 0 
            END
        ) AS avg_discount_pct
    FROM user_weeks
    GROUP BY user_id, week_number
),

user_trajectory AS (
    SELECT
        user_id,
        MAX(CASE WHEN week_number = 0 THEN 1 ELSE 0 END) AS w0,
        MAX(CASE WHEN week_number = 1 THEN 1 ELSE 0 END) AS w1,
        MAX(CASE WHEN week_number = 2 THEN 1 ELSE 0 END) AS w2,
        MAX(CASE WHEN week_number = 3 THEN 1 ELSE 0 END) AS w3,
        MAX(CASE WHEN week_number = 0 THEN orders END) AS orders_w0,
        MAX(CASE WHEN week_number = 1 THEN orders END) AS orders_w1,
        MAX(CASE WHEN week_number = 2 THEN orders END) AS orders_w2,
        MAX(CASE WHEN week_number = 3 THEN orders END) AS orders_w3,
        MAX(CASE WHEN week_number = 0 THEN avg_aov END) AS aov_w0,
        MAX(CASE WHEN week_number = 1 THEN avg_aov END) AS aov_w1,
        MAX(CASE WHEN week_number = 2 THEN avg_aov END) AS aov_w2,
        MAX(CASE WHEN week_number = 3 THEN avg_aov END) AS aov_w3,
        MAX(CASE WHEN week_number = 0 THEN avg_discount_pct END) AS disc_w0,
        MAX(CASE WHEN week_number = 1 THEN avg_discount_pct END) AS disc_w1,
        MAX(CASE WHEN week_number = 2 THEN avg_discount_pct END) AS disc_w2,
        MAX(CASE WHEN week_number = 3 THEN avg_discount_pct END) AS disc_w3
    FROM weekly_metrics
    GROUP BY user_id
),

user_segments AS (
    SELECT
        *,
        CASE
            WHEN w0 = 1 AND w1 = 1 AND w2 = 1 AND w3 = 1 THEN 'Habit_4W'
            WHEN w0 = 1 AND w1 = 0 THEN 'Drop_W1'
            WHEN w0 = 1 AND w1 = 1 AND w2 = 0 THEN 'Drop_W2'
            WHEN w0 = 1 AND w1 = 1 AND w2 = 1 AND w3 = 0 THEN 'Drop_W3'
            ELSE 'Other'
        END AS segment
    FROM user_trajectory
)

SELECT
    segment,
    COUNT(*) AS users,
    ROUND(AVG(orders_w0)::numeric, 2) AS orders_w0,
    ROUND(AVG(orders_w1)::numeric, 2) AS orders_w1,
    ROUND(AVG(orders_w2)::numeric, 2) AS orders_w2,
    ROUND(AVG(orders_w3)::numeric, 2) AS orders_w3,
    ROUND(AVG(aov_w0)::numeric, 2) AS aov_w0,
    ROUND(AVG(aov_w1)::numeric, 2) AS aov_w1,
    ROUND(AVG(aov_w2)::numeric, 2) AS aov_w2,
    ROUND(AVG(aov_w3)::numeric, 2) AS aov_w3,
    ROUND(AVG(disc_w0)::numeric, 4) AS disc_w0,
    ROUND(AVG(disc_w1)::numeric, 4) AS disc_w1,
    ROUND(AVG(disc_w2)::numeric, 4) AS disc_w2,
    ROUND(AVG(disc_w3)::numeric, 4) AS disc_w3
FROM user_segments
WHERE segment != 'Other'
GROUP BY segment
ORDER BY segment;