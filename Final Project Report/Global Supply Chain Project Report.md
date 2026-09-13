# Supply Chain Analytics Project — Final Report
### DataCo Global Order & Logistics Data (2015–2018)

---

## 1. Executive Summary

I spent this project digging into three years of real order and shipping data from DataCo Global — a company shipping to customers across 5 markets and over 160 countries — to answer a simple question: where is this business actually losing money and reliability, and why?

Here's what I found. More than half of all shipments arrive late, and it comes down almost entirely to one shipping mode being unreliable, not to where the order is going or what time of year it is. On the money side, the categories that sell the most aren't the ones making the best margins, and close to one in five order lines actually lose money. Cancelled orders alone add up to over $744K in lost sales. Every number in this report came straight out of the database — nothing here is estimated or rounded up for effect.

---

## 2. Business Context

DataCo Global sells sporting goods, apparel, electronics, and related products through a distribution network spanning 5 markets, 23 regions, and 4 shipping modes. I worked with 180,519 individual order line items across 65,752 orders, covering January 2015 through early 2018.

Going in, the general feeling at the business was "shipping feels unreliable" and "some categories probably aren't as profitable as they look" — but nobody had actually measured it. My job here was to turn that gut feeling into real numbers, and then figure out what's actually causing each problem so any fix targets the real issue instead of a guess.

---

## 3. Business Problems

I framed the whole project around four questions:

1. **Are our deliveries actually reliable?** If not, is it a shipping-mode issue, a regional issue, or a seasonal issue?
2. **Are some orders riskier than others?** Cancelled, fraud-flagged, on hold, stuck in payment review — is this concentrated somewhere specific, or spread evenly across the business?
3. **Does selling more actually mean making more?** Or are some of our biggest categories quietly thin on margin?
4. **What do cancelled orders cost us**, and is there any real pattern to when or where they happen?

---

## 4. Data & Methodology

I worked from a real, publicly available DataCo Global dataset (not synthetic). Before touching any analysis, I removed every customer-identifying column — name, email, password, street address — since none of that was needed and it shouldn't be floating around in a project file.

The work moved through three main stages:

- **MySQL** — I built a proper 7-table relational schema (Dim_Date, Dim_Customers, Dim_Locations, Dim_Products, Dim_Shipping_Mode, Fact_Orders, Fact_Shipments), loaded and validated the data, and wrote SQL covering all four problems using joins, CTEs, window functions, and HAVING clauses.
- **Python** — I pulled the validated data back out of MySQL, double-checked it arrived clean, built out the key business metrics, and ran exploratory analysis with charts to actually see each pattern, not just read it as a number.
- **Power BI** — I built a 3-page interactive dashboard (Executive Overview, Operations, Financial Impact) so these findings are something a non-technical stakeholder can actually click through and explore, not just read as a static document.

Every important number below was checked twice — once in SQL, once in Python — and I confirmed they matched exactly before I trusted them enough to put in this report.

---

## 5. Key Findings

### Finding 1 — One shipping mode is dragging down our entire delivery reliability number
Overall, **54.83%** of shipments arrive late. That number gets a lot more useful once you break it down by shipping mode: **First Class sits at a 95.32% late rate** — by far the worst of the four — while Standard Class is at just 38.07%. Average delay company-wide is 0.57 days, but that ranges from basically zero for Standard Class to nearly two days for Second Class.

I checked whether region or time of year explains this, and they don't. Late rate by region only moves between about 55% and 58% across all 23 regions — practically flat. And tracking it month by month across the full three years, it stays in a tight 53%–57% band with no seasonal spike anywhere. So this isn't a "we can't handle the holiday rush" problem or a "one region has bad infrastructure" problem — it's specifically a First Class shipping problem.

