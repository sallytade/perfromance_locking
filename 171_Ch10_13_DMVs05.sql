SELECT * FROM sys.dm_os_sys_info
SELECT * FROM sys.dm_os_tasks
SELECT description, name FROM sys.dm_os_loaded_modules 

--Find out what has the most entries
--in memory
SELECT TOP (20)[Name], COUNT(*) AS 'Count'
FROM sys.dm_os_memory_cache_entries
GROUP BY [Name]
ORDER BY COUNT(*) DESC;


-- Lots of adhoc queries will show up as CACHESTORE_SQLCP 
SELECT type, SUM(pages_kb)/1024 AS TotalMemoryUsed 
FROM sys.dm_os_memory_clerks
GROUP BY [type]  
ORDER BY SUM(pages_kb) DESC

-- Drop clean buffers and then look:
DBCC DROPCLEANBUFFERS

SELECT type, SUM(pages_kb)/1024 AS TotalMemoryUsed 
FROM sys.dm_os_memory_clerks
GROUP BY [type]  
ORDER BY SUM(pages_kb) DESC

SELECT SUM(pages_kb) AS [CurrentSizeOfTokenCache(kb)] 
FROM sys.dm_os_memory_clerks 
WHERE name = 'TokenAndPermUserStore'

--WARNING: Do not use on production without
--a full understanding!
DBCC FREESYSTEMCACHE('TokenAndPermUserStore')


-- Total size of the plan cache
SELECT (SUM(pages_kb) ) * 8  / (1024.0 * 1024.0) AS plan_cache_in_GB
FROM sys.dm_os_memory_cache_counters
WHERE type = 'CACHESTORE_SQLCP' 
	OR type = 'CACHESTORE_OBJCP'

-- If you have a massive percentage of "1" usecounts, you might
--		want to experiment with forced parameterization:
SELECT TOP(10) usecounts
	, COUNT(*) AS Entries
	, SUM(size_in_bytes/1024/1024) AS PlanCacheSize_mb
FROM sys.dm_exec_cached_plans
GROUP BY usecounts
ORDER BY usecounts ASC