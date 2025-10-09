CREATE TABLE ksiegowosc.pracownicy (
    id_pracownika SERIAL PRIMARY KEY,
    imie VARCHAR(30),
    nazwisko VARCHAR(30),
    adres TEXT,
    telefon VARCHAR(15)
);
COMMENT ON TABLE ksiegowosc.pracownicy IS 'Dane pracownikow: id, imie, nazwisko, adres, telefon';
  
CREATE TABLE ksiegowosc.godziny (
    id_godziny SERIAL PRIMARY KEY,
    data DATE,
    liczba_godzin NUMERIC(4,4),
    id_pracownika INT,
    FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika)
);
COMMENT ON TABLE ksiegowosc.godziny IS 'Dane godzin: id_godziny, data, liczba_godzin , id_pracownika';

CREATE TABLE ksiegowosc.pensja (
    id_pensji SERIAL PRIMARY KEY,
    stanowisko TEXT,
    kwota NUMERIC(10,2)
);
COMMENT ON TABLE ksiegowosc.pensja IS 'Dane pensji: id_pensji, stanowisko, kwota';

CREATE TABLE ksiegowosc.premia (
    id_premii SERIAL PRIMARY KEY,
    rodzaj TEXT,
    kwota NUMERIC(10,2)
);
COMMENT ON TABLE ksiegowosc.premia IS 'Dane premii: id_premii, rodzaj, kwota';

CREATE TABLE ksiegowosc.wynagrodzenie (
    id_wynagrodzenia SERIAL PRIMARY KEY,
    data DATE,
    id_pracownika INT,
    id_godziny INT,
    id_pensji INT,
    id_premii INT,
    FOREIGN KEY (id_pracownika) REFERENCES ksiegowosc.pracownicy(id_pracownika),
    FOREIGN KEY (id_godziny) REFERENCES ksiegowosc.godziny(id_godziny),
    FOREIGN KEY (id_pensji) REFERENCES ksiegowosc.pensja(id_pensji),
    FOREIGN KEY (id_premii) REFERENCES ksiegowosc.premia(id_premii)
);
COMMENT ON TABLE ksiegowosc.wynagrodzenie IS 'Dane wynagrodzen:  id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii';

