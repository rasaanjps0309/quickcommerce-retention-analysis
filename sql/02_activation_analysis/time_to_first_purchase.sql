WITH user_activation_base AS(
SELECT 
	user_id, 
	signup_datetime AS acquisition_datetime,
	acquisition_source,
	
	CASE 
		WHEN first_order_datetime IS NULL THEN NULL 
		ELSE (first_order_datetime::date - signup_datetime::date)
	END AS time_to_first_order
	
FROM qb.users)

SELECT 
	DATE_TRUNC('MONTH',acquisition_datetime)::date AS acquisition_month, 
	COUNT(user_id) AS total_users, 
	
	COUNT(CASE WHEN time_to_first_order = 0 THEN user_id END) AS Day_0,
	COUNT(CASE WHEN time_to_first_order = 1 THEN user_id END) AS day_1,
	COUNT(CASE WHEN time_to_first_order = 2 THEN user_id END) AS day_2,
	COUNT(CASE WHEN time_to_first_order = 3 THEN user_id END) AS Day_3,
	COUNT(CASE WHEN time_to_first_order >3 THEN user_id END) AS beyond_day_3,
	COUNT(CASE WHEN time_to_first_order IS NULL THEN user_id END) AS never_ordered
	
FROM user_activation_base
GROUP BY acquisition_month;

-- time to first order curve ----

WITH user_activation_base AS(
SELECT 
	user_id, 
	signup_datetime AS acquisition_datetime,
	acquisition_source,
	
	CASE 
		WHEN first_order_datetime IS NULL THEN NULL 
		ELSE (first_order_datetime::date - signup_datetime::date)
	END AS time_to_first_order
	
FROM qb.users)

SELECT 
	time_to_first_order,
	COUNT(user_id) AS total_user
	
FROM user_activation_base
GROUP BY time_to_first_order
ORDER BY time_to_first_order;