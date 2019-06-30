USE [master]
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'dbUniquifier')
BEGIN
	ALTER DATABASE dbUniquifier SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE dbUniquifier
END
GO
RESTORE DATABASE [dbUniquifier] FROM  DISK = N'C:\Temp\dbUniquifier.bak' WITH  FILE = 1
,  MOVE N'dbMeetupDT' TO N'E:\SQLDADOS01\dbUniquifier.mdf'
,  MOVE N'dbMeetupDT_log' TO N'E:\SQLLOG01\dbUniqueifier.ldf',  NOUNLOAD,  STATS = 5
GO


