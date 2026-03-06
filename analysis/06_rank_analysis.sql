/*
   top and bottom performers across products, customers, categories and counntries. 
*/

-- Displays product revenue ranking across all products.
SELECT
p.product_name,
SUM(f.sales_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS revenue_rank
FROM gold.fact_sales f
JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY revenue_rank;
GO

-- Displays product demand ranking based on quantity sold.
SELECT
p.product_name,
SUM(f.quantity) AS total_quantity_sold,
RANK() OVER (ORDER BY SUM(f.quantity) DESC) AS quantity_rank
FROM gold.fact_sales f
JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY quantity_rank;
GO

-- Displays customer revenue ranking across all customers.
SELECT
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS customer_rank
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY customer_rank;
GO

-- Displays category revenue ranking across product categories.
SELECT
p.category,
SUM(f.sales_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS category_rank
FROM gold.fact_sales f
JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY category_rank;
GO

-- Displays country revenue ranking across all customer countries.
SELECT
c.country,
SUM(f.sales_amount) AS total_revenue,
RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS country_rank
FROM gold.fact_sales f
JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY country_rank;
GO

