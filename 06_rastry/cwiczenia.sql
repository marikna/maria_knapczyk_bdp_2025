-- 1 wyodrębnienie kafelkow nakładających się na geometrię
CREATE TABLE knapczyk.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ILIKE 'porto';

alter table knapczyk.intersects
add column rid SERIAL PRIMARY KEY;

CREATE INDEX idx_intersects_rast_gist ON knapczyk.intersects
USING gist (ST_ConvexHull(rast));

-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('knapczyk'::name,
'intersects'::name,'rast'::name);


-- 2 Obcinanie rastra na podstawie wektora.
CREATE TABLE knapczyk.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

SELECT * FROM knapczyk.clip LIMIT 10;


-- 3 Połączenie wielu kafelków w jeden raster.
CREATE TABLE knapczyk.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

SELECT * FROM knapczyk.union


-- RASTROWANIE (wektor -> raster)
-- 1 Przykład pokazuje użycie funkcji ST_AsRaster w celu rastrowania tabeli z parafiami o takiej samej
-- charakterystyce przestrzennej tj.: wielkość piksela, zakresy itp.

CREATE TABLE knapczyk.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM knapczyk.porto_parishes



-- 2 Wynikowy raster z poprzedniego zadania to jedna parafia na rekord, na wiersz tabeli. Użyj QGIS lub
-- ArcGIS do wizualizacji wyników. Drugi przykład łączy rekordy z poprzedniego przykładu przy użyciu funkcji ST_UNION 
-- w pojedynczy raster.

DROP TABLE knapczyk.porto_parishes; --> drop table porto_parishes first
CREATE TABLE knapczyk.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM knapczyk.porto_parishes
-- wygladaja tak samo

-- 3 Przykład 3 - ST_Tile
-- Po uzyskaniu pojedynczego rastra można generować kafelki za pomocą funkcji ST_Tile.

DROP TABLE knapczyk.porto_parishes; --> drop table porto_parishes first
CREATE TABLE knapczyk.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

SELECT * FROM knapczyk.porto_parishes


-- WEKTORYZOWANIE (raster -> wektor)
-- 1 Funkcja St_Intersection jest podobna do ST_Clip. ST_Clip zwraca raster, a ST_Intersection zwraca
-- zestaw par wartości geometria-piksel, ponieważ ta funkcja przekształca raster w wektor przed
-- rzeczywistym „klipem”. Zazwyczaj ST_Intersection jest wolniejsze od ST_Clip więc zasadnym jest
-- przeprowadzenie operacji ST_Clip na rastrze przed wykonaniem funkcji ST_Intersection.

create table knapczyk.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM knapczyk.intersection


-- 2 
-- ST_DumpAsPolygons konwertuje rastry w wektory (poligony).

CREATE TABLE knapczyk.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM knapczyk.dumppolygons

-- Obie funkcje zwracają zestaw wartości geomval



-- ANALIZA RASTRÓW
-- Funkcja ST_Band służy do wyodrębniania pasm z rastra
CREATE TABLE knapczyk.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

SELECT * FROM knapczyk.landsat_nir

--ST_Clip może być użyty do wycięcia rastra z innego rastra. Poniższy przykład wycina jedną parafię z
-- tabeli vectors.porto_parishes. Wynik będzie potrzebny do wykonania kolejnych przykładów.
CREATE TABLE knapczyk.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

SELECT * FROM knapczyk.paranhos_dem
--w qgis dodaje sie takie jeziorko male

-- Przykład 3 - ST_Slope
-- Poniższy przykład użycia funkcji ST_Slope wygeneruje nachylenie przy użyciu poprzednio
-- wygenerowanej tabeli (wzniesienie).
CREATE TABLE knapczyk.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM knapczyk.paranhos_dem AS a;

SELECT * FROM knapczyk.paranhos_slope
-- w qgis na jeziorku robia sie takie falki jakby esyfloresy

-- Przykład 4 - ST_Reclass
-- Aby zreklasyfikować raster należy użyć funkcji ST_Reclass.
CREATE TABLE knapczyk.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM knapczyk.paranhos_slope AS a;

SELECT * FROM knapczyk.paranhos_slope_reclass
-- znajduje najbielsze fragmenty

-- Przykład 5 - ST_SummaryStats
-- Aby obliczyć statystyki rastra można użyć funkcji ST_SummaryStats. Poniższy przykład wygeneruje
-- statystyki dla kafelka.
SELECT st_summarystats(a.rast) AS stats
FROM knapczyk.paranhos_dem AS a;


-- Przykład 6 - ST_SummaryStats oraz Union
-- Przy użyciu UNION można wygenerować jedną statystykę wybranego rastra.
SELECT st_summarystats(ST_Union(a.rast))
FROM knapczyk.paranhos_dem AS a;

-- ST_SummaryStats zwraca złożony typ danych


-- Przykład 7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM knapczyk.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

-- Przykład 8 - ST_SummaryStats w połączeniu z GROUP BY
-- Aby wyświetlić statystykę dla każdego poligonu "parish" można użyć polecenia GROUP BY
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--Przykład 9 - ST_Value
-- Funkcja ST_Value pozwala wyodrębnić wartość piksela z punktu lub zestawu punktów. Poniższy
-- przykład wyodrębnia punkty znajdujące się w tabeli vectors.places.
-- Ponieważ geometria punktów jest wielopunktowa, a funkcja ST_Value wymaga geometrii
-- jednopunktowej, należy przekonwertować geometrię wielopunktową na geometrię jednopunktową
-- za pomocą funkcji (ST_Dump(b.geom)).geom.
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

