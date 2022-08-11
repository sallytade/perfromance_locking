SELECT name, type_desc
FROM sys.system_objects
WHERE schema_id = 4
	AND name LIKE 'dm_io_%'
ORDER BY name

SELECT DB_NAME(mf.database_id) AS DB
	, mf.physical_name, mf.type_desc
	, vfs.*
	, ISNULL(io_stall/NULLIF((num_of_reads + num_of_writes), 0), 0)
		AS Latency
FROM sys.dm_io_virtual_file_stats(null,null) vfs
JOIN sys.master_files mf
	ON mf.database_id= vfs.database_id
	AND mf.file_id= vfs.file_id
ORDER BY DB_NAME(mf.database_id)

SELECT DB_NAME(vfs.database_id) AS db
	, CAST(SUM(vfs.num_of_bytes_read+ vfs.num_of_bytes_written) / 1048576.
		AS DECIMAL(12, 2)) AS IO_MB
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
GROUP BY vfs.database_id
ORDER BY IO_MB DESC


SELECT name, type_desc
FROM sys.system_objects
WHERE schema_id = 4
	AND name LIKE 'dm_os_%'
ORDER BY name

--Current wait info:
SELECT wait_type, wait_time_ms/ 1000. as wait_time_s
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC

--Clear out stats:
DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR)

--Run this at a later time to view waits since CLEAR
SELECT wait_type, wait_time_ms/ 1000. as wait_time_s
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC