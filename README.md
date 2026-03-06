# 📊 Advanced SQL Retail Analysis

## 🧾 Project Overview

This project demonstrates **advanced SQL techniques** for analyzing retail sales data.  
It simulates a modern analytics workflow using a **layered data architecture** and multiple analytical modules.

The project explores:

- 🔎 database exploration  
- 🧩 dimensional analysis  
- 📈 cumulative metrics  
- 🏆 ranking and performance analysis  
- 🧠 segmentation  
- 👥 customer analytics  
- 📦 product analytics  

The goal is to transform **raw retail transaction data** into meaningful **business insights using SQL**.

---

# 🗂️ Project Structure
```text
advanced-sql-retail-analysis
│
├── analysis
│   ├── 01_database_exploration.sql
│   ├── 02_dimension_exploration.sql
│   ├── 03_measures_exploration.sql
│   ├── 04_magnitude_analysis.sql
│   ├── 05_cumulative_analysis.sql
│   ├── 06_rank_analysis.sql
│   ├── 07_part_to_whole_analysis.sql
│   ├── 08_data_segmentation.sql
│   ├── 09_performance_analysis.sql
│   ├── 10_change_over_time_analysis.sql
│   ├── customer_report.sql
│   └── product_report.sql
│
├── datasets
│   ├── bronze
│   ├── silver
│   └── gold
│       ├── dim_customers.csv
│       ├── dim_products.csv
│       └── fact_sales.csv
│
├── results
│   ├── customer_report.csv
│   └── product_report.csv
│
├── scripts
│   ├── bronze_01.sql
│   ├── silver_02.sql
│   ├── gold_03.sql
│   └── init_db.sql
│
└── README.md
```
---

# 🏗️ Data Architecture

This project follows a **Medallion Architecture** commonly used in modern data platforms.

### 🥉 Bronze Layer
Raw ingested data with minimal transformation.

### 🥈 Silver Layer
Cleaned, standardized, and structured datasets.

### 🥇 Gold Layer
Business-ready dimensional model used for analytics.

Tables in the **Gold Layer**:

- 👥 `dim_customers`
- 📦 `dim_products`
- 💰 `fact_sales`

This layer supports **analytical queries, reporting, and KPI generation**.

---

# 📊 Analytical Modules

The `analysis` folder contains SQL modules focusing on different analytical perspectives.

### 🔍 Database Exploration
Explores schema structure and table contents.

### 🧩 Dimension Exploration
Analyzes categorical fields such as customers, products, and categories.

### 📏 Measures Exploration
Investigates key metrics like sales, quantity, and revenue.

### 📐 Magnitude Analysis
Quantifies the scale of business activity across business dimensions.

### 📈 Cumulative Analysis
Calculates running totals and moving averages for key metrics.

### 🏆 Rank Analysis
Ranks products, customers, and categories based on performance.

### 🧮 Part-to-Whole Analysis
Measures the percentage contribution of segments to overall totals.

### 🧠 Data Segmentation
Groups customers and products into meaningful behavioral segments.

### 🚀 Performance Analysis
Evaluates **Year-over-Year (YoY)** and **Month-over-Month (MoM)** business performance.

### ⏳ Change Over Time Analysis
Analyzes trends, seasonality, and growth patterns in business activity.

---

# 📑 Reporting Views

Two analytical reporting views summarize business performance.

### 👥 Customer Report

Provides customer-level metrics including:

- total orders  
- total revenue  
- total quantity purchased  
- product diversity  
- customer lifespan  
- recency (months since last order)  
- average order value  
- average monthly spend  

---

### 📦 Product Report

Provides product-level performance metrics such as:

- total orders  
- total customers  
- total sales  
- total quantity sold  
- product lifespan  
- product recency  
- average selling price  
- average order revenue  
- average monthly revenue  

---

# 📁 Results

Generated reports are exported to the `results` folder:

- 📄 `customer_report.csv`
- 📄 `product_report.csv`

These files contain **aggregated analytical outputs** derived from SQL views.

---

# ⚙️ Technologies Used

- 🗄️ SQL Server  
- 💻 T-SQL  
- 🧱 Dimensional Modeling  
- 📊 Analytical SQL (Window Functions, Aggregations, CTEs)

---

# ▶️ How to Run the Project

### 1️⃣ Initialize the database

Run:

scripts/init_db.sql

### 2️⃣ Build the data layers

Run:

scripts/bronze_01.sql  
scripts/silver_02.sql  
scripts/gold_03.sql  

### 3️⃣ Run analytical queries

Execute SQL files inside the **analysis** directory.

### 4️⃣ Generate reports

Run:

analysis/customer_report.sql  
analysis/product_report.sql  

---

# 🧠 Key SQL Concepts Demonstrated

- Common Table Expressions (CTEs)
- Window Functions
- Ranking Functions
- Time-Based Analysis
- Segmentation Techniques
- Aggregation Methods
- Dimensional Joins

---

# 🎯 Project Purpose

This project demonstrates how SQL can transform **transactional retail data** into **structured analytical insights** using industry-style **data modeling, analytical querying, and reporting practices**.
