EXEC sp_who
EXEC sp_who2
EXEC sp_lock

KILL 51 
KILL 51 WITH STATUSONLY

/*
	Relational databases use locks for concurrency. 

	Modifications require an "Exclusive" lock ("X")
		- The data cannot be viewed, by default, by other sessions

	KEY is effectively "row level locking"
	TAB is table, PAGE is page-level lock

	"S" is a "shared" lock - anyone can view

	Readers block writers;
	writers block readers 

	Steve J (writer) is blocking two readers:
		- Steve W: needs a "S" lock for every row in the table
		- Guy K.: needs a "S" lock for one row

	"I" = "Intent"

	GRANT allows the access
	WAIT places you in the queue 
*/

SELECT * FROM sys.dm_tran_locks WHERE request_status = 'WAIT'

-- There is a bug in early version of SQL 2012
SELECT * 
FROM sys.dm_tran_locks tl
JOIN sys.dm_os_waiting_tasks wt
	ON tl.lock_owner_address = wt.resource_address

SELECT * 
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50