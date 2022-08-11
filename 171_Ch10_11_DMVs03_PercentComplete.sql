-- Perfect for backups, DBCC, and other jobs that send a 'percent complete' signal
-- Queries do not send this signal...

SELECT @@SERVERNAME ServerName, r.session_id, r.start_time, r.[status], r.percent_complete, DB_NAME(r.database_id) DBName, 
r.last_wait_type, r.blocking_session_id, DATEDIFF(MINUTE, r.start_time, GETDATE()) StartTime, 
    CASE percent_complete WHEN 0 THEN 0 
            ELSE (((DATEDIFF(MINUTE, start_time, GETDATE()) * 100 ) / percent_complete ) - (DATEDIFF(MINUTE, start_time, GETDATE()))) 
    END TimeLeft, 
r.command, q.[text] 
FROM sys.dm_exec_requests r 
JOIN sys.dm_exec_sessions s 
	ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) q 
WHERE r.estimated_completion_time > 0
    AND s.is_user_process = 1


/*
In a new window:
	BACKUP DATABASE Adventureworks
	TO DISK = 'AWBig.bak'
	WITH INIT
*/