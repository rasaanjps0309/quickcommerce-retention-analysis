-- Basic Data Validation : Sanity Check : Nulls , Distinct Values , outliers ------

SELECT 
	-- ROW COUNT CHECK 
	COUNT(*) AS row_counts,
	COUNT(DISTINCT user_id) AS total_user_count,
	COUNT(signup_datetime) AS datetime_rows,
	COUNT(acquisition_source) AS acq_rows,
	COUNT(acquisition_cost) AS acq_cost_rows,
	COUNT(first_order_datetime) AS first_order_rows,
	COUNT(is_loyalty_member) AS loyaty_rows,
	

	-- DISTINCT VALUE CHECK 
	COUNT(DISTINCT city) AS presence_in_cities,
	COUNT( DISTINCT acquisition_source) AS acq_channel,
	SUM(is_loyalty_member) AS total_loyalty_members,

	-- DATA VALUE CHECKS
	AVG(acquisition_cost) AS avg_cost,
	SUM(acquisition_cost) AS toatl_acq_cost,
	MIN(signup_datetime) AS min_signup_date,
	MAX(signup_datetime) AS max_signup_date


FROM qb.users ;


-- city wise growth --

SELECT 
	city,
	COUNT(DISTINCT user_id) AS total_user

FROM qb.users
GROUP BY city ;


-- Device level penetration 

SELECT 
	device_os, 
	COUNT(DISTINCT user_id) AS total_user

FROM qb.users
GROUP BY device_os;


-- Acquisition Source Level ----
WITH acquisition_base AS(
SELECT 
	acquisition_source,
	SUM(acquisition_cost) AS acq_cost,
	COUNT(user_id) AS total_user,
	SUM(is_loyalty_member) AS loyalty_member_count , 
	COUNT(first_order_datetime) AS first_order_placed_count,
	ROUND(AVG(first_order_datetime::date - signup_datetime::date)) AS avg_days_to_activation
	
FROM qb.users
GROUP BY acquisition_source
) 

SELECT 
	acquisition_source,
	acq_cost,
	loyalty_member_count,
	
	ROUND(acq_cost/SUM(acq_cost)OVER(),2) AS cost_pct_share,
	
	total_user,
	ROUND(total_user/ SUM(total_user)OVER(),2) AS user_pct_share,

	first_order_placed_count, 
	ROUND(first_order_placed_count:: numeric /total_user:: numeric ,2) AS cvr,

	avg_days_to_activation 
	
FROM acquisition_base