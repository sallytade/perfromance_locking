-- List blocking/locking history:
SELECT o.object_id 
	, SCHEMA_NAME(o.schema_id) AS schema_name
	, OBJECT_NAME(os.object_id) AS table_name
	, i.name AS index_name
	, i.index_id
	, row_lock_count
	, row_lock_wait_count
	, CAST(100.0 * row_lock_wait_count / (1 + row_lock_count) AS DECIMAL(19,5)) AS block_percentage
	, row_lock_wait_in_ms
	, CAST(1.0 * row_lock_wait_in_ms / (1 + row_lock_wait_count) AS DECIMAL(15,2)) AS avg_row_lock_waits_in_ms
FROM sys.dm_db_index_operational_stats (db_id(),NULL,NULL,NULL) os
JOIN sys.objects o
	ON os.object_id = o.object_id
JOIN sys.indexes i
	ON i.object_id = os.object_id
	AND i.index_id = os.index_id
WHERE objectproperty(os.object_id,'IsUserTable') = 1
ORDER BY row_lock_wait_count DESC, SCHEMA_NAME(o.schema_id), OBJECT_NAME(os.object_id)

-- Currently running SQL:
SELECT
    x.session_id,
    x.host_name,
    x.login_name,
    x.start_time,
    x.totalReads,
    x.totalWrites,
    x.totalCPU,
    x.writes_in_tempdb,
    (
        SELECT 
            text AS [text()]
        FROM sys.dm_exec_sql_text(x.sql_handle)
        FOR XML PATH(''), TYPE
    ) AS sql_text,
    COALESCE(x.blocking_session_id, 0) AS blocking_session_id,
    (
        SELECT 
            p.text
        FROM 
        (
            SELECT 
                MIN(sql_handle) AS sql_handle
            FROM sys.dm_exec_requests r2
            WHERE 
                r2.session_id = x.blocking_session_id
        ) AS r_blocking
        CROSS APPLY
        (
            SELECT 
                text AS [text()]
            FROM sys.dm_exec_sql_text(r_blocking.sql_handle)
            FOR XML PATH(''), TYPE
        ) p (text)
    ) AS blocking_text
FROM
(
    SELECT
        r.session_id,
        s.host_name,
        s.login_name,
        r.start_time,
        r.sql_handle,
        r.blocking_session_id,
        SUM(r.reads) AS totalReads,
        SUM(r.writes) AS totalWrites,
        SUM(r.cpu_time) AS totalCPU,
        SUM(tsu.user_objects_alloc_page_count + tsu.internal_objects_alloc_page_count) AS writes_in_tempdb
    FROM sys.dm_exec_requests r
    JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
    JOIN sys.dm_db_task_space_usage tsu ON s.session_id = tsu.session_id and r.request_id = tsu.request_id
    WHERE r.status IN ('running', 'runnable', 'suspended')
    GROUP BY
        r.session_id,
        s.host_name,
        s.login_name,
        r.start_time,
        r.sql_handle,
        r.blocking_session_id
) x

 