SELECT pe.stanowisko, (SUM(pe.kwota) + SUM(pr.kwota)) AS suma_wynagrodzen
FROM ksiegowosc.pensja pe
JOIN ksiegowosc.wynagrodzenie w
ON pe.id_pensji = w.id_pensji
JOIN ksiegowosc.premia pr
ON w.id_premii = pr.id_premii
GROUP BY pe.stanowisko
