-- 
-- PAGELATCH
-- @datatuning
-- https://blog.datatuning.com.br/
-- 
USE [<your dbname>]
GO
--Cria��o da tabela
if exists(select 1 from sys.tables where name = 'tbAcessoApp')
begin
	drop table dbo.tbAcessoApp
end
create table dbo.tbAcessoApp
(
	id int identity not null,
	origem uniqueidentifier, 
	[data] datetime,
	constraint PK_tbAcessoApp PRIMARY KEY(id)
)
go
exec sp_spaceused tbAcessoApp
exec sp_help tbAcessoApp
go
/*************************************************************************
*******************Comandos para inser��es na tabela**********************
*************************************************************************/
create procedure dbo.pr_InsereAcessoApp
as
begin
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
insert into dbo.tbAcessoApp (origem,data) values(newid(),getdate())
end
go
/*
Execute o programa SQLQueryStress que est� no diretorio Ferramentas e execute o comando:
EXEC dbo.pr_InsereAcessoApp
Configura��es:
1. clique no bot�o Database e configure seu acesso;
2. Number of iteration: 1000
3. Number of threads: 2000

O programa ir� abrir 2000 conex�es simultaneas e cada conexao executara a procedure pr_InsereAcessoApp 1000 vezes.
*/
/*
Query para consultar a quantidade de conex�es abertas
*/
select count(0) from sys.dm_exec_connections
/*
Query que consulta o total de requisicoes por wait_resource.
Essa query mostra claramente que varias requests estao aguardando para escrever na mesma pagina
*/
select wait_resource,count(0) as totalrequests from sys.dm_exec_requests r group by wait_resource order by count(0) desc
/*
Procedure que lista as requests do banco de dados com algumas informacoes interessantes
*/
exec master..sp_requests
go
