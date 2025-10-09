SELECT DISTINCT id_pracownika
FROM ksiegowosc.wynagrodzenie as w
JOIN ksiegowosc.pensja as pe
ON w.id_pensji = pe.id_pensji
JOIN ksiegowosc.premia as pr 
ON w.id_premii = pr.id_premii
WHERE (pe.kwota + pr.kwota) > 2000 AND pr.id_premii IS NULL
