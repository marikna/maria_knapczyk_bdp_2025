SELECT imie, nazwisko
FROM ksiegowosc.pracownicy AS p
JOIN ksiegowosc.godziny AS g
ON p.id_pracownika = g.id_pracownika
JOIN ksiegowosc.wynagrodzenie AS w
ON p.id_pracownika = w.id_pracownika
WHERE (g.liczba_godzin - 160) > 0
AND w.id_premii IS NULL;
