WITH user_base_made_first_order AS(
SELECT 
	user_id, 
	signup_datetime AS acquisition_datetime,
	acquisition_source,
	first_order_datetime
	
FROM qb.users
WHERE first_order_datetime IS NOT NULL
),
order_ranking AS(
	SELECT 
		user_id, 
		order_id,
		order_placed_datetime,
		ROW_NUMBER()OVER(PARTITION BY user_id ORDER BY order_placed_datetime) AS ord_seq_rnk 
	FROM qb.orders 
)

SELECT 
	
	CASE WHEN so.second_order_datetime IS NULL THEN NULL 
	ELSE so.second_order_datetime::date - ub.first_order_datetime::date
	END AS time_to_second_order, 
	COUNT(ub.user_id) AS total_user
FROM user_base_made_first_order AS ub 
LEFT JOIN (
	SELECT 
		user_id,
		order_placed_datetime AS second_order_datetime
	FROM order_ranking
	WHERE ord_seq_rnk = 2
) AS so
ON ub.user_id = so.user_id 
GROUP BY  time_to_second_order
ORDER BY  time_to_second_order