### Finding 2 — Order risk is real, but it's spread evenly, not hiding in one corner
**10.78%** of all orders land in a risk status — cancelled, flagged for suspected fraud, on hold, or stuck in payment review. I checked this against region, customer segment, and shipping mode, and none of them stand out: risk by region ranges from about 9% to 13% (Southern Africa highest at 12.71%), and by customer segment it's nearly identical across Consumer (10.96%), Home Office (10.73%), and Corporate (10.49%). Fraud specifically is just 2.25% overall, again with no region jumping out.

Honestly, this is a useful thing to know even though it's a "nothing stands out" result — it tells me the fix isn't "watch this one region more closely," it's "improve payment and fraud screening across the board," because the risk really is spread that evenly.

### Finding 3 — Our biggest sellers aren't our most profitable products
Fishing is the #1 category by total sales, but when I ranked every category by profit margin instead, Fishing dropped to around **#29 out of roughly 50**. Overall margin sits at 11%, and **18.71% of all order lines are actually losing money** — and that loss rate is remarkably consistent across nearly every category, not concentrated in some obvious weak spot.

Looking at this by department instead of category made the gap even clearer: **Book Shop has the lowest margin of any department, at just 7.02%**, well behind Fitness at the top. You'd never catch this looking at a sales-ranked list, since Book Shop doesn't sell enough to appear near the top — but its margin problem is real and worth fixing once you know to check for it.

### Finding 4 — Cancellations are a steady cost, not a solvable "hot spot"
Cancelled orders account for **$744,370.39 in lost sales** and **$75,345.63 in lost profit**. I checked whether this concentrates by region, shipping mode, or order price, and it really doesn't: cancellation rate by order value is nearly identical whether the order is Low (2.06%), Medium (2.05%), or High-value (2.02%) — price basically has zero relationship with cancellation. By region it's a narrow 2.0%–3.1% range, and by shipping mode 1.88%–2.31% — again nothing stands out. And tracking the monthly trend over three years, there's no acceleration or improvement — it's a steady, ongoing cost, not a growing crisis or a fading one.

---

## 6. Recommendations

| Priority | Recommendation | Based On |
|---|---|---|
| **High** | Investigate the First Class shipping carrier or process specifically — this is where the real problem lives, not across shipping in general. | Finding 1 |
| **High** | Review pricing, discounting, and cost structure across the whole business rather than category by category. Since the ~19% loss-making rate is so consistent everywhere, this looks like a structural issue, not a "cut this one category" issue. | Finding 3 |
| **Medium** | Take a closer look at Book Shop specifically. Its margin is meaningfully behind everything else, and it's small enough that a targeted pricing or supplier review is realistic to actually do. | Finding 3 |
| **Medium** | Strengthen payment verification and fraud screening company-wide. A targeted regional or segment-based approach won't help much here, since risk really is spread evenly. | Finding 2 |
| **Low** | Treat cancellations as a predictable, ongoing cost rather than something to "solve" by targeting a specific segment — focus instead on general order-verification steps like confirming payment earlier in the process. | Finding 4 |

---

## 7. Limitations

- This is real historical data from one specific company (DataCo Global, 2015–2018), not a general supply-chain benchmark — these findings describe this business, not the industry as a whole.
- The dataset has no supplier, inventory, or purchase-order information, so nothing here touches stock levels, warehousing, or upstream supplier reliability — that data simply doesn't exist in this source.
- "Cancellation" in this data means an order that never completed — there's no separate flag for a product being returned after delivery, so Finding 4 is about pre-fulfillment cancellations specifically, not post-delivery returns.
- Customer-registered country only has 2 values across all 20,652 customers, so every regional finding in this report uses the order's actual shipping destination instead, which is complete and reliable.

---

## 8. Future Scope

- If supplier or inventory data ever becomes available, extend this to look at whether the First Class delay traces back to a specific carrier partner, warehouse, or route.
- Dig into the Book Shop margin problem at the individual product level to figure out if it's a pricing issue, a cost issue, or just the wrong mix of products.
- Since no single factor (region, shipping mode, price) predicts cancellation well on its own, it might be worth testing whether combining several of these together does a better job — even weak individual signals can sometimes add up to something more useful together.
