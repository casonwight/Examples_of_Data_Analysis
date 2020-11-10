from sklearn.preprocessing import StandardScaler
from sklearn import preprocessing
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import GridSearchCV
import pandas as pd
import numpy as np
import os
import pickle
import heapq

# Read in all the data created by Analysis.py
X_train = pd.read_csv("X_train.csv").iloc[:,1:]
X_test = pd.read_csv("X_test.csv").iloc[:,1:]
Y_train = pd.read_csv("Y_train.csv")['Department']
Y_test = pd.read_csv("Y_test.csv")['Department']

# Scale the data
scaler = StandardScaler()
scaler.fit(X_train)
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)

# Properly label the ys
le = preprocessing.LabelEncoder()
le.fit(Y_train)
Y_train = le.transform(Y_train)
Y_test = le.transform(Y_test)

#### Neural Net Analysis

# Fit a Neural Net
parameter_space = {
    'hidden_layer_sizes': [(500,300),(700,350), (300,300), 
                           (300,150), (200,150)],
    'activation': ['tanh', 'relu'],
    'solver': ['sgd'],
    'alpha': [0.05],
    'learning_rate': ['constant'],
}
mlp = MLPClassifier(max_iter=200)

# Grid search for best layer sizes, activations,
# solvers, alphas, and types of learning rates

# Each of these was tested rather extensively, and arriveed at the 
# Subset defined in lines 33-40
clf = GridSearchCV(mlp, parameter_space, n_jobs=-1, cv=3, verbose = 10)
clf.fit(X_train, Y_train)

print('Best parameters found:\n', clf.best_params_)

# Refit the model for documentation purposes 
#   (prior lines could be skipped)
mlp = MLPClassifier(max_iter=200, 
                    hidden_layer_sizes = [700,350],
                    activation = 'tanh',
                    solver = 'sgd',
                    alpha = .05,
                    learning_rate = 'constant')
mlp.fit(X_train,Y_train)

# Save the Neural net
pickle.dump(mlp, open("final_Neural_net.sav", 'wb'))

mlp = pickle.load(open("final_Neural_net.sav", 'rb'))

# predict on the test set of unknown values
new_X = pd.read_csv("new_X.csv").iloc[:,2:]
new_X = scaler.transform(new_X)
new_preds = mlp.predict_proba(new_X)


fitted_valsNN = mlp.predict_proba(X_train)
pred_valsNN = mlp.predict_proba(X_test)


preds = []
preds2 = []
preds3 = []
fits = []
fits2 = []
fits3 = []

# Get the 2nd and 3rd best predictions as well
# This is so that a user could potentially select from top 3 
# guesses from the neural net
for i in range(len(fitted_valsNN)):
    fits.append(fitted_valsNN[i].argmax())
    withoutBest = fitted_valsNN[i][fitted_valsNN[i]<fitted_valsNN[i].max()]
    fits2.append(withoutBest.argmax())
    without2Best = withoutBest[withoutBest<withoutBest.max()]
    fits3.append(without2Best.argmax())
    
for i in range(len(pred_valsNN)):
    preds.append(pred_valsNN[i].argmax())
    withoutBest = pred_valsNN[i][pred_valsNN[i]<pred_valsNN[i].max()]
    preds2.append(withoutBest.argmax())
    without2Best = withoutBest[withoutBest<withoutBest.max()]
    preds3.append(without2Best.argmax())
    


newpreds = []
for i in range(len(new_preds)):
    newpreds.append(new_preds[i].argmax())

le.inverse_transform(newpreds)

fitteds = []
for i in range(np.shape(Y_train)[0]):
    fitteds.append(fits[i]==Y_train[i] or fits2[i] == Y_train[i] or fits3[i]==Y_train[i])

# % time in top 3 (within sample)
np.mean(fitteds)

predicteds = []
for i in range(np.shape(Y_test)[0]):
    predicteds.append(preds[i]==Y_test[i] or preds2[i] == Y_test[i] or preds3[i]==Y_test[i])

# % time in top 3 (out of sample)
np.mean(predicteds)

# % of time top guess is correct (in and out of sample)
np.mean(preds==Y_test)
np.mean(fits==Y_train)

# confusion matrices
pd.crosstab(le.inverse_transform(fits),le.inverse_transform(Y_train))
pd.crosstab(le.inverse_transform(preds),le.inverse_transform(Y_test))
