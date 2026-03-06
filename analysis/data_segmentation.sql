-- Displays the distribution of products across predefined cost ranges.
WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE
WHEN cost < 100 THEN 'Below 100'
WHEN cost BETWEEN 100 AND 500 THEN '100-500'
WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;
GO

-- Displays the number of customers within each spending-based segment.
WITH customer_spending AS (
SELECT
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM (
SELECT
customer_key,
CASE
WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
ELSE 'New'
END AS customer_segment
FROM customer_spending
) segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
GO

-- Displays the distribution of orders across different order value ranges.
SELECT
CASE
WHEN sales_amount < 100 THEN 'Small Order'
WHEN sales_amount BETWEEN 100 AND 500 THEN 'Medium Order'
WHEN sales_amount BETWEEN 500 AND 1000 THEN 'Large Order'
ELSE 'Very Large Order'
END AS order_segment,
COUNT(order_number) AS total_orders
FROM gold.fact_sales
GROUP BY
CASE
WHEN sales_amount < 100 THEN 'Small Order'
WHEN sales_amount BETWEEN 100 AND 500 THEN 'Medium Order'
WHEN sales_amount BETWEEN 500 AND 1000 THEN 'Large Order'
ELSE 'Very Large Order'
END
ORDER BY total_orders DESC;
GO

-- Displays customer distribution across age groups.
SELECT
CASE
WHEN DATEDIFF(year, birthdate, GETDATE()) < 25 THEN 'Under 25'
WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 25 AND 40 THEN '25-40'
WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 40 AND 60 THEN '40-60'
ELSE '60+'
END AS age_group,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
WHERE birthdate IS NOT NULL
GROUP BY
CASE
WHEN DATEDIFF(year, birthdate, GETDATE()) < 25 THEN 'Under 25'
WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 25 AND 40 THEN '25-40'
WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 40 AND 60 THEN '40-60'
ELSE '60+'
END
ORDER BY total_customers DESC;
GO

-- Displays customer segmentation into spending quartiles using NTILE.
WITH customer_total_spending AS (
SELECT
customer_key,
SUM(sales_amount) AS total_spending
FROM gold.fact_sales
GROUP BY customer_key
)
SELECT
customer_key,
total_spending,
NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartile
FROM customer_total_spending
ORDER BY spending_quartile, total_spending DESC;
GO
