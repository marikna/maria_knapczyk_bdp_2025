-- 1

CREATE TABLE obiekty (
nazwa VARCHAR(10),
geometria geometry);

-- a
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt1',
ST_GeomFromText( -- A compound curve is a single, continuous curve that has both curved (circular) segments and linear segments
	'COMPOUNDCURVE(
            	(0 1, 1 1),                       
            	CIRCULARSTRING(1 1, 2 0, 3 1),    
            	CIRCULARSTRING(3 1, 4 2, 5 1),    
            	(5 1, 6 1)                         
        )',
	0)
);


-- b 
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt2',
ST_GeomFromText( -- like a polygon, with an outer ring and zero or more inner rings. 
				 -- The difference is that a ring can take the form of a circular string, linear string or compound string.
	'CURVEPOLYGON(
     	COMPOUNDCURVE(
     				(10 6, 10 2),
                	CIRCULARSTRING(10 2, 12 0, 14 2),
                	CIRCULARSTRING(14 2, 16 4, 14 6),
                	(14 6, 10 6)
            ),
        COMPOUNDCURVE(
                	CIRCULARSTRING(11 2, 12 1, 13 2),
					CIRCULARSTRING(13 2, 12 3, 11 2))
        )', 
	0)
);

-- c
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt3',
ST_GeomFromText( 'POLYGON((7 15, 12 13, 10 17, 7 15)
		)',
    0)
);



-- d 
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt4',
ST_GeomFromText(
	'MULTILINESTRING(
				  (20.5 19.5, 22 19),
				  (22 19, 26 21),
				  (26 21, 25 22),
				  (25 22, 27 24),
				  (27 24, 25 25),
				  (25 25, 20 20) )',
    0)
);


-- 	e
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt5',
ST_GeomFromText(
    'MULTIPOINT Z (30 30 59, 38 32 234)',
    0)
);


-- f 
INSERT INTO obiekty (nazwa, geometria)
VALUES (
'obiekt6',
ST_GeomFromText(
	'GEOMETRYCOLLECTION(
            LINESTRING (1 1, 3 2),
            POINT (4 2)
        )',
	0)
);

SELECT * FROM obiekty;



-- 2

