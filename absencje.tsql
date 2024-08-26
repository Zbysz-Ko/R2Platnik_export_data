--Zestawienie wprowadzonych urlopów, chorobowych i innych nieobecności na dany okres

DECLARE @d_od datetime, @d_do datetime, @podsw int, @ku int, @kz int, @in int
set @d_od={D/Od/DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)}
set @d_do={D/Do/DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)}
set @ku={L/Karta urlopowa/1}
set @kz={L/Karta zasiłkowa/1}
set @in={L/Inne nieobecności/1}

SELECT 
p.X_I,
un.Od, un.Do,
p.Nazwisko, p.Imie, pd.Drugie_imie, pd.PESEL,
--h.AzNazwa as 'Akt.zatr.', 
un.Opis,
un.Rodzaj, 
un.Ilosc_dni as 'Ilość dni'

FROM 
(
select u.X_I_HISTORII as 'X_IHistorii', u.OD as 'Od', u.DO as 'Do', 
'urlop' as 'Opis', <BIN>.fn_Kod('KART_URL','R_DNIA',u.R_DNIA) as 'Rodzaj', 
u.IL_DNI as 'Ilosc_dni'
from KART_URL u where (u.L=0) and (@ku=1)
UNION
select z.X_I_HISTORII as 'X_IHistorii', z.OKRES_OD as 'Od', z.OKRES_DO as 'Do', 
'chorobowe' as 'Opis', <BIN>.fn_Kod('KART_ZAS','R_NIEOB',z.R_NIEOB) as 'Rodzaj', 
z.IL_DNI_ZAS as 'Ilosc_dni'
from KART_ZAS z where (@kz=1)
UNION
select s.X_IHistoria as 'X_IHistorii', s.Od as 'Od', s.Do as 'Do', 'nieobecność' as 'Opis', 
<BIN>.fn_Kod('OKRESHIS','Rodzaj_nieobecnosci',s.Rodzaj_nieobecnosci) as 'Rodzaj', 
cast((s.DO-s.OD) as int)+1 as 'Ilosc_dni'
from OKRESHIS s where (@in=1)
) un
LEFT JOIN HISTORIA h ON (un.X_IHistorii=h.X_I)
LEFT JOIN PRACOWNK p ON p.X_I = h.X_IPracownik 
LEFT JOIN PracDane pd ON pd.X_IPracownik = h.X_IPracownik 
--LEFT JOIN DZIAL d ON d.X_I = dbo.fn_X_IDzial(h.X_I,@d_do)

WHERE 
--warunek na aktualne zatrudnienie lub zatrudnienie przeniesione do historiiOR(h.AzNazwa<>'')
((h.AktZatrudnienie=1))AND(p.Skasowany=0)

--warunek na okres nieobecności
--((un.Od>=@d_od)AND((un.Do<=@d_do)OR(cast(@d_do as int)<=0)))

--warunek na pracę w zadanym okresie
--AND((un.Od<=@d_do)OR(cast(@d_do as int)<=0))AND(un.Do>=@d_od)

--warunek na pracę w zadanym okresie
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
