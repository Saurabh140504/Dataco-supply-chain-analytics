# Supply Chain Analytics — DataCo Global Order & Logistics Data

> An end-to-end Data Analyst portfolio project — the same investigation built through MySQL, Python, and Power BI, with every core number cross-checked across all three tools before being called final.

---

## Business Problem

This project is built around DataCo Global, a real distribution company shipping orders across 5 markets and more than 160 countries. The company has three years of real order and shipping records — but before this project, nobody had actually measured whether the business's general sense that "shipping feels unreliable" and "some categories are probably thinner on margin" was actually true, or by how much.

The goal was to turn that vague sense into real, defensible numbers:

- Are deliveries actually reliable — and if not, is it caused by shipping mode, region, or season?
- Are some orders riskier than others — cancelled, fraud-flagged, on hold, stuck in payment review — concentrated somewhere specific, or spread evenly?
- Does selling more actually mean making more, or are some of the biggest categories quietly thin on margin?
- What do cancelled orders actually cost the business, and is there a real pattern to them?

### Objectives

- Build a properly validated relational database from a real, messy, 53-column flat file
- Identify exactly which shipping mode, not just "shipping in general," is driving late deliveries
- Understand which product categories and departments are genuinely profitable, not just high-volume
- Quantify the real cost of order cancellations and check whether it's predictable or effectively random
- Reproduce every key number across MySQL, Python, and Power BI, so the final findings are provably consistent, not just plausible

### Who This Would Matter To (Stakeholders)

- **Operations / Logistics Manager** — wants to know which shipping mode to renegotiate or replace
- **Risk / Fraud Team** — wants to know whether fulfillment risk is concentrated somewhere specific or needs a company-wide fix
- **Category / Merchandising Manager** — wants to know which categories and departments are genuinely worth investing in
- **Finance / Senior Management** — wants a trustworthy, validated set of numbers before approving any operational changes

---

## Table of Contents

