-- Data set : Restaurant Order
-- Source : mavenanalytics
	-- https://mavenanalytics.io/data-playground?order=date_added%2Cdesc&pageSize=10&search=rder
-- Queried using MySQL

-- In this project, first i will explore each table individualy, and than analyze the customer behavior
	-- I put the 'ANALYZING CUSTOMER BEHAVIOR' part in the top to show my ability to draw meaningfull insight from your data.

-- ANALYZING CUSTOMER BEHAVIOR
-- What is the highest ordered dish? what category is it from?

SELECT menu_item_id,
	item_name,
	category,
	total_order
FROM menu_items men
JOIN (
	SELECT item_id, 
	COUNT(*) AS total_order
	FROM order_details
	GROUP BY item_id) ord
ON men.menu_item_id = ord.item_id
ORDER BY total_order DESC;

-- what dish brings the most income?
SELECT menu_item_id, 
	item_name, 
	price, 
	total_ordered,
	(price * total_ordered) AS total_income
FROM menu_items men
JOIN (
	SELECT item_id,
	COUNT(*) AS total_ordered
	FROM order_details
	GROUP BY item_id) ord
ON men.menu_item_id = ord. item_id
ORDER BY (price * total_ordered) DESC;

-- -- what category brings the most income?
WITH income AS (
SELECT menu_item_id, 
	category, 
    item_name, 
	price, 
	total_ordered,
	(price * total_ordered) AS total_income
FROM menu_items men
JOIN (
	SELECT item_id,
	COUNT(*) AS total_ordered
	FROM order_details
	GROUP BY item_id) ord
ON men.menu_item_id = ord. item_id
ORDER BY (price * total_ordered) DESC
)

SELECT category,
	SUM(total_income) AS total_income_per_cat
FROM income
GROUP BY category
ORDER BY SUM(total_income) DESC;

-- What is the best day for our restaurant?

-- What day brings the most order
SELECT DISTINCT DAYOFWEEK(order_date) as day,
COUNT(*) AS total_order
FROM order_details
GROUP BY DAYOFWEEK(order_date)
ORDER BY COUNT(*) DESC;
	
-- What day brings the most income?
WITH total_per_item_per_day AS
(
SELECT item_name,
price,
DAYOFWEEK(order_date) AS day,
COUNT(order_details_id) AS total_orderd,
(price * (COUNT(order_details_id))) AS income_per_dish_per_day
FROM menu_items men
JOIN order_details ord
ON men.menu_item_id = ord.item_id
GROUP BY item_name, price, DAYOFWEEK(order_date)
)
SELECT day,
SUM(income_per_dish_per_day) AS income_per_day
FROM total_per_item_per_day
GROUP BY day
ORDER BY SUM(income_per_dish_per_day) DESC;

-- what is the month with the highest income?
WITH total_per_item_per_month AS
(
SELECT item_name,
price,
EXTRACT(MONTH FROM order_date) AS month,
COUNT(order_details_id) AS total_orderd,
(price * (COUNT(order_details_id))) AS income_per_dish_per_month
FROM menu_items men
JOIN order_details ord
ON men.menu_item_id = ord.item_id
GROUP BY item_name, price, EXTRACT(MONTH FROM order_date)
)
SELECT month,
SUM(income_per_dish_per_month) AS income_per_month
FROM total_per_item_per_month
GROUP BY month
ORDER BY SUM(income_per_dish_per_month) DESC;



-- EXPLORING THE menu_items table

-- finding the numbers of iems on the menu
SELECT COUNT(DISTINCT menu_item_id)
FROM menu_items;

-- finding the most and least expensive items on the menu
SELECT *
FROM (SELECT menu_item_id,item_name,price
FROM menu_items
ORDER BY PRICE DESC
LIMIT 1) AS menu;

WITH most_expensive AS
(SELECT item_name AS most_expensive, 
price
FROM menu_items
WHERE price = (SELECT MAX(price) FROM menu_items)),

least_expensive AS
(SELECT item_name AS least_expensive, 
price
FROM menu_items
WHERE price = (SELECT MIN(price) FROM menu_items))

SELECT most_expensive, most_expensive.price,
	least_expensive, least_expensive.price
FROM most_expensive, least_expensive;

-- What are the Italians food on the menu? and what is the most and least expensive Italian food?
SELECT item_name
FROM menu_items
WHERE category = 'Italian';

WITH most_exp_ita AS
(SELECT item_name AS most_exp_ita, 
price
FROM menu_items
WHERE category = 'Italian' AND 
price = (SELECT MAX(price) FROM menu_items WHERE category = 'Italian')),
least_exp_ita AS
(SELECT item_name AS least_exp_ita,
price
FROM menu_items
WHERE category = 'Italian' AND
price = (SELECT MIN(price) FROM menu_items WHERE category = 'Italian'))

SELECT *
FROM  most_exp_ita, least_exp_ita;

-- How many dishes per category? What is the average price for each category?
SELECT category,
COUNT(*) AS total_dishes,
ROUND(AVG(price), 2) AS avg_price
FROM menu_items
GROUP BY category;

-- EXPLORING the order_details table

-- What is the date range of the orders?

SELECT DISTINCT 
MAX(order_date) AS latest,
MIN(order_date) AS oldest,
CONCAT((MAX(order_date) - MIN(order_date)), ' days') AS date_range
FROM order_details
;

-- How many order did each dish have?
SELECT COALESCE(item_id, 'unknown') AS item_id, 
item_name,
COUNT(*) AS total_order
FROM order_details ord
JOIN menu_items men
ON ord.item_id = men.menu_item_id
GROUP BY item_id
ORDER BY total_order DESC
;

-- Which order_id has 12 or more orders?

SELECT order_id
FROM (
	SELECT order_id,
	COUNT(*) AS total_order
	FROM order_details
	GROUP BY order_id
	HAVING COUNT(*) >= 12
)AS total_per_orderid;