-- Topographic Position Index (TPI)
-- TPI porównuje wysokość każdej komórki w DEM ze średnią wysokością określonego sąsiedztwa wokół tej komórki. 
-- Wartości dodatnie reprezentują lokalizacje, które są wyższe niż średnia ich otoczenia, zgodnie z definicją sąsiedztwa 
-- (grzbietów). Wartości ujemne reprezentują lokalizacje, które są niższe niż ich otoczenie (doliny). 
-- Wartości TPI bliskie zeru to albo płaskie obszary (gdzie nachylenie jest bliskie zeru), albo obszary o stałym nachyleniu.

-- Funkcja ST_Value pozwala na utworzenie mapy TPI z DEM wysokości. Obecna wersja PostGIS może obliczyć TPI jednego 
-- piksela za pomocą sąsiedztwa wokół tylko jednej komórki. Poniższy przykład pokazuje jak obliczyć TPI przy użyciu 
-- tabeli rasters.dem jako danych wejściowych. Tabela nazywa się TPI30 ponieważ ma rozdzielczość 30 metrów i TPI używa 
-- tylko jednej komórki sąsiedztwa do obliczeń. Tabela wyjściowa z wynikiem zapytania zostanie stworzona w 
-- schemacie knapczyk, jest więc możliwa jej wizualizacja w QGIS.

create table knapczyk.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

-- Poniższa kwerenda utworzy indeks przestrzenny:
CREATE INDEX idx_tpi30_rast_gist ON knapczyk.tpi30
USING gist (ST_ConvexHull(rast));

-- Dodanie constraintów:
SELECT AddRasterConstraints('knapczyk'::name,
'tpi30'::name,'rast'::name);

-- wynikiem jest taka splaszczona jakby wyskrobana delikatnie mapka

-- ograniczenie tylko i wylacznie do porto
CREATE TABLE knapczyk.tpi30_porto AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem a, vectors.porto_parishes b
WHERE ST_Intersects(a.rast, b.geom)
  AND b.municipality ILIKE 'porto';


-- ALGEBRA MAP
-- Istnieją dwa sposoby korzystania z algebry map w PostGIS. Jednym z nich jest użycie wyrażenia, a drugim funkcji zwrotnej. 
-- NDVI=(NIR-Red)/(NIR+Red)
-- wskaźnik używany w analizie satelitarnej do oceny zdrowia i gęstości roślinności na ziemi, ocenia zazielenienie

-- Z WYRAZENIEM
CREATE TABLE knapczyk.porto_ndvi AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, 1,
r.rast, 4,
'([rast2.val] - [rast1.val]) / ([rast2.val] +
[rast1.val])::float','32BF'
) AS rast
FROM r;

-- Poniższe zapytanie utworzy indeks przestrzenny na wcześniej stworzonej tabeli:
CREATE INDEX idx_porto_ndvi_rast_gist ON knapczyk.porto_ndvi
USING gist (ST_ConvexHull(rast));
-- Dodanie constraintów:
SELECT AddRasterConstraints('knapczyk'::name,
'porto_ndvi'::name,'rast'::name);

--wynikiem jest pociete porto 

-- Z FUNKCJA
-- W pierwszym kroku należy utworzyć funkcję, które będzie wywołana później:

create or replace function knapczyk.ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;
-- W kwerendzie algebry map należy można wywołać zdefiniowaną wcześniej funkcję:
CREATE TABLE knapczyk.porto_ndvi2 AS
WITH r AS (
SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
r.rid,ST_MapAlgebra(
r.rast, ARRAY[1,4],
'knapczyk.ndvi(double precision[],
integer[],text[])'::regprocedure, --> This is the function!
'32BF'::text
) AS rast
FROM r;
-- Dodanie indeksu przestrzennego:
CREATE INDEX idx_porto_ndvi2_rast_gist ON knapczyk.porto_ndvi2
USING gist (ST_ConvexHull(rast));
-- Dodanie constraintów:
SELECT AddRasterConstraints('knapczyk'::name,
'porto_ndvi2'::name,'rast'::name);

--wynik zawiera wieksza czesc terenu


-- EKSPORT DANYCH

-- opcja 1: zapis przez qgis wybranej warstwy

-- opcja 2: Funkcja ST_AsTiff tworzy dane wyjściowe jako binarną reprezentację pliku tiff, może to być przydatne
--na stronach internetowych, skryptach itp., w których programista może kontrolować, co zrobić z
-- plikiem binarnym, na przykład zapisać go na dysku lub po prostu wyświetlić.
SELECT ST_AsTiff(ST_Union(rast))
FROM knapczyk.porto_ndvi;

-- opcja 3: Zapisywanie danych na dysku za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM knapczyk.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, '/Users/marysiaknapczyk/Desktop/inf/7sem/bdp/cw6/myraster.tiff') --> Save the file in a place
-- where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.


-- w terminalu
CREATE TABLE knapczyk.porto_ndvi_union AS
SELECT ST_Union(rast) AS rast
FROM knapczyk.porto_ndvi;

-- komenda
-- gdal_translate "PG:host=localhost dbname=postgis_raster user=marysiaknapczyk schema=knapczyk 
-- table=porto_ndvi_union column=rast" /Users/marysiaknapczyk/Desktop/inf/7sem/bdp/cw6/myraster.tiff


-- PUBLIKOWANIE MAPSERVER

