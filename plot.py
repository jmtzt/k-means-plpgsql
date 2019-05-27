#Felipe Augusto Arruda 1948423
#João Marcelo Tozato 1913310
#Vinicius Ribeiro Furlan 1913409

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="ticks", color_codes=True)

# irisOriginal = sns.load_dataset("iris")
# plt.figure()
# sns.pairplot(irisOriginal, hue="species")
# plt.savefig('irisOriginal.pdf', bbox_inches= 'tight')
# %matplotlib inline
#cl_number,sepal_length,sepal_width,petal_length,petal_width,dist
df = pd.read_csv('clusters.csv', usecols = ['cl_number','sepal_length','sepal_width','petal_length','petal_width'])


for i in range(len(df.cl_number.unique().tolist())):
    df.cl_number[df.cl_number == i+1] = 'cluster: ' + str(i+1)
    

# print(df.head())
plt.figure()
sns.pairplot(df, hue = "cl_number")
plt.savefig('irisPLPGSQL_100iteracoes_k=' + str(len(df.cl_number.unique().tolist())) + '.pdf', bbox_inches = 'tight')