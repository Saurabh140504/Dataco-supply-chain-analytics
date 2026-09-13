-- SUPPLY CHAIN ANALYTICS PROJECT
-- Database: Supply_Chain
-- Dataset: DataCo Global Order & Logistics

-- 1. DATABASE SETUP
CREATE DATABASE IF NOT EXISTS Supply_Chain;
USE Supply_Chain;

-- 2. CREATE DIMENSION TABLES
-- Date dimension
CREATE TABLE Dim_Date (
    Date DATE PRIMARY KEY,
    Year INT,
    Month INT,
    Quarter VARCHAR(5),
    Week_Number INT,
    Day_Of_Week VARCHAR(15)
);

-- Customer dimension
CREATE TABLE Dim_Customers (
    Customer_ID INT PRIMARY KEY,
    Segment VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Zipcode INT
);

-- Location dimension
CREATE TABLE Dim_Locations (
    Location_ID VARCHAR(20) PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Region VARCHAR(50),
    Market VARCHAR(50)
);

-- Product dimension
CREATE TABLE Dim_Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(150),
    Unit_Price DECIMAL(10,2),
    Category_ID INT,
    Category_Name VARCHAR(100),
    Department_ID INT,
    Department_Name VARCHAR(100),
    Status INT
);

-- Shipping mode dimension
CREATE TABLE Dim_Shipping_Mode (
    Shipping_Mode_ID VARCHAR(20) PRIMARY KEY,
    Shipping_Mode VARCHAR(30)
);

-- 3. CREATE FACT TABLES
-- Order item level fact table
CREATE TABLE Fact_Orders (
    Order_Item_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Customer_ID INT,
    Product_ID INT,
    Location_ID VARCHAR(20),
    Order_Date DATE,
    Quantity INT,
    Item_Price DECIMAL(10,2),
    Discount_Amount DECIMAL(10,2),
    Discount_Rate DECIMAL(6,4),
    Sales_Amount DECIMAL(10,2),
    Order_Item_Total DECIMAL(10,2),
    Profit_Ratio DECIMAL(6,4),
    Profit_Amount DECIMAL(10,2),
    Order_Status VARCHAR(30)
);

-- Shipment level fact table
CREATE TABLE Fact_Shipments (
    Order_Item_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Shipping_Mode_ID VARCHAR(20),
    Order_Date DATE,
    Shipping_Date DATE,
    Days_Shipping_Actual INT,
    Days_Shipping_Scheduled INT,
    Delivery_Status VARCHAR(30),
    Late_Delivery_Risk INT,
    Shipping_Delay_Days INT
);

-- 4. LOAD CSV DATA
SET GLOBAL local_infile = 1;
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- Dimension tables
LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Dim_Date.csv'
INTO TABLE Dim_Date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Dim_Customers.csv'
INTO TABLE Dim_Customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Dim_Locations.csv'
INTO TABLE Dim_Locations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Dim_Products.csv'
INTO TABLE Dim_Products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Dim_Shipping_Mode.csv'
INTO TABLE Dim_Shipping_Mode
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Fact tables
LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Fact_Orders.csv'
INTO TABLE Fact_Orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'C:/CAPSTONE/Supply Chain Analytics Project/Dataset/Fact_Shipments.csv'
INTO TABLE Fact_Shipments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

COMMIT;

SET unique_checks = 1;
SET foreign_key_checks = 1;
SET autocommit = 1;

-- 5. ADD FOREIGN KEY CONSTRAINTS
ALTER TABLE Fact_Orders
    ADD CONSTRAINT fk_orders_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Dim_Customers(Customer_ID),
    ADD CONSTRAINT fk_orders_product
        FOREIGN KEY (Product_ID)
        REFERENCES Dim_Products(Product_ID),
    ADD CONSTRAINT fk_orders_location
        FOREIGN KEY (Location_ID)
        REFERENCES Dim_Locations(Location_ID),
    ADD CONSTRAINT fk_orders_date
        FOREIGN KEY (Order_Date)
        REFERENCES Dim_Date(Date);

