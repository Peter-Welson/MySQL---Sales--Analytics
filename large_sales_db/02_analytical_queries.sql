-- Q1
-- Calculate total revenue, total cost, and total profit per product category (filtering only for Completed orders).
-- ANSWER A)
SELECT
	p.Category,
	SUM(Quantity * Cost_price) AS Total_Cost,
	SUM(Quantity * (1- Discount) * Unit_Price) AS Total_Revenue,
	SUM((Quantity * (1- Discount) * Unit_Price) - (Quantity * Cost_price)) AS Total_Profit1,
	SUM(Quantity *( ((1- discount)* Unit_price)- Cost_price ))AS Total_Profit2
FROM Orders o
LEFT JOIN Products p
	ON o.product_id = p.product_id
    where status = 'Completed'
GROUP BY p.Category;
    
    
-- Answer B)
WITH CategoryTotals AS (
    SELECT 
        p.Category,
        SUM(o.quantity * p.cost_price) AS Total_Cost,
        SUM(o.quantity * (1 - o.discount) * p.unit_price) AS Total_Revenue
    FROM Orders o
    LEFT JOIN Products p 
        ON o.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY p.Category
)
SELECT 
    Category,
    Total_Cost,
    Total_Revenue,
    (Total_Revenue - Total_Cost) AS Total_Profit
FROM CategoryTotals;

-- ===========================================================================
-- Q2
-- Rank sales representatives within each region based on their total sales revenue.
-- Answe A) 
Select *
from sales_reps;
Select *
from products;
Select *
From Orders;

with Revenue_rank as
(Select o.rep_id, SUM(quantity * (1-discount) *unit_price) AS Total_Revenue
from orders o
Left Join products p
	ON o.product_id = p.product_id
	where o.status = 'Completed'
GROUP BY o.rep_id
order by Total_revenue Desc

)
select s.Rep_id, S.Rep_Name, Region, S.Hire_date,
round(Total_revenue,2) AS Total_Revenue,
Dense_Rank () over(partition by region Order by Total_Revenue Desc) AS REP_RANK
from Revenue_rank R
join sales_reps S
	ON R.rep_id = S.rep_ID;
    
-- ANSWE B)
SELECT 
    s.rep_id,
    s.rep_name,
    s.region,
    s.hire_date,
    ROUND(SUM(o.quantity * (1 - o.discount) * p.unit_price), 2) AS Total_Revenue,
    DENSE_RANK() OVER (
        PARTITION BY s.region 
        ORDER BY SUM(o.quantity * (1 - o.discount) * p.unit_price) DESC
    ) AS REP_RANK
FROM sales_reps s
JOIN orders o 
    ON s.rep_id = o.rep_id
JOIN products p 
    ON o.product_id = p.product_id
WHERE o.status = 'Completed'
GROUP BY 
    s.rep_id, 
    s.rep_name, 
    s.region, 
    s.hire_date
ORDER BY 
    s.region, 
    REP_RANK;
    
-- =================================================================================
-- Q3
-- For each customer, find the number of days between their current completed order and their previous completed order.
-- Answe A) 
with Orders_flow as 
(
	Select
		first_name,
		last_name,
		c.customer_id,
        order_date,
		lag(order_date,1) over(partition by customer_id order by order_date) as Previous_Date
	From Orders o
	join customers c
		on o.Customer_id = c.customer_id
)
Select * , datediff(order_date, previous_date) Days_Number
from orders_flow
order by customer_id, order_date;

-- ANSWER B)
SELECT 
    c.first_name,
    c.last_name,
    o.customer_id,
    o.order_date,
    LAG(o.order_date) OVER (
        PARTITION BY o.customer_id 
        ORDER BY o.order_date
    ) AS Previous_Date,
    DATEDIFF(
        o.order_date, 
        LAG(o.order_date) OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_date
        )
    ) AS Days_Number
FROM Orders o
JOIN Customers c 
    ON o.customer_id = c.customer_id
ORDER BY 
    o.customer_id, 
    o.order_date;
-- =================================================================================
-- Q4 
-- Calculate total monthly revenue and the Month-over-Month (MoM) revenue growth percentage for 2024.
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') AS month, 
        SUM(o.quantity * (1 - o.discount) * p.unit_price) AS total_value
    FROM orders o
    JOIN products p 
        ON o.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
