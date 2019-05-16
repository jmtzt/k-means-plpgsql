import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# %matplotlib inline
#cl_number,sepal_length,sepal_width,petal_length,petal_width,dist
df = pd.read_csv('clusters.csv')

# print(df.columns)

plt.scatter(df.sepal_length, df.sepal_width, c = df.cl_number)
plt.show()