SELECT 
	ROUND(AVG(kwota), 2) AS srednia_asystenta,
	ROUND(MIN(kwota), 2) AS min_asystenta,
	ROUND(MAX(kwota), 2) AS max_asystenta
FROM ksiegowosc.pensja
WHERE stanowisko = 'Asystent'
