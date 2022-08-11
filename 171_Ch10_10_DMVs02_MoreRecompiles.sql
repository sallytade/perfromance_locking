-- Shows statement-level recompiles

SELECT 
	SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(o.object_id) AS Object
	, o.type_desc AS ObjectType
    , SUBSTRING(text,qs.statement_start_offset/2
        ,(CASE    
            WHEN qs.statement_end_offset = -1 THEN len(convert(nvarchar(max), text)) * 2 
            ELSE qs.statement_end_offset 
        END - qs.statement_start_offset)/2) AS stmt 
    ,qs.plan_generation_num as recompiles
    ,qs.execution_count as execution_count
    , CAST(
		ROUND(100 * (qs.plan_generation_num / CAST(qs.execution_count AS DECIMAL)), 2)
	AS DECIMAL(10, 2)) AS percent_recompiles
    ,qs.total_elapsed_time - qs.total_worker_time as total_wait_time
    ,qs.total_worker_time as cpu_time
    ,qs.total_logical_reads as reads
    ,qs.total_logical_writes as writes
    , *
FROM sys.dm_exec_query_stats qs
LEFT JOIN sys.dm_exec_requests r 
    ON qs.sql_handle = r.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
LEFT JOIN sys.objects o
	ON st.objectid = o.object_id
WHERE qs.execution_count > 30
	AND qs.plan_generation_num > 10
	AND (100 * qs.plan_generation_num / CAST(qs.execution_count AS DECIMAL)> 20) -- only when 20% or more of executions are recompiles
	-- AND st.dbid = DB_ID('LearnItFirst')
-- ORDER BY execution_count DESC 
ORDER BY recompiles DESC 


-- Shows object-level rollup of number of statement-level recompiles
-- It is possible that a stored proc has 1000% recompiles. This is due
-- to statement-level recompiles. A stored proc may have 100 statements
-- and each one can be recompiled at each call or none may be recompiled
-- at execution (or anywhere in between).

SELECT 
	SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(o.object_id) AS Object
	, o.type_desc AS ObjectType
	, MAX(qs.execution_count) AS execution_count
    , SUM(qs.plan_generation_num) as recompiles
    , CAST(
		ROUND(100 * (SUM(qs.plan_generation_num) / CAST(MAX(qs.execution_count) AS DECIMAL)), 2)
	AS DECIMAL(10, 2)) AS percent_recompiles
    , SUM(qs.total_elapsed_time - qs.total_worker_time) as total_wait_time
    , SUM(qs.total_worker_time) as cpu_time
    , SUM(qs.total_logical_reads) as reads
    , SUM(qs.total_logical_writes) as writes
FROM sys.dm_exec_query_stats qs
LEFT JOIN sys.dm_exec_requests r 
    ON qs.sql_handle = r.sql_handle
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
LEFT JOIN sys.objects o
	ON st.objectid = o.object_id
WHERE qs.execution_count > 30
	AND qs.plan_generation_num > 10
	AND (100 * qs.plan_generation_num / CAST(qs.execution_count AS DECIMAL)> 20) -- only when 20% or more of executions are recompiles
	-- AND st.dbid = DB_ID('LearnItFirst')
	AND o.object_id IS NOT NULL
GROUP BY SCHEMA_NAME(o.schema_id) + '.' + OBJECT_NAME(o.object_id)
	, o.type_desc
-- ORDER BY execution_count DESC 
ORDER BY recompiles DESC 
