SELECT imie, nazwisko, (g.liczba_godzin - 160) AS liczba_nadgodzin
FROM ksiegowosc.pracownicy as p
JOIN ksiegowosc.godziny as g
ON p.id_pracownika = g.id_pracownika
WHERE (g.liczba_godzin - 160) > 0
