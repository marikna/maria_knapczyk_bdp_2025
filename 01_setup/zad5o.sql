SELECT pe.stanowisko, COUNT(pr.id_premii) AS ilosc_premii_dla_stanowiska
FROM ksiegowosc.pensja pe 
JOIN ksiegowosc.wynagrodzenie w
ON pe.id_pensji = w.id_pensji
JOIN ksiegowosc.premia pr
ON w.id_premii = pr.id_premii
GROUP BY pe.stanowisko
