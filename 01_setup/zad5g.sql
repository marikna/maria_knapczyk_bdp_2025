SELECT imie, nazwisko
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.wynagrodzenie as w
ON p.id_pracownika = w.id_pracownika
JOIN ksiegowosc.pensja as pe
ON w.id_pensji = pe.id_pensji
WHERE pe.kwota BETWEEN 1500 AND 3000
