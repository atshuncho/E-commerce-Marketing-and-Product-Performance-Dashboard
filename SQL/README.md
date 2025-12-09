
# E-Commerce SQL Insights

This project contains a set of SQL queries designed to extract business insights from an e-commerce dataset. The analysis covers product performance, marketing efficiency, revenue trends, customer behavior, and profitability.

##  Product Performance
1. **Top 5 Products by Revenue** – Identifies the highest-grossing products based on total revenue.
2. **Top 5 Products by Number of Orders** – Ranks products based on order frequency.
3. **Top Product Categories by Revenue** – Highlights which categories contribute most to revenue.
4. **Highest Average Quantity per Order** – Evaluates products based on quantity ordered per transaction.

##  Channel & Marketing Efficiency
5. **Revenue by Marketing Channel** – Summarizes total revenue generated per marketing channel.
6. **Return on Ad Spend (ROAS)** – Calculates how much revenue each £1 of ad spend returns.
7. **Customer Acquisition Cost (CAC)** – Computes ad spend per unique customer by channel.
8. **Marketing Spend Comparison** – Compares average and total marketing spend across channels.

##  Time-Based Revenue Trends
9. **Monthly Revenue Trends** – Shows revenue evolution month over month.
10. **Month-on-Month % Change** – Calculates revenue growth/decline rate monthly.
11. **Highest Marketing Spend Month** – Identifies the month with the highest total marketing spend.
12. **YTD Revenue** – Computes year-to-date revenue by summing monthly revenues within each year.

##  Customer Insights
13. **Unique Customers** – Counts the number of distinct customers.
14. **Average Revenue per Customer** – Determines the mean revenue each customer contributes.
15. **Top Countries by Order Volume** – Ranks customer countries by number of orders.

##  Profitability Metrics
16. **Product Profit Margins** – Calculates each product's profit margin based on unit costs and revenue.

---

**Technologies Used:**
- SQL (MySQL compatible)
- Window Functions: `LAG()`, `SUM() OVER`
- Aggregations, Joins, Subqueries, CTEs

**Note:** All calculations take into account discounts where applicable to ensure realistic metrics.

