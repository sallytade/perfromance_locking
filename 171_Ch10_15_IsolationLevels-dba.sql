/*
	In SQL Server, readers block writers and writers block 
	readers (by default). This is done with isolation levels.

	By default, a SQL Server client connection is 
	READ COMMITTED isolation level. 

	We can change this:
		-- At the connection level (which affects all queries for the
			duration of the connection
		-- At the table level (which affect only that one table)

	By default, lock_timeout=-1 (infinite wait for resource). 
	Lock timeout can be changed with SET LOCK_TIMEOUT (value_in_ms)

	Sometimes we want to change isolation levels. 
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Table hints allow us to be granular with our isolation levels.

	WITH(NOLOCK) - essentially "READ UNCOMMITTED" for a single table
		in a single query

	WITH(NOWAIT) - essentially "READ COMMITTED" but, if any wait occurs,
		raise error 1222

	WITH(READPAST) - essentially "READ COMMITTED" but skips any locked
		rows

	Strategies for avoiding excess locking and blocking
		- Close your transactions ASAP
		- Long running queries cause long-held shared locks
			- Can you "get away with" WITH(NOLOCK) on long query?
		- Can you change the reader's isolation level?
		- Row versioning/snapshot isolation?
		- Smaller batch sizes
		- Set lock timeout
		- Kill runaway SPIDs/vacationing user
			1) Find the offender
			2) KILL 51



*/
EXEC sp_lock