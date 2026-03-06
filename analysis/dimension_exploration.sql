-- 1. Customer countries
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;
GO

-- 2. Customer gender categories
SELECT DISTINCT
    gender
FROM gold.dim_customers
ORDER BY gender;
GO

-- 3. Customer marital status categories
SELECT DISTINCT
    marital_status
FROM gold.dim_customers
ORDER BY marital_status;
GO

-- 4.Customer acquisition dates (customer creation timeline)
SELECT DISTINCT
    create_date
FROM gold.dim_customers
ORDER BY create_date;
GO

--5. Customer birthdates (can later derive age groups)
SELECT DISTINCT
    birthdate
FROM gold.dim_customers
ORDER BY birthdate;
GO

--6.Product categories
SELECT DISTINCT
    category
FROM gold.dim_products
ORDER BY category;
GO

--7. Product subcategories
SELECT DISTINCT
    subcategory
FROM gold.dim_products
ORDER BY subcategory;
GO

-- 8.Product hierarchy (category → subcategory → product)
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
GO

-- 9Product lines
SELECT DISTINCT
    product_line
FROM gold.dim_products
ORDER BY product_line;
GO

-- 10.Product maintenance types
SELECT DISTINCT
    maintenance
FROM gold.dim_products
ORDER BY maintenance;
GO

-- 11. Order date range
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM gold.fact_sales;
GO

--12. Shipping date range
SELECT
    MIN(shipping_date) AS earliest_shipping_date,
    MAX(shipping_date) AS latest_shipping_date
FROM gold.fact_sales;
GO

--13. Due date range
SELECT
    MIN(due_date) AS earliest_due_date,
    MAX(due_date) AS latest_due_date
FROM gold.fact_sales;
GO
