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
-- 			RAISE NOTICE 'I: %', i;
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

SELECT CENTROID_FN(3);

SELECT * FROM CENTROID;
DELETE FROM CENTROID;

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

SELECT DISTINCT ON (dist) cl_number, sepal_length, sepal_width, petal_length, petal_width, dist FROM DISTANCIAS WHERE dist = (SELECT min(dist) FROM DISTANCIAS WHERE cod = 1);

SELECT * FROM CLUSTERS;

DROP TABLE CLUSTERS;

select insere_regiao_fn();

select * from clusters;

-- CALCULA NOVOS CENTROS
SELECT cl_number, AVG(sepal_length), AVG(sepal_width), AVG(petal_length), AVG(petal_width) FROM CLUSTERS GROUP BY cl_number;

SELECT * FROM CENTROID;

CREATE TABLE NEW_CENTROID(
	cl_number integer,
	sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL
);

CREATE OR REPLACE FUNCTION KMEANS_FN(kn integer, iter integer) RETURNS VOID AS $$
	DECLARE
		aux_new record;
		aux_centr record;
		j integer := 0;
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
		
			INSERT INTO NEW_CENTROID SELECT cl_number, AVG(sepal_length) as avg_sl, AVG(sepal_width) as avg_sw, AVG(petal_length) as avg_pl, AVG(petal_width) as avg_pw FROM CLUSTERS GROUP BY cl_number ORDER BY cl_number ASC;	
 			
			-- MEXER AQUI AI JA ERAS
 			SELECT * INTO aux_new FROM new_centroid;
			SELECT * INTO aux_centr FROM centroid;
 			--UPDATE CENTROID SET sepal_length = aux.sepal_length, sepal_width = aux.sepal_width, petal_length = aux.petal_length, petal_width = aux.petal_length WHERE centroid.cl_number = aux.cl_number;
			
			--EXIT WHEN (ABS(aux_new.sepal_length - aux_centr.sepal_length) < 0.00001) AND (ABS(aux_new.sepal_width - aux_centr.sepal_width) < 0.00001) AND
 			--(ABS(aux_new.petal_length - aux_centr.petal_length) < 0.00001) AND (ABS(aux_new.petal_width - aux_centr.petal_width) < 0.00001);	
			
				
			
			RAISE NOTICE 'AQUI PELA % VEZ', j;
			j := j + 1;
			
			EXIT WHEN J = ITER;	
			
			DELETE FROM DISTANCIAS;
			DELETE FROM CENTROID;
			DELETE FROM CLUSTERS;
			
			INSERT INTO CENTROID SELECT * FROM NEW_CENTROID;
			
			DELETE FROM NEW_CENTROID;
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

SELECT KMEANS_FN(3,50);

DELETE FROM CENTROID;
DELETE FROM CLUSTERS;
DELETE FROM DISTANCIAS;
delete from new_centroid;

SELECT * FROM NEW_CENTROID;
SELECT * FROM CENTROID;
SELECT * FROM DISTANCIAS;
SELECT cl_number, AVG(sepal_length), AVG(sepal_width), AVG(petal_length), AVG(petal_width) FROM CLUSTERS GROUP BY cl_number;

select * from clusters;



