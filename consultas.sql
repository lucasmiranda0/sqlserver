GO

--Retorne os nomes dos produtos que começam com as letras a, d, de m a z, ordenados por nome.
SELECT ProductName From Products 
WHERE ProductName LIKE 'A%' 
OR ProductName LIKE 'D%'
OR ProductName LIKE '[M-Z]%'
ORDER BY ProductName 

GO

--Retorne os nomes dos fornecedores que estão sem homepage informada na tabela.
SELECT CompanyName  FROM Suppliers 
WHERE HomePage IS NULL 

GO

--Mostre a lista de países dos clientes da empresa (tabela Customers), sem repetições
SELECT DISTINCT Country FROM Customers 

GO

--Mostre os nomes dos clientes que não fizeram pedidos
SELECT CompanyName FROM Customers 
WHERE CustomerID NOT IN
(SELECT CustomerID FROM Orders)

GO

--Listar sem repetições os nomes de empregados que fizeram pedidos no mês de Janeiro/1997
SELECT DISTINCT FirstName, LastName FROM Employees AS E
INNER JOIN Orders AS O 
ON E.EmployeeID = O.EmployeeID 
WHERE OrderDate BETWEEN  '1997-01-01' AND '1997-01-31' 

GO

--Listar os nomes das empresas clientes atendidas por Nancy Davolio, sem repetições
SELECT DISTINCT  CompanyName FROM Customers C
INNER JOIN Orders AS O 
ON C.CustomerID = O.CustomerID  
WHERE O.EmployeeID = 8 

GO

--Mostrar os nomes e telefones de clientes e empregados.
SELECT C.CompanyName, C.Phone 
FROM Customers C
UNION 
SELECT name = (E.FirstName + ' ' + E.LastName), E.HomePhone 
FROM Employees E

GO

--Mostre a menor e maior datas de pedidos realizados.
SELECT MIN(OrderDate), MAX(OrderDate) FROM Orders

GO

--Mostrar quantos produtos existem em cada categoria. Mostrar o nome da categoria (tabelas Products e Categories)
SELECT c.CategoryName, COUNT(*) AS Qtd FROM Products p 
JOIN Categories c 
ON p.CategoryID=c.CategoryID 
GROUP BY c.CategoryName

GO

--Listar a quantidade de pedidos feitos por cada cliente entre Janeiro/97 e Junho/97. Mostrar o nome da empresa cliente.
SELECT COUNT(Orders.OrderID) AS QTD, Customers.CompanyName 
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID 
WHERE OrderDate BETWEEN '01/01/1997' AND '06/30/1997'
GROUP BY Customers.CompanyName 

GO

--Listar a venda total realizada por empregado no mês de Abril/1997
SELECT COUNT(Orders.OrderID) AS QTD, Employees.FirstName, Employees.LastName  
FROM Orders
INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID  
WHERE OrderDate BETWEEN '04/01/1997' AND '04/30/1997'
GROUP BY Employees.FirstName, Employees.LastName   

GO

--Listar o nome e a soma dos valores de pedidos feitos para cada produto no mês de Março/1998 dos 10 maiores 
SELECT TOP 10 SUM(od.UnitPrice * od.Quantity), p.ProductName FROM Orders o 
JOIN [Order Details] od ON o.OrderID= od.OrderID 
JOIN Products p ON p.ProductID=od.ProductID
WHERE MONTH(o.OrderDate) = 3 AND YEAR(o.OrderDate) = 1998
GROUP BY p.ProductName 

GO

--Listar os 5 fornecedores que mais foram acionados no ano de 1997, por total de vendas. Mostrar o nome do fornecedor e o total da venda.
SELECT TOP 5 COUNT(Orders.OrderID) AS QTD, Customers.CompanyName  
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID  
WHERE OrderDate BETWEEN '01/01/1997' AND '12/31/1997'
GROUP BY Customers.CompanyName  