#1.  Wybierz nazwy i adresy wszystkich klientów
SELECT CompanyName, Address FROM Customers

#2.  Wybierz nazwiska i numery telefonów pracowników
SELECT LastName, HomePhone FROM Employees

#3.  Wybierz nazwy i ceny produktów
SELECT ProductName, UnitPrice FROM Products

#4.  Pokaż wszystkie kategorie produktów (nazwy i opisy)
SELECT CategoryName, Description FROM Categories

#5.  Pokaż nazwy i adresy stron www dostawców
SELECT CompanyName, HomePage FROM Suppliers

#6.  Wybierz nazwy i adresy wszystkich klientów mających siedziby w Londynie
SELECT CompanyName, Address, City FROM Customers
WHERE City = 'London'

#7.  Wybierz nazwy i adresy wszystkich klientów mających siedziby we Francji lub w Hiszpanii
SELECT CompanyName, Address, Country FROM Customers
WHERE Country = 'France' OR Country = 'Spain'

#8.  Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00
SELECT ProductName, UnitPrice FROM Products
WHERE UnitPrice BETWEEN 20.00 AND 30.00

#9.  Wybierz nazwy i ceny produktów z kategorii “meat”
SELECT Products.ProductName, Products.UnitPrice, Categories.CategoryName FROM Products
JOIN Categories ON Categories.CategoryID = Products.CategoryID
WHERE Categories.CategoryName LIKE 'Meat/Poultry'

#10.  Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych przez firmę
#“Tokyo Traders”
SELECT Products.ProductName, Products.UnitsInStock, Suppliers.CompanyName FROM Products
JOIN Suppliers ON Suppliers.SupplierID = Products.SupplierID
WHERE Suppliers.CompanyName LIKE 'Tokyo Traders'

#11.  Wybierz nazwy produktów których nie ma w magazynie
SELECT ProductName, UnitsInStock FROM Products
WHERE UnitsInStock = 0

#12. Szukamy informacji o produktach sprzedawanych w butelkach (bottle)
SELECT * FROM Products
WHERE QuantityPerUnit LIKE '%bottle%'

#13.  Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się na literę z
#zakresu od B do L
SELECT * FROM Employees
WHERE LastName BETWEEN 'B%' AND 'M%'

#14.  Wyszukaj informacje o stanowisku pracowników, których nazwiska zaczynają się na literę B lub L
SELECT LastName, Title FROM Employees
WHERE LastName LIKE 'B%' OR LastName LIKE 'L%'

#15.  Znajdź nazwy kategorii, które w opisie zawierają przecinek

#16.  Znajdź klientów, którzy w swojej nazwie mają w którymś miejscu słowo “Store”

#17.  Szukamy informacji o produktach o cenach mniejszych niż 10 lub większych niż 20

#18.  Napisz instrukcję select tak aby wybrać numer zlecenia, datę zamówienia, numer klienta dla
#wszystkich niezrealizowanych jeszcze zleceń, dla których krajem odbiorcy jest Argentyna

#19.  Wybierz nazwy i kraje wszystkich klientów, wyniki posortuj według kraju, w ramach danego kraju
#nazwy firm posortuj alfabetycznie

#20.  Wybierz informację o produktach (grupa, nazwa, cena), produkty posortuj wg grup a w grupach
#malejąco wg ceny

#21.  Wybierz nazwy i kraje wszystkich klientów mających siedziby w Japonii (Japan) lub we Włoszech
#(Italy), wyniki posortuj według kraju, w ramach danego kraju nazwy firm posortuj alfabetycznie
