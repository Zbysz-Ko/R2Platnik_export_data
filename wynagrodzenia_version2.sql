-- Generuje dane z pasków wypłaty dla danego zakresu dat, dla każdego pracownika zatrudnionego w tym okresie.

DECLARE @r_od int, @r_do int, @m_od int, @m_do int
set @r_od={I/Rok od/Year(GetDate())}
set @m_od={I/Miesiac od/Month(GetDate())}
set @r_do={I/Rok do/Year(GetDate())}
set @m_do={I/Miesiac do/Month(GetDate())}

declare @SkladnikString NVARCHAR(MAX)
declare @PolasysString NVARCHAR(MAX)
declare @PivotQuery NVARCHAR(MAX)

-- UWAGA! Pamiętaj wygenerować najpierw "IN" dla 2 poniższych definicji!
-- Generuje używane i unikalne elementy z pasków.
-- Zapytania SQL o nazwach "Unikalne*". Ustaw te same daty.
SET @SkladnikString = (SELECT STRING_AGG(quotename(Nazwa), ', ') as Nazwa 
FROM (SELECT DISTINCT Nazwa FROM R2P_platnik10_bin.dbo.SKLADNIK sk 
WHERE sk.X_I IN (23, 46, 15, 9, 66, 32, 63, 43, 55, 49, 27, 64, 7, 
44, 70, 30, 41, 65, 36, 42, 59, 17, 60, 40, 11, 68, 28, 37) ) x)

SET @PolasysString = (SELECT STRING_AGG(quotename(Nazwa), ', ') as Nazwa 
FROM (SELECT DISTINCT Nazwa FROM R2P_platnik10_bin.dbo.Polasys ps 
WHERE ps.X_I IN(46, 92, 115, 75, 9, 15, 109, 3, 72, 212, 66, 32, 12, 
35, 106, 112, 63, 6, 43, 55, 241, 49, 113, 67, 21, 107, 250, 58, 130, 
81, 64, 38, 7, 44, 50, 47, 70, 18, 84, 10, 61, 253, 4, 142, 65, 79, 73, 
36, 105, 13, 62, 5, 242, 56, 148, 76, 108, 59, 82, 251, 33, 39, 16, 88, 
102, 53, 71, 240, 77, 17, 31, 83, 34, 11, 54, 91, 68, 80, 28, 74, 249, 
57, 14, 37, 243, 8, 51)) y)

SET @PivotQuery = 
'SELECT 
np.X_IPracownik as ''ID_Pracownika'', 
np.Imie, 
np.Nazwisko, 
l.Kartoteka_z_miesiaca, 
l.Kartoteka_z_roku,
rl.Nazwa as ''Zakres listy'', 
dl.Nazwa as ''Rodzaj listy'', 
l.IdeZUS, 
l.Numer as ''Numer Listy Płacowej'',
'+@SkladnikString+', 
'+@PolasysString+' 
FROM R2P_platnik10_dane_1.dbo.NPOZLIST np
LEFT JOIN R2P_platnik10_dane_1.dbo.LISTA l ON np.X_ILista = l.X_I 
LEFT JOIN RODZLIST rl ON l.X_IRodzaj = rl.X_I  
LEFT JOIN R2P_platnik10_bin.dbo.DEFLIST dl ON l.X_IDefList = dl.X_I  
LEFT JOIN (
	SELECT [X_I_POZL], '+@SkladnikString+' 
	FROM
	(
	SELECT sk.Nazwa, pskl.WW, pskl.X_I_POZL FROM R2P_platnik10_bin.dbo.SKLADNIK sk
	LEFT JOIN R2P_platnik10_dane_1.dbo.POZLSKL pskl ON sk.X_I = pskl.X_I_SKL
	) src
	PIVOT
	(
	max(WW) FOR Nazwa IN ('+@SkladnikString+')
	) pvt
) skl ON np.X_I = skl.X_I_POZL
LEFT JOIN (
	SELECT [X_I_POZL], '+@PolasysString+' 
	FROM
	(
	SELECT ps.Nazwa, psys.WW, psys.X_I_POZL FROM R2P_platnik10_bin.dbo.Polasys ps
	LEFT JOIN R2P_platnik10_dane_1.dbo.POZLSYS psys ON ps.X_I = psys.X_I_SYS
	) srcs
	PIVOT
	(
	max(WW) FOR Nazwa IN ('+@PolasysString+')
	) pvts
) psy ON np.X_I = psy.X_I_POZL
WHERE 
-- Wykluczenie list delegacyjnych
l.X_IDefList <> 38
AND
-- Określenie zakresu
l.Od >= dbo.fn_BDate('+CAST(@m_od AS VARCHAR)+', '+CAST(@r_od AS VARCHAR)+') 
AND l.Do <= dbo.fn_EDate('+CAST(@m_do AS VARCHAR)+', '+CAST(@r_do AS VARCHAR)+')'

EXECUTE sp_executesql @PivotQuery
