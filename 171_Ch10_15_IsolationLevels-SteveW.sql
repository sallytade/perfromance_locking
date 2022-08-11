-- Steve W: 55
DBCC USEROPTIONS -- shows connection-level settings

SET lock_timeout -1

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

USE AdventureWorks
GO
SELECT * FROM Production.Product WITH(NOLOCK)

SELECT COUNT(*) FROM Production.Product WITH(NOWAIT)

SELECT COUNT(*) FROM Production.Product WITH(READPAST)