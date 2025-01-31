USE [BancoDeDados]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spVerificarIntegridadeBanco]
AS
BEGIN
	DECLARE @dbName NVARCHAR(128);
	DECLARE @sql NVARCHAR(MAX);

	DECLARE db_cursor CURSOR
	FOR
	SELECT QUOTENAME(name)
	FROM sys.databases
	WHERE state_desc = 'ONLINE'
		AND name NOT IN (
			'master'
			,'tempdb'
			,'model'
			,'msdb'
			);

	OPEN db_cursor;

	FETCH NEXT
	FROM db_cursor
	INTO @dbName;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = '
    INSERT INTO HistoricoIntegridadeBanco (
        HiIBaError, HiIBaLevel, HiIBaState, HiIBaMessageText, HiIBaRepairLevel, HiIBaStatus,
        HiIBaDbId, HiIBaDbFragId, HiIBaObjectId, HiIBaIndexId, HiIBaPartitionID, HiIBaAllocUnitID,
        HiIBaRidDbId, HiIBaRidPruId, HiIBaFile, HiIBaPage, HiIBaSlot, HiIBaRefDbId, HiIBaRefPruId,
        HiIBaRefFile, HiIBaRefPage, HiIBaRefSlot, HiIBaAllocation
    )
    EXEC (''DBCC CHECKDB(' + @dbName + ') WITH TABLERESULTS'')';

		--PRINT @sql;
		EXEC sp_executesql @sql;

		FETCH NEXT
		FROM db_cursor
		INTO @dbName;
	END
END

CLOSE db_cursor;

DEALLOCATE db_cursor;
