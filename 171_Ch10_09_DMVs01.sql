SELECT name, type 
FROM sys.system_objects 
WHERE name like 'dm_%' 
ORDER BY name

;WITH BaseQuery AS (
	SELECT SUBSTRING(name, 4, 255) AS PartialName
	FROM sys.system_objects 
	WHERE name like 'dm_%' 
)
SELECT Category = 
	LEFT(PartialName, CHARINDEX('_', PartialName, 1) - 1)
	, COUNT(*) AS Objects
FROM BaseQuery
GROUP BY LEFT(PartialName, CHARINDEX('_', PartialName, 1) - 1)
ORDER BY Category

SELECT TOP 5 total_worker_time/execution_count AS [Avg CPU Time],
    SUBSTRING(st.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY total_worker_time/execution_count DESC;
