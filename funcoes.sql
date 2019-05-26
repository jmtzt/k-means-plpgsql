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

SELECT NORMALIZE_FN();

-- CALCULO DA DISTANCIA ENTRE CADA LINHA DA TABELA IRIS NORMALIZADO
-- E A TABELA CENTROID, ATRIBUTO POR ATRIBUTO
CREATE OR REPLACE FUNCTION DISTANCE_FN(sli REAL, slc REAL, swi REAL, swc REAL, plir REAL, plc REAL, pwir REAL, pwc REAL) RETURNS REAL AS $$
	BEGIN
		RETURN sqrt(power((slc - sli), 2) + power((swi - swc), 2) + power((plir - plc), 2) + power((pwir - pwc), 2));
	END;
$$ LANGUAGE PLPGSQL;

-- BASICAMENTE A JUNCAO DE TODAS AS FUNCOES DESCRITAS NO ARQUIVO FUNCOES_PRIMITIVO A FIM DE IMPLEMENTAR O  KMEANS
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

CREATE OR REPLACE FUNCTION RESET_TABLES() RETURNS VOID AS $$
	BEGIN
		DELETE FROM CENTROID;
		DELETE FROM CLUSTERS;
		DELETE FROM DISTANCIAS;
		DELETE FROM NEW_CENTROID;
	END
$$ LANGUAGE PLPGSQL