ALTER TABLE Fact_Shipments
    ADD CONSTRAINT fk_shipments_mode
        FOREIGN KEY (Shipping_Mode_ID)
        REFERENCES Dim_Shipping_Mode(Shipping_Mode_ID),
    ADD CONSTRAINT fk_shipments_order_date
        FOREIGN KEY (Order_Date)
        REFERENCES Dim_Date(Date),
    ADD CONSTRAINT fk_shipments_shipping_date
        FOREIGN KEY (Shipping_Date)
        REFERENCES Dim_Date(Date),
    ADD CONSTRAINT fk_shipments_order_item
        FOREIGN KEY (Order_Item_ID)
        REFERENCES Fact_Orders(Order_Item_ID);

-- 6. DATA VALIDATION
-- Row counts
SELECT COUNT(*) AS Date_Rows FROM Dim_Date;
SELECT COUNT(*) AS Customer_Rows FROM Dim_Customers;
SELECT COUNT(*) AS Location_Rows FROM Dim_Locations;
SELECT COUNT(*) AS Product_Rows FROM Dim_Products;
SELECT COUNT(*) AS Shipping_Mode_Rows FROM Dim_Shipping_Mode;
SELECT COUNT(*) AS Order_Rows FROM Fact_Orders;
SELECT COUNT(*) AS Shipment_Rows FROM Fact_Shipments;

-- Check LOCAL INFILE status
SHOW VARIABLES LIKE 'local_infile';

-- Check customer ZIP codes
SELECT COUNT(*) AS Null_Zipcode
FROM Dim_Customers
WHERE Zipcode IS NULL;

SELECT COUNT(*) AS Zero_Zipcode
FROM Dim_Customers
WHERE Zipcode = 0;

SELECT Customer_ID, Segment, City, State, Country, Zipcode
FROM Dim_Customers
WHERE Zipcode = 0;

-- Convert zero ZIP codes to NULL
SET SQL_SAFE_UPDATES = 0;

UPDATE Dim_Customers
SET Zipcode = NULL
WHERE Zipcode = 0;

SET SQL_SAFE_UPDATES = 1;

-- Recheck ZIP codes after cleaning
SELECT COUNT(*) AS Null_Zipcode
FROM Dim_Customers
WHERE Zipcode IS NULL;

SELECT COUNT(*) AS Zero_Zipcode
FROM Dim_Customers
WHERE Zipcode = 0;

-- Duplicate check
SELECT Order_Item_ID, COUNT(*) AS duplicate_count
FROM Fact_Orders
GROUP BY Order_Item_ID
HAVING COUNT(*) > 1;

-- Invalid-value checks
SELECT COUNT(*) AS negative_quantity
FROM Fact_Orders
WHERE Quantity <= 0;

SELECT COUNT(*) AS negative_price
FROM Fact_Orders
WHERE Item_Price < 0;

SELECT COUNT(*) AS invalid_shipping_dates
FROM Fact_Shipments
WHERE Shipping_Date < Order_Date;

-- 7. DELIVERY PERFORMANCE ANALYSIS
-- Overall late-delivery rate
SELECT
    ROUND(
        SUM(CASE WHEN Late_Delivery_Risk = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_delivery_pct
FROM Fact_Shipments;

-- Late-delivery rate by shipping mode
SELECT
    sm.Shipping_Mode,
    COUNT(*) AS total_shipments,
    SUM(fs.Late_Delivery_Risk) AS late_shipments,
    ROUND(SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*), 2) AS late_pct
FROM Fact_Shipments fs
JOIN Dim_Shipping_Mode sm
    ON fs.Shipping_Mode_ID = sm.Shipping_Mode_ID
GROUP BY sm.Shipping_Mode
ORDER BY late_pct DESC;

-- Late-delivery rate by region and market
SELECT
    dl.Region,
    dl.Market,
    COUNT(*) AS total_shipments,
    ROUND(SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*), 2) AS late_pct
