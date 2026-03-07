-- Displays the percentage share of customers by country.
SELECT
country,
COUNT(customer_key) AS total_customers,
100.0 * COUNT(customer_key)/ SUM(COUNT(customer_key)) OVER () as pct_customers
FROM gold.dim_customers
GROUP BY country
ORDER by pct_customers DESC;
GO

-- Displays the percentage share of customers by gender.
SELECT
gender,
COUNT(customer_key) AS total_customers,
100.0 * COUNT(customer_key)/SUM(COUNT(customer_key)) OVER () AS pct_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY pct_customers DESC;
GO

-- Displays the percentage share of customers by marital status.
SELECT
marital_status,
COUNT(customer_key) AS total_customers,
100.0 * COUNT(customer_key) /sum(COUNT(customer_key)) OVER () AS pct_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY pct_customers DESC;
GO

-- Displays the percentage share of products by category.
SELECT
category,
COUNT(product_key) AS total_products,
100.0 * COUNT(product_key)/SUM(COUNT(product_key)) OVER () AS pct_products
FROM gold.dim_products
GROUP BY category
ORDER BY pct_products DESC;
GO

-- Displays the percentage share of products by subcategory.
SELECT
subcategory,
COUNT(product_key) AS total_products,
100.0 * COUNT(product_key)/  SUM(COUNT(product_key)) OVER () AS pct_products
FROM gold.dim_products
GROUP BY subcategory
ORDER BY pct_products DESC;
GO

-- Displays the percentage share of total product cost by category.
SELECT
category,
AVG(cost) AS avg_product_cost,
100.0 * AVG(cost)/ SUM(AVG(cost)) OVER () AS pct_cost_share
FROM gold.dim_products
GROUP BY category
ORDER BY pct_cost_share DESC;
GO

-- Displays the percentage contribution of each product category to total revenue.
SELECT
p.category,
SUM(f.sales_amount) AS total_revenue,
100.0 * SUM(f.sales_amount)/SUM(SUM(f.sales_amount)) OVER () AS pct_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key =f.product_key
GROUP BY p.category
ORDER BY pct_revenue DESC;
GO

-- Displays the percentage contribution of each product subcategory to total revenue.
SELECT
p.subcategory,
SUM(f.sales_amount) as total_revenue,
100.0 * SUM(f.sales_amount) / SUM(SUM(f.sales_amount)) OVER () AS pct_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
GROUP BY p.subcategory
ORDER BY pct_revenue DESC;
GO

-- Displays the percentage share of items sold by country.
SELECT
c.country,
SUM(f.quantity) AS total_items_sold,
100.0 * SUM(f.quantity)/ SUM(SUM(f.quantity)) OVER () AS pct_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key  =f.customer_key
GROUP BY c.country
ORDER BY pct_items_sold DESC;
GO

-- Displays the percentage share of items sold by product category.
SELECT
p.category,
SUM(f.quantity) AS total_items_sold,
100.0 * SUM(f.quantity)/SUM(SUM(f.quantity)) OVER () AS pct_items_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
GROUP BY p.category
ORDER BY pct_items_sold DESC;
GO

-- Displays each country's percentage contribution to total revenue.
SELECT
c.country,
SUM(f.sales_amount) AS total_revenue,
100.0 * SUM(f.sales_amount)/SUM(SUM(f.sales_amount)) OVER () AS pct_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key=f.customer_key
GROUP BY c.country
ORDER BY pct_revenue DESC;
GO
