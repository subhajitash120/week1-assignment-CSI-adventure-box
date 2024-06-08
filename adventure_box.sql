CREATE DATABASE adventure_box
use adventure_box

-- Create tables
CREATE TABLE Sales.Customer (
    CustomerID INT PRIMARY KEY,
    CompanyName NVARCHAR(100),
    City NVARCHAR(50),
    CountryRegionCode NVARCHAR(3),
    Fax NVARCHAR(20)
);

CREATE TABLE Sales.SalesOrderHeader (
    SalesOrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    ShipDate DATE,
    ShipPostalCode NVARCHAR(20),
    ShipCountryRegionCode NVARCHAR(3),
    SalesPersonID INT,
    TotalDue DECIMAL(18, 2),
    FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID)
);

CREATE TABLE Sales.SalesOrderDetail (
    SalesOrderDetailID INT PRIMARY KEY,
    SalesOrderID INT,
    ProductID INT,
    OrderQty INT,
    LineTotal DECIMAL(18, 2),
    FOREIGN KEY (SalesOrderID) REFERENCES Sales.SalesOrderHeader(SalesOrderID)
);

CREATE TABLE Production.Product (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(100),
    ProductCategoryID INT,
    Discontinued BIT,
    UnitsInStock INT,
    UnitsOnOrder INT
);

