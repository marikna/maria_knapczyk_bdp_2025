-- shp2pgsql -I -s 4326 T2018_KAR_BUILDINGS.shp public.buildings_2019 | psql -d baza_przestrzenna

-- 1  budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana pomiędzy 2018 a 2019).

SELECT *
FROM buildings_2019
WHERE NOT EXISTS (
    SELECT *
    FROM buildings_2018
    WHERE ST_Equals(buildings_2019.geom, buildings_2018.geom)
);


-- 2 ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub wybudowanych budynków, które znalezione zostały w zadaniu 1. 
-- Policz je wg ich kategorii.

-- shp2pgsql -I -s 4326 T2019_KAR_POI_TABLE.shp public.points_2019 | psql -d baza_przestrzenna

WITH wyremontowane AS (
    SELECT *
    FROM buildings_2019
    WHERE NOT EXISTS (
        SELECT 1
        FROM buildings_2018
        WHERE ST_Equals(buildings_2019.geom, buildings_2018.geom)
    )
)

SELECT 
p.type,
COUNT(*) AS liczba_punktow
FROM points_2019 p
JOIN wyremontowane w
ON ST_Distance(p.geom, w.geom) <= 500
GROUP BY p.type;


-- 3 Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli T2019_KAR_STREETS 
-- przetransformowane do układu współrzędnych DHDN.Berlin/Cassini (EPSG = 3068)

CREATE TABLE streets_reprojected AS
SELECT 
    gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel,
    ST_Transform(geom, 3068) AS geom
FROM streets_2019;

SELECT * FROM streets_reprojected;


-- 4 Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.

CREATE TABLE IF NOT EXISTS input_points (  
	poi_id SERIAL,
	geom geometry(Point)
);


INSERT INTO input_points
VALUES
	(1, ST_MakePoint(8.36093, 49.03174)),
	(2, ST_MakePoint(8.39876, 49.00644));


-- 5 Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych DHDN.Berlin/Cassini.

UPDATE input_points
SET geom = ST_SetSRID(geom, 3068);

SELECT * FROM input_points;

-- 6 Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej z punktów w tabeli ‘input_points’. 
-- Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.

ALTER TABLE nodes_2019
ALTER COLUMN geom TYPE geometry(Point, 3068)
USING ST_Transform(geom, 3068);

WITH point_line AS (
	SELECT ST_MakeLine(geom) AS geom
FROM input_points
)
	
SELECT *
FROM nodes_2019 n, point_line l
WHERE ST_DWithin(n.geom, l.geom, 200); -- Returns true if the geometries are within a given distance


-- 7 Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) 
-- znajduje się w odległości 300 m od parków (LAND_USE_A).

SELECT COUNT(*) AS shops_in_300m_park
FROM points_2019 p
JOIN land_2019 l
ON ST_DWithin(
	ST_Transform(p.geom, 3068),
    ST_Transform(l.geom, 3068),
    300)
WHERE p.type = 'Sporting Goods Store';


-- 8 Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). 
-- Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.

CREATE TABLE IF NOT EXISTS 
T2019_KAR_BRIDGES AS 
SELECT 
ST_Intersection(r.geom, w.geom) as geom
FROM railway_2019 r
JOIN water_2019 w 
ON ST_Intersects(r.geom, w.geom);

SELECT * FROM T2019_KAR_BRIDGES;
