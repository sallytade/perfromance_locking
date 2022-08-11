-- Steve J. - 51
USE AdventureWorks
GO
BEGIN TRAN
	UPDATE Production.Product
	SET Name = 'Steve''s Magic iWidget'
	WHERE ProductId = 1

	SELECT @@TRANCOUNT

ROLLBACK