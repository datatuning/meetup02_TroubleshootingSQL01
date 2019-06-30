-- 
-- PAGELATCH
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE [<your dbname>]
GO
/******************************************************************
Criação do campo Hash para ser o campo de particionamento da tabela
*******************************************************************/
ALTER TABLE tbAcessoApp ADD hashValue AS (CONVERT([INT], abs([id])%(40))) PERSISTED NOT NULL
/*
Demostracao de como funciona o campo hash
select 1%40
select 2%40
select 3%40
select 4%40
select 5%40
select 6%40
select 40%40
*/
/*
Dropa a constraint para incluir o campo hash na PK e poder realizar o particionamento por ele
*/
ALTER TABLE dbo.tbAcessoApp DROP CONSTRAINT PK_tbAcessoApp
GO
/*
Cria partition function com 40 particoes. A quantidade de particoes esta diretamente ligado com a formula do campo hash.
Caso deseje particionar em menos particoes tem que mudar a formula do campo hash.
*/
CREATE PARTITION FUNCTION PF_hashValue (int)  
AS RANGE LEFT FOR VALUES (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39) ;  
GO  
/*
Cria partition scheme jogando todas as particoes para o FG PRIMARY, pois a ideia eh termos um particionamento logico para diminuir o PAGELATCH
*/
CREATE PARTITION SCHEME PS_hashValue   
AS PARTITION PF_hashValue ALL TO([PRIMARY]) ;  
GO
/*
Recriar PK incluindo campo hash na constraint e realizando o particionamento
*/
ALTER TABLE dbo.tbAcessoApp ADD CONSTRAINT PK_tbAcessoApp PRIMARY KEY(id,hashValue) ON PS_hashValue(hashValue)
GO
/*
Apos particionar a tabela refaca a a simulacao com o SQLQueryStress com as mesmas 
configuracoes citadas no arquivo 0.Simulacao
*/
/**************************************************************
Query para consultar a distribuição dos registros nas partições
**************************************************************/
DECLARE @TABLE_NAME SYSNAME = 'tbAcessoApp'
SELECT
 T.OBJECT_ID,
 T.NAME,
 P.PARTITION_ID,
 P.PARTITION_NUMBER,
 P.ROWS
FROM SYS.PARTITIONS P
INNER JOIN SYS.TABLES T ON P.OBJECT_ID = T.OBJECT_ID
WHERE P.PARTITION_ID IS NOT NULL
AND T.NAME = @TABLE_NAME
AND P.index_id = 1
ORDER BY P.partition_number
