SELECT id_pracownika, kwota
FROM ksiegowosc.wynagrodzenie as w
JOIN ksiegowosc.pensja as pe
ON w.id_pensji = pe.id_pensji
ORDER BY pe.kwota ASC
