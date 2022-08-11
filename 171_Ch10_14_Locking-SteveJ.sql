-- Steve J. - 51 @@SPID
USE AdventureWorks
GO

BEGIN TRAN
	-- An "X" lock is placed on the resource until the transaction 
	--		has completed
	UPDATE Production.Product
	SET Name = 'Steve''s Magic iWidget'
	WHERE ProductId = 1
	
SELECT * FROM Production.Product

SELECT @@TRANCOUNT -- One open transaction

ROLLBACK