-- Create Database
CREATE DATABASE IF NOT EXISTS large_sales_db;
USE large_sales_db;

-- 1. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE,
    city VARCHAR(50),
    region VARCHAR(20)
);

-- 2. Products Table
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost_price DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

-- 3. Sales Reps Table
CREATE TABLE IF NOT EXISTS sales_reps (
    rep_id INT AUTO_INCREMENT PRIMARY KEY,
    rep_name VARCHAR(100),
    region VARCHAR(20),
    hire_date DATE
);

-- 4. Orders Table (Main Fact Table)
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    rep_id INT,
    product_id INT,
    quantity INT,
    discount DECIMAL(4,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

USE large_sales_db;

-- Clear previous data if needed
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE orders;
TRUNCATE TABLE sales_reps;
TRUNCATE TABLE products;
TRUNCATE TABLE customers;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert Products
INSERT INTO products (product_name, category, cost_price, unit_price) VALUES
('Pro Laptop 15', 'Electronics', 750.00, 1200.00),
('Wireless Ergonomic Mouse', 'Electronics', 15.00, 45.00),
('4K Ultra Monitor 27', 'Electronics', 200.00, 450.00),
('Mechanical Gaming Keyboard', 'Electronics', 40.00, 95.00),
('Noise Cancelling Headphones', 'Electronics', 80.00, 180.00),
('Executive Leather Chair', 'Furniture', 120.00, 310.00),
('Standing Electric Desk', 'Furniture', 250.00, 580.00),
('Modern Bookshelf', 'Furniture', 60.00, 140.00),
('Ergonomic Footrest', 'Furniture', 12.00, 35.00),
('Stainless Steel Water Bottle', 'Accessories', 5.00, 22.00),
('USB-C Multi-Port Hub', 'Accessories', 18.00, 50.00),
('Laptop Backpack 17in', 'Accessories', 22.00, 65.00);

-- Insert Sales Reps
INSERT INTO sales_reps (rep_name, region, hire_date) VALUES
('Sarah Jenkins', 'North', '2021-03-15'),
('Michael Chang', 'North', '2022-01-10'),
('David Ross', 'East', '2020-06-01'),
('Emily Watson', 'East', '2023-02-20'),
('James Miller', 'South', '2019-11-05'),
('Jessica Taylor', 'South', '2022-08-14'),
('Robert Wilson', 'West', '2021-09-01'),
('Amanda Martinez', 'West', '2023-04-12');

-- Insert Sample Customers (10 Representative Customers)
INSERT INTO customers (first_name, last_name, email, signup_date, city, region) VALUES
('John', 'Doe', 'john.doe@example.com', '2022-01-15', 'New York', 'North'),
('Jane', 'Smith', 'jane.smith@example.com', '2022-03-22', 'Boston', 'North'),
('Alex', 'Jones', 'alex.j@domain.org', '2022-05-10', 'Philadelphia', 'East'),
('Maria', 'Garcia', 'm.garcia@company.com', '2022-07-19', 'Miami', 'South'),
('William', 'Brown', 'wbrown@example.com', '2022-09-01', 'Atlanta', 'South'),
('Sophia', 'Davis', 'sdavis@test.io', '2023-01-11', 'Chicago', 'North'),
('Liam', 'Johnson', 'liam.j@example.com', '2023-02-28', 'Dallas', 'South'),
('Emma', 'Wilson', 'e.wilson@domain.net', '2023-04-05', 'Seattle', 'West'),
('Noah', 'Martinez', 'noah.m@example.com', '2023-06-18', 'San Francisco', 'West'),
('Oliver', 'Anderson', 'oliver.a@company.com', '2023-08-22', 'Denver', 'West');


-- Set the session variable cte_max_recursion_depth to a higher number (e.g., 2000) right before running your insert query
SET SESSION cte_max_recursion_depth = 2000;


-- Generate 1,000+ Orders across 2023–2025 using a Recursive CTE
INSERT INTO orders (order_date, customer_id, rep_id, product_id, quantity, discount, status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 1200
)
SELECT 
    -- Generate dates between Jan 1, 2023 and Dec 31, 2025
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 1095) DAY) AS order_date,
    FLOOR(1 + RAND() * 10) AS customer_id,
    FLOOR(1 + RAND() * 8) AS rep_id,
    FLOOR(1 + RAND() * 12) AS product_id,
    FLOOR(1 + RAND() * 10) AS quantity,
    -- Random discounts: 0%, 5%, 10%, or 15%
    ELT(FLOOR(1 + RAND() * 4), 0.00, 0.05, 0.10, 0.15) AS discount,
    -- Order Statuses (with 'Cancelled' and 'Returned' for data cleaning practice)
    ELT(FLOOR(1 + RAND() * 10), 
        'Completed', 'Completed', 'Completed', 'Completed', 'Completed', 
        'Completed', 'Completed', 'Pending', 'Cancelled', 'Returned') AS status
FROM seq;
