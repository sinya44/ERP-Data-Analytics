USE ERP_DB;
GO
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
ALTER TABLE PurchaseOrders ADD CONSTRAINT CHK_PO_Quantity CHECK (Quantity > 0);
ALTER TABLE PurchaseOrders ADD CONSTRAINT CHK_PO_UnitPrice CHECK (UnitPrice > 0);
ALTER TABLE Customers ADD CONSTRAINT UQ_Customer_Email UNIQUE (CustomerEmail);
ALTER TABLE Payments ADD CONSTRAINT DF_Payment_Status DEFAULT 'Pending' FOR PaymentStatus;
EXEC sp_fkeys @pktable_name = 'Customers';
EXEC sp_fkeys @pktable_name = 'Products';
ALTER TABLE PurchaseOrders ADD CONSTRAINT FK_PurchaseOrders_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID);
ALTER TABLE PurchaseOrders ADD CONSTRAINT FK_PurchaseOrders_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
ALTER TABLE Inventory ADD CONSTRAINT FK_Inventory_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
ALTER TABLE Returns ADD CONSTRAINT FK_Returns_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);
ALTER TABLE Payments ADD SalesOrderID INT;
ALTER TABLE Payments ADD CONSTRAINT FK_Payments_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);
ALTER TABLE Shipments ADD SalesOrderID INT;
ALTER TABLE Shipments ADD CONSTRAINT FK_Shipments_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);
ALTER TABLE Returns ADD SalesOrderID INT;
ALTER TABLE Returns ADD CONSTRAINT FK_Returns_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);
SELECT DISTINCT SalesOrderID
FROM Returns
WHERE SalesOrderID IS NOT NULL
AND SalesOrderID NOT IN
(
    SELECT SalesOrderID
    FROM SalesOrders
);
SELECT COUNT(*) AS TotalSalesOrders FROM SalesOrders;
SELECT COUNT(*) AS TotalRows FROM ERP_Raw;
SELECT COUNT(DISTINCT SalesOrderID) AS UniqueSalesOrders FROM ERP_Raw;
INSERT INTO SalesOrders
(
    SalesOrderID,
    CustomerID,
    EmployeeID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice,
    TotalSalesAmount
)
SELECT
    SalesOrderID,
    MAX(CustomerID),
    MAX(EmployeeID),
    MAX(ProductID),
    MAX(OrderDate),
    MAX(Quantity),
    MAX(UnitPrice),
    MAX(Total_Sales)
FROM ERP_Raw
WHERE SalesOrderID IS NOT NULL
GROUP BY SalesOrderID;
SELECT COUNT(*) AS TotalSalesOrders FROM SalesOrders;
ALTER TABLE Payments ADD CONSTRAINT FK_Payments_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'SalesOrders';
sp_help Payments;
sp_help Shipments;
SELECT
    fk.name AS ForeignKeyName
FROM sys.foreign_keys fk
WHERE parent_object_id = OBJECT_ID('Payments');
SELECT
    fk.name AS ForeignKeyName
FROM sys.foreign_keys fk
WHERE parent_object_id = OBJECT_ID('Returns');
SELECT r.ReturnID, r.SalesOrderID
FROM Returns r
LEFT JOIN SalesOrders s
ON r.SalesOrderID = s.SalesOrderID
WHERE s.SalesOrderID IS NULL;
SELECT TOP 10
ReturnID,
SalesOrderID
FROM ERP_Raw
WHERE ReturnID IS NOT NULL;
DELETE FROM Returns;
INSERT INTO Returns (ReturnID, SalesOrderID)
SELECT
    ReturnID,
    MAX(SalesOrderID)
FROM ERP_Raw
WHERE ReturnID IS NOT NULL
GROUP BY ReturnID;
SELECT TOP 10 * FROM Returns;
ALTER TABLE Returns ADD CONSTRAINT FK_Returns_SalesOrders FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID);