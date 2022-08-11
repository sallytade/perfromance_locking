
-- Hardware 
SELECT cpu_count AS LogicalCPUs
	, scheduler_count AS schedulers
	,CAST(physical_memory_kb/1024 AS VARCHAR) + 'MB' AS [RAM installed in box]
	, CAST(committed_kb/1024 AS VARCHAR) + 'MB' AS [In-use memory ]
FROM sys.dm_os_sys_info
