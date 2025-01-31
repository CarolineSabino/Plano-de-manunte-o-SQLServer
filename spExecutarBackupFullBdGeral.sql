USE [BancoDeDados]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spExecutarBackupFullBdGeral]
    @CaminhoDestinoArquivo NVARCHAR(500)

		-- exec spExecutarBackupFullBdGeral 'H:\BACKUP\'
AS   
BEGIN
    SET NOCOUNT ON
    DECLARE @SQL NVARCHAR(1000) = '', @NomeBanco NVARCHAR(500)
    
    DECLARE NomesBancosParaBackup CURSOR FOR
        SELECT name  
        FROM master.sys.databases
        WHERE name NOT IN ('tempdb')
                    
    OPEN NomesBancosParaBackup
    
    FETCH NEXT FROM NomesBancosParaBackup INTO @NomeBanco;
    
    WHILE @@FETCH_STATUS = 0  
    BEGIN 
        SET @SQL = 'BACKUP DATABASE ' + QUOTENAME(@NomeBanco) + ' TO DISK = ''' + @CaminhoDestinoArquivo + @NomeBanco + '.bak'' WITH INIT'
			 
        EXEC sp_executesql @SQL
        
        FETCH NEXT FROM NomesBancosParaBackup INTO @NomeBanco
    END

    CLOSE NomesBancosParaBackup
    DEALLOCATE NomesBancosParaBackup
END