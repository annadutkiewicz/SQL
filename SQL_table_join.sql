#1. Napisz polecenie zwracające nazwy produktów i firmy je dostarczające (tak aby produkty bez dostarczycieli i
#dostarczyciele. bez produktów nie pojawiali się w wyniku).
SELECT CompanyName, Products.ProductName FROM Suppliers
JOIN Products ON Suppliers.SupplierID = Products.SupplierID

#2. Napisz polecenie zwracające jako wynik nazwy klientów, którzy złożyli zamówienia po 01 marca 1996
SELECT DISTINCT Customers.CompanyName, OrderDate FROM Orders
JOIN Customers ON Customers.CustomerID = Orders.CustomerID
WHERE OrderDate > '1996-03-01'

#3. Napisz polecenie zwracające wszystkich klientów z datami zamówień.
SELECT DISTINCT Customers.CompanyName, OrderDate FROM Orders
JOIN Customers ON Customers.CustomerID = Orders.CustomerID