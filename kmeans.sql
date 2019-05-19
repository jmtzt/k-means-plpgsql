CREATE TABLE IRIS(
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);

-- Iris-versicolor - 1
-- Iris-setosa - 2
-- Iris-virginica - 3

CREATE TABLE IRIS_NORMALIZADO(
	cod SERIAL,
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);


CREATE TABLE CENTROID(
	cl_number integer,
	sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL
);


CREATE TABLE DISTANCIAS(
	cod integer,
	cl_number integer,
	sepal_length REAL,
	sepal_width REAL, 
	petal_length REAL,
	petal_width REAL,
	dist REAL
);

CREATE TABLE CLUSTERS(
	cl_number integer,
	sepal_length REAL,
	sepal_width REAL, 
	petal_length REAL,
	petal_width REAL,
	dist REAL
);

CREATE TABLE NEW_CENTROID(
	cl_number integer,
	sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL
);
-- TODO
-- COMO RESOLVER ISSO, TIPO PRA RODAR NO PC DO PROFESSOR SEM TER QUE ELE MUDAR AQUI
COPY IRIS from '/Users/jmttzt/Desktop/5Periodo/BD2/trabalho1/iris.data' DELIMITER ',';
--COPY IRIS from 'C:/Users/vinic/Desktop/Trabalhos/BD2/TrabsBD/k-means-plpgsql/iris.data' DELIMITER ',';

-- FUNCAO PARA A NORMALIZACAO DOS DADOS DO DATASET IRIS
-- NESTA FUNCAO FAZEMOS O USO DE MIN-MAX NORMALIZATION
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

-- CRIACAO DE KN PONTOS INICIALIZADOS ALEATORIAMENTE 
-- QUE SAO AS COORDENADAS DOS CENTROIDES
-- CADA UM DESTES COM O SEU RESPECTIVO ID
CREATE OR REPLACE FUNCTION CENTROID_FN(kn integer) RETURNS VOID AS $$
	BEGIN
		FOR i in 1 .. kn LOOP
			INSERT INTO CENTROID (cl_number, sepal_length, sepal_width, petal_length, petal_width) SELECT i, random(), random(), random(), random();
-- 			RAISE NOTICE 'I: %', i;
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

-- CALCULO DA DISTANCIA ENTRE CADA LINHA DA TABELA IRIS NORMALIZADO
-- E A TABELA CENTROID, ATRIBUTO POR ATRIBUTO
CREATE OR REPLACE FUNCTION DISTANCE_FN(sli REAL, slc REAL, swi REAL, swc REAL, plir REAL, plc REAL, pwir REAL, pwc REAL) RETURNS REAL AS $$
	BEGIN
		RETURN sqrt(power((slc - sli), 2) + power((swi - swc), 2) + power((plir - plc), 2) + power((pwir - pwc), 2));
	END;
$$ LANGUAGE PLPGSQL;

-- INSERE EM UMA TABELA AS DISTANCIAS CALCULADAS, AS COORDENADAS DOS PONTOS E O CENTROIDE RESPECTIVO DESTE CALCULO
CREATE OR REPLACE FUNCTION CALC_DIST() RETURNS VOID AS $$
	BEGIN
		INSERT INTO DISTANCIAS SELECT I.COD, CE.CL_NUMBER, I.sepal_length, I.sepal_width, I.petal_length, I.petal_width, DISTANCE_FN(I.sepal_length, CE.sepal_length, I.sepal_width, CE.sepal_width, I.petal_length, CE.petal_length, I.petal_width, CE.petal_width)
										FROM IRIS_NORMALIZADO AS I, CENTROID AS CE;
	END;
$$ LANGUAGE PLPGSQL;

SELECT CALC_DIST();

-- A FIM DE DETERMINAR A QUAL GRUPO TAL PONTO PERTENCE, E PRECISO DETERMINAR A MENOR DISTANCIA
-- ENTRE AS KN DISTANCIAS CALCULADAS POR TUPLA DA TABELA IRIS NORMALIZADA
-- PARA ISSO, FAZ-SE O USO DESTA FUNCAO
CREATE OR REPLACE FUNCTION INSERE_REGIAO_FN() RETURNS VOID AS $$
	BEGIN
		FOR i in 1 .. 150 LOOP
			INSERT INTO CLUSTERS SELECT DISTINCT ON (dist) cl_number, sepal_length, sepal_width, petal_length, petal_width, dist FROM DISTANCIAS WHERE dist = (SELECT min(dist) FROM DISTANCIAS WHERE cod = i);
		END LOOP;
	END;
$$ LANGUAGE PLPGSQL;

-- BASICAMENTE A JUNCAO DE TODAS AS FUNCOES DESCRITAS ACIMA A FIM DE IMPLEMENTAR O  KMEANS
-- A FUNCAO RECEBE O NUMERO DE AGRUPAMENTOS QUE SERAO FEITOS E O NUMERO DE ITERACOES DESEJADAS 
-- PARA A EXECUCAO DO ALGORITMO
CREATE OR REPLACE FUNCTION KMEANS_FN(kn integer, iter integer) RETURNS VOID AS $$
	DECLARE
		aux_new RECORD;
		aux_centr RECORD;
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
 			
 			SELECT * INTO aux_new FROM new_centroid;
			SELECT * INTO aux_centr FROM centroid;
 			
			RAISE NOTICE 'ITERACAO NRO: %', j;
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


-- USO DO CODIGO
-- SELECT KMEANS_FN(KN, ITER)
-- O RESULTADO DOS AGRUPAMENTOS ESTARA ARMAZENADO NA
-- TABELA CLUSTERS, DESSA FORMA, PARA QUE SEJA POSSIVEL A VISUALIZACAO DOS DADOS
-- POR MEIO DE UM CODIGO PYTHON, E PRECISO SALVA-LA EM CSV, TAL QUAL O CODIGO ABAIXO
SELECT KMEANS_FN(3,50);

SELECT * FROM CLUSTERS;

COPY CLUSTERS TO ‘clusters.csv' DELIMITER ',' CSV HEADER;

DELETE FROM CENTROID;
DELETE FROM CLUSTERS;
DELETE FROM DISTANCIAS;
DELETE FROM NEW_CENTROID;