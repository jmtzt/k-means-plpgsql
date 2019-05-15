import pandas as pd 
import numpy as np
from sklearn.utils import shuffle

df = pd.read_csv('/Users/jmttzt/Desktop/5Periodo/BD2/trabalho1/iris.csv') 

# print(df)

classes = df['species']  
df = df.drop(['species'],axis=1) 
data = df.values.tolist() 
data = np.array(data)
data_new = data[:5]  


import random
import numpy as np
 # coordenadas 3 centroides
c1 = [float(np.random.randint(4,8)),float(np.random.randint(1,5)),
      float(np.random.randint(1,7)),float(np.random.randint(0,3))]
c2 = [float(np.random.randint(4,8)),float(np.random.randint(1,5)),
      float(np.random.randint(1,7)),float(np.random.randint(0,3))]
c3 = [float(np.random.randint(4,8)),float(np.random.randint(1,5)),
      float(np.random.randint(1,7)),float(np.random.randint(0,3))]


epochs = 1
while epochs < 2:
    cluster_1 = []
    cluster_2 = []
    cluster_3 = []
    for point in data_new:
            ## distancias do ponto para os centroides
            dis_point_c1 = ((c1[0]-point[0])**2 + (c1[1]-point[1])**2 + 
                                (c1[2]-point[2])**2 + (c1[3]-point[3])**2)**0.5
            dis_point_c2 = ((c2[0]-point[0])**2 + (c2[1]-point[1])**2 + 
                                (c2[2]-point[2])**2 + (c2[3]-point[3])**2)**0.5
            dis_point_c3 = ((c3[0]-point[0])**2 + (c3[1]-point[1])**2 + 
                                (c3[2]-point[2])**2 + (c3[3]-point[3])**2)**0.5
            distances = [dis_point_c1, dis_point_c2, dis_point_c3]
            print('distances')
            print(distances)
            pos = distances.index(min(distances))
            if(pos == 0):
                    cluster_1.append(point)
            elif(pos == 1):
                    cluster_2.append(point)
            else:
                    cluster_3.append(point)
            epochs += 1
print('cluster 1')
print(cluster_1)
print('cluster 2')
print(cluster_2)
print('cluster 3')
print(cluster_3)