CREATE TABLE Production.ProductCategory (
    ProductCategoryID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Purchasing.Vendor (
    VendorID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Purchasing.ProductVendor (
    ProductID INT,
    VendorID INT,
    PRIMARY KEY (ProductID, VendorID),
    FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID),
    FOREIGN KEY (VendorID) REFERENCES Purchasing.Vendor(VendorID)
);

CREATE TABLE HumanResources.Employee (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES HumanResources.Employee(EmployeeID)
);

-- Insert sample data
INSERT INTO Sales.Customer (CustomerID, CompanyName, City, CountryRegionCode, Fax) VALUES
(1, 'Customer A', 'Berlin', 'DE', NULL),
(2, 'Customer B', 'London', 'UK', '12345'),
(3, 'Customer C', 'Paris', 'FR', NULL);

INSERT INTO Sales.SalesOrderHeader (SalesOrderID, CustomerID, OrderDate, ShipDate, ShipPostalCode, ShipCountryRegionCode, SalesPersonID, TotalDue) VALUES
(1, 1, '2020-01-01', '2020-01-05', '10115', 'DE', 1, 500.00),
(2, 2, '2020-02-01', '2020-02-05', 'E1 6AN', 'UK', 2, 1000.00),
(3, 3, '2020-03-01', '2020-03-05', '75001', 'FR', 1, 1500.00);

INSERT INTO Sales.SalesOrderDetail (SalesOrderDetailID, SalesOrderID, ProductID, OrderQty, LineTotal) VALUES
(1, 1, 1, 10, 500.00),
(2, 2, 2, 20, 1000.00),
(3, 3, 3, 30, 1500.00);

INSERT INTO Production.Product (ProductID, Name, ProductCategoryID, Discontinued, UnitsInStock, UnitsOnOrder) VALUES
(1, 'Tofu', 1, 0, 50, 20),
(2, 'Chai', 1, 0, 60, 0),
(3, 'Ikura', 1, 1, 10, 0);

INSERT INTO Production.ProductCategory (ProductCategoryID, Name) VALUES
(1, 'Beverages');

INSERT INTO Purchasing.Vendor (VendorID, Name) VALUES
(1, 'Specialty Biscuits, Ltd.');

INSERT INTO Purchasing.ProductVendor (ProductID, VendorID) VALUES
(1, 1),
(2, 1),
(3, 1);

INSERT INTO HumanResources.Employee (EmployeeID, FirstName, LastName, ManagerID) VALUES
(1, 'John', 'Doe', NULL),
(2, 'Jane', 'Smith', 1),
(3, 'Jim', 'Brown', 1);


--List of all customers

SELECT * FROM Sales.Customer;

--List of all customers where company name ending in N

SELECT * FROM Sales.Customer
WHERE CompanyName LIKE '%N';

--List of all customers who live in Berlin or London

SELECT * FROM Sales.Customer
WHERE City IN ('Berlin', 'London');

--List of all customers who live in UK or USA

SELECT * FROM Sales.Customer
WHERE CountryRegionCode IN ('UK', 'US');

--List of all products sorted by product name

SELECT * FROM Production.Product
ORDER BY Name;

--List of all products where product name starts with an A

SELECT * FROM Production.Product
WHERE Name LIKE 'A%';

--List of customers who ever placed an order

SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;

--List of customers who live in London and have bought chai

SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE c.City = 'London' AND p.Name = 'Chai';

--List of customers who never place an order

SELECT c.CustomerID, c.CompanyName
FROM Sales.Customer c
LEFT JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;

--List of customers who ordered Tofu

SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

--Details of first order of the system

SELECT TOP 1 * 
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;

--Find the details of most expensive order date

SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--For each order get the OrderID and Average quantity of items in that order

SELECT SalesOrderID, AVG(OrderQty) AS AverageQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

--For each order get the orderID, minimum quantity and maximum quantity for that order

SELECT SalesOrderID, MIN(OrderQty) AS MinQuantity, MAX(OrderQty) AS MaxQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

--Get a list of all managers and total number of employees who report to them

SELECT ManagerID, COUNT(EmployeeID) AS NumberOfReports
FROM HumanResources.Employee
GROUP BY ManagerID;

--Get the OrderID and the total quantity for each order that has a total quantity of greater than 300

SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;

--List of all orders placed on or after 1996/12/31

SELECT * 
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';

--List of all orders shipped to Canada

SELECT * 
FROM Sales.SalesOrderHeader
WHERE ShipCountryRegionCode = 'CA';

--List of all orders with order total > 200

SELECT * 
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;

--List of countries and sales made in each country

SELECT ShipCountryRegionCode, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY ShipCountryRegionCode;

--List of Customer ContactName and number of orders they placed

SELECT c.CustomerID, c.CompanyName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.CompanyName;

--List of customer contact names who have placed more than 3 orders

SELECT c.CustomerID, c.CompanyName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.CompanyName
HAVING COUNT(soh.SalesOrderID) > 3;

--List of discontinued products which were ordered between 1/1/1997 and 1/1/1998

SELECT DISTINCT p.ProductID, p.Name
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.Discontinued = 1
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

  --List of employee FirstName, LastName, Supervisor FirstName, LastName

  SELECT e.FirstName AS EmployeeFirstName, e.LastName AS EmployeeLastName,
       s.FirstName AS SupervisorFirstName, s.LastName AS SupervisorLastName
FROM HumanResources.Employee e
LEFT JOIN HumanResources.Employee s ON e.ManagerID = s.EmployeeID;

--List of Employees id and total sale conducted by employee

SELECT SalesPersonID, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID;

--List of employees whose FirstName contains character a

SELECT EmployeeID, FirstName, LastName
FROM HumanResources.Employee
WHERE FirstName LIKE '%a%';

--List of managers who have more than four people reporting to them

SELECT ManagerID, COUNT(EmployeeID) AS NumberOfReports
FROM HumanResources.Employee
GROUP BY ManagerID
HAVING COUNT(EmployeeID) > 4;

--List of Orders and ProductNames

SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

--List of orders placed by the best customer

SELECT TOP 1 c.CustomerID, c.CompanyName, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY COUNT(soh.SalesOrderID) DESC;

--List of orders placed by customers who do not have a Fax number

SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE c.Fax IS NULL;

--List of Postal codes where the product Tofu was shipped

SELECT DISTINCT soh.ShipPostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

--List of Product Names that were shipped to France

SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE soh.ShipCountryRegionCode = 'FR';

--List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd.'

SELECT p.Name, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.VendorID = v.VendorID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

--List of products that were never ordered

SELECT p.ProductID, p.Name
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

--List of products where units in stock is less than 10 and units on order are 0

SELECT ProductID, Name
FROM Production.Product
WHERE UnitsInStock < 10 AND UnitsOnOrder = 0;

--List of top 10 countries by sales

SELECT TOP 10 ShipCountryRegionCode, SUM(TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader
GROUP BY ShipCountryRegionCode
ORDER BY TotalSales DESC;

--Number of orders each employee has taken for customers with CustomerIDs between A and AO

SELECT soh.SalesPersonID, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY soh.SalesPersonID;

--Orderdate of most expensive order

SELECT TOP 1 OrderDate
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

--Product name and total revenue from that product

SELECT p.Name, SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name;

--Supplied and number of products offered

SELECT v.Name AS VendorName, COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.Vendor v
JOIN Purchasing.ProductVendor pv ON v.VendorID = pv.VendorID
GROUP BY v.Name;

--Top ten customers based on their business

SELECT TOP 10 c.CustomerID, c.CompanyName, SUM(soh.TotalDue) AS TotalBusiness
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalBusiness DESC;

--What is the total revenue of the company

SELECT SUM(TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
