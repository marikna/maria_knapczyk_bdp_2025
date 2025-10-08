INSERT INTO ksiegowosc.pracownicy (id_pracownika, imie, nazwisko, adres, telefon) VALUES
(1, 'Anna', 'Kowalska', 'ul. Lipowa 12, Warszawa', '600123456'),
(2, 'Jan', 'Nowak', 'ul. Długa 5, Kraków', '601234567'),
(3, 'Piotr', 'Wiśniewski', 'ul. Krótka 8, Gdańsk', '602345678'),
(4, 'Katarzyna', 'Wójcik', 'ul. Słoneczna 3, Wrocław', '603456789'),
(5, 'Michał', 'Kowalczyk', 'ul. Zielona 15, Poznań', '604567890'),
(6, 'Ewa', 'Kamińska', 'ul. Polna 7, Łódź', '605678901'),
(7, 'Tomasz', 'Lewandowski', 'ul. Piękna 10, Szczecin', '606789012'),
(8, 'Agnieszka', 'Zielińska', 'ul. Krucza 4, Lublin', '607890123'),
(9, 'Paweł', 'Szymański', 'ul. Wesoła 2, Katowice', '608901234'),
(10, 'Magdalena', 'Woźniak', 'ul. Krótka 6, Białystok', '609012345');

INSERT INTO ksiegowosc.godziny (id_godziny, data, liczba_godzin, id_pracownika) VALUES
(1, '2025-10-01', '8', 1),
(2, '2025-10-02', '6', 2),
(3, '2025-10-03', '9', 3),
(4, '2025-10-04', '5', 4),
(5, '2025-10-05', '7', 5),
(6, '2025-10-06', '8', 6),
(7, '2025-10-07', '4', 7),
(8, '2025-10-08', '10', 8),
(9, '2025-10-09', '6', 9),
(10, '2025-10-10', '7', 10);

INSERT INTO ksiegowosc.pensja (id_pensji, stanowisko, kwota) VALUES
(1, 'Księgowy', 5000),
(2, 'Księgowa', 4800),
(3, 'Analityk', 5500),
(4, 'Manager', 7000),
(5, 'Asystent', 4000),
(6, 'Specjalista', 5200),
(7, 'Administrator', 4500),
(8, 'Koordynator', 5300),
(9, 'Dyrektor', 9000),
(10, 'Asystent', 4200);

INSERT INTO ksiegowosc.premia (id_premii, rodzaj, kwota) VALUES
(1, 'Motywacyjna', 500),
(2, 'Okolicznościowa', 300),
(3, 'Świąteczna', 700),
(4, 'Roczna', 1000),
(5, 'Motywacyjna', 400),
(6, 'Okolicznościowa', 350),
(7, 'Świąteczna', 600),
(8, 'Roczna', 800),
(9, 'Motywacyjna', 900),
(10, 'Okolicznościowa', 450);

INSERT INTO ksiegowosc.wynagrodzenie (id_wynagrodzenia, data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
(1, '2025-10-01', 1, 1, 1, 1),
(2, '2025-10-02', 2, 2, 2, 2),
(3, '2025-10-03', 3, 3, 3, 3),
(4, '2025-10-04', 4, 4, 4, 4),
(5, '2025-10-05', 5, 5, 5, 5),
(6, '2025-10-06', 6, 6, 6, 6),
(7, '2025-10-07', 7, 7, 7, 7),
(8, '2025-10-08', 8, 8, 8, 8),
(9, '2025-10-09', 9, 9, 9, 9),
(10, '2025-10-10', 10, 10, 10, 10);
