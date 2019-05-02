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

CREATE OR REPLACE FUNCTION DATA_NORM(min_sl REAL, max_sl REAL,
								      min_sw REAL, max_sw REAL, min_pl REAL,
									  max_pl REAL, min_pw REAL, max_pw REAL) RETURNS
TABLE(	sepal_length REAL,
    	sepal_width REAL,
    	petal_length REAL,
    	petal_width REAL,
    	species INTEGER) AS $$
		
		BEGIN
		
			RETURN QUERY SELECT ((sepal_length - min_sl)/(max_sl - min_sl)),
								 ((sepal_width - min_sw)/(max_sw - min_sw)),
								 ((petal_length - min_pl)/(max_pl - min_pl)),
								 ((petal_width - min_pw)/(max_pw - min_pw)),
								 species FROM IRIS;
		END;
$$ LANGUAGE PLPGSQL;

SELECT DATA_NORM(SELECT MIN(IRIS.sepal_length) FROM IRIS, SELECT MAX(IRIS.sepal_length) FROM IRIS,
				 SELECT MIN(IRIS.sepal_width) FROM IRIS, SELECT MAX(IRIS.sepal_width) FROM IRIS,
				 SELECT MIN(IRIS.petal_length) FROM IRIS, SELECT MAX(IRIS.petal_length) FROM IRIS,
				 SELECT MIN(IRIS.petal_width) FROM IRIS, SELECT MAX(IRIS.petal_width) FROM IRIS);