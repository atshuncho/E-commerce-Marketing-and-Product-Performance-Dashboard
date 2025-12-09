-- Product Performance
-- 1. Top 5 products by Revenue
WITH product_revenue AS(
SELECT
	p.ProductName,
    CASE
		WHEN DiscountPercent <> 0 THEN (o.Quantity*o.UnitPrice*(1-o.DiscountPercent))
        ELSE (o.Quantity*o.UnitPrice)
    END AS Revenue
FROM
	ecom_products p
		JOIN
	ecom_orders o ON p.ProductID = o.ProductID)
SELECT
	ProductName, ROUND(SUM(Revenue),2) AS Revenue_by_Product
FROM 
	product_revenue
GROUP BY ProductName
ORDER BY ProductName DESC
LIMIT 5;

-- 2 Top 5 Products by number of orders
SELECT 
    p.ProductName, COUNT(o.OrderID) AS Amount_of_Orders
FROM
    ecom_products p
        JOIN
    ecom_orders o ON p.ProductID = O.ProductID
GROUP BY P.ProductName
ORDER BY Amount_of_Orders DESC
LIMIT 5;

-- 3.Which Product Categories contribute the most to the total revenue? 

WITH Categories_rev AS(
SELECT
	p.Category,
    CASE
		WHEN DiscountPercent <> 0 THEN (o.Quantity*o.UnitPrice*(1-o.DiscountPercent))
        ELSE (o.Quantity*o.UnitPrice)
    END AS Revenue
FROM
	ecom_products p
		JOIN
	ecom_orders o ON p.ProductID = o.ProductID)
SELECT
	Category, ROUND(SUM(Revenue),2) AS Revenue
FROM
	Categories_rev
GROUP BY Category
ORDER BY Revenue
LIMIT 5;

-- 4 Which Products have the highest average quantity per order
SELECT 
    p.ProductName,
    ROUND(AVG(o.Quantity), 2) AS Avg_Quantity_per_Order
FROM
    ecom_products p
        JOIN
    ecom_orders o ON p.ProductID = o.ProductID
GROUP BY P.ProductName
ORDER BY Avg_Quantity_per_Order DESC;

-- Channel & Marketing Efficiency
-- 5 Which marketing channels generate the most revenue?
WITH Channels_rev AS(
SELECT
	Channel, 
    CASE
		WHEN DiscountPercent <> 0 THEN (UnitPrice*(1-DiscountPercent)*Quantity)
        ELSE (UnitPrice*Quantity)
	END AS Revenue
FROM
	ecom_orders)
SELECT
	Channel, ROUND(SUM(Revenue),2) AS Revenue
FROM
	Channels_rev
GROUP BY channel
ORDER BY Revenue DESC;

-- 6 Which channel has the highest return on Ad spend?
    
WITH All_Channel_Rev AS(
SELECT
	Channel, 
    CASE
		WHEN DiscountPercent <> 0 THEN (UnitPrice*(1-DiscountPercent)*Quantity)
        ELSE (UnitPrice*Quantity)
	END AS Revenue
FROM
	ecom_orders),
Revenue_per_Channel AS(
SELECT
	Channel,
    SUM(Revenue) AS Total_Revenue
FROM
	All_Channel_Rev
GROUP BY Channel),
Ad_spend_per_channel AS(
SELECT
	Channel, 
    SUM(Spend) AS Ad_spend
FROM
	ecom_marketing_spend
GROUP BY Channel
)
SELECT
	ad.Channel, 100 * ROUND((Total_Revenue / Ad_spend),2) AS Return_on_Ad_Spend
FROM
	Ad_spend_per_channel ad
		JOIN
	Revenue_per_Channel r ON ad.Channel = r.Channel
ORDER BY Return_on_Ad_Spend DESC;

-- 7. Which Channel has the lowest Customer Acquisition Cost (Ad costs / Distinct amount of customers)

WITH Ad_Spend_per_Channel AS(
SELECT
	Channel, SUM(Spend) AS Ad_Spend
FROM
	ecom_marketing_spend
GROUP BY Channel
), 
Customers_per_Channel AS(
SELECT
	Channel, COUNT(DISTINCT CustomerID) AS Amount_of_Customers
FROM
	ecom_orders
GROUP BY Channel
)
SELECT
	ads.Channel, ROUND((ads.Ad_Spend/cpc.Amount_of_Customers),2) AS CAC
FROM
	Ad_Spend_per_Channel ads
		JOIN
	Customers_per_Channel cpc ON cpc.Channel = ads.Channel
