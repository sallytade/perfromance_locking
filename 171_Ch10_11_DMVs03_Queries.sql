SELECT CAST(query_plan AS xml) AS xmlData, * 
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) qp
WHERE qp.dbid = DB_ID()
   
-- Longest running historical queries
SELECT SUBSTRING(sql.text, (qs.statement_start_offset/2)+1, 
	((CASE qs.statement_end_offset
	  WHEN -1 THEN DATALENGTH(sql.text)
	 ELSE qs.statement_end_offset
	 END - qs.statement_start_offset)/2) + 1) AS StatementText
	, sql.text
	, last_execution_time as LastExecuted
	, qs.execution_count
	, last_elapsed_time/1000000.0 as ElapsedTimeInSeconds
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS sql
-- ORDER BY qs.execution_count DESC
ORDER BY last_elapsed_time DESC
