SELECT id_pracownika, imie, nazwisko 
FROM ksiegowosc.pracownicy
WHERE LEFT(imie, 1) = 'J'
