USE [BancoDeDados]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spAtualizarIndice]
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX) = ''
        ,@ID VARCHAR(MAX) = ''
        ,@ATUALIZACAO NVARCHAR(MAX) = ''
        ,@STATISTICS NVARCHAR(MAX) = ''

  
    SELECT TOP 5 
        @SQL = @SQL + 'ALTER INDEX ' + QUOTENAME(InManIndice) + ' ON ' + QUOTENAME(InManTabela) + ' ' + InManOperacao + ' WITH(FILLFACTOR=95);'
        ,@ID = @ID + CAST(InManId AS VARCHAR) + ','
    FROM Traces.dbo.IndiceManutencao
    WHERE InManSituacao = 'P'
    ORDER BY InManFragmentacao DESC

  
    IF LEN(@ID) > 0
        SET @ID = LEFT(@ID, LEN(@ID) - 1)
    ELSE
        RETURN 

   
    SET @ATUALIZACAO = 'UPDATE Traces.dbo.IndiceManutencao SET InManSituacao = ''F'' WHERE InManId IN (' + @ID + ')'

  
    EXEC SP_EXECUTESQL @SQL

 
    EXEC SP_EXECUTESQL @ATUALIZACAO

   
    SELECT DISTINCT @STATISTICS = ISNULL(@STATISTICS, '') + 'UPDATE STATISTICS ' + QUOTENAME(InManTabela) + ' WITH FULLSCAN;'
    FROM Traces.dbo.IndiceManutencao
    WHERE InManSituacao = 'F'
        AND InManDataExec IS NULL

 
    SET @ATUALIZACAO = 'UPDATE Traces.dbo.IndiceManutencao SET InManDataExec = GETDATE() WHERE InManId IN (' + @ID + ')'

 
    IF @STATISTICS IS NOT NULL
        EXEC SP_EXECUTESQL @STATISTICS


    EXEC SP_EXECUTESQL @ATUALIZACAO
END