FROM Fact_Shipments fs
JOIN Fact_Orders fo
    ON fs.Order_Item_ID = fo.Order_Item_ID
JOIN Dim_Locations dl
    ON fo.Location_ID = dl.Location_ID
GROUP BY dl.Region, dl.Market
ORDER BY late_pct DESC;

-- Average shipping delay
SELECT
    ROUND(AVG(Shipping_Delay_Days), 2) AS avg_delay_days_overall
FROM Fact_Shipments;

-- Average shipping delay by shipping mode
SELECT
    sm.Shipping_Mode,
    ROUND(AVG(fs.Shipping_Delay_Days), 2) AS avg_delay_days
FROM Fact_Shipments fs
JOIN Dim_Shipping_Mode sm
    ON fs.Shipping_Mode_ID = sm.Shipping_Mode_ID
GROUP BY sm.Shipping_Mode
ORDER BY avg_delay_days DESC;

-- Shipping-mode reliability ranking
SELECT
    sm.Shipping_Mode,
    ROUND(SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*), 2) AS late_pct,
    RANK() OVER (
        ORDER BY SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*) ASC
    ) AS reliability_rank
FROM Fact_Shipments fs
JOIN Dim_Shipping_Mode sm
    ON fs.Shipping_Mode_ID = sm.Shipping_Mode_ID
GROUP BY sm.Shipping_Mode
ORDER BY reliability_rank;

-- Monthly late-delivery rate
SELECT
    dd.Year,
    dd.Month,
    COUNT(*) AS total_shipments,
    ROUND(SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*), 2) AS late_pct
FROM Fact_Shipments fs
JOIN Dim_Date dd
    ON fs.Order_Date = dd.Date
GROUP BY dd.Year, dd.Month
ORDER BY dd.Year, dd.Month;

-- Region ranking by late-delivery rate
SELECT
    dl.Region,
    ROUND(SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*), 2) AS late_pct,
    RANK() OVER (
        ORDER BY SUM(fs.Late_Delivery_Risk) * 100.0 / COUNT(*) DESC
    ) AS worst_region_rank
FROM Fact_Shipments fs
JOIN Fact_Orders fo
    ON fs.Order_Item_ID = fo.Order_Item_ID
JOIN Dim_Locations dl
    ON fo.Location_ID = dl.Location_ID
GROUP BY dl.Region
ORDER BY worst_region_rank;

-- 8. ORDER STATUS AND RISK ANALYSIS
-- Order-status distribution
SELECT
    Order_Status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Fact_Orders),
        2
    ) AS pct
FROM Fact_Orders
GROUP BY Order_Status
ORDER BY order_count DESC;

