-- Felipe Augusto Arruda 1948423
-- João Marcelo Tozato 1913310
-- Vinicius Ribeiro Furlan 1913409

A fim de obter os resultados obtidos por este trabalho, é preciso seguir os seguintes passos:

1) No arquivo createTables.sql, na linha 15 é preciso trocar o argumento da funcão COPY 
para a pasta que contém o arquivo iris.data contido neste .zip, visto que este .data contém modificações necessárias
para que a criação das tabelas seja feita normalmente.
Após a mudança, executar o código neste arquivo.

2) Executar o arquivo funcoes.sql, a fim de criar as funções necessárias para a execução posterior do kmeans

3) No arquivo testes.sql é possível executar o agrupamento com o número desejado de k e iterações, após a execução da funcao kmeans_fn
o resultado dos agrupamentos está contido na tabela clusters, que poderá ser exportada como um .csv com headers, seja por um comando sql
ou feito diretamente pelo pgAdmin  a fim de fazer o uso do código plot.py contido neste arquivo.