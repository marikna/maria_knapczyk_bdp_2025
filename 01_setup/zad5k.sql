SELECT stanowisko, COUNT(stanowisko) AS liczba_pracownikow
FROM ksiegowosc.pensja
GROUP BY stanowisko
