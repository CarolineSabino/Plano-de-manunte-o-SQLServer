DECLARE @dbName NVARCHAR(128)
DECLARE @sql NVARCHAR(MAX)

DECLARE db_cursor CURSOR
FOR
SELECT name
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
	SET @sql = 'USE ' + QUOTENAME(@dbName) + '; EXEC sp_updatestats;';

	EXEC sp_executesql @sql;

	FETCH NEXT
	FROM db_cursor
	INTO @dbName;
END

CLOSE db_cursor;

DEALLOCATE db_cursor;