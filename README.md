# MySQL Sales Analytics & Window Functions

A comprehensive SQL portfolio project demonstrating advanced analytical queries, data transformation, and window functions using MySQL 8.0.

---

## 📌 Project Overview
This project focuses on analyzing transactional sales data to extract actionable business insights. Key techniques demonstrated include date casting/cleaning, aggregate reporting, CTEs (Common Table Expressions), and window functions like `LAG()` and `DENSE_RANK()`.

---

## 🛠️ Key Topics & SQL Techniques Covered

1. **Data Cleaning & Type Casting:**
   - Converting string dates to standard SQL `DATE` format using `STR_TO_DATE()` and `ALTER TABLE`.

2. **Aggregation & Grouping:**
   - Finding top-performing product categories by total revenue.
   - Summarizing monthly sales trends using `DATE_FORMAT()`.

3. **Window Functions (`LAG` & `DENSE_RANK`):**
   - **Month-over-Month (MoM) Difference:** Comparing current monthly total revenue against previous months.
   - **Category-Specific Metrics:** Partitioning by category to calculate category-level revenue shifts.
   - **Percentage Growth:** Calculating exact percentage growth rates month-over-month.
   - **Time Gap Analysis:** Calculating days elapsed between consecutive regional sales using `DATEDIFF()` and `LAG()`.
   - **Top-N Ranking:** Utilizing `DENSE_RANK()` within CTEs to identify the top 2 revenue transactions per region.

---

## 📁 Repository Structure

```text
├── README.md        # Project documentation and summary
└── solutions.sql    # Complete SQL script with annotated queries
