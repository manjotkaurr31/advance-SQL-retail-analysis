-- cumulative revenue growth over time using a running total of monthly sales
SELECT
order_month,
total_sales,
SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales
FROM
(
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
where order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
) t
ORDER BY order_month;
GO

-- cumulative order volume over time using a running total of monthly orders
SELECT
order_month,
total_orders,
SUM(total_orders) OVER (ORDER BY order_month) AS running_total_orders
FROM
(
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
COUNT(order_number) AS total_orders
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
) t
ORDER BY order_month;
GO

-- moving average of monthly sales
SELECT
order_month,
total_sales,
AVG(total_sales) OVER (
ORDER BY order_month
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_avg_3_month_sales
FROM
(
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date is not null
GROUP BY DATETRUNC(MONTH, order_date)
) t
ORDER BY order_month;
GO
