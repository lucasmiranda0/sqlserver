# Consultas, Procedimentos Armazenados e Gatilhos feitos no SQLServer

A base de dados NorthWind foi utilizada para a realização desses exercícios.

**Consultas**:

1. Retorne os nomes dos produtos que começam com as letras a, d, de m a z, ordenados por nome.

```sql
SELECT ProductName From Products 
WHERE ProductName LIKE 'A%' 
OR ProductName LIKE 'D%'
OR ProductName LIKE '[M-Z]%'
ORDER BY ProductName 
```

2. Retorne os nomes dos fornecedores que estão sem homepage informada na tabela.

```sql
SELECT CompanyName  FROM Suppliers 
WHERE HomePage IS NULL
```

3. Mostre a lista de países dos clientes da empresa (tabela Customers), sem repetições

```sql
SELECT DISTINCT Country FROM Customers 
```

4. Mostre os nomes dos clientes que não fizeram pedidos

```sql
SELECT CompanyName FROM Customers 
WHERE CustomerID NOT IN
(SELECT CustomerID FROM Orders)
```

5. Listar sem repetições os nomes de empregados que fizeram pedidos no mês de Janeiro/1997

```sql
SELECT DISTINCT FirstName, LastName FROM Employees AS E
INNER JOIN Orders AS O 
ON E.EmployeeID = O.EmployeeID 
WHERE OrderDate BETWEEN  '1997-01-01' AND '1997-01-31' 
```

6. Listar os nomes das empresas clientes atendidas por Nancy Davolio, sem repetições

```sql
SELECT DISTINCT  CompanyName FROM Customers C
INNER JOIN Orders AS O 
ON C.CustomerID = O.CustomerID  
WHERE O.EmployeeID = 8 
```

7. Mostrar os nomes e telefones de clientes e empregados.

```sql
SELECT C.CompanyName, C.Phone 
FROM Customers C
UNION 
SELECT name = (E.FirstName + ' ' + E.LastName), E.HomePhone 
FROM Employees E
```

8. Mostre a menor e maior datas de pedidos realizados.

```sql
SELECT MIN(OrderDate), MAX(OrderDate) FROM Orders
```

9. Mostrar quantos produtos existem em cada categoria. Mostrar o nome da categoria (tabelas Products e Categories)

```sql
SELECT c.CategoryName, COUNT(*) AS Qtd FROM Products p 
JOIN Categories c 
ON p.CategoryID=c.CategoryID 
GROUP BY c.CategoryName
```

10. Listar a quantidade de pedidos feitos por cada cliente entre Janeiro/97 e Junho/97. Mostrar o nome da empresa cliente.

```sql
SELECT COUNT(Orders.OrderID) AS QTD, Customers.CompanyName 
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID 
WHERE OrderDate BETWEEN '01/01/1997' AND '06/30/1997'
GROUP BY Customers.CompanyName 
```

11. Listar a venda total realizada por empregado no mês de Abril/1997

```sql
SELECT COUNT(Orders.OrderID) AS QTD, Employees.FirstName, Employees.LastName  
FROM Orders
INNER JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID  
WHERE OrderDate BETWEEN '04/01/1997' AND '04/30/1997'
GROUP BY Employees.FirstName, Employees.LastName 
```

12. Listar o nome e a soma dos valores de pedidos feitos para cada produto no mês de Março/1998 dos 10 maiores 

```sql
SELECT TOP 10 SUM(od.UnitPrice * od.Quantity), p.ProductName FROM Orders o 
JOIN [Order Details] od ON o.OrderID= od.OrderID 
JOIN Products p ON p.ProductID=od.ProductID
WHERE MONTH(o.OrderDate) = 3 AND YEAR(o.OrderDate) = 1998
GROUP BY p.ProductName 
```

13. Listar os 5 fornecedores que mais foram acionados no ano de 1997, por total de vendas. Mostrar o nome do fornecedor e o total da venda.

```sql
SELECT TOP 5 COUNT(Orders.OrderID) AS QTD, Customers.CompanyName  
FROM Orders
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID  
WHERE OrderDate BETWEEN '01/01/1997' AND '12/31/1997'
GROUP BY Customers.CompanyName 
```



**Procedimentos armazenados**:

