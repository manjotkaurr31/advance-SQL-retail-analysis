/*
             - Overall business YoY growth
             - Monthly business momentum
             - Product performance
             - Customer performance
*/
-- Displays year-over-year growth in total business revenue.
WITH yearly_sales AS (
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
)
SELECT
order_year,
total_sales,
LAG(total_sales) OVER (ORDER BY order_year) AS previous_year_sales,
total_sales - LAG(total_sales) OVER (ORDER BY order_year) AS yoy_change
FROM yearly_sales
ORDER BY order_year;
GO

-- Displays month-over-month sales performance across the entire business.
WITH monthly_sales AS (
SELECT
DATETRUNC(MONTH, order_date) AS order_month,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
)
SELECT
order_month,
total_sales,
LAG(total_sales) OVER (ORDER BY order_month) AS previous_month_sales,
total_sales - LAG(total_sales) OVER (ORDER BY order_month) AS mom_change
FROM monthly_sales
ORDER BY order_month;
GO

-- Displays yearly product sales performance compared with the product's historical average and previous year.
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS order_year,
p.product_key,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
YEAR(f.order_date),
p.product_key,
p.product_name
)
SELECT
order_year,
product_key,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_key) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_key) AS diff_from_avg,
CASE
WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_key) THEN 'Above Avg'
WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_key) THEN 'Below Avg'
ELSE 'Avg'
END AS avg_performance,
LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) AS previous_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) AS yoy_change,
CASE
WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) THEN 'Increase'
WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_key ORDER BY order_year) THEN 'Decrease'
ELSE 'No Change'
END AS yoy_trend
FROM yearly_product_sales
ORDER BY product_key, order_year;
GO

-- Displays yearly customer spending and its change compared with the previous year.
WITH yearly_customer_sales AS (
SELECT
YEAR(order_date) AS order_year,
customer_key,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
YEAR(order_date),
customer_key
)
SELECT
order_year,
customer_key,
total_sales,
LAG(total_sales) OVER (PARTITION BY customer_key ORDER BY order_year) AS previous_year_sales,
total_sales - LAG(total_sales) OVER (PARTITION BY customer_key ORDER BY order_year) AS yoy_change
FROM yearly_customer_sales
ORDER BY customer_key, order_year;
GO