- [Important Measures at a Glance](#important-measures-at-a-glance)
- [Dataset Overview](#dataset-overview)
- [Part 1 — MySQL](#part-1--mysql)
- [Part 2 — Python](#part-2--python)
- [Part 3 — Power BI](#part-3--power-bi)
- [Dashboard Pages — Screenshots & Insights](#dashboard-pages--screenshots--insights)
- [Cross-Tool Validation](#cross-tool-validation)
- [Key Insights & Recommendations](#key-insights--recommendations)
- [Repository Structure](#repository-structure)
- [Tools Used](#tools-used)
- [Limitations](#limitations)

---

## Important Measures at a Glance

The 9 numbers that matter most in this project — everything else in the report supports one of these:

| Measure | Value | Business Problem |
|---|---:|---|
| Total Sales | $36.78M | Overall scale |
| Total Profit | $3.97M | Overall scale |
| Overall Profit Margin % | 11% | Profitability |
| Loss-Making Order Rate | 18.71% | Profitability |
| Late Delivery Rate | 54.83% | Shipping reliability |
| Average Shipping Delay | 0.57 days | Shipping reliability |
| Risk Order Rate | 10.78% | Fulfillment risk |
| Fraud Rate | 2.25% | Fulfillment risk |
| Cancelled Sales Value / Profit Value | $744,370.39 / $75,345.63 | Cancellations |

---

## Dataset Overview

| Table | Rows | What one row means |
|---|---:|---|
| `Dim_Date` | 1,133 | One calendar day |
| `Dim_Customers` | 20,652 | One customer |
| `Dim_Locations` | 3,772 | One unique shipping destination |
| `Dim_Products` | 118 | One product |
| `Dim_Shipping_Mode` | 4 | One shipping mode |
| `Fact_Orders` | 180,519 | One order line item |
| `Fact_Shipments` | 180,519 | One shipment record per order line item |

**Period covered:** January 2015 – February 2018

This is a proper star schema — 5 dimension tables supporting 2 fact tables that share the same grain (`Order_Item_ID`) — rebuilt from a single flat 53-column source file, not something the data arrived as. Full column-level detail, known data-quality issues, and a feasibility check against the four business problems are documented separately in [`Supply_Chain_Data_Overview.md`](./Supply_Chain_Data_Overview.md).

---

# Part 1 — MySQL

**Flow:** Design the schema → Load the data → Add foreign keys → Validate → Write 25 business queries across 4 problems

### Database Structure

Database name: **`Supply_Chain`**. Dimensions created first, then the two fact tables, since a foreign key can't point at a table that doesn't exist yet.

```text
Dim_Customers     → Fact_Orders     (Customer_ID)
Dim_Products      → Fact_Orders     (Product_ID)
Dim_Locations     → Fact_Orders     (Location_ID)
Dim_Date          → Fact_Orders     (Order_Date)
Dim_Shipping_Mode → Fact_Shipments  (Shipping_Mode_ID)
Dim_Date          → Fact_Shipments  (Order_Date, Shipping_Date)
Fact_Orders       → Fact_Shipments  (Order_Item_ID, shared grain)
```

All 7 tables were loaded and validated against expected row counts, and all 8 foreign key constraints were confirmed active with zero rejected rows — meaning the data, once loaded, had no orphaned keys anywhere.

### What SQL Found

SQL is where every headline number in this project first came from — it's the layer closest to the raw data, so it's what I trusted to establish the baseline before anything got visualized or modeled.

- **54.83% of all shipments are late**, and breaking that down by shipping mode immediately showed the gap wasn't even — First Class alone sits at 95.32% late versus 38.07% for Standard Class.
- **10.78% of orders fall into a risk status** (cancelled, fraud, on hold, or payment review), and grouping this by region, segment, and shipping mode showed the rate barely moves anywhere — a genuinely useful "spread evenly, not concentrated" result.
- **Fishing leads every category in total sales, but ranks only around #29 out of ~50 on profit margin** — this only became visible once margin was calculated as `SUM(Profit)/SUM(Sales)` per category and ranked separately from a plain sales ranking.
- **$744,370.39 in cancelled sales value**, and checking this against order-value buckets (Low/Medium/High) showed almost no difference in cancellation rate — price doesn't predict cancellation.

##### Full SQL: [`Global_Supply_Chain.sql`](Global_Supply_Chain.sql)

✅ **MySQL stage complete and validated.**

---

# Part 2 — Python

**Flow:** Load from MySQL (not the raw files) → Confirm the cleaning, don't redo it → Build KPIs → Cross-check against SQL → Explore visually → Written insights

### What Python Found

Python's job wasn't to repeat the SQL analysis — it was to go a level deeper by actually visualizing the patterns SQL could only describe as numbers.

- **The sales-vs-profit scatter plot made the margin finding impossible to miss.** Plotting every category's total sales against its profit margin showed a cloud, not a line — high-sales categories are scattered up and down the margin axis just as much as low-sales ones, visually confirming that volume and profitability are independent of each other here.
- **The profit-margin box plot by category revealed spread that a single average hides.** Some categories have a wide range of line-level margins underneath a similar-looking average, which a bar chart of averages alone would never show.
- **Cross-checking KPIs in pandas against SQL's results confirmed the numbers were trustworthy** — late delivery rate, risk order rate, and both cancellation dollar figures all matched exactly, which is what allowed me to build the rest of the analysis on top of them with confidence.
- **The monthly late-delivery trend line, plotted out visually, made the "no seasonality" finding concrete** — the line stays in a tight band all the way across three years with no seasonal spike anywhere.

**Notebook:** [`Global_Supply_Chain.ipynb`](Global_Supply_Chain.ipynb)

✅ **Python matches MySQL exactly** on every cross-checked KPI.

---

# Part 3 — Power BI

**Flow:** Connect to the same validated database → Build the data model → Write DAX measures → Build 3 report pages → Add slicers → Validate against known numbers

### Data Model

Same 7 tables as MySQL and Python. `Fact_Orders` and `Fact_Shipments` share a `1:1` relationship on `Order_Item_ID`, kept inactive by default since it isn't needed for the standard visuals. The two `Fact_Shipments`↔`Dim_Date` relationships (`Order_Date` and `Shipping_Date`) can't both be active against the same dimension at once, so `Order_Date` was kept active to match `Fact_Orders`.

### What Power BI Found

Power BI's job was translation and interactivity, not new discovery — but building it interactive is exactly what surfaced a few things static charts alone hadn't made obvious.

- **Filtering by shipping mode on the Operations page makes the First Class problem impossible to ignore** — with every slicer set to "All," it's already the tallest bar on the page, but toggling other modes on and off shows just how much of an outlier it really is compared to the rest.
- **The order-status donut turns a single "10.78% risk" number into a full picture** — seeing COMPLETE at 32.96% next to PENDING_PAYMENT at 22.07% and PROCESSING at 12.13% shows how much of the business is routine versus how much genuinely needs attention.
- **The sales-and-profit trend line on the Executive Overview page shows a sharp drop right at the very end of the timeline** (Jan 2018) — this lines up with the dataset simply ending in early February 2018, not a real business decline, and is worth remembering when reading that chart so the last data point isn't misread as a warning sign.
- **Slicers on the Financial Impact and Operations pages make it possible to check whether any single category or region drives the patterns** — filtering through them confirms what SQL already found: nothing regional stands out, reinforcing that these are company-wide patterns, not isolated pockets.

##### Power BI File: [Download the .pbix](Global_Supply_Chain.pbix)

✅ **Power BI matches MySQL and Python** on every headline number.

---

## Dashboard Pages — Screenshots & Insights

### Page 1 — Executive Overview
<img width="1327" height="751" alt="Screenshot 2026-09-13 194055" src="https://github.com/user-attachments/assets/743ec36a-f729-444e-97c7-d749d8804fc2" />

At a glance: $36.78M in total sales, $3.97M in profit, an 11% overall margin, a 55% late-delivery rate, and a 2% cancellation rate. Fishing leads every category by a wide margin ($6.9M), nearly double the #3 category (Camping & Hiking, $4.1M). The sales-and-profit trend line stays remarkably stable across all three years — hovering close to $1M in monthly sales almost every month — until it drops sharply in the very last month shown (Jan 2018), which reflects the dataset simply ending mid-month rather than any real business decline.

### Page 2 — Operations: Shipping & Fulfillment Risk
<img width="1340" height="750" alt="Screenshot 2026-09-13 194112" src="https://github.com/user-attachments/assets/2beb87ba-aaee-4348-b869-d84bae225ae6" />

This page makes the shipping problem impossible to miss: First Class sits at 0.95 (95%) late, more than double Standard Class at 0.38. The late-delivery trend line stays locked in a narrow 0.52–0.57 band for the full three years, with one visible dip around mid-2016 but no sustained seasonal pattern. Risk rate by customer segment is nearly flat (Consumer 0.110, Home Office 0.107, Corporate 0.105), and the order-status donut shows the 180,519 orders are mostly routine — a third fully complete, another fifth still in payment processing — with the risk-related statuses (on hold, fraud, cancelled, payment review) making up a real but clearly minority share.

### Page 3 — Financial Impact: Profitability & Cancellations
<img width="1325" height="742" alt="Screenshot 2026-09-13 194127" src="https://github.com/user-attachments/assets/7e478190-51a9-41b9-b34d-27249120c0b1" />

The scatter chart shows exactly what the numbers predicted: sales volume climbs steadily to the right, but profit margin stays clustered in roughly the same 0.05–0.15 band regardless of how much a category sells — bigger doesn't mean more profitable here. The department bar chart shows a clear gap between Fitness at the top (~0.115) and Book Shop at the bottom (~0.07), a difference invisible unless margin is checked directly. Fishing also leads in cancelled sales value (~$130K), consistent with it being the top-selling category overall — bigger categories naturally cancel more in raw dollars. The cancellation trend chart shows a clean, steadily climbing cumulative total reaching $0.74M by Jan 2018, with no sign of acceleration or improvement along the way.

---

## Cross-Tool Validation

The same numbers, checked three independent ways:

| Metric | MySQL | Python | Power BI |
|---|---:|---:|---:|
| Late Delivery Rate | 54.83% | 54.83% | 0.55 ✅ |
| Average Shipping Delay | 0.57 days | 0.57 days | 0.57 ✅ |
| Risk Order Rate | 10.78% | 10.78% | 0.11 ✅ |
| Fraud Rate | 2.25% | 2.25% | 0.02 ✅ |
| Overall Profit Margin | 11% | 11% | 0.11 ✅ |
| Loss-Making Order Rate | 18.71% | 18.71% | 0.19 ✅ |
| Cancellation Rate | ~2.05% | ~2.05% | 0.02 ✅ |
| Cancelled Sales Value | $744,370.39 | $744,370.39 | 744.37K ✅ |
| Cancelled Profit Value | $75,345.63 | $75,345.63 | 75.35K ✅ |

---

## Key Insights & Recommendations

**1. First Class shipping, specifically, is the reliability problem — not the company overall.** It has a 95.32% late-delivery rate versus 38.07% for Standard Class, and this holds steady across every region and every month of the 3-year period. → Worth renegotiating that specific carrier contract or reviewing its fulfillment process, rather than a company-wide logistics overhaul.

**2. Order risk is real but spread evenly — there's no single weak spot to target.** 10.78% of orders fall into a risk status, and that rate barely moves across region (9–13%), customer segment (10.5–11%), or shipping mode. → Worth strengthening payment/fraud screening company-wide rather than targeting one region or segment.

**3. Our biggest-selling category isn't our most profitable one.** Fishing leads in total sales but ranks only around #29 out of ~50 categories on profit margin, and 18.71% of all order lines lose money at a similarly consistent rate across nearly every category. → Points to a structural pricing or cost issue worth reviewing business-wide, not a "cut the underperforming category" fix.

**4. Book Shop has the weakest margin of any department (7.02%) — invisible at the category level.** It doesn't sell enough to show up near the top of any sales-ranked list, but its margin problem is real once you check for it. → Worth a targeted pricing or supplier review, since it's a small enough department to act on directly.

**5. Cancellations are a steady cost, not a solvable "hot spot."** $744,370.39 in cancelled sales and $75,345.63 in lost profit, with no meaningful pattern by region, shipping mode, or order value, and no upward or downward trend over 3 years. → Better handled with general order-verification process improvements than by trying to predict which orders will cancel.

---

## Repository Structure

```text
Dataco-supply-chain-analytics    
│
|── Dataset
|   └── Dim_Date.csv 
|   └── Dim_Customers.csv
|   └── Dim_Locations.csv
|   └── Dim_Products.csv
|   └── Dim_Shipping_Mode.csv
|   └── Fact_Orders.csv  
|   └── Fact_Shipments.csv
|── Dataset Understanding.md
|   └── Global Supply Chain Data_Overview
|
├── Global_Supply_Chain.sql            
│                           
├── Global_Supply_Chain.ipynb
| 
├── Global_Supply_Chain.pbix
└── images/
|   ├── executive_overview.png
|   ├── operations_shipping_risk.png
|   └── financial_impact.png
|       
├── Final_Project_Report.md                    
└──  README.md                                        
```

---

## Tools Used

| Stage | Tools & Techniques |
|---|---|
| MySQL | MySQL Workbench, `LOAD DATA INFILE`, foreign keys, joins (including two-hop joins), CTEs, window functions (`RANK`, running `SUM() OVER`), `HAVING` |
| Python | pandas, numpy, matplotlib, seaborn, SQLAlchemy, PyMySQL, Jupyter Notebook |
| Power BI | Power Query, star-schema data modeling, active/inactive relationship management, DAX (`DIVIDE`, `CALCULATE`), slicers, date hierarchies |

---

## Limitations

- This is real historical data from one specific company (DataCo Global, 2015–2018) — findings describe this business, not a universal supply-chain benchmark.
- The dataset has no supplier, inventory, or purchase-order information — nothing here covers stock levels, warehousing, or upstream supplier reliability.
- "Cancellation" in this data means an order that never completed — there is no separate flag for a product being returned after delivery.
- Customer-registered country only has 2 values across all 20,652 customers, so every regional finding in this project uses the order's actual shipping destination instead.
- A formal statistics stage (hypothesis testing) was intentionally left out of this version of the project — the "no meaningful pattern" findings above (region, segment, shipping mode, order value) are backed by real, verified aggregate numbers, but not by a formal significance test.

---
Thanks for reading this far. Happy to walk through any part of this in more detail.

**Connect with me:** *https://www.linkedin.com/in/saurabh-chaudhari-ds/*
