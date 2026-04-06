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

-- Step 1: First order per user
first_order AS (
    SELECT 
        user_id,
        order_id,
        order_placed_datetime,
        order_value,
        item_count,
        delivery_time_mins,
        discount_value,
        DATE_TRUNC('week', order_placed_datetime)::date AS cohort_week
    FROM (
        SELECT 
            o.*,
            ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_placed_datetime) AS rn
        FROM orders_filtered o
    ) t
    WHERE rn = 1
),

-- Step 2: Join to find returns within 7 days
user_return_flag AS (
    SELECT 
        f.user_id,
        f.cohort_week,

        f.order_value,
        f.item_count,
        f.delivery_time_mins,
        f.discount_value,

        -- if any order exists in 7d window → 1 else 0
        MAX(
            CASE 
                WHEN o.order_placed_datetime > f.order_placed_datetime
                 AND o.order_placed_datetime <= f.order_placed_datetime + INTERVAL '7 days'
                THEN 1 ELSE 0 
            END
        ) AS returned_7d

    FROM first_order f
    LEFT JOIN orders_filtered o
        ON f.user_id = o.user_id

    GROUP BY 
        f.user_id,
        f.cohort_week,
        f.order_value,
        f.item_count,
        f.delivery_time_mins,
        f.discount_value
),

-- Step 3: Aggregate metrics
final AS (
    SELECT
        cohort_week,
        returned_7d,

        COUNT(*) AS users,

        AVG(delivery_time_mins) AS avg_delivery_time,

        AVG(
            CASE 
                WHEN order_value > 0 
                THEN discount_value::numeric / order_value
                ELSE 0 
            END
        ) AS avg_discount_pct,

        AVG(order_value) AS avg_basket_value,
        AVG(item_count) AS avg_item_count

    FROM user_return_flag
    GROUP BY cohort_week, returned_7d
)

SELECT
    cohort_week,

    CASE 
        WHEN returned_7d = 1 THEN 'Returned_7d'
        ELSE 'Not_Returned_7d'
    END AS user_segment,

    users,
    ROUND(avg_delivery_time, 2) AS avg_delivery_time,
    ROUND(avg_discount_pct, 4) AS avg_discount_pct,
    ROUND(avg_basket_value, 2) AS avg_basket_value,
    ROUND(avg_item_count, 2) AS avg_item_count

FROM final
ORDER BY cohort_week, user_segment;