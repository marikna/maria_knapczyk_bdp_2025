DELETE FROM ksiegowosc.wynagrodzenie
WHERE id_pensji IN (
    SELECT id_pensji FROM ksiegowosc.pensja WHERE kwota < 1200
);

DELETE FROM ksiegowosc.premia
WHERE id_premii IN (
    SELECT id_premii FROM ksiegowosc.wynagrodzenie
    WHERE id_pensji IN (SELECT id_pensji FROM ksiegowosc.pensja WHERE kwota < 1200)
);

DELETE FROM ksiegowosc.godziny
WHERE id_godziny IN (
    SELECT id_godziny FROM ksiegowosc.wynagrodzenie
    WHERE id_pensji IN (SELECT id_pensji FROM ksiegowosc.pensja WHERE kwota < 1200)
);

DELETE FROM ksiegowosc.pracownicy
WHERE id_pracownika IN (
    SELECT id_pracownika FROM ksiegowosc.wynagrodzenie
    WHERE id_pensji IN (SELECT id_pensji FROM ksiegowosc.pensja WHERE kwota < 1200)
);

DELETE FROM ksiegowosc.pensja
WHERE kwota < 1200;
