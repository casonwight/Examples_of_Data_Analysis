import pandas as pd
import os
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.feature_extraction.text import TfidfVectorizer
import shelve

os.chdir('C:\\Users\\cason\\Desktop\\Classes\\Assignments\\Stat 666\\Final Project')

my_shelf = shelve.open('Feature_Selection_Results.out','n')

talks = pd.read_csv('Talk_Quotes_Data.csv', parse_dates = [1])
speeches = pd.read_csv('Speech_Quotes_Data.csv', parse_dates = [1])

all_talks = talks.append(speeches, ignore_index=True)
all_talks = all_talks[all_talks.Content.str.len() > 30]
np.shape(all_talks)

del talks
del speeches

X_train_all, X_test_all, y_train, y_test = train_test_split(all_talks, all_talks.Speaker, test_size=0.2)
X_train = X_train_all.Content
X_test = X_test_all.Content
speaker_dict = {k:v for v, k in enumerate(all_talks.Speaker.unique())}
y_train = [speaker_dict[speaker] for speaker in list(y_train)]
y_test = [speaker_dict[speaker] for speaker in list(y_test)]
to_speaker_dict = {v:k for v, k in enumerate(all_talks.Speaker.unique())}


vectorizer = TfidfVectorizer(analyzer = 'word', 
                             stop_words = 'english',
                             max_features = 2500,
                             ngram_range = (1,3))
vectorizer.fit(list(all_talks.Content))
tfidf_X_train = vectorizer.transform(X_train)
tfidf_X_test = vectorizer.transform(X_test)

scaler = StandardScaler(with_mean=False)
tfidf_X_train = scaler.fit_transform(tfidf_X_train)
tfidf_X_test = scaler.transform(tfidf_X_test)
feature_names = vectorizer.get_feature_names()

denselist_X_train = tfidf_X_train.todense().tolist()
dfwords = pd.DataFrame(denselist_X_train, columns=feature_names)

to_save = ['X_test', 'X_test_all', 'X_train', 'X_train_all', 'all_talks',
           'dfwords', 'feature_names', 'speaker_dict', 'tfidf_X_test', 
           'tfidf_X_train', 'to_speaker_dict', 'y_test', 'y_train']

for key in to_save:
    my_shelf[key] = globals()[key]

my_shelf.close()
