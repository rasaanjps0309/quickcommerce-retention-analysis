WITH base AS (
    SELECT 
        user_id,
        order_id,
        order_placed_datetime,

        -- First order per user
        MIN(order_placed_datetime) OVER (PARTITION BY user_id) AS first_order_datetime,

        -- Days since first order
        (order_placed_datetime::date - 
         MIN(order_placed_datetime) OVER (PARTITION BY user_id)::date) 
         AS days_since_first_order

    FROM qb.orders
	WHERE LOWER(order_status) = 'delivered'
),

week_bucket AS (
    SELECT 
        user_id,

        -- Weekly cohort (IMPORTANT FIX)
        DATE_TRUNC('week', first_order_datetime)::date AS cohort_week,

        order_id,

        -- Week buckets: W0 = day 0–6, W1 = 7–13, ...
        FLOOR(days_since_first_order / 7) AS week_number

    FROM base
)

SELECT
    cohort_week,

    COUNT(DISTINCT CASE WHEN week_number = 0 THEN user_id END) AS W0,
    COUNT(DISTINCT CASE WHEN week_number = 1 THEN user_id END) AS W1,
    COUNT(DISTINCT CASE WHEN week_number = 2 THEN user_id END) AS W2,
    COUNT(DISTINCT CASE WHEN week_number = 3 THEN user_id END) AS W3,
    COUNT(DISTINCT CASE WHEN week_number = 4 THEN user_id END) AS W4,
    COUNT(DISTINCT CASE WHEN week_number = 5 THEN user_id END) AS W5,
    COUNT(DISTINCT CASE WHEN week_number = 6 THEN user_id END) AS W6,
    COUNT(DISTINCT CASE WHEN week_number = 7 THEN user_id END) AS W7,
    COUNT(DISTINCT CASE WHEN week_number = 8 THEN user_id END) AS W8,
    COUNT(DISTINCT CASE WHEN week_number = 9 THEN user_id END) AS W9,
    COUNT(DISTINCT CASE WHEN week_number = 10 THEN user_id END) AS W10,
    COUNT(DISTINCT CASE WHEN week_number = 11 THEN user_id END) AS W11,
    COUNT(DISTINCT CASE WHEN week_number = 12 THEN user_id END) AS W12,
    COUNT(DISTINCT CASE WHEN week_number = 13 THEN user_id END) AS W13,
    COUNT(DISTINCT CASE WHEN week_number = 14 THEN user_id END) AS W14

FROM week_bucket
GROUP BY cohort_week
ORDER BY cohort_week;