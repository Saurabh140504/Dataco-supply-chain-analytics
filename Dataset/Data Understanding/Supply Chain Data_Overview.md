# Data Overview

## 1. Project Title

**Supply Chain Analytics Project — DataCo Global Order & Logistics Data (2015–2018)**

---

## 2. Dataset Source

* **Dataset:** DataCo Smart Supply Chain for Big Data Analysis
* **Source:** Public Kaggle dataset based on DataCo Global historical order and logistics data
* **Data period:** January 1, 2015 to February 6, 2018
* **Dataset type:** Historical company order and shipping data
* **Current structure:** The original 53-column dataset has been cleaned and divided into 7 tables using a star-schema structure.
* **Customer information:** Customer name, email, password, and street address were removed during data preparation.

The final dataset contains 5 dimension tables and 2 fact tables.

---

## 3. Business Context

DataCo Global operates an international order and distribution business.

The dataset contains orders shipped across:

* **5 markets:** Pacific Asia, USCA, Africa, Europe, LATAM
* **23 regions**
* **4 shipping modes:** First Class, Second Class, Standard Class, Same Day
* **118 products**
* **50 categories**
* **11 departments**

The data provides information about orders, customers, products, locations, shipping modes, delivery performance, sales, discounts, and profit.

The project focuses on understanding delivery performance, fulfillment issues, profitability, and order cancellations.

---

## 4. Dataset Overview

The cleaned dataset is divided into the following 7 CSV files:

| File                  |    Rows | Columns |
| --------------------- | ------: | ------: |
| Dim_Customers.csv     |  20,652 |       6 |
| Dim_Date.csv          |   1,133 |       6 |
| Dim_Locations.csv     |   3,772 |       6 |
| Dim_Products.csv      |     118 |       8 |
| Dim_Shipping_Mode.csv |       4 |       2 |
| Fact_Orders.csv       | 180,519 |      15 |
| Fact_Shipments.csv    | 180,519 |      10 |

### Data Types

**Integer fields**

`Customer_ID`, `Product_ID`, `Category_ID`, `Department_ID`, `Order_ID`, `Order_Item_ID`, `Quantity`, `Late_Delivery_Risk`, `Status`

**Text fields**

`Location_ID`, `Shipping_Mode_ID`, `Segment`, `City`, `State`, `Country`, `Region`, `Market`, `Category_Name`, `Department_Name`, `Order_Status`, `Delivery_Status`

**Numeric fields**

`Unit_Price`, `Item_Price`, `Discount_Amount`, `Discount_Rate`, `Sales_Amount`, `Order_Item_Total`, `Profit_Ratio`, `Profit_Amount`, `Zipcode`

**Date fields**

`Date`, `Order_Date`, `Shipping_Date`

### Date Range

* `Dim_Date`: 2015-01-01 to 2018-02-06
* `Fact_Orders.Order_Date`: 2015-01-01 to 2018-01-31
* `Fact_Shipments.Shipping_Date`: 2015-01-03 to 2018-02-06

The shipment date extends beyond the last order date because orders placed toward the end of January can be shipped in early February.

---

## 5. Data Grain

### Fact_Orders

Each row represents **one order line item**.

`Order_Item_ID` is unique across all 180,519 rows.

The 180,519 order line items belong to **65,752 unique orders**.

This means one order can contain multiple products or line items.

### Fact_Shipments

Each row represents the shipment information for one order line item.

`Order_Item_ID` is also unique in this table and matches the `Order_Item_ID` in `Fact_Orders`.

The two fact tables can therefore be joined using:

`Order_Item_ID`

### Dimension Tables

* `Dim_Customers` — one row per customer
* `Dim_Products` — one row per product
* `Dim_Locations` — one row per unique destination location
* `Dim_Shipping_Mode` — one row per shipping mode
* `Dim_Date` — one row per calendar date

### Importance of Grain

The fact tables are at the **order-line level**, not the order level.

For example, calculating average order value directly from `Fact_Orders` would give an incorrect result because an order can contain multiple line items.

Order-level calculations should first aggregate the data using `Order_ID`.

---

## 6. Data Dictionary

### Dim_Customers

