#1. Policz średnią cenę jednostkową dla wszystkich produktów w tabeli products.
SELECT AVG(UnitPrice) FROM Products

#2. Zsumuj wszystkie wartości w kolumnie quantity w tabeli order details
SELECT SUM(Quantity) FROM `Order Details`

#3. Podaj liczbę produktów o cenach mniejszych niż 10$ lub większych niż 20$
SELECT COUNT(*) FROM Products
WHERE (UnitPrice < 10) OR (UnitPrice > 20)

#4. Podaj maksymalną cenę produktu dla produktów o cenach poniżej 20$
SELECT MAX(UnitPrice) FROM Products
WHERE UnitPrice < 20

#5. Podaj maksymalną i minimalną i średnią cenę produktu dla produktów o produktach sprzedawanych w
#butelkach (bottle)
SELECT MAX(UnitPrice), MIN(UnitPrice), AVG(UnitPrice) FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

#6. Wypisz informację o wszystkich produktach o cenie powyżej średniej
SELECT * FROM Products
WHERE UnitPrice > (SELECT AVG(Unitprice) FROM Products)

#7. Podaj sumę zamówienia o numerze 10250
SELECT *, (UnitPrice * Quantity * (1 - Discount)) FROM `Order Details`
WHERE OrderID = 10250

#8. Napisz polecenie, które zwraca informacje o zamówieniach z tablicy order details. Zapytanie ma grupować i
#wyświetlać identyfikator każdego produktu a następnie obliczać ogólną zamówioną ilość. Ogólna ilość jest sumowana
#funkcją agregującą SUM i wyświetlana jako jedna wartość dla każdego produktu.
SELECT ProductID, SUM(Quantity) FROM `Order Details`
GROUP BY ProductID

#9. Podaj maksymalną cenę zamawianego produktu dla każdego zamówienia
SELECT OrderID, MAX(UnitPrice) FROM `Order Details`
GROUP BY OrderID

#10. Posortuj zamówienia wg maksymalnej ceny produktu
SELECT OrderID, MAX(UnitPrice) AS max FROM `Order Details`
GROUP BY OrderID
ORDER BY max DESC

#11. Podaj maksymalną i minimalną cenę zamawianego produktu dla każdego zamówienia
SELECT OrderID, MAX(UnitPrice) AS max, MIN(UnitPrice) AS min FROM `Order Details`
GROUP BY OrderID

#12. Podaj liczbę zamówień dostarczanych przez poszczególnych spedytorów
SELECT ShipVia, COUNT(OrderID) FROM Orders
GROUP BY ShipVia

#13. Który z spedytorów był najaktywniejszy w 1994 roku
SELECT ShipVia, COUNT(OrderID) FROM Orders
WHERE YEAR(ShippedDate) = 1994
GROUP BY ShipVia

#14. Wyświetl zamówienia dla których liczba pozycji zamówienia jest większa niż 5
SELECT * FROM `Order Details`
GROUP BY OrderID HAVING COUNT(OrderID) > 5

#15. Wyświetl klientów którzy dla których w 1995 roku zrealizowano więcej niż 8 zamówień (wyniki posortuj
#malejąco wg łącznej kwoty za dostarczenie zamówień dla każdego z klientów)
SELECT CustomerID, COUNT(OrderID), SUM(Freight) FROM Orders
WHERE YEAR(ShippedDate) = 1995
GROUP BY CustomerID HAVING COUNT(OrderID) > 5
ORDER BY SUM(Freight) DESC