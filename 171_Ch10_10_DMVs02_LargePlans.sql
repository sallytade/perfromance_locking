-- Get large plans with usecounts
SELECT
	cache_plan.objtype,
	CAST(cache_plan.size_in_bytes / 1024.0 / 1024.0 AS DECIMAL(19,2)) as size_in_mb,
	cache_plan.cacheobjtype,
	cache_plan.usecounts,
	sql_text.text
FROM sys.dm_exec_cached_plans as cache_plan
OUTER APPLY sys.dm_exec_sql_text (cache_plan.plan_handle) as sql_text
WHERE cache_plan.size_in_bytes > 1000000
ORDER BY cache_plan.size_in_bytes desc