| Column      | Data Type | Description                 | Example     | Analysis Use              |
| ----------- | --------- | ---------------------------- | ----------- | -------------------------- |
| Customer_ID | Integer   | Unique customer ID          | 1, 2, 3     | Join key                  |
| Segment     | Text      | Customer segment            | Consumer    | Segment analysis          |
| City        | Text      | Customer city               | Brownsville | Customer geography        |
| State       | Text      | Customer state               | TX          | Customer geography        |
| Country     | Text      | Registered customer country | EE. UU.     | Limited geographic use    |
| Zipcode     | Float     | Customer ZIP code           | 78521.0     | Not used in core analysis |

### Dim_Date

| Column      | Data Type | Description      | Example    | Analysis Use       |
| ----------- | --------- | ------------------ | ---------- | ------------------- |
| Date        | Date      | Calendar date    | 2015-01-01 | Time analysis      |
| Year        | Integer   | Calendar year    | 2015       | Yearly trends      |
| Month       | Integer   | Calendar month   | 1–12       | Monthly trends     |
| Quarter     | Text      | Calendar quarter | Q1         | Quarterly analysis |
| Week_Number | Integer   | Week number      | 1–53       | Weekly analysis    |
| Day_Of_Week | Text      | Day name         | Thursday   | Weekday analysis   |

### Dim_Locations

| Column      | Data Type | Description                | Example         | Analysis Use        |
| ----------- | --------- | ----------------------------- | --------------- | -------------------- |
| Location_ID | Text      | Location key               | LOC-00001       | Join key            |
| City        | Text      | Destination city           | Bekasi          | Geographic analysis |
| State       | Text      | Destination state/province | Java Occidental | Geographic analysis |
| Country     | Text      | Destination country        | Indonesia       | Geographic analysis |
| Region      | Text      | Destination region         | Southeast Asia  | Regional analysis   |
| Market      | Text      | Market grouping            | Pacific Asia    | Market analysis     |

### Dim_Products

| Column          | Data Type | Description        | Example                                 | Analysis Use             |
| --------------- | --------- | -------------------- | ---------------------------------------- | ------------------------- |
| Product_ID      | Integer   | Product ID         | 19                                      | Join key                 |
| Product_Name    | Text      | Product name       | Nike Men's Fingertrap Max Training Shoe | Product analysis         |
| Unit_Price      | Float     | Catalog price      | 124.99                                  | Price analysis           |
| Category_ID     | Integer   | Category ID        | 2                                       | Grouping                 |
| Category_Name   | Text      | Product category   | Soccer                                  | Category profitability   |
| Department_ID   | Integer   | Department ID      | 2                                       | Grouping                 |
| Department_Name | Text      | Product department | Fitness                                 | Department profitability |
| Status          | Integer   | Product status     | 0                                       | Not used in analysis     |

### Dim_Shipping_Mode

| Column           | Data Type | Description       | Example     | Analysis Use      |
| ---------------- | --------- | -------------------- | ----------- | ------------------- |
| Shipping_Mode_ID | Text      | Shipping mode key | SHP-1       | Join key          |
| Shipping_Mode    | Text      | Shipping service  | First Class | Shipping analysis |

### Fact_Orders

| Column           | Data Type | Description                     | Example    | Analysis Use         |
| ---------------- | --------- | ---------------------------------- | ---------- | ---------------------- |
| Order_Item_ID    | Integer   | Order line item ID              | 180517     | Primary key          |
| Order_ID         | Integer   | Order ID                        | 77202      | Order-level analysis |
| Customer_ID      | Integer   | Customer ID                     | 20755      | Customer analysis    |
| Product_ID       | Integer   | Product ID                      | 1360       | Product analysis     |
| Location_ID      | Text      | Destination location            | LOC-00001  | Location analysis    |
| Order_Date       | Date      | Order date                      | 2018-01-31 | Time analysis        |
| Quantity         | Integer   | Units ordered                   | 1          | Volume analysis      |
| Item_Price       | Float     | Price per unit                  | 327.75     | Revenue analysis     |
| Discount_Amount  | Float     | Discount amount                 | 13.11      | Discount analysis    |
| Discount_Rate    | Float     | Discount percentage             | 0.04       | Discount analysis    |
| Sales_Amount     | Float     | Sales before discount           | 327.75     | Revenue analysis     |
| Order_Item_Total | Float     | Sales after discount            | 314.64     | Net revenue          |
| Profit_Ratio     | Float     | Profit as a percentage of sales | 0.29       | Profitability        |
| Profit_Amount    | Float     | Profit amount                   | 91.25      | Profitability        |
| Order_Status     | Text      | Order status                    | COMPLETE   | Fulfillment analysis |

