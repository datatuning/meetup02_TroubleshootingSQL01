-- 
-- ERROR 666
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE master
GO
IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE NAME = 'dbUniquifier')
BEGIN
	CREATE DATABASE [dbUniquifier] ON PRIMARY 
	( NAME = N'dbUniquifier', FILENAME = N'E:\SQLDADOS01\dbUniquifiermdf' , SIZE = 1000MB , FILEGROWTH = 1000MB)
	 LOG ON
	( NAME = N'dbUniquifier_log', FILENAME = N'E:\SQLLOG01\dbUniquifier_log.ldf' , SIZE = 1000MB , FILEGROWTH = 1000MB)
END
GO
USE dbUniquifier
GO
/*
Cria função que gera números aleatórios para ajudar nos 
inserts em massa na preparação do ambiente
Autor: Itzik Ben-Gan
Reference: http://tsql.solidq.com/SourceCodes/GetNums.txt
*/
IF OBJECT_ID('dbo.GetNums') IS NOT NULL
  DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
WITH
L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
SELECT n FROM Nums WHERE n <= @n;
GO
IF EXISTS(SELECT 1 FROM sys.tables WHERE name='UniqTable1') DROP TABLE dbo.UniqTable1
GO
CREATE TABLE dbo.UniqTable1(
	Id INT NOT NULL,
	Id2 INT NOT NULL,
	RecDate DATETIME DEFAULT(SYSDATETIME())
)
GO
CREATE CLUSTERED INDEX idx_UniqTable1 ON dbo.UniqTable1(Id,Id2)
ALTER INDEX idx_UniqTable1 ON dbo.UniqTable1 REBUILD WITH(DATA_COMPRESSION=PAGE)
GO
/*
Insere 2.147.000.000 bilhões de registros de 10 mil em 10 mil registros
e apaga 9.999 para não deixar a tabela vazia, pois se apagar todos os
registros o Uniquiefier ZERA. Nesse caso faltará 483.647 registros para
que ocorra o problema.

Obs: levará várias e várias horas... tenha paciência ou use o backup que 
     disponibilizamos no diretorio Backup do repositorio onde faltam 
	 100.000 registros para que ocorra o problema
*/
DECLARE @CONTADOR INT = 0
WHILE(@CONTADOR < 214700)
BEGIN
	INSERT INTO dbo.UniqTable1 (Id,Id2)
	SELECT 1,2
	FROM dbo.GetNums(10000);
	
	DELETE TOP(9999) FROM dbo.UniqTable1
	SET @CONTADOR = @CONTADOR + 1
	PRINT '@CONTADOR: ' + CAST(@CONTADOR AS VARCHAR(10))
END
GO