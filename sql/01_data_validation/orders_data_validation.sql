-- Orders status distribution 
SELECT 
	order_status,
	COUNT(order_id) AS total_order
FROM qb.orders
GROUP BY order_status;



-- Orders Data -- 

SELECT 
	DATE_TRUNC('MONTH',order_placed_datetime)::date AS month ,
	COUNT(DISTINCT order_placed_datetime::date) AS days,
	COUNT(order_id) AS total_orders, 
	COUNT(order_id)/COUNT(DISTINCT user_id) AS order_frequency,
	SUM(order_value) AS total_gmv,
	SUM(order_value - discount_value) AS net_gmv,
	SUM(is_first_order) AS new_users,
	ROUND((SUM(order_value)/COUNT(order_id)),2) AS aov

FROM qb.orders
WHERE order_placed_datetime::date <'2025-04-01'
GROUP BY DATE_TRUNC('MONTH',order_placed_datetime)::date;

