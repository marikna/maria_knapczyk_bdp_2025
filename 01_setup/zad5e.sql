SELECT id_pracownika, imie, nazwisko 
FROM ksiegowosc.pracownicy
WHERE RIGHT(imie, 1) = 'a' AND POSITION('n' IN LOWER(nazwisko)) > 0;
