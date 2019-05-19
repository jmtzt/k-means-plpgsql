import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
sns.set(style="ticks", color_codes=True)

irisOriginal = sns.load_dataset("iris")
plt.figure()
sns.pairplot(irisOriginal, hue="species")
plt.savefig('irisOriginal.pdf', bbox_inches= 'tight')
# %matplotlib inline
#cl_number,sepal_length,sepal_width,petal_length,petal_width,dist
df = pd.read_csv('clusters.csv', usecols = ['cl_number','sepal_length','sepal_width','petal_length','petal_width'])
df.cl_number[df.cl_number == 1] = 'versicolor'
df.cl_number[df.cl_number == 2] = 'setosa'
df.cl_number[df.cl_number == 3] = 'virginica'
# print(df.head())
plt.figure()
sns.pairplot(df, hue = "cl_number")
plt.savefig('irisPLPGSQL', bbox_inches = 'tight')