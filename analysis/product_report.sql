IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
/* Base query retrieving core sales and product data */
SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
),

product_aggregations AS (
/* Product-level aggregation of sales metrics */
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    SUM(sales_amount)/NULLIF(SUM(quantity),0) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
)
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_sale_date,
DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,
CASE
    WHEN total_sales>50000 THEN 'High-Performer'
    WHEN total_sales >=10000 THEN 'Mid-Range'
    ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- Average order revenue
total_sales/NULLIF(total_orders,0) AS avg_order_revenue,
-- Average monthly revenue
CASE
    WHEN lifespan= 0 THEN total_sales
    ELSE total_sales/lifespan
END AS avg_monthly_revenue

FROM product_aggregations;
GO
