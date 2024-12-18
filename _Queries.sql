CREATE DATABASE Project;
USE project;

SELECT * FROM sales;
SELECT COUNT(*) FROM sales;
SHOW TABLES;
DESCRIBE sales;

-- Year wise sales comparison of product
WITH Year_data AS (SELECT DISTINCT(EXTRACT(YEAR FROM STR_TO_DATE(`Date`,'%d-%m-%Y'))) AS Year,
SUM(`Value`) AS Sales,
round(SUM(`Cost of Sales`),0) AS Cost
FROM sales
GROUP BY `Year`)
SELECT *,(sales-Cost) AS profit,Round(((sales-Cost)/sales)*100,2) Gross_Margine FROM year_data;

SELECT (33747779/29676350)*100; 

-- Avg sales
SELECT SUM(`value`)/count(distinct(LEFT(STR_TO_DATE(`Date`,'%d-%m-%Y'),7))) AS Avg_sales from sales;

SELECT distinct(EXTRACT(Year FROM STR_TO_DATE(`Date`,'%d-%m-%Y'))) AS `year`,
SUM(`value`)/count(distinct(LEFT(STR_TO_DATE(`Date`,'%d-%m-%Y'),7))) AS Avg_sales from sales group by `year`;

-- Month wise sales
With Sample AS(Select * , EXTRACT(Year FROM STR_TO_DATE(`Date`,'%d-%m-%Y')) AS `year`,
EXTRACT(MONTH FROM STR_TO_DATE(`Date`,'%d-%m-%Y')) AS `Month` From sales)
SELECT distinct(month) AS D_month, 
Sum(Case when `year` = 2022 then value end) AS revenue_2022,
Sum(Case when `year` = 2023 then value end) AS revenue_2023,
Sum(Case when `year` = 2024 then value end) AS revenue_2024
from sample GROUP BY D_month order by month ASC;

-- Top & bottom 5 product by sale value
WITH
ProductSales AS (SELECT `Product id`,Product,SUM(`value`) AS ProductTotalSales FROM sales GROUP BY `Product id`,Product),
TotalSales AS (SELECT SUM(`value`) AS OverallTotalSales FROM sales)
SELECT ps.`Product id`,ps.Product,
ps.ProductTotalSales,
(ps.ProductTotalSales / ts.OverallTotalSales) * 100 AS ContributionPercentage
FROM ProductSales ps
CROSS JOIN TotalSales ts order by ps.ProductTotalSales DESC LIMIT 5;

SELECT `Product ID`, Product, SUM(Value) AS Total_Sales FROM sales GROUP BY `Product ID`, Product ORDER BY Total_Sales ASC LIMIT 5;

-- Product with highest margin
WITH Margin AS (SELECT DISTINCT(Product),`Product ID`,
SUM(`Value`) OVER (PARTITION BY `Product ID`) AS Sales,
SUM(`Cost of Sales`) OVER (PARTITION BY `Product ID`) AS Cost FROM sales)
SELECT DISTINCT(Product),`Product ID`,sales,cost,ROUND(((Sales-Cost)/Sales)*100,2) AS Product_Margin 
FROM Margin 
ORDER BY Product_Margin DESC;

SELECT * FROM sales WHERE `Product ID` Like '%77';

-- Highst Selling month by product
SELECT `Product ID`, Product,
EXTRACT(MONTH FROM STR_TO_DATE(`Date`,'%d-%m-%Y')) AS `Month`, 
SUM(Value) AS Total_Sales 
FROM sales WHERE `product id` = "lxm/pdt/3"
GROUP BY `Product ID`, Product,`Month` 
ORDER BY Total_Sales DESC LIMIT 1;

-- Top selling product (Quantity)
SELECT product, ROUND(SUM(quantity),2) AS Sales_Quantity FROM sales Group by product ORDER BY Sales_Quantity DESC;

-- Number of customer from different state
SELECT DISTINCT(LEFT(`GSTIN/UIN`,2)) AS State_code FROM sales;

WITH Customer_State AS (SELECT customer, `GSTIN/UIN`,
CASE WHEN (LEFT(`GSTIN/UIN`,2))=24 THEN "Gujarat" WHEN (LEFT(`GSTIN/UIN`,2))=23 THEN "Madya Pradesh" END AS State FROM sales)
SELECT State, COUNT(Distinct(`customer`)) FROM Customer_State GROUP BY State;

-- Sales in both states
WITH StateSales AS (SELECT
CASE WHEN (LEFT(`GSTIN/UIN`,2))=24 THEN "Gujarat"
     WHEN (LEFT(`GSTIN/UIN`,2))=23 THEN "Madya Pradesh"
	 END AS State,
SUM(`Value`) AS Revenue FROM sales GROUP BY State),
TotalSales AS (SELECT SUM(`Value`) AS Total FROM sales)
SELECT StateSales.State,StateSales.Revenue,(StateSales.Revenue/TotalSales.Total)*100 AS Contributiion
FROM StateSales
Cross JOIN TotalSales;

-- product data not found
SELECT * FROM sales WHERE `Cost of Sales` = 0;
SELECT COUNT(Distinct(`voucher no.`)) FROM sales WHERE `Cost of Sales` = 0;

-- Top 5 customer
WITH CustomerSales AS (SELECT `Customer ID`, Customer, 
SUM(Value) AS Total_Sales 
FROM sales GROUP BY `Customer ID`, Customer 
ORDER BY Total_Sales DESC LIMIT 5),
TotalSales AS (SELECT SUM(Value) AS Total_Sales FROM sales)
SELECT CustomerSales.`Customer ID`, CustomerSales.Customer, CustomerSales.Total_Sales, 
(CustomerSales.Total_Sales/TotalSales.Total_Sales)*100 AS contribution
FROM CustomerSales Cross join TotalSales;

-- Number of customer by legal status
SELECT (SELECT COUNT(Distinct(customer))
FROM sales
WHERE `GSTIN/UIN` LIKE '_____P%') AS sales_to_individual, (SELECT COUNT(Distinct(customer))
FROM sales
WHERE `GSTIN/UIN` LIKE '_____F%') AS sales_to_firm From sales limit 1;

SELECT COUNT(DISTINCT(`customer id`)) from sales;
SELECT (204/284)*100,(73/284)*100,(7/284)*100;

-- Join two tables
SELECT * FROM sales join customer on sales.`customer ID` = Customer.`ID`;

-- customer with missing data
WITH Combine AS (SELECT * FROM sales join customer on sales.`customer ID` = Customer.`ID`)
SELECT customer, `customer ID`, City, Email FROM Combine WHERE City is NULL OR Email is NULL;
