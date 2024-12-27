create database pizza_db;
show databases;
use pizza_db;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);
CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);
select * from order_details;

/*Basic:*/
/*Retrieve the total number of orders placed.*/
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

/*Calculate the total revenue generated from pizza sales.*/
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_Revenue
FROM
    order_details od
        LEFT JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

/*Identify the highest-priced pizza.*/
SELECT 
    *
FROM
    pizzas
WHERE
    price = (SELECT 
            MAX(price)
        FROM
            pizzas);

/*Identify the most common pizza size ordered.*/
SELECT 
    size, COUNT(size) AS Max_Ordered_Pizza_Size
FROM
    order_details od
        LEFT JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY COUNT(size) DESC
LIMIT 1;

/*List the top 5 most ordered pizza types along with their quantities.*/

SELECT 
    pt.name, COUNT(od.pizza_id) AS frequent_Pizza
FROM
    order_details od
        LEFT JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        LEFT JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY COUNT(od.pizza_id) DESC
LIMIT 5;

/*Intermediate:*/
/*Join the necessary tables to find the total quantity of each pizza category ordered.*/
SELECT 
    pt.category, SUM(od.quantity) AS Total_Qunatity
FROM
    order_details od
        LEFT JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        LEFT JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY SUM(od.quantity) DESC;

/*Determine the distribution of orders by hour of the day.*/
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour,
    COUNT(order_id) AS No_Of_Order
FROM
    orders
GROUP BY hour
ORDER BY No_Of_Order ASC;

/*Join relevant tables to find the category-wise distribution of pizzas.*/
SELECT 
    pt.category, COUNT(pt.name) as No_Of_Pizza_Type
FROM
    pizza_types pt
GROUP BY pt.category;

/*Group the orders by date and calculate the average number of pizzas ordered per day.*/
SELECT 
    AVG(Total_Quantity) AS Avrage_Quantity_Per_Day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS Total_Quantity
    FROM
        orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS Order_Quantity;

/*Determine the top 3 most ordered pizza types based on revenue.*/
SELECT 
    pt.name AS Pizza_Name,
    ROUND(SUM(od.quantity * p.price), 2) AS Revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;


/*Advanced:
/*Calculate the percentage contribution of each pizza type to total revenue.*/
SELECT 
    pt.category AS Pizza_Category,
    ROUND(ROUND(SUM(od.quantity * p.price), 2) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2)
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id
                        JOIN
                    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id) * 100,
            2) AS Revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY Revenue;

/*Analyze the cumulative revenue generated over time.*/
SELECT order_date,SUM(Day_Revenue) OVER(ORDER BY order_date) AS Cum_Revenue 
FROM
	(SELECT 
		o.order_date, ROUND(SUM(od.quantity * p.price),2) AS Day_Revenue
	FROM
		orders o
			JOIN
		order_details od ON o.order_id = od.order_id
			JOIN
		pizzas p ON p.pizza_id = od.pizza_id
	GROUP BY o.order_date) 
AS Sales ;


/*Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
SELECT Category, Name, Revenue FROM
(SELECT 
	Category, Name, Revenue, 
	rank() over (partition by Category order by Revenue desc ) as RN FROM
	(SELECT 
		pt.category AS Category,
		pt.name AS Name,
		ROUND(SUM(od.quantity * p.price), 2) AS Revenue
			FROM
			order_details od
				JOIN
			pizzas p ON od.pizza_id = p.pizza_id
				JOIN
			pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
		GROUP BY pt.category , pt.name) AS A) AS B WHERE RN < 4 ;