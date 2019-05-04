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



SELECT * FROM IRIS;

SELECT MIN(SEPAL_LENGTH) AS MIN_SL, MAX(SEPAL_LENGTH) AS MAX_SL,
		MIN(SEPAL_WIDTH) AS MIN_SW, MAX(SEPAL_WIDTH) AS MAX_SW,
		MIN(PETAL_LENGTH) AS MIN_PL, MAX(PETAL_LENGTH) AS MAX_PL,
		MIN(PETAL_WIDTH) AS MIN_PW, MAX(PETAL_WIDTH) AS MAX_PW
			FROM IRIS;
-- MIN_SL = 4.3
-- MAX_SL = 7.9
-- MIN_SW = 2
-- MAX_SW = 4.4
-- MIN_PL = 1
-- MAX_PL = 6.9
-- MIN_PW = 0.1
-- MAX_PW = 2.5

CREATE TABLE IRIS_NORMALIZADO(
    sepal_length REAL,
    sepal_width REAL,
    petal_length REAL,
    petal_width REAL,
    species INTEGER
);

INSERT INTO IRIS_NORMALIZADO 
	SELECT (SEPAL_LENGTH - 4.3)/(7.9 - 4.3),
			(SEPAL_WIDTH - 2)/(4.4 - 2),
			(PETAL_LENGTH - 1)/(6.9 - 1),
			(PETAL_WIDTH - 0.1)/(2.5 - 0.1),
			SPECIES FROM IRIS;
SELECT * FROM IRIS_NORMALIZADO;

