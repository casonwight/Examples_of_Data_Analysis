# Cason Wight
# Example of Elastic Net Regression
# 1/23/2020


from sklearn.linear_model import ElasticNet
from sklearn.model_selection import GridSearchCV
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import statsmodels.api as sm
from sklearn.preprocessing import StandardScaler
import statistics as stat

# read in the data
filepath = 'Rivers.csv'
rivers = pd.read_csv(filepath)

# Look at the data
rivers.head()
rivers.describe()
rivers.info()
rivers.columns

# Define the x and y matrices
x = rivers.loc[:,'strmOrder':'Lat']
x_standard = StandardScaler().fit_transform(x)
y = rivers.loc[:,'Metric']


# Fit an elastic net
enet = ElasticNet(tol = .001, max_iter=10000)

# Grid search for best weighting and best penalty
parametersGrid = {"alpha": np.arange(.1176, .1178, .00001),
                      "l1_ratio": np.arange(0.155, .157, 0.0001)}
grid = GridSearchCV(enet,parametersGrid,scoring='neg_mean_squared_error',cv=5)
grid.fit(sm.add_constant(x_standard), y)

# Assign the best parameters
best_params = grid.best_params_
best_alpha = list(best_params.values())[0]
best_l1_ratio = list(best_params.values())[1]

# assign the "best" elastic net and fit it 
best_lasso = ElasticNet(alpha = best_alpha, l1_ratio = best_l1_ratio)
best_grid = best_lasso.fit(sm.add_constant(x_standard), y)


# We want the credible interval (through bootstrapping) of the coefficients
columns_to_estimate = ["gord","cls1","Longitude","Somehwat Excessive", "cls2"]
ests = pd.DataFrame(columns=columns_to_estimate)
 
for i in range(0,1000):
    this_x = (x.sample(n=np.shape(x)[0],replace=True)-np.mean(x))/np.std(x)
    this_y = y[this_x.index]
    this_enet = ElasticNet(alpha = best_alpha, l1_ratio = best_l1_ratio)
    this_enet.fit(sm.add_constant(this_x.values), this_y)
    ests.loc[i,:] = pd.DataFrame(np.reshape(this_enet.coef_,(-1,1)),columns=['F']).loc[[8, 69, 95, 92, 73],:].transpose().values[0]

# 95% credible intervals of estimated effects
ests.quantile([.025, .975], numeric_only=False)


# R^2 for the Elastic Net
predictions = grid.predict(sm.add_constant(x_standard))
1-np.mean((predictions-y)**2)/np.mean((y-np.mean(y))**2)


# Cross Validation
numGroups = 6
new_col =np.random.randint(1, numGroups, len(x_standard))[...,None] 

xCross = np.concatenate((x_standard, new_col), 1)
MSE = pd.DataFrame(columns=["MSE"])

for i in range(1,numGroups):
    included = xCross[:,-1]==i
    excluded = xCross[:,-1]!=i
    groupies = xCross[included,:-1]
    outies = xCross[excluded,:-1]
    this_Enet = ElasticNet(alpha = best_alpha, l1_ratio = best_l1_ratio).fit(sm.add_constant(outies), y[excluded])
    predictions = this_Enet.predict(sm.add_constant(groupies))
    MSE.loc[i-1] = np.mean((predictions-y[included])**2)


# The rMSE and Atd. Dev
print("\nMSE for each group:")
print(MSE)
print("\nAverage MSE:")
print(np.mean(MSE))
print("\nAverage rMSE:")
print(np.sqrt(np.mean(MSE)))
print("\nVariance of Resale Value:")
print(stat.variance(y))
print("\Standard Deviation of Resale Value:")
print(np.sqrt(stat.variance(y)))


# Fitted vs actuals to check assumptions
fitted = best_grid.predict(sm.add_constant(x_standard))
actuals = y

plt.plot([-1.6, 2], [-1.6, 2], color = "black")
plt.scatter(fitted, actuals)
plt.xlabel('Fitted')
plt.ylabel('Response')
plt.title("Fitted Values against True Response in Elastic Net")
plt.savefig('FittedAgainstResiduals.png')
plt.show()
