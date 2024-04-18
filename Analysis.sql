-- create databse pizzahut

CREATE DATABASE pizzahut;

-- use database pizzahut

USE pizzahut;

-- create a table pizzas

CREATE TABLE pizzas (
    pizza_id VARCHAR(30) NOT NULL,
    pizza_type_id VARCHAR(30) NOT NULL,
    size VARCHAR(3) NOT NULL,
    price DOUBLE NOT NULL,
    PRIMARY KEY (pizza_id)
);

-- check schema

DESC pizzas;

-- import data from csv file into pizzas table
-- check the data with select statement

SELECT 
    *
FROM
    pizzas;
    
-- import table pizza_types
-- check data in the table pizza_types

DESC pizza_types;
SELECT 
    *
FROM
    pizza_types;

-- create table orders
CREATE TABLE orders (
    order_id	INT NOT NULL,
    order_date	date NOT NULL,
    order_time	time NOT NULL,
    PRIMARY KEY (order_id)
);

-- view records in orders
SELECT 
    *
FROM
    orders
LIMIT 10;

-- create table order details

CREATE TABLE order_details (
	order_details_id	INT NOT NULL,
    order_id	INT NOT NULL,
    pizza_id	TEXT NOT NULL,
    quantity	INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- show schema

DESC order_details;

-- view records in orders
SELECT 
    *
FROM
    order_details
LIMIT 10;

-- We will not start solving the queries

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p USING (pizza_id);
    
-- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p USING (pizza_type_id)
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS od USING (pizza_id)
GROUP BY p.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY quantity;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(*) AS total
FROM
    pizza_types
GROUP BY category
ORDER BY total;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY order_date) AS total_orders;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, ROUND(SUM(quantity * price), 2) AS revenue
FROM
    pizzas
        JOIN
    pizza_types USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY name
ORDER BY revenue DESC;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    category,
    ROUND((SUM(quantity * price) / (SELECT 
                    SUM(quantity * price)
                FROM
                    pizzas
                        JOIN
                    pizza_types USING (pizza_type_id)
                        JOIN
                    order_details USING (pizza_id))) * 100,
            2) AS percentage
FROM
    pizzas
        JOIN
    pizza_types USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY category;

-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cumulative_revenue from
(select order_date, sum(quantity*price) as revenue
from
order_details join pizzas using(pizza_id)
join orders using(order_id)
group by order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select category, name,
sum(quantity*price) as revenue
from
pizza_types join pizzas using(pizza_type_id)
join order_details using(pizza_id)
group by category, name) as a) as b
where rn <= 3;