DECLARE @r_od int, @r_do int, @m_od int, @m_do int
set @r_od={I/Rok od/Year(GetDate())}
set @m_od={I/Miesiac od/Month(GetDate())}
set @r_do={I/Rok do/Year(GetDate())}
set @m_do={I/Miesiac do/Month(GetDate())}

declare @Query as NVARCHAR(MAX) = ''
declare @Counter as int = 1
declare @CounterMax as int = 120

while @Counter <= @CounterMax
	begin
		set @Query = @Query+'
		(SELECT X_ISys'+RIGHT('000'+CAST(@Counter AS VARCHAR(3)), 3)+' as ''Dane''
		FROM Lista 
		WHERE 
		X_ISys'+RIGHT('000'+CAST(@Counter AS VARCHAR(3)), 3)+' IS NOT NULL
		AND Od >= dbo.fn_BDate('+CAST(@m_od AS VARCHAR)+', '+CAST(@r_od AS VARCHAR)+') 
		AND Do <= dbo.fn_EDate('+CAST(@m_do AS VARCHAR)+', '+CAST(@r_do AS VARCHAR)+'))'
		IF @Counter < @CounterMax 
			set @Query = @Query+'
			UNION'
		set @Counter = @Counter + 1
	end

set @Query = 'SELECT STRING_AGG(Dane, '', '') 
FROM (
'+@Query+'
) sys'

--EXECUTE sp_executesql @Query
EXEC(@Query)
--SELECT @Query as 'Zapytanie'
