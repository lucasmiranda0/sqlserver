GO

--Dado um país (country) passado como parâmetro para uma stored procedure, retorne uma tabela que tenha os campos nomes dos clientes (Customers.CompanyName), nomes dos vendedores (Employees.FirstName, Employees.LastName) e o número e a data do pedido (Order.OrderID, Order.OrderDate) para todos os pedidos que tanto, o vendedor, quanto o cliente, quanto os fornecedores dos produtos do pedido sejam todos do país recebido como parâmetro. OBS: o pedido deverá ser desconsiderado se tiver pelo menos 1 produto de um fornecedor que não seja do país desejado.
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


GO

--Crie uma stored procedure que retorne uma tabela que mostre os três produtos mais vendidos de cada categoria (Categories.CategoryID, Categories.CategoryName), ordenando por Products.CategoryID e Products.ProductName. Considere o somatório do campo quantidade ([Order Details].quantity) para verificar os produtos mais vendidos. OBS: não é permitida a utilização de cursores.
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