ORDER BY CAC ASC;

-- 8. How does marketing spend compare across channels
SELECT 
    Channel,
    ROUND(AVG(Spend), 2) AS Average_Marketing_Spend,
    ROUND(SUM(Spend), 2) AS Total_Marketing_Spend
FROM
    ecom_marketing_spend
GROUP BY Channel;
	
-- Time Based Trends
-- 9 and 10.How has revenue changed month over month
WITH orders_dates AS (
SELECT
OrderDate,
CASE
	WHEN DiscountPercent <> 0 THEN (Quantity*UnitPrice*(1-DiscountPercent))
	ELSE (Quantity*UnitPrice)
END AS Revenue
FROM
	ecom_orders
	), Monthly_revenue AS(
SELECT
	YEAR(OrderDate) as Year, MONTH(OrderDate) as Month, ROUND(SUM(Revenue),2) AS Total_Revenue
FROM
	orders_dates
GROUP BY 
	Year, Month
ORDER BY Year, Month)
Select
	Year, 
    Month, 
    Total_Revenue, 
    LAG(Total_Revenue) OVER (ORDER BY Year, Month) as Prev_Rev,
    100 * (Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Year, Month))/ LAG(Total_Revenue) OVER (ORDER BY Year, Month) AS MoM_Percentage_Change
FROM
	Monthly_revenue;

-- 11. Which Month had the highest marketing spend?
SELECT 
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    ROUND(SUM(Spend), 2) AS Total_Marketing_Spend
FROM
    ecom_marketing_spend
GROUP BY year , month
ORDER BY Total_Marketing_Spend DESC
LIMIT 1
;
-- 12. YTD Revenue
 WITH orders_dates AS (
  SELECT
    OrderDate,
    CASE
      WHEN DiscountPercent <> 0 THEN (Quantity * UnitPrice * (1 - DiscountPercent))
      ELSE (Quantity * UnitPrice)
    END AS Revenue
  FROM
    ecom_orders
),
monthly_revenue AS (
  SELECT
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    ROUND(SUM(Revenue), 2) AS Total_Revenue
  FROM
    orders_dates
  GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
)
SELECT
  Year,
  Month,
  Total_Revenue,
  ROUND(SUM(Total_Revenue) OVER (PARTITION BY Year ORDER BY Month),2) AS YTD_Revenue
FROM
  monthly_revenue
ORDER BY
  Year, Month;

-- Customer Insights
-- 13, How many unique customers placed orders
SELECT 
    COUNT(DISTINCT CustomerID) Amount_of_customers
FROM
    ecom_orders
;

-- 14 What is the average Revenue per customer
WITH Customer_Sales AS (
  SELECT CustomerID, 
         SUM(CASE 
           WHEN DiscountPercent <> 0 THEN Quantity * UnitPrice * (1 - DiscountPercent)
           ELSE Quantity * UnitPrice
         END) AS TotalRevenue
  FROM ecom_orders
  GROUP BY CustomerID
)
SELECT ROUND(AVG(TotalRevenue),2) AS Avg_Revenue_Per_Customer
FROM Customer_Sales;
-- 15 Which Countries have the highest customer order volumes
SELECT 
    Country, COUNT(OrderID) AS Total_Orders
FROM
    ecom_orders
GROUP BY Country
ORDER BY Total_Orders;

-- Profitability
-- 16 What is the overall profit margin by Product
WITH Profit_per_Product AS( 
SELECT
	ep.ProductName, SUM(((eo.UnitPrice - ep.CostPrice)* eo.Quantity)) AS Profit
FROM
	ecom_products ep
		JOIN
	ecom_orders eo ON eo.ProductID = ep.ProductID
GROUP BY
	ep.ProductName),
product_revenue AS(
SELECT
	p.ProductName,
    CASE
		WHEN DiscountPercent <> 0 THEN (o.Quantity*o.UnitPrice*(1-o.DiscountPercent))
        ELSE (o.Quantity*o.UnitPrice)
    END AS Revenue
FROM
	ecom_products p
		JOIN
	ecom_orders o ON p.ProductID = o.ProductID),
Revenue_per_product AS (
SELECT
	ProductName, ROUND(SUM(Revenue),2) AS Revenue_by_Product
FROM 
	product_revenue
GROUP BY ProductName)
SELECT
	P.ProductName, ROUND(100 *(P.Profit / R.Revenue_by_Product),2) AS Profit_Margin
FROM
	Profit_per_Product P 
		JOIN
	Revenue_per_product R ON P.ProductName = R.ProductName;
    


