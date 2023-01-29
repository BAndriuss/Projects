select * 
from PortfolioProjects..['Sales Orders Sheet$']
ORDER BY OrderDate DESC

select * 
from PortfolioProjects..['Store Locations Sheet$']
order by 1

---------------------------------- Deleting rows where County/State/Population are duplicated ----------------------------------
DROP table #StoreLocationsCleaned
--Creating temp table
Create Table #StoreLocationsCleaned
(
_StoreID numeric,
[City Name] nvarchar(255),
County nvarchar(255),
StateCode nvarchar(255),
State nvarchar(255),
Type nvarchar(255),
Latitude float,
Longtitude float,
AreaCode numeric,
Population numeric,
[Household Income] numeric,
[Median Income] numeric,
[Land Area] numeric,
[Water Area] numeric,
[Time Zone] nvarchar(255)
)

INSERT INTO #StoreLocationsCleaned
SELECT *
FROM PortfolioProjects..['Store Locations Sheet$']

select *
FROM #StoreLocationsCleaned
ORDER BY County

-- Using CTE to search for duplicates

With Dupes AS (
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY County,
					 State,
					 Population
					 ORDER BY
					 _StoreID
		) row_num
FROM #StoreLocationsCleaned
)
--DELETE 
SELECT *
FROM Dupes
Where row_num >1


---------------------------------------------------

-- Customers that made company the most profit
SELECT a._CustomerID,b.[Customer Names], SUM([Order Quantity]) AS Orders, SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS Profit
FROM PortfolioProjects..['Sales Orders Sheet$'] AS a
JOIN PortfolioProjects..['Customers Sheet$'] AS b
ON a._CustomerID = b._CustomerID
GROUP BY a._CustomerID, b.[Customer Names]
ORDER BY Profit DESC

-- the most demanded product

SELECT b.[Product Name], SUM(a.[Order Quantity]) AS Total_orders
FROM PortfolioProjects..['Sales Orders Sheet$'] AS a
JOIN PortfolioProjects..['Products Sheet$'] AS b
ON a._ProductID = b._ProductID
GROUP BY [Product Name]
ORDER BY Total_orders DESC

-- Which city had the most profit

SELECT a._StoreID, b.[City Name],b.County, b.State, YEAR(a.OrderDate), MONTH(a.OrderDate), SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS Profit
FROM PortfolioProjects..['Sales Orders Sheet$'] AS a
RIGHT JOIN #StoreLocationsCleaned AS b
ON b._StoreID = a._StoreID
GROUP BY  a._StoreID, [City Name], b.County, b.State, YEAR(a.OrderDate), MONTH(a.OrderDate)
ORDER BY Profit DESC

-- Which sales team had the most customers

SELECT a._SalesTeamID, b.[Sales Team], Count(a._SalesTeamID) AS total_customers
FROM PortfolioProjects.. ['Sales Orders Sheet$'] AS a
JOIN PortfolioProjects.. ['Sales Team Sheet$'] AS b
ON a._SalesTeamID = b._SalesTeamID
GROUP BY a._SalesTeamID, b.[Sales Team]
ORDER BY 3 DESC

-- Which sales tem had the most total customers, profit
SELECT a._SalesTeamID, b.[Sales Team],Count(a._SalesTeamID) AS [Total customers], SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS Profit
FROM PortfolioProjects.. ['Sales Orders Sheet$'] AS a
JOIN PortfolioProjects.. ['Sales Team Sheet$'] AS b
ON a._SalesTeamID = b._SalesTeamID
GROUP BY a._SalesTeamID, b.[Sales Team]
ORDER BY 4 DESC

-- Profit by date //  Daily Sales TABLE

SELECT OrderDate, SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS [Total Sales]
FROM PortfolioProjects..['Sales Orders Sheet$']
GROUP BY OrderDate
ORDER BY 1

-- Profit by year // CATEGORY  TABLE

SELECT YEAR(OrderDate) AS Year, SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS [Total Sales]
FROM PortfolioProjects..['Sales Orders Sheet$']
GROUP BY YEAR(OrderDate)
ORDER BY 1

-- Profit by month // top bar, TOTAL SALES, TOTAL ORDERS

SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(OrderDate) as [Total Orders], SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS [Total Sales]
FROM PortfolioProjects..['Sales Orders Sheet$']
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY 1,2,4


-- Most used Sales channell
SELECT [Sales Channel], COUNT([Sales Channel]) as Orders
FROM PortfolioProjects..['Sales Orders Sheet$']
GROUP BY [Sales Channel]
ORDER BY 2 DESC

-- Which city had the most profit by every month // top bar,  CITY WITH MOST SALES

SELECT a._StoreID, b.[City Name],b.County, b.State, YEAR(a.OrderDate) AS Year, MONTH(a.OrderDate) AS Month, SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS Profit
FROM PortfolioProjects..['Sales Orders Sheet$'] AS a
RIGHT JOIN #StoreLocationsCleaned AS b
ON b._StoreID = a._StoreID
GROUP BY  a._StoreID, [City Name], b.County, b.State, YEAR(a.OrderDate), MONTH(a.OrderDate)
ORDER BY Year, Month, Profit DESC


-- The most demanded product for every month // Top 5 Demanded Products 

SELECT b.[Product Name],YEAR(a.OrderDate) AS Year ,MONTH(a.OrderDate) AS Month, SUM(a.[Order Quantity]) AS Total_orders
FROM PortfolioProjects..['Sales Orders Sheet$'] AS a
JOIN PortfolioProjects..['Products Sheet$'] AS b
ON a._ProductID = b._ProductID
GROUP BY [Product Name],YEAR(a.OrderDate),MONTH(a.OrderDate)
ORDER BY YEAR(a.OrderDate), MONTH(a.OrderDate), Total_orders DESC

-- Which city had the most profit by every month // top bar,  CITY WITH MOST SALES

SELECT _StoreID, [City Name], County, State, Year, Month, Profit, row_num
FROM (
		Select  a._StoreID,
				[City Name],
				b.County,
				b.State,
				YEAR(a.OrderDate) AS Year,
				MONTH(a.OrderDate) AS Month,
				SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) AS Profit,
				ROW_NUMBER() OVER (
								   PARTITION BY YEAR(a.OrderDate), MONTH(a.OrderDate)
								   ORDER BY SUM(([Unit Price]-[Unit Cost])*[Order Quantity]) DESC
								   ) AS row_num

		From PortfolioProjects..['Sales Orders Sheet$'] AS a
		RIGHT JOIN #StoreLocationsCleaned AS b
		ON b._StoreID = a._StoreID

		GROUP BY  a._StoreID, [City Name], b.County, b.State, YEAR(a.OrderDate), MONTH(a.OrderDate)
	 ) c
Where row_num = 1
ORDER BY Year, Month, Profit DESC


