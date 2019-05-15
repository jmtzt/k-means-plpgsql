CREATE TABLE IRIS(
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);

-- Iris-setosa - 0
-- Iris-versicolor - 1
-- Iris-virginica - 2

COPY IRIS from '/Users/jmttzt/Desktop/5Periodo/BD2/trabalho1/iris.data' DELIMITER ',';
--COPY IRIS from 'C:/Users/vinic/Desktop/Trabalhos/BD2/TrabsBD/k-means-plpgsql/iris.data' DELIMITER ',';


SELECT * FROM IRIS;

--SELECT MIN(SEPAL_LENGTH) AS MIN_SL, MAX(SEPAL_LENGTH) AS MAX_SL,
--		MIN(SEPAL_WIDTH) AS MIN_SW, MAX(SEPAL_WIDTH) AS MAX_SW,
--		MIN(PETAL_LENGTH) AS MIN_PL, MAX(PETAL_LENGTH) AS MAX_PL,
--		MIN(PETAL_WIDTH) AS MIN_PW, MAX(PETAL_WIDTH) AS MAX_PW
--			FROM IRIS;
-- MIN_SL = 4.3
-- MAX_SL = 7.9
-- MIN_SW = 2
-- MAX_SW = 4.4
-- MIN_PL = 1
-- MAX_PL = 6.9
-- MIN_PW = 0.1
-- MAX_PW = 2.5

-- INSERT INTO IRIS_NORMALIZADO 
-- 	SELECT (SEPAL_LENGTH - 4.3)/(7.9 - 4.3),
-- 			(SEPAL_WIDTH - 2)/(4.4 - 2),
-- 			(PETAL_LENGTH - 1)/(6.9 - 1),
-- 			(PETAL_WIDTH - 0.1)/(2.5 - 0.1),
-- 			SPECIES FROM IRIS;
-- SELECT * FROM IRIS_NORMALIZADO;


-- CREATE OR REPLACE FUNCTION CREATE_CENTROID (kn integer)
-- RETURNS TABLE
-- (
-- 	cod int,
-- 	sepal_length REAL,
--     sepal_width REAL,
--     petal_length REAL,
--     petal_width REAL,
-- 	species INTEGER
-- ) AS $$
-- DECLARE
-- 	REG RECORD;
-- 	RAND INT[];
-- BEGIN
-- 	FOR i IN 1..kn 
-- 		loop
-- 			RAND[i]:= floor(random() * 150 + 1)::int;
-- 		end loop;
		
-- 	return query Select * from IRIS_NORMALIZADO where IRIS_NORMALIZADO.cod = any(RAND);
-- END; $$
-- Language PLPGSQL;