-- Overall risk-status rate
SELECT
    ROUND(
        SUM(
            CASE
                WHEN Order_Status IN (
                    'CANCELED',
                    'SUSPECTED_FRAUD',
                    'ON_HOLD',
                    'PAYMENT_REVIEW'
                )
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS risk_status_pct
FROM Fact_Orders;

-- Fraud rate by region and market
SELECT
    dl.Region,
    dl.Market,
    SUM(CASE WHEN fo.Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END) AS fraud_orders,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(CASE WHEN fo.Order_Status = 'SUSPECTED_FRAUD' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS fraud_pct
FROM Fact_Orders fo
JOIN Dim_Locations dl
    ON fo.Location_ID = dl.Location_ID
GROUP BY dl.Region, dl.Market
ORDER BY fraud_pct DESC;

-- Risk rate by customer segment
SELECT
    dc.Segment,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(
            CASE
                WHEN fo.Order_Status IN (
                    'CANCELED',
                    'SUSPECTED_FRAUD',
                    'ON_HOLD',
                    'PAYMENT_REVIEW'
                )
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS risk_pct
FROM Fact_Orders fo
JOIN Dim_Customers dc
    ON fo.Customer_ID = dc.Customer_ID
GROUP BY dc.Segment
ORDER BY risk_pct DESC;

-- Risk rate by region using CTEs
WITH region_totals AS (
    SELECT
        dl.Region,
        COUNT(*) AS total_orders
    FROM Fact_Orders fo
    JOIN Dim_Locations dl
        ON fo.Location_ID = dl.Location_ID
    GROUP BY dl.Region
),
region_risk AS (
    SELECT
        dl.Region,
        COUNT(*) AS risk_orders
    FROM Fact_Orders fo
    JOIN Dim_Locations dl
        ON fo.Location_ID = dl.Location_ID
    WHERE fo.Order_Status IN (
        'CANCELED',
        'SUSPECTED_FRAUD',
        'ON_HOLD',
        'PAYMENT_REVIEW'
    )
    GROUP BY dl.Region
)
SELECT
    rt.Region,
    rt.total_orders,
    COALESCE(rr.risk_orders, 0) AS risk_orders,
    ROUND(
        COALESCE(rr.risk_orders, 0) * 100.0 / rt.total_orders,
        2
    ) AS risk_pct
FROM region_totals rt
LEFT JOIN region_risk rr
    ON rt.Region = rr.Region
ORDER BY risk_pct DESC;

-- Cancellation/fraud rate by shipping mode
SELECT
    sm.Shipping_Mode,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(
            CASE
                WHEN fo.Order_Status IN ('CANCELED', 'SUSPECTED_FRAUD')
                THEN 1 ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS risk_pct
FROM Fact_Orders fo
JOIN Fact_Shipments fs
    ON fo.Order_Item_ID = fs.Order_Item_ID
JOIN Dim_Shipping_Mode sm
    ON fs.Shipping_Mode_ID = sm.Shipping_Mode_ID
GROUP BY sm.Shipping_Mode
ORDER BY risk_pct DESC;

-- 9. SALES AND PROFITABILITY ANALYSIS
-- Sales and profit by category
SELECT
    dp.Category_Name,
    ROUND(SUM(fo.Sales_Amount), 2) AS total_sales,
    ROUND(SUM(fo.Profit_Amount), 2) AS total_profit
FROM Fact_Orders fo
JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Category_Name
ORDER BY total_sales DESC;

-- Profit margin by category
SELECT
    dp.Category_Name,
    ROUND(SUM(fo.Sales_Amount), 2) AS total_sales,
    ROUND(
        SUM(fo.Profit_Amount) / SUM(fo.Sales_Amount) * 100,
        2
    ) AS profit_margin_pct
FROM Fact_Orders fo
JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Category_Name
ORDER BY total_sales DESC;

-- Loss-making order lines by category
SELECT
    dp.Category_Name,
    SUM(CASE WHEN fo.Profit_Amount < 0 THEN 1 ELSE 0 END) AS loss_making_lines,
    COUNT(*) AS total_lines,
    ROUND(
        SUM(CASE WHEN fo.Profit_Amount < 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS loss_pct
FROM Fact_Orders fo
JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Category_Name
ORDER BY loss_making_lines DESC;

-- Profitability by department
SELECT
    dp.Department_Name,
    ROUND(SUM(fo.Sales_Amount), 2) AS total_sales,
    ROUND(
        SUM(fo.Profit_Amount) / SUM(fo.Sales_Amount) * 100,
        2
    ) AS profit_margin_pct
FROM Fact_Orders fo

JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Department_Name
ORDER BY total_sales DESC;

-- Categories with above-average sales and below-average margin
WITH category_stats AS (
    SELECT
        dp.Category_Name,
        SUM(fo.Sales_Amount) AS total_sales,
        SUM(fo.Profit_Amount) / SUM(fo.Sales_Amount) * 100 AS margin_pct
    FROM Fact_Orders fo
    JOIN Dim_Products dp
        ON fo.Product_ID = dp.Product_ID
    GROUP BY dp.Category_Name
)
SELECT
    Category_Name,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(margin_pct, 2) AS margin_pct
FROM category_stats
WHERE total_sales > (SELECT AVG(total_sales) FROM category_stats)
  AND margin_pct < (SELECT AVG(margin_pct) FROM category_stats)
ORDER BY total_sales DESC;

-- Sales rank versus margin rank by category
SELECT
    dp.Category_Name,
    RANK() OVER (
        ORDER BY SUM(fo.Sales_Amount) DESC
    ) AS sales_rank,
    RANK() OVER (
        ORDER BY SUM(fo.Profit_Amount) / SUM(fo.Sales_Amount) DESC
    ) AS margin_rank
FROM Fact_Orders fo
JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Category_Name
ORDER BY sales_rank;

-- Categories with more than 3,000 loss-making order lines
SELECT
    dp.Category_Name,
    SUM(CASE WHEN fo.Profit_Amount < 0 THEN 1 ELSE 0 END) AS loss_making_lines
FROM Fact_Orders fo
JOIN Dim_Products dp
    ON fo.Product_ID = dp.Product_ID
GROUP BY dp.Category_Name
HAVING SUM(CASE WHEN fo.Profit_Amount < 0 THEN 1 ELSE 0 END) > 3000
ORDER BY loss_making_lines DESC;

-- 10. CANCELLATION ANALYSIS
-- Sales and profit value of cancelled order lines
SELECT
    COUNT(*) AS cancelled_lines,
    ROUND(SUM(Sales_Amount), 2) AS total_sales_cancelled,
    ROUND(SUM(Profit_Amount), 2) AS total_profit_cancelled
FROM Fact_Orders
WHERE Order_Status = 'CANCELED';

-- Cancellation rate by region and market
SELECT
    dl.Region,
    dl.Market,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(CASE WHEN fo.Order_Status = 'CANCELED' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS cancel_pct
FROM Fact_Orders fo
JOIN Dim_Locations dl
    ON fo.Location_ID = dl.Location_ID
GROUP BY dl.Region, dl.Market
ORDER BY cancel_pct DESC;

-- Cancellation rate by shipping mode
SELECT
    sm.Shipping_Mode,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(CASE WHEN fo.Order_Status = 'CANCELED' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS cancel_pct
FROM Fact_Orders fo
JOIN Fact_Shipments fs
    ON fo.Order_Item_ID = fs.Order_Item_ID
JOIN Dim_Shipping_Mode sm
    ON fs.Shipping_Mode_ID = sm.Shipping_Mode_ID
GROUP BY sm.Shipping_Mode
ORDER BY cancel_pct DESC;

-- Cancellation rate by order-value bucket
SELECT
    CASE
        WHEN Sales_Amount < 100 THEN 'Low (<100)'
        WHEN Sales_Amount < 300 THEN 'Medium (100-300)'
        ELSE 'High (300+)'
    END AS value_bucket,
    COUNT(*) AS total_orders,
    ROUND(
        SUM(CASE WHEN Order_Status = 'CANCELED' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS cancel_pct
FROM Fact_Orders
GROUP BY value_bucket
ORDER BY cancel_pct DESC;

-- Monthly cancelled sales and running total
SELECT
    dd.Year,
    dd.Month,
    ROUND(SUM(fo.Sales_Amount), 2) AS monthly_cancelled_sales,
    ROUND(
        SUM(SUM(fo.Sales_Amount)) OVER (
            ORDER BY dd.Year, dd.Month
        ),
        2
    ) AS running_total_cancelled_sales
FROM Fact_Orders fo
JOIN Dim_Date dd
    ON fo.Order_Date = dd.Date
WHERE fo.Order_Status = 'CANCELED'
GROUP BY dd.Year, dd.Month
ORDER BY dd.Year, dd.Month;