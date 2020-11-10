import pandas as pd
import os
import numpy as np
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.linear_model import LogisticRegression
import pickle
import shelve

my_shelf = shelve.open('Feature_Selection_Results.out')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()

# Multinomial Logistic Regression for Prediction
MLR_model = LogisticRegression(random_state=0, 
                            multi_class='multinomial', 
                            penalty='l1',   # Lasso Regression
                            C = 1 / 1000.0, # NEED TO GRID SEARCH
                            solver='saga')
MLR_model.fit(tfidf_X_train, y_train)

in_predictions_MLR = MLR_model.predict(tfidf_X_train)
out_predictions_MLR = MLR_model.predict(tfidf_X_test)

MLR_in_accuracy = accuracy_score(in_predictions_MLR, y_train)
MLR_out_accuracy = accuracy_score(out_predictions_MLR, y_test)

filename = 'MLR_model.sav'
pickle.dump(MLR_model, open(filename, 'wb'))

# Support Vector Machines for Prediction
SVM_model = SVC(kernel='linear', 
                C = 1 / 1000.0,  # NEED TO GRID SEARCH?
                probability = True,
                verbose = True)
SVM_model.fit(tfidf_X_train, y_train)

in_predictions_SVM = SVM_model.predict(tfidf_X_train)
out_predictions_SVM = SVM_model.predict(tfidf_X_test)

SVM_in_accuracy = accuracy_score(in_predictions_SVM, y_train)
SVM_out_accuracy = accuracy_score(out_predictions_SVM, y_test)

filename = 'SVM_model.sav'
pickle.dump(SVM_model, open(filename, 'wb'))

# Deep Neural Net for Prediction