-- CREATE OR REPLACE FUNCTION CALC_DISTANCIAS (kn integer)
-- RETURNS TABLE 
-- (
-- 	dis_point_c1 REAL,
-- 	dis_point_c2 REAL, 
-- 	dis_point_c3 REAL
-- ) as $$
-- DECLARE
-- 	REG RECORD;
-- 	DIS RECORD;
-- BEGIN
-- --	SELECT INTO REG * FROM CREATE_CENTROID(3);
-- --	INSERT INTO DIS VALUES SQRT((POWER((REG.sepal_length - IRIS_NORMALIZADO.sepal_length),2) + 
-- --					POWER((REG.sepal_width - IRIS_NORMALIZADO.sepal_width),2) +
-- --					POWER((REG.petal_length - IRIS_NORMALIZADO.petal_length),2) +
-- --					POWER((REG.petal_width - IRIS_NORMALIZADO.petal_width),2)));
-- 	FOR REG IN(SELECT 
--  		sepal_length,
--     	sepal_width,
--     	petal_length,
--     	petal_width  
--         FROM CREATE_CENTROID(kn)
--  		LOOP
--         	dis_point_c1 :=  SQRT((POWER((REG.sepal_length - IRIS_NORMALIZADO.sepal_length),2) + 
-- 					POWER((REG.sepal_width - IRIS_NORMALIZADO.sepal_width),2) +
-- 					POWER((REG.petal_length - IRIS_NORMALIZADO.petal_length),2) +
-- 					POWER((REG.petal_width - IRIS_NORMALIZADO.petal_width),2)));
 			
--         	RETURN NEXT;
--  		END LOOP;
-- 	RETURN QUERY SELECT * FROM DIS;
-- END; $$
-- LANGUAGE PLPGSQL;

-- SELECT CALC_DISTANCIAS()
--CREATE TABLE IRIS_TESTE(
--	cod SERIAL,
 --   sepal_length REAL,
  --  sepal_width REAL,
   -- petal_length REAL,
   -- petal_width REAL,
   -- species INTEGER
--);
--insert into IRIS_TESTE select * from create_centroid(3);

--SELECT * FROM IRIS_TESTE;

CREATE TABLE IRIS_NORMALIZADO(
	cod SERIAL,
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);

-- FUNCAO PARA A NORMALIZACAO DOS DADOS DO DATASET IRIS

CREATE OR REPLACE FUNCTION NORMALIZE_FN() RETURNS VOID AS $$
	DECLARE
		REG RECORD;
	BEGIN
		SELECT MIN(SEPAL_LENGTH) AS MIN_SL, MAX(SEPAL_LENGTH) AS MAX_SL,
				MIN(SEPAL_WIDTH) AS MIN_SW, MAX(SEPAL_WIDTH) AS MAX_SW,
				MIN(PETAL_LENGTH) AS MIN_PL, MAX(PETAL_LENGTH) AS MAX_PL,
				MIN(PETAL_WIDTH) AS MIN_PW, MAX(PETAL_WIDTH) AS MAX_PW INTO REG 
				FROM IRIS;
				
		INSERT INTO IRIS_NORMALIZADO (sepal_length, sepal_width, petal_length, petal_width, species)
				SELECT (SEPAL_LENGTH - REG.MIN_SL)/(REG.MAX_SL - REG.MIN_SL),
				(SEPAL_WIDTH - REG.MIN_SW)/(REG.MAX_SW - REG.MIN_SW),
				(PETAL_LENGTH - REG.MIN_PL)/(REG.MAX_PL - REG.MIN_PL),
				(PETAL_WIDTH - REG.MIN_PW)/(REG.MAX_PW - REG.MIN_PW),
				SPECIES FROM IRIS;
	END
$$ LANGUAGE PLPGSQL;

SELECT NORMALIZE_FN();

SELECT * FROM IRIS_NORMALIZADO;

CREATE TABLE CENTROID(
	cl_number integer,
	sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL
);

CREATE OR REPLACE FUNCTION CENTROID_FN(kn integer) RETURNS VOID AS $$
	BEGIN
		FOR i in 1 .. kn LOOP
			INSERT INTO CENTROID (cl_number, sepal_length, sepal_width, petal_length, petal_width) SELECT i, random(), random(), random(), random();
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

SELECT CENTROID_FN(3);

SELECT * FROM CENTROID;

-- CREATE OR REPLACE FUNCTION MIN_INDEX_ARRAY(V REAL[], kn integer) RETURNS INTEGER AS $$
-- 	DECLARE
-- 		min_val REAL := 2147483647;
-- 		min_index integer;
-- 	BEGIN
-- 		FOR i IN 1 .. kn LOOP
-- 			IF V[i] < min_val THEN
-- 				min_index = i;
-- 			END IF;
-- 		END LOOP;
-- 		RETURN min_index;
-- 	END;
-- $$ LANGUAGE PLPGSQL;

-- SELECT MIN_INDEX_ARRAY(ARRAY[6,4,3,7,2,1, 0.03], 7);


CREATE OR REPLACE FUNCTION DISTANCE_FN(sli REAL, slc REAL, swi REAL, swc REAL, plir REAL, plc REAL, pwir REAL, pwc REAL) RETURNS REAL AS $$
	BEGIN
		RETURN sqrt(power((slc - sli), 2) + power((swi - swc), 2) + power((plir - plc), 2) + power((pwir - pwc), 2));
	END;
$$ LANGUAGE PLPGSQL;

CREATE TABLE DISTANCIAS(
	cod integer,
	cl_number integer,
	sepal_length REAL,
	sepal_width REAL, 
	petal_length REAL,
	petal_width REAL,
	dist REAL
);

CREATE OR REPLACE FUNCTION CALC_DIST() RETURNS VOID AS $$
	BEGIN
		INSERT INTO DISTANCIAS SELECT I.COD, CE.CL_NUMBER, I.sepal_length, I.sepal_width, I.petal_length, I.petal_width, DISTANCE_FN(I.sepal_length, CE.sepal_length, I.sepal_width, CE.sepal_width, I.petal_length, CE.petal_length, I.petal_width, CE.petal_width)
										FROM IRIS_NORMALIZADO AS I, CENTROID AS CE;
	END;
$$ LANGUAGE PLPGSQL;

SELECT CALC_DIST();

select cod, cl_number, min(dist) from distancias group by cod, cl_number order by cod, cl_number asc;

CREATE TABLE CLUSTERS(
	cl_number integer,
	sepal_length REAL,
	sepal_width REAL, 
	petal_length REAL,
	petal_width REAL,
	dist REAL
);

CREATE OR REPLACE FUNCTION INSERE_REGIAO_FN() RETURNS VOID AS $$
	BEGIN
		FOR i in 1 .. 150 LOOP
			INSERT INTO CLUSTERS SELECT DISTINCT ON (dist) cl_number, sepal_length, sepal_width, petal_length, petal_width, dist FROM DISTANCIAS WHERE dist = (SELECT min(dist) FROM DISTANCIAS WHERE cod = i);
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

DROP TABLE CLUSTERS;

select insere_regiao_fn();

select * from clusters;

-- CALCULA NOVOS CENTROS
SELECT cl_number, AVG(sepal_length), AVG(sepal_width), AVG(petal_length), AVG(petal_width) FROM CLUSTERS GROUP BY cl_number;

SELECT * FROM CENTROID;

CREATE OR REPLACE FUNCTION KMEANS_FN(kn integer, iter integer) RETURNS VOID AS $$
	DECLARE
		new_centroid RECORD;
	BEGIN
		FOR i in 1 .. kn LOOP
			INSERT INTO CENTROID (cl_number, sepal_length, sepal_width, petal_length, petal_width) SELECT i, random(), random(), random(), random();
		END LOOP;
		FOR i in 1 .. iter LOOP
			INSERT INTO DISTANCIAS SELECT I.COD, CE.CL_NUMBER, I.sepal_length, I.sepal_width, I.petal_length, I.petal_width, DISTANCE_FN(I.sepal_length, CE.sepal_length, I.sepal_width, CE.sepal_width, I.petal_length, CE.petal_length, I.petal_width, CE.petal_width)
										FROM IRIS_NORMALIZADO AS I, CENTROID AS CE;
			FOR i in 1 .. 150 LOOP
				INSERT INTO CLUSTERS SELECT DISTINCT ON (dist) cl_number, sepal_length, sepal_width, petal_length, petal_width, dist FROM DISTANCIAS WHERE dist = (SELECT min(dist) FROM DISTANCIAS WHERE cod = i);
			END LOOP;
		
			SELECT cl_number, AVG(sepal_length) as avg_sl, AVG(sepal_width) as avg_sw, AVG(petal_length) as avg_pl, AVG(petal_width) as avg_pw INTO new_centroid FROM CLUSTERS GROUP BY cl_number ORDER BY cl_number ASC;	
-- 		EXIT WHEN (ABS(new_centroid.avg_sl - CENTROID.sepal_length) < 0.01) AND (ABS(new_centroid.avg_sw - CENTROID.sepal_width) < 0.01) AND
-- 			(ABS(new_centroid.avg_pl - CENTROID.petal_length) < 0.01) AND (ABS(new_centroid.avg_pw - CENTROID.petal_width) < 0.01);	
		
			
			UPDATE CENTROID SET sepal_length = new_centroid.avg_sl, sepal_width = new_centroid.avg_sw, petal_length = new_centroid.avg_pl, petal_width = new_centroid.avg_pw WHERE centroid.cl_number = new_centroid.cl_number;
			
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

SELECT KMEANS_FN(3,1);

SELECT * FROM CENTROID;
SELECT * FROM DISTANCIAS;
SELECT cl_number, AVG(sepal_length), AVG(sepal_width), AVG(petal_length), AVG(petal_width) FROM CLUSTERS GROUP BY cl_number;


