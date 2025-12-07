
# DAX Measures for Ecommerce Power BI Dashboard

This document outlines the DAX measures created for the ecommerce dashboard project, detailing their purpose and logic.

---

## Date Table Calculations

### `DimDate`
```DAX
DimDate = CALENDARAUTO()
```
Automatically generates a calendar table based on data model date ranges.

### `Year`
```DAX
Year = YEAR(DimDate[Date])
```
Extracts the year from the date.

### `Month`
```DAX
Month = FORMAT(DimDate[Date], "MMMM")
```
Extracts the full month name from the date.

---

## Key Metrics Used

### `Average Order Value`
```DAX
Average Order Value = 
VAR AmountOfOrders = CALCULATE(COUNT(ecom_orders[OrderID]))
RETURN DIVIDE(CALCULATE(SUM(ecom_orders[Revenue])), AmountOfOrders)
```
Calculates the average revenue generated per order.

### `Customer Acquisition Cost`
```DAX
Customer Acquisition cost = 
VAR adcosts = CALCULATE(SUM(ecom_marketing_spend[Spend]))
RETURN DIVIDE(adcosts, DISTINCTCOUNT(ecom_orders[CustomerID]))
```
Calculates the marketing spend divided by the number of unique customers acquired.

### `Marketing Contribution`
```DAX
Marketing Contribution = CALCULATE(SUM(ecom_orders[Revenue])) - CALCULATE(SUM(ecom_marketing_spend[Spend]))
```
Net contribution from marketing efforts, calculated as revenue minus ad spend.

### `Marketing Efficiency Ratio`
```DAX
Marketing Efficiency Ratio = DIVIDE(CALCULATE(SUM(ecom_orders[Revenue])), CALCULATE(SUM(ecom_marketing_spend[Spend])))
```
Revenue generated for every £1 spent on ads.

### `MoM % Change`
```DAX
MoM % Change = 
VAR CurrentMonth = CALCULATE(SUM(ecom_orders[Revenue]))
VAR PreviousMonthx = CALCULATE(SUM(ecom_orders[Revenue]), PREVIOUSMONTH(DimDate[Date]))
RETURN DIVIDE(CurrentMonth - PreviousMonthx, PreviousMonthx)
```
Month-over-month change in revenue.

### `Profit`
```DAX
Profit = SUMX(ecom_orders, ecom_orders[Quantity] * RELATED(ecom_products[Profit Per ProductID]))
```
Total profit by multiplying quantity sold by the per-product profit.

### `Profit Margin`
```DAX
Profit Margin = [Profit] / CALCULATE(SUM(ecom_orders[Revenue]))
```
Ratio of profit to revenue.

### `Return on Ad Spend`
```DAX
Return on Ad Spend = 
VAR TotalRevenue = SUM(ecom_orders[Revenue])
VAR TotalAdSpend = CALCULATE(SUM('Channel Advertisment'[Spend]))
RETURN DIVIDE(TotalRevenue, TotalAdSpend)
```
Revenue divided by advertising spend.

### `Revenue`
```DAX
Revenue = IF(ecom_orders[DiscountPercent] = 0, ecom_orders[Quantity] * ecom_orders[UnitPrice], ecom_orders[Quantity] * ecom_orders[UnitPrice] * (1 - ecom_orders[DiscountPercent]))
```
Calculates true revenue considering discount logic.

### `YTD Revenue`
```DAX
YTD Revenue = TOTALYTD(CALCULATE(SUM(ecom_orders[Revenue])), DimDate[Date])
```
Total Year-to-Date revenue using the date table.

---

##  Top N Metrics

### `Top N Products by Orders`
```DAX
Top N Products by Orders = 
VAR SelectedN = 'Top N Products'[TopNProducts Value]
VAR RankedProducts = RANKX(ALL(ecom_products[ProductName]), CALCULATE(COUNT(ecom_orders[OrderID])))
RETURN IF(SelectedN >= RankedProducts, CALCULATE(COUNT(ecom_orders[OrderID])))
```

### `Top N Products by Sales`
```DAX
Top N Products by Sales = 
VAR SelectedN = [TopNProducts Value]
VAR ProductRanking = RANKX(ALL(ecom_products[ProductName]), CALCULATE(SUM(ecom_orders[Revenue])))
RETURN IF(SelectedN >= ProductRanking, CALCULATE(SUM(ecom_orders[Revenue])))
```

---

## Other Measures Created but Not Used in Final Report

These measures were explored during the development phase but were not included in the final dashboard:

- `Top N Products by Orders`
- `Top N Products by Sales`

They may still be useful in future iterations of the report.

---

**Note:** Measures rely on relationships between `DimDate`, `ecom_orders`, `ecom_marketing_spend`, `ecom_products`, and `'Channel Advertisment'` tables being properly defined in the data model.
