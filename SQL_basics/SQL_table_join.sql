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

#4. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00, dla każdego produktu podaj
#dane adresowe dostawcy.
SELECT ProductName, UnitPrice, Suppliers.Address, Suppliers.City, Suppliers.Country FROM Products
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
WHERE UnitPrice BETWEEN 20 AND 30

#5. Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych przez firmę Tokyo
#Traders.
SELECT ProductName, UnitsInStock, Suppliers.CompanyName FROM Products
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
WHERE Suppliers.CompanyName = 'Tokyo Traders'

#6. Wybierz nazwy i numery telefonów dostawców, dostarczających produkty, których aktualnie nie ma w
#magazynie
SELECT CompanyName, Phone, Products.UnitsInStock FROM Suppliers
JOIN Products ON Suppliers.SupplierID = Products.SupplierID
WHERE Products.UnitsInStock = 0

#7. Napisz polecenie zwracające listę produktów zamawianych w dniu 1996-08-04.
SELECT Products.ProductName, OrderDate FROM Orders
JOIN `Order Details` ON Orders.OrderID = `Order Details`.OrderID
JOIN Products ON `Order Details`.ProductID = Products.ProductID
WHERE OrderDate = '1994-08-04'

#8. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00, dla każdego produktu podaj
#dane adresowe dostawcy, interesują nas tylko produkty z kategorii Meat/Poultry.
SELECT ProductName, UnitPrice, Categories.CategoryName FROM Products
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
JOIN Categories ON Products.ProductID = Categories.CategoryID
WHERE (UnitPrice BETWEEN 20 AND 30)
AND (CategoryName = 'Meat/Poultry')

#9. Wybierz nazwy i ceny produktów z kategorii Confections dla każdego produktu podaj nazwę dostawcy.
SELECT ProductName, UnitPrice, Suppliers.CompanyName, Categories.CategoryName FROM Products
JOIN Suppliers ON Products.SupplierID = Suppliers.SupplierID
JOIN Categories ON Products.ProductID = Categories.CategoryID
WHERE Categories.CategoryName = 'Confections'

#10. Wybierz nazwy i numery telefonów klientów, którym w 1997 roku przesyłki dostarczała firma United
#Package.
SELECT DISTINCT Customers.CompanyName, Customers.Phone, Shippers.CompanyName, Orders.OrderDate FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN Shippers ON Shippers.ShipperID = Orders.ShipVia
WHERE YEAR(Orders.OrderDate) = 1994 AND Shippers.CompanyName LIKE 'United Package'

#11. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii Confections.
SELECT DISTINCT CompanyName, Phone, Categories.CategoryName FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
JOIN `Order Details` ON Orders.OrderID = `Order Details`.OrderID
JOIN Products ON Products.ProductID = `Order Details`.ProductID
JOIN Categories ON Categories.CategoryID = Products.CategoryID
WHERE CategoryName = 'Confections'

#12. Napisz polecenie, które pokazuje pary pracowników zajmujących to samo stanowisko
SELECT a.LastName, a.Title, b.Title, b.LastName FROM Employees AS a
JOIN Employees AS b
ON a.Title = b.Title
WHERE a.EmployeeID < b.EmployeeID

#13. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych
SELECT a.EmployeeID, a.FirstName, a.LastName, a.ReportsTo, b.EmployeeID, b.FirstName, b.LastName, b.ReportsTo
FROM Employees AS a
JOIN Employees AS b ON b.ReportsTo = a.EmployeeID
ORDER BY a.LastName

#14. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych
SELECT a.EmployeeID, a.FirstName, a.LastName, a.ReportsTo FROM Employees AS a
LEFT OUTER JOIN Employees AS b ON b.ReportsTo = a.EmployeeID
WHERE b.EmployeeID is NULL
ORDER BY a.LastName

#15. Dla każdej kategorii produktu, podaj łączną liczbę zamówionych jednostek
SELECT Categories.CategoryName, SUM(Products.UnitsOnOrder) FROM Categories
JOIN Products ON Categories.CategoryID = Products.CategoryID
GROUP BY Categories.CategoryName

#16. Dla każdego zamówienia podaj łączną liczbę zamówionych jednostek
SELECT `Order Details`.OrderID, SUM(quantity) AS Sum_Quantity FROM `Order Details`
JOIN Products ON `Order Details`.ProductID = Products.ProductID
GROUP BY `Order Details`.OrderID
ORDER BY 2 DESC

#17. Zmodyfikuj poprzedni przykład, aby pokazać tylko takie zamówienia, dla których łączna liczba jednostek jest
#większa niż 250
SELECT `Order Details`.OrderID, SUM(quantity) AS Sum_Quantity FROM `Order Details`
JOIN Products ON `Order Details`.ProductID = Products.ProductID
GROUP BY `Order Details`.OrderID HAVING (SUM(quantity) > 250)
ORDER BY 2 DESC