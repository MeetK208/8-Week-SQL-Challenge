SET search_path = pizza_runner;



-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
create function custom_week(p_input date)
  returns int
as
$$
   select (p_input - date_trunc('year', p_input)::date) / 7 ;
$$
language sql
immutable; 

SELECT
	CUSTOM_WEEK (REGISTRATION_DATE),
	COUNT(RUNNER_ID)
FROM
	RUNNERS
GROUP BY	1;

DROP FUNCTION CUSTOM_WEEK (DATE);

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
	RUNNER_ID,
	AVG(PREPARATIONTIME)
FROM
	(
		SELECT
			C.ORDER_ID,
			RUNNER_ID,
			COUNT(C.PIZZA_ID) AS PIZZACOUNT,
			EXTRACT(
				EPOCH
				FROM
					(R.PICKUP_TIME - C.ORDER_TIME)
			) / 60 AS PREPARATIONTIME
		FROM
			CUSTOMER_ORDERS AS C
			INNER JOIN RUNNER_ORDERS AS R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			DISTANCE_KM != -1
		GROUP BY
			C.ORDER_ID,
			RUNNER_ID,
			C.ORDER_TIME,
			R.PICKUP_TIME
		ORDER BY
			3
	)
GROUP BY
	1
order by 1

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?

	
	
-- What was the average distance travelled for each customer?

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT
	ABS(MIN(PREPARATIONTIME) - MAX(PREPARATIONTIME)) MAXTIME
FROM
	(
		SELECT
			C.ORDER_ID,
			COUNT(C.PIZZA_ID) AS PIZZACOUNT,
			EXTRACT(
				EPOCH
				FROM
					(R.PICKUP_TIME - C.ORDER_TIME)
			) / 60 AS PREPARATIONTIME
		FROM
			CUSTOMER_ORDERS AS C
			INNER JOIN RUNNER_ORDERS AS R ON C.ORDER_ID = R.ORDER_ID
		WHERE
			DISTANCE_KM != -1
		GROUP BY
			C.ORDER_ID,
			C.ORDER_TIME,
			R.PICKUP_TIME
		ORDER BY
			3
	)
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
	CO.ORDER_ID,
	runner_id,
	distance_km * 60 / duration_min avgTime
FROM
	CUSTOMER_ORDERS CO
	INNER JOIN RUNNER_ORDERS RO ON CO.ORDER_ID = RO.ORDER_ID
WHERE
	DISTANCE_KM != -1
group by 
	CO.ORDER_ID, runner_id, distance_km,duration_min
ORDER BY
1	
-- What is the successful delivery percentage for each runner?

SELECT
	RUNNER_ID,
	(sum(case 
		when CANCELLATION = 'NULL' then 1
	else 0
	end) * 100) / count(RUNNER_ID) as success 
FROM
	RUNNER_ORDERS
group by 1
order by 1