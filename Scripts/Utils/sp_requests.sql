use master
GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE name = 'sp_requests') DROP PROCEDURE dbo.sp_requests
GO
CREATE PROCEDURE dbo.sp_requests
@spid int = null                   
,@blocking tinyint = null                    
as                            
begin                            
 SELECT                             
 RIGHT('0' + CONVERT(varchar(6), DATEDIFF(SECOND,r.start_time,getdate())/86400),2)                        
 + ' ' + RIGHT('0' + CONVERT(varchar(6), DATEDIFF(SECOND,r.start_time,getdate()) % 86400 / 3600), 2)                        
 + ':' + RIGHT('0' + CONVERT(varchar(2), (DATEDIFF(SECOND,r.start_time,getdate()) % 3600) / 60), 2)                        
 + ':' + RIGHT('0' + CONVERT(varchar(2), DATEDIFF(SECOND,r.start_time,getdate()) % 60), 2) as [dd hh:mm:ss]                        
 ,r.session_id
 ,r.blocking_session_id
 ,r.wait_time
 ,r.wait_type
 ,r.wait_resource
 ,s.login_name
 ,s.host_name
 ,s.program_name
 ,CommandText = SUBSTRING(qt.text, (r.statement_start_offset/2)+1, ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(qt.text) WHEN 0 THEN DATALENGTH(qt.text) ELSE r.statement_end_offset END - r.statement_start_offset)/2)+1)
 ,r.cpu_time
 ,r.total_elapsed_time
 ,r.logical_reads
 ,r.writes     
 ,QueryPlan = [plan].query_plan
 ,[Text] = qt.text
 ,r.sql_handle
 ,r.plan_handle
 ,qt.objectid
 FROM sys.dm_exec_requests r      
 CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) qt
 OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) as [plan]
 LEFT JOIN sys.dm_exec_sessions s on s.session_id = r.session_id
 where 1=1
 and r.session_id > 50
 and r.session_id <> @@SPID
 and (@blocking is null or @blocking is not null and r.blocking_session_id > 0)
 and (@spid is null or r.session_id = @spid or r.blocking_session_id = @spid)
 order by r.start_time
       
end