1. Dado um país (country) passado como parâmetro para uma stored procedure, retorne uma tabela que tenha os campos nomes dos clientes (Customers.CompanyName), nomes dos vendedores (Employees.FirstName, Employees.LastName) e o número e a data do pedido (Order.OrderID, Order.OrderDate) para todos os pedidos que tanto, o vendedor, quanto o cliente, quanto os fornecedores dos produtos do pedido sejam todos do país recebido como parâmetro. OBS: o pedido deverá ser desconsiderado se tiver pelo menos 1 produto de um fornecedor que não seja do país desejado.

```sql
CREATE PROC questao1
@country varchar(30) AS
SELECT c.CompanyName, e.FirstName, e.LastName, o.OrderID, o.OrderDate 
FROM Orders o 
JOIN Customers c ON c.CustomerID = o.CustomerID 
JOIN Employees e ON e.EmployeeID = o.EmployeeID
JOIN [Order Details] od ON od.OrderID = o.OrderID 
JOIN Products p ON p.ProductID = od.ProductID 
JOIN Suppliers s ON s.SupplierID = p.SupplierID
WHERE o.ShipCountry = @country AND c.Country = @country AND e.Country = @country AND s.Country = @country

EXEC questao1 'USA'
```

2. Crie uma stored procedure que retorne uma tabela que mostre os três produtos mais vendidos de cada categoria (Categories.CategoryID, Categories.CategoryName), ordenando por Products.CategoryID e Products.ProductName. Considere o somatório do campo quantidade ([Order Details].quantity)  para verificar os produtos mais vendidos. OBS: não é permitida a utilização de cursores.

```sql
CREATE PROC questao2 AS
SELECT * FROM (
SELECT SUM(od.ProductID * od.Quantity) AS teste, p.ProductID, p.ProductName, c.CategoryName,
ROW_NUMBER() OVER (PARTITION BY c.CategoryName 
ORDER BY SUM(od.ProductID * od.Quantity) DESC, c.CategoryName) AS consulta1
FROM [Order Details] od 
JOIN Products p ON p.ProductID = od.ProductID 
JOIN Categories c ON c.CategoryID = p.CategoryID 
GROUP BY p.ProductID, p.ProductName, c.CategoryName
) consulta 
WHERE consulta1 <=3

EXEC questao2 
```



**Gatilhos**:

1. Crie uma trigger que impeça a inserção de um novo pedido se tanto o cliente (Customers), quanto o vendedor (Employees) forem da mesma cidade e já tiverem realizados mais de 10 pedidos no último mês.

```sql
CREATE TRIGGER questao3 
ON Orders 
FOR INSERT AS
IF (SELECT COUNT(*) FROM INSERTED Orders 
JOIN Customers c ON c.CustomerID = Orders.CustomerID 
WHERE MONTH(Orders.OrderDate) = MONTH(GETDATE()) 
AND YEAR(Orders.OrderDate) = YEAR(GETDATE())) > 10 
AND (SELECT COUNT(*) FROM INSERTED Orders
JOIN Customers c2 ON c2.CustomerID = Orders.CustomerID
JOIN Employees e2 ON e2.EmployeeID = Orders.EmployeeID
WHERE c2.City = e2.City) > 0
BEGIN 
	PRINT 'Mais de 10 preços unitários'
	ROLLBACK TRANSACTION 
END
ELSE IF (SELECT COUNT(*) FROM INSERTED Orders 
JOIN Employees e ON e.EmployeeID = Orders.EmployeeID  
WHERE MONTH(Orders.OrderDate) = MONTH(GETDATE()) 
AND YEAR(Orders.OrderDate) = YEAR(GETDATE())) > 10
AND (SELECT COUNT(*) FROM INSERTED Orders
JOIN Customers c2 ON c2.CustomerID = Orders.CustomerID
JOIN Employees e2 ON e2.EmployeeID = Orders.EmployeeID
WHERE c2.City = e2.City) > 0
BEGIN 
	PRINT 'Mais de 10 preços unitários'
	ROLLBACK TRANSACTION 
END

EXEC questao3
```

2. Crie uma trigger na tabela Products para INSERT e UPDATE que garanta que  existam no máximo 10 preços unitários (Products.UnitPrice) diferentes para fornecedores Paraguaios.

```sql
CREATE TRIGGER questao4
ON Products 
FOR INSERT, UPDATE AS
IF (SELECT COUNT(DISTINCT p.UnitPrice) FROM Products p 
  JOIN Suppliers s ON s.SupplierID = p.SupplierID 
  WHERE s.Country = 'Paraguay') > 10
BEGIN 
	PRINT 'Mais de 10 preços unitários'
	ROLLBACK TRANSACTION 
END

EXEC questao4
```