### Fact_Shipments

| Column                  | Data Type | Description                 | Example       | Analysis Use         |
| ----------------------- | --------- | ------------------------------ | ------------- | ---------------------- |
| Order_Item_ID           | Integer   | Order line item ID          | 180517        | Primary key          |
| Order_ID                | Integer   | Order ID                    | 77202         | Order analysis       |
| Shipping_Mode_ID        | Text      | Shipping mode               | SHP-4         | Shipping analysis    |
| Order_Date              | Date      | Order date                  | 2018-01-31    | Time analysis        |
| Shipping_Date           | Date      | Shipment date               | 2018-02-03    | Shipping analysis    |
| Days_Shipping_Actual    | Integer   | Actual shipping days        | 3             | Delivery performance |
| Days_Shipping_Scheduled | Integer   | Scheduled shipping days     | 4             | Delivery comparison  |
| Delivery_Status         | Text      | Delivery result             | Late delivery | Delivery analysis    |
| Late_Delivery_Risk      | Integer   | Late delivery indicator     | 0 or 1        | Risk analysis        |
| Shipping_Delay_Days     | Integer   | Actual minus scheduled days | -1            | Delay analysis       |

---

## 7. Key Identifiers

* **Order_ID:** Identifies an order and can appear across multiple order line items.
* **Order_Item_ID:** Unique identifier for an order line item and the primary key of both fact tables.
* **Customer_ID:** Identifies a customer.
* **Product_ID:** Identifies a product.
* **Location_ID:** Identifies a destination location. This key was created during data preparation.
* **Shipping_Mode_ID:** Identifies a shipping mode. This key was created during data preparation.

There is no separate shipment ID. Shipment information is recorded using `Order_Item_ID`.

---

## 8. Business Dimensions

The main dimensions available in the dataset are:

* **Market:** 5 values
* **Region:** 23 values
* **Country:** Destination country
* **Shipping Mode:** 4 values
* **Product:** 118 products
* **Category:** 50 categories
* **Department:** 11 departments
* **Customer Segment:** Consumer, Home Office, Corporate
* **Order Status:** 9 values
* **Delivery Status:** 4 values

The dataset does not contain supplier, warehouse, or procurement dimensions.

---

## 9. Business Measures

The main measures available are:

* `Sales_Amount`
* `Order_Item_Total`
* `Quantity`
* `Discount_Amount`
* `Discount_Rate`
* `Profit_Amount`
* `Profit_Ratio`
* `Item_Price`
* `Unit_Price`
* `Days_Shipping_Actual`
* `Days_Shipping_Scheduled`
* `Shipping_Delay_Days`
* `Late_Delivery_Risk`

There is **no shipping or freight cost field** in the dataset.

Therefore, the project can analyze shipping performance based on delivery time, but not shipping cost.

---

## 10. Date Understanding

The dataset contains three main date fields:

* `Date`
* `Order_Date`
* `Shipping_Date`

### Date Coverage

* Earliest date: **2015-01-01**
* Latest date: **2018-02-06**

`Order_Date` ends on January 31, 2018, while `Shipping_Date` extends to February 6, 2018.

All order and shipment dates are available in `Dim_Date`.

There are no missing or invalid dates.

`Shipping_Delay_Days` is calculated as:

**Actual Shipping Days − Scheduled Shipping Days**

Examples:

* Negative value → shipment was ahead of schedule
* Zero → shipment was on time
* Positive value → shipment was delayed

---

## 11. Data Quality Assessment

| Check                        | Result                                                  |
| ----------------------------- | ---------------------------------------------------------- |
| Missing values               | 3 null values, all in `Dim_Customers.Zipcode`           |
| Duplicate rows               | No fully duplicated rows in either fact table           |
| Duplicate `Order_Item_ID`    | None                                                    |
| Repeated `Order_ID`          | Expected because orders can contain multiple line items |
| Invalid dates                | None                                                    |
| Negative Quantity            | None                                                    |
| Negative Item Price          | None                                                    |
| Negative Sales Amount        | None                                                    |
| Negative Discount Amount     | None                                                    |
| Invalid Unit Price           | None                                                    |
| Negative Profit              | 33,784 order line items (18.7%)                         |
| Category consistency         | No inconsistent category values found                   |
| Status consistency           | No invalid status values found                          |
| Missing delivery information | None                                                    |

