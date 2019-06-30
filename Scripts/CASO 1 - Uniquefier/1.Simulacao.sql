-- 
-- ERROR 666
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE dbUniquifier
GO
EXEC sp_spaceused UniqTable
GO
/*Insere registros de 10 mil em 10 mil até causar o erro 666*/
INSERT INTO UniqTable(Id,Id2)
SELECT 1,2 FROM GetNums(10000)
GO
/*
Consulta os últimos 10 registros e gera o commando DBCC PAGE 
já com o endereço a página onde está o registro.
*/
SELECT TOP 10 *,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.UniqTable 
ORDER BY Id DESC, Id2 DESC
GO
/*Consulta o Uniqueifier é necessário habilitar a TF 3604 para rodar o DBCC PAGE*/
DBCC TRACEON(3604)
GO
--Cola o resultado da query que monta o comando DBCC PAGE para verificar o UNIQUEIFIER do registro
DBCC PAGE('dbUniquifier',1,512,3)
GO
/*
>>> Troubleshooting 1 <<<
Abaixo tentamos várias formas de rebuild para sanar o problema do erro 666
Apenas a opção de ALTER INDEX ALL....WITH(ONLINE=ON) que resolve o problema(cuidado, não é garantido que continuará funcionando nas próximas versões)
Referências:
	https://blogs.msdn.microsoft.com/psssql/2018/02/16/uniqueifier-considerations-and-error-666/
	https://blogs.msdn.microsoft.com/luti/2018/02/16/uniqueifier-details-in-sql-server/

*/
ALTER INDEX idx_UniqTable ON UniqTable REBUILD
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX idx_UniqTable ON UniqTable REBUILD PARTITION = ALL
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX idx_UniqTable ON UniqTable REBUILD WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX idx_UniqTable ON UniqTable REBUILD PARTITION = ALL WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX ALL ON UniqTable REBUILD 
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX ALL ON UniqTable REBUILD PARTITION = ALL 
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
ALTER INDEX ALL ON UniqTable REBUILD WITH(ONLINE=ON)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
/*
>>> Troubleshooting 2 <<<
Outra forma de resolução e a que a própria descrição do erro informa a fazer...
*/
DROP INDEX idx_UniqTable ON UniqTable
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
CREATE CLUSTERED INDEX IDX_UniqTable ON UniqTable(Id,Id2)
INSERT INTO UniqTable(Id,Id2) VALUES(1,2)
GO
/*
Consulta os últimos 10 registros e gera o commando DBCC PAGE 
já com o endereço a página onde está o registro.
*/
SELECT top 10 *
, sys.fn_physlocformatter(%%PHYSLOC%%) AS PhysLocation
,'DBCC PAGE('''+DB_NAME()+''',1,'+SUBSTRING(sys.fn_physlocformatter(%%PHYSLOC%%),4,CHARINDEX(':',sys.fn_physlocformatter(%%PHYSLOC%%),4)-4)+',3)' as DBCCPAGE
FROM dbo.UniqTable 
ORDER BY Id DESC, Id2 DESC
/*Consulta o Uniqueifier é necessário habilitar a TF 3604 para rodar o DBCC PAGE*/
DBCC TRACEON(3604)
GO
/*Cola o resultado da query que monta o comando DBCC PAGE para verificar o UNIQUEIFIER do registro*/
DBCC PAGE('dbUniquifier',1,16189,3)
GO