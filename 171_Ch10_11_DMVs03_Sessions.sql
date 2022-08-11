DBCC FREEPROCCACHE

SELECT sql.text AS StatementText
	, last_execution_time as LastExecuted
	, qs.execution_count
	, last_elapsed_time/1000000.0 as Elapsed_ss
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS sql
ORDER BY qs.execution_count DESC


-- Returns all non-internal sessions
SELECT *
	, DATEDIFF(mi, login_time, GETDATE()) AS LoggedInMinutes 
	, DB_NAME(database_id) AS CurrentDb
FROM sys.dm_exec_sessions
WHERE session_id > 50 -- @SPIDs > 50 are "clients" out of the SQL Server

-- Number of sessions for each login/program
SELECT login_name, [program_name]
	, COUNT(session_id) AS Sessions
FROM sys.dm_exec_sessions s
WHERE session_id > 50
GROUP BY login_name, [program_name]
ORDER BY Sessions DESC

-- Number of sessions for each program
SELECT [program_name]
	, COUNT(session_id) AS Sessions
FROM sys.dm_exec_sessions s
WHERE session_id > 50
GROUP BY [program_name]
ORDER BY Sessions DESC

-- May be very unreliable! Clients by IP address
SELECT  ec.client_net_address,
        es.[program_name],
        es.[host_name],
        es.login_name,
        COUNT(ec.session_id) AS [connection count]
FROM sys.dm_exec_sessions AS es
JOIN sys.dm_exec_connections AS ec
	ON es.session_id = ec.session_id
GROUP BY ec.client_net_address,
        es.[program_name],
        es.[host_name],
        es.login_name
ORDER BY ec.client_net_address,
        es.[program_name] 