### Important Data Observations

**Customer Country**

`Dim_Customers.Country` contains only two values:

* `EE. UU.`
* `Puerto Rico`

Because of this, customer-registered country is not suitable for detailed geographic analysis.

`Dim_Locations` should be used for destination-based geographic analysis.

**Product Status**

`Dim_Products.Status` contains only the value `0` for all 118 products.

This column does not provide useful information for the analysis and should be excluded.

**Negative Profit**

33,784 of the 180,519 order line items have negative `Profit_Amount`.

This represents approximately **18.7%** of all order line items and is an important area for profitability analysis.

---

## 12. Data Limitations

The following information is not available in the dataset:

* Inventory levels
* Stock-on-hand
* Warehouse information
* Supplier/vendor information
* Procurement records
* Purchase orders
* Reorder points
* Safety stock
* Stockout events
* Shipping/freight costs
* Product return records

`Order_Status = CANCELED` can be used to study cancellations, but it should not be treated as product returns.

Because inventory, warehouse, supplier, procurement, and stockout data are not available, these areas are outside the scope of this project.

---

## 13. Analysis Feasibility

| Business Problem                                  | Data Available | Can Analyze? | Limitation                            |
| --------------------------------------------------- | --------------- | ------------- | -------------------------------------- |
| Shipping reliability by mode, region, and market | Yes            | Yes          | No major limitation                   |
| Fulfillment risk by region, market, and segment  | Yes            | Yes          | Customer country has limited values   |
| Category and department profitability            | Yes            | Yes          | No major limitation                   |
| Order cancellation analysis                      | Yes            | Yes          | Cancellations are not product returns |
| Inventory and stockout analysis                  | No             | No           | No inventory or stock data            |
| Supplier and procurement analysis                | No             | No           | No supplier or procurement data       |
| Shipping cost analysis                           | No             | No           | No shipping cost field                |

---

## 14. Business Problem Statement

### Business Context

DataCo Global operates across five markets and uses four shipping modes to deliver orders.

The dataset shows a significant delivery performance issue, along with a considerable number of loss-making order line items.

The project will focus on identifying the main operational and profitability issues using order, shipment, customer, product, location, and financial data.

---

### Problem 1 — Shipping and Logistics Reliability

Delivery performance may differ between shipping modes, regions, and markets.

**Business Question:**

Which shipping modes, regions, and markets have the highest late-delivery rates?

**Why It Matters:**

Understanding where delivery delays are concentrated can help improve shipping-mode allocation, delivery planning, and logistics operations.

---

### Problem 2 — Order Fulfillment Risk

Orders can have different outcomes, including completed, cancelled, fraud-related, payment-related, or other incomplete statuses.

**Business Question:**

Which regions, markets, and customer segments have higher levels of fulfillment risk?

**Why It Matters:**

Identifying high-risk areas can help the business focus its operational and fraud-prevention efforts where they are most needed.

---

### Problem 3 — Sales Volume vs. Profitability

High sales do not always result in high profit.

The dataset contains **33,784 loss-making order line items**, representing approximately **18.7%** of all order line items.

**Business Question:**

Which categories and departments generate strong sales and profit, and which have a higher concentration of loss-making orders?

**Why It Matters:**

The business can use this analysis to identify products and categories that need pricing, discount, or sales-strategy changes.

---

### Problem 4 — Order Cancellations

Cancelled orders represent sales opportunities that do not result in completed transactions.

**Business Question:**

How much sales and profit value is associated with cancelled orders, and where are cancellations most concentrated?

**Why It Matters:**

Finding patterns in cancellations can help identify areas where changes to the order or fulfillment process may reduce lost revenue.

---

### Project Scope

This project covers:

* Shipping reliability
* Delivery performance
* Fulfillment risk
* Sales analysis
* Profitability analysis
* Order cancellations
* Market analysis
* Regional analysis
* Shipping-mode analysis
* Product analysis
* Category and department analysis

The following areas are outside the project scope because the required data is not available:

* Inventory
* Warehouse operations
* Suppliers
* Procurement
* Reorder points
* Safety stock
* Stockouts
* Shipping costs
* Product returns

The analysis will be based on the historical DataCo dataset and the patterns available in the provided data.