sales_with_lag AS (
    SELECT 
        month,
        total_value,
        LAG(total_value) OVER (ORDER BY month) AS previous_sale
    FROM monthly_sales
)
SELECT 
    month,
    total_value,
    previous_sale,
    CONCAT(ROUND(((total_value - previous_sale) / previous_sale) * 100, 2), '%') AS MoM_Growth
FROM sales_with_lag
WHERE month LIKE '2024%';

-- ANSWER B)
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_date,
        DATE_FORMAT(o.order_date, '%Y-%m') AS Month,
        SUM(o.quantity * (1 - o.discount) * p.unit_price) AS Total_Value
    FROM orders o
    JOIN products p 
        ON o.product_id = p.product_id
    WHERE o.status = 'Completed'
    GROUP BY 
        DATE_FORMAT(o.order_date, '%Y-%m-01'),
        DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT 
    curr.Month,
    curr.Total_Value,
    prev.Total_Value AS Previous_sale,
    CONCAT(
        ROUND(((curr.Total_Value - prev.Total_Value) / prev.Total_Value) * 100, 2),
        '%'
    ) AS MoM_Growth
FROM monthly_sales curr
LEFT JOIN monthly_sales prev 
    ON prev.month_date = DATE_SUB(curr.month_date, INTERVAL 1 MONTH)
WHERE curr.Month LIKE '2024%'
ORDER BY curr.Month;

-- =========================================================
-- Q5 
-- Sales Representative Productivity & Monthly Revenue Efficiency Analysis

SELECT S.REP_ID, S.REP_NAME, S.HIRE_DATE, timestampdiff(MONTH, S.HIRE_DATE,'2025-12-29') AS PERIOD_MONTH,
ROUND(SUM(QUANTITY * (1-DISCOUNT) * UNIT_PRICE),0) as TOTAL_REVENUE,
(ROUND(SUM(QUANTITY * (1-DISCOUNT) * UNIT_PRICE),0)/timestampdiff(MONTH, S.HIRE_DATE,'2025-12-29')) AS AVG_PRODUCTIVITY_MONTH

FROM ORDERS O
JOIN PRODUCTS P
	ON O.PRODUCT_ID = P.PRODUCT_ID
JOIN SALES_REPS S
	ON O.REP_ID = S.REP_ID
WHERE o.status = 'Completed'
GROUP BY S.REP_ID, S.REP_NAME, S.HIRE_DATE, timestampdiff(MONTH, S.HIRE_DATE,'2025-12-29')
ORDER BY (ROUND(SUM(QUANTITY * (1-DISCOUNT) * UNIT_PRICE),0)/timestampdiff(MONTH, S.HIRE_DATE,'2025-12-29')) DESC
;
-- ANSWER B)
WITH rep_base_sales AS (
    SELECT 
        s.rep_id,
        s.rep_name,
        s.hire_date,
        TIMESTAMPDIFF(MONTH, s.hire_date, '2025-12-29') AS period_month,
        ROUND(SUM(o.quantity * (1 - o.discount) * p.unit_price), 0) AS total_revenue
    FROM orders o
    JOIN products p 
        ON o.product_id = p.product_id
    JOIN sales_reps s 
        ON o.rep_id = s.rep_id
    WHERE o.status = 'Completed'
    GROUP BY 
        s.rep_id, 
        s.rep_name, 
        s.hire_date
)
SELECT 
    rep_id,
    rep_name,
    hire_date,
    period_month,
    total_revenue,
    ROUND(total_revenue / period_month, 2) AS avg_productivity_month
FROM rep_base_sales
ORDER BY avg_productivity_month DESC;
-- ==============================================================
-- Q6
-- Write a query that displays a running total of sales revenue generated over time for each sales representative.

SELECT 
	ORDER_ID,
    REP_NAME,
    ORDER_DATE,
	(QUANTITY * (1 - DISCOUNT) * UNIT_PRICE) AS REVENUE ,
	ROUND(SUM(QUANTITY * (1 - DISCOUNT) * UNIT_PRICE) OVER (PARTITION BY REP_NAME ORDER BY ORDER_DATE ASC, ORDER_ID ASC),2) AS RUNNING_REVENUE
FROM ORDERS O
JOIN PRODUCTS P
	ON O.PRODUCT_ID = P.PRODUCT_ID
JOIN sales_reps S
	ON S.REP_ID = O.REP_ID
WHERE STATUS = 'COMPLETED'
ORDER BY 
    S.REP_NAME ASC,
    O.ORDER_DATE ASC,
    O.ORDER_ID ASC;
-- ========================================================================
