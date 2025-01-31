USE [BancoDeDados]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spPreencherTbIndiceManutencao]
AS
INSERT INTO Traces.dbo.IndiceManutencao
SELECT object_name(PS.OBJECT_ID) InManTabela
	,IND.name
	,PS.avg_fragmentation_in_percent
	,'REBUILD'
	,'P'
	,NULL
FROM sys.dm_db_INDex_physical_stats(db_id(), NULL, NULL, NULL, NULL) PS
INNER JOIN sys.INDexes IND
	ON (
			PS.INDex_id = IND.INDex_id
			AND PS.object_id = IND.object_id
			)
WHERE PS.INDex_id > 0
	AND PS.page_count > 100
	AND PS.avg_fragmentation_in_percent >= 30

UNION ALL

SELECT object_name(PS.object_id) tabela
	,IND.name
	,PS.avg_fragmentation_in_percent
	,'REORGANIZE'
	,'P'
	,NULL
FROM sys.dm_db_INDex_physical_stats(db_id(), null, null, null, null) PS
INNER JOIN sys.INDexes IND
	ON (
			PS.INDex_id = IND.INDex_id
			AND PS.object_id = IND.object_id
			)
WHERE PS.INDex_id > 0
	AND PS.page_count > 100
	AND PS.avg_fragmentation_in_percent > 10
	AND PS.avg_fragmentation_in_percent < 30




