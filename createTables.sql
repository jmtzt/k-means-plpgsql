--Felipe Augusto Arruda 1948423
--João Marcelo Tozato 1913310
--Vinicius Ribeiro Furlan 1913409

CREATE TABLE IRIS(
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);
-- INSIRA O PATH PARA IRIS.DATA CONTIDA NO ARQUIVO COMPRIMIDO
-- E IMPORTANTE UTILIZAR ESTE ARQUIVO, VISTO QUE HA MODIFICACOES FEITAS
-- PREVIAMENTE A FIM DE QUE A COLUNA SPECIES SEJA UM NUMERO INTEIRO
COPY IRIS FROM '/Users/jmttzt/Desktop/5Periodo/BD2/trabalho1/iris.data' DELIMITER ',';

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