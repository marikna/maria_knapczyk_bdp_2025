SELECT id_pracownika, pe.kwota, pr.kwota
FROM ksiegowosc.wynagrodzenie as w
JOIN ksiegowosc.pensja as pe
ON w.id_pensji = pe.id_pensji
JOIN ksiegowosc.premia as pr 
ON w.id_premii = pr.id_premii
ORDER BY pe.kwota DESC, pr.kwota DESC
