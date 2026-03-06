 /*
            - To compute core business KPIs.
            - To summarize revenue, orders, customers, and operational performance.
            - To detect potential anomalies in sales activity.
*/
-- 1. Total revenue generated from all sales
SELECT 
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;
GO
  
-- 2. Total number of items sold across all orders
SELECT 
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;
GO

-- 3. Average selling price of products
SELECT 
    AVG(price) AS avg_price
FROM gold.fact_sales;
GO

-- 4. Total number of unique orders placed
SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
GO

-- 5. Total number of products available in the catalog
SELECT 
    COUNT(product_key) as total_products
FROM gold.dim_products;
GO

-- 6. Total number of customers in the system
SELECT 
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers;
GO

-- 7. Number of customers who actually placed an order
SELECT 
    COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales;
GO

-- 8. Average revenue generated per order
SELECT 
    SUM(sales_amount)* 1.0/COUNT(DISTINCT order_number) AS avg_order_value
FROM gold.fact_sales;
GO

-- 9. Average number of items purchased in a single order
SELECT 
    SUM(quantity)*1.0/COUNT(DISTINCT order_number) AS avg_items_per_order
FROM gold.fact_sales;
GO

-- 10. Average revenue generated per customer
SELECT 
    SUM(sales_amount)*1.0 /COUNT(DISTINCT customer_key) AS revenue_per_customer
FROM gold.fact_sales;
GO

-- 11. Average cost of products in the catalog
SELECT 
    AVG(cost) AS avg_product_cost
FROM gold.dim_products;
GO

-- 12. Average time taken to ship an order
SELECT 
    AVG(DATEDIFF(day, order_date, shipping_date)) AS avg_shipping_days
FROM gold.fact_sales;
GO

-- 13. Number of orders that were shipped after the due date
SELECT 
    COUNT(*) AS late_orders
FROM gold.fact_sales
WHERE shipping_date>due_date;
GO

-- 14. Combined KPI report (all key metrics in one result table)
SELECT 'Total Sales' AS metric, SUM(sales_amount)AS answer FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity)FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders',COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', COUNT(product_key) FROM gold.dim_products
UNION ALL
SELECT 'Total Customers',COUNT(customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Active Customers', COUNT(DISTINCT customer_key) FROM gold.fact_sales
UNION ALL
SELECT 'Average Order Value', SUM(sales_amount)*1.0/COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Average Items per Order', SUM(quantity)*1.0 /COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Revenue per Customer', SUM(sales_amount)*1.0 /COUNT(DISTINCT customer_key) FROM gold.fact_sales
UNION ALL
SELECT 'Average Shipping Days', AVG(DATEDIFF(day,order_date, shipping_date)) FROM gold.fact_sales;
GO
