--Zestawienie umów o pracę rozpoczynających się w zadanym okresie

DECLARE @d_od datetime, @d_do datetime, @j_dzial_od int, @j_dzial_do int, @podsw int
set @d_od={D/Od/DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)}
set @d_do={D/Do/DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)}
--set @j_dzial_od={C(DZIAŁY)/Dział od/0}
--set @j_dzial_do={C(DZIAŁY)/Dział do/9999}
--set @podsw={L/Tylko podświetleni/0}

SELECT 
p.X_I,
p.Nazwisko, p.Imie,
pd.PESEL,  
h.AzNazwa as 'Akt.zatr.', 
d.Nazwa as 'Fizyczny', 
<BIN>.fn_Kod('UMPRACA','Rodzaj_umowy',up.Rodzaj_umowy) as 'Rodz.umowy', 
up.OkresOd as 'Okres od', up.OkresDo as 'Okres do', 
cast(up.Etat_licznik as varchar)+'/'+cast(up.Etat_mianownik as varchar) as 'Etat', 
za.Nazwa as 'Zawód',
st.Nazwa as 'Stanowisko', 
'Dół' = CASE 
			WHEN CHARINDEX('p/z', LOWER(st.Nazwa)) > 0 THEN 'Tak'
			WHEN CHARINDEX('dołowy', LOWER(st.Nazwa)) > 0 THEN 'Tak'
			WHEN CHARINDEX('sztygar', LOWER(st.Nazwa)) > 0 THEN 'Tak'
			ELSE 'Nie' 
			END, 
dbo.fn_ANG_Skl(1,'płaca zasadnicza',up.X_I) as 'Stawka'

FROM 
HISTORIA h 
LEFT JOIN PRACOWNK p ON p.X_I = h.X_IPracownik 
LEFT JOIN DZIAL d ON d.X_I = dbo.fn_X_IDzial(h.X_I,@d_do)

--złączenie z umowami o pracę
JOIN UMPRACA up ON (up.X_IAktZatrudnienie=h.X_I)
--typu nowa umowa (0:nowa umowa 1 i 2:zmiana i wypowiedzenie warunkow 3: zakończenie)
--AND (up.Typ_umowy=0) 
--umowy o prace rozpoczęte w zadanym okresie
--AND
--((up.OkresOd>=@d_od)
--AND((up.OkresOd<=@d_do)OR(cast(@d_do as int)<=0)))

LEFT JOIN <BIN>.ZAWOD za ON za.X_I = up.X_IZawod
LEFT JOIN STANOW st ON st.X_I = up.X_IStanowiska
LEFT JOIN PracDane pd ON pd.X_IPracownik = p.X_I

WHERE 

--warunek na aktualne zatrudnienie lub zatrudnienie przeniesione do historii
((h.AktZatrudnienie=1)OR(h.AzNazwa<>''))AND(p.Skasowany=0)

--warunek na działy
--AND(d.X_J>=@j_dzial_od)AND((@j_dzial_do=0)OR(d.X_J<=@j_dzial_do))

--warunek na podświetlonych pracowników
--AND((@podsw=0)OR(<BIN>.fn_Podsw(p.X_I,p.X_P,<USERIDE>,'PracownikT')=1))

AND(
--warunek na umowy o pracę w zadanym okresie
((h.Od IS NOT NULL)AND((h.Od<=@d_do)OR(cast(@d_do as int)<=0))AND((h.Do IS NULL)OR(h.Do>=@d_od)))
--umowy cywilnoprawne w zadanym okresie
OR ((h.ZOd IS NOT NULL)AND((h.ZOd<=@d_do)OR(cast(@d_do as int)<=0))AND((h.ZDo IS NULL)OR(h.ZDo>=@d_od)))
--umowy o współpracy w zadanym okresie
OR ((h.BOd IS NOT NULL)AND((h.BOd<=@d_do)OR(cast(@d_do as int)<=0))AND((h.BDo IS NULL)OR(h.BDo>=@d_od)))
)

ORDER BY 
p.Nazwisko, p.Imie, h.X_I
