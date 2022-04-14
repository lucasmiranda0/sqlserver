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
