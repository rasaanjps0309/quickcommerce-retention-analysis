WITH base AS (
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('week', MIN(order_placed_datetime) OVER (PARTITION BY user_id))::date AS cohort_week,
        FLOOR(
            (order_placed_datetime::date - 
             MIN(order_placed_datetime::date) OVER (PARTITION BY user_id)
            ) / 7
        )::int AS week_number
    FROM qb.orders
	WHERE LOWER(order_status) = 'delivered'
),
consecutive AS (
    SELECT 
        user_id,
        cohort_week,
        week_number,
        -- Check if user was active in every week from 0 to current week_number
        CASE WHEN week_number = COUNT(*) OVER (
            PARTITION BY user_id 
            ORDER BY week_number 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) - 1 
        -- week_number 0 with count 1 = consecutive
        -- week_number 1 with count 2 = consecutive (was in 0 and 1)
        -- week_number 3 with count 3 = NOT consecutive (skipped a week)
        THEN 1 ELSE 0 END AS is_consecutive
    FROM base
)
SELECT 
    cohort_week,
    COUNT(DISTINCT CASE WHEN week_number = 0 THEN user_id END) AS w0,
    COUNT(DISTINCT CASE WHEN week_number = 1 AND is_consecutive = 1 THEN user_id END) AS w1,
    COUNT(DISTINCT CASE WHEN week_number = 2 AND is_consecutive = 1 THEN user_id END) AS w2,
    COUNT(DISTINCT CASE WHEN week_number = 3 AND is_consecutive = 1 THEN user_id END) AS w3,
    COUNT(DISTINCT CASE WHEN week_number = 4 AND is_consecutive = 1 THEN user_id END) AS w4,
    COUNT(DISTINCT CASE WHEN week_number = 5 AND is_consecutive = 1 THEN user_id END) AS w5,
    COUNT(DISTINCT CASE WHEN week_number = 6 AND is_consecutive = 1 THEN user_id END) AS w6,
    COUNT(DISTINCT CASE WHEN week_number = 7 AND is_consecutive = 1 THEN user_id END) AS w7,
    COUNT(DISTINCT CASE WHEN week_number = 8 AND is_consecutive = 1 THEN user_id END) AS w8
FROM consecutive
GROUP BY cohort_week
ORDER BY cohort_week;