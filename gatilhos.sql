GO

--Crie uma trigger que impeça a inserção de um novo pedido se tanto o cliente (Customers), quanto o vendedor (Employees) forem da mesma cidade e já tiverem realizados mais de 10 pedidos no último mês.
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


GO 

--Crie uma trigger na tabela Products para INSERT e UPDATE que garanta que existam no máximo 10 preços unitários (Products.UnitPrice) diferentes para fornecedores Paraguaios.
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