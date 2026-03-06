-- Displays yearly sales performance including revenue, units sold, orders, and unique customers.
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_units_sold,
COUNT(order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS unique_customers,
AVG(price) AS avg_selling_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY order_year;
GO

-- Displays quarterly sales performance to observe trends within each year.
SELECT
DATEPART(YEAR, order_date) AS order_year,
DATEPART(QUARTER, order_date) AS order_quarter,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_units,
COUNT(order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
DATEPART(YEAR, order_date),
DATEPART(QUARTER, order_date)
ORDER BY
order_year,
order_quarter;
GO

-- Displays monthly sales and customer activity to analyze chronological business trends.
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
SUM(sales_amount) AS monthly_sales,
SUM(quantity) AS units_sold,
COUNT(order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month;
GO

-- Displays aggregated sales performance by calendar month to observe seasonal patterns.
SELECT
MONTH(order_date) AS month_of_year,
DATENAME(MONTH, order_date) AS month_name,
SUM(sales_amount) AS total_sales,
AVG(sales_amount) AS avg_order_value,
SUM(quantity) AS units_sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
MONTH(order_date),
DATENAME(MONTH, order_date)
ORDER BY month_of_year;
GO

-- Displays the trend of active customers and revenue generation over time.
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
COUNT(DISTINCT customer_key) AS active_customers,
COUNT(order_number) AS total_orders,
SUM(sales_amount) AS revenue_generated
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month;
GO

-- Displays overall product demand over time based on quantity sold.
SELECT
DATETRUNC(MONTH, f.order_date) AS order_month,
SUM(f.quantity) AS total_units_sold,
COUNT(DISTINCT f.product_key) AS unique_products_sold
FROM gold.fact_sales f
WHERE f.order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, f.order_date)
ORDER BY order_month;
GO

-- Displays changes in order fulfillment timelines based on shipping and due dates.
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
AVG(DATEDIFF(day, order_date, shipping_date)) AS avg_shipping_days,
AVG(DATEDIFF(day, order_date, due_date)) AS avg_due_days
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY order_month;
GO
