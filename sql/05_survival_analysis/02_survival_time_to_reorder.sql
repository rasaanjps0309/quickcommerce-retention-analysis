WITH valid_orders AS (
    SELECT *
    FROM qb.orders
    WHERE lower(order_status) = 'delivered'  -- adjust if needed
),

first_orders AS (
    SELECT 
        user_id,
        order_placed_datetime AS first_order_date
    FROM valid_orders
    WHERE is_first_order = 1
),

second_orders AS (
    SELECT 
        o.user_id,
        MIN(o.order_placed_datetime) AS second_order_date
    FROM valid_orders o
    JOIN first_orders f 
        ON o.user_id = f.user_id
        AND o.order_placed_datetime > f.first_order_date
    GROUP BY 1
),

final AS (
    SELECT 
        f.user_id,
        f.first_order_date,
        s.second_order_date,

        DATE '2025-03-31' AS obs_end_date,

        CASE 
            WHEN s.second_order_date IS NOT NULL 
                THEN DATE_PART('day', s.second_order_date - f.first_order_date)
            ELSE DATE_PART('day', DATE '2025-03-31' - f.first_order_date)
        END AS days_to_event,

        CASE 
            WHEN s.second_order_date IS NULL THEN 1 ELSE 0 
        END AS censored

    FROM first_orders f
    LEFT JOIN second_orders s 
        ON f.user_id = s.user_id
)

SELECT * FROM final;