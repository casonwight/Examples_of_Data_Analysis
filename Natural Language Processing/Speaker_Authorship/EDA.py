import pandas as pd
import os
import numpy as np
from plotnine import ggplot, aes, coord_flip, geom_bar, labs, geom_line, facet_wrap, geom_point
import shelve
from sklearn.decomposition import PCA
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
import matplotlib.pyplot as plt
import datetime

os.chdir('C:\\Users\\cason\\Desktop\\Classes\\Assignments\\Stat 666\\Final Project')

my_shelf = shelve.open('Feature_Selection_Results.out')
for key in my_shelf:
    globals()[key]=my_shelf[key]
my_shelf.close()

overall_mean = dfwords.mean()
dfwords['Speaker'] = X_train_all.Speaker
oaks = dfwords.query('Speaker == "Dallin H. Oaks"').mean()
oaks = (oaks - overall_mean).reset_index()
oaks.columns = ['Word', 'Mean TF-IDF Score']
oaks = oaks.sort_values('Mean TF-IDF Score', ascending = False).iloc[[0,2,3,5,6,2496,2497,2498,2499],:]
oaks.Word = pd.Categorical(oaks.Word, categories = oaks.sort_values('Mean TF-IDF Score')['Word'])

(ggplot(oaks, aes(x = 'Word', y = 'Mean TF-IDF Score'))
     + geom_bar(stat = 'identity')
     + coord_flip()
     + labs(title = "Elder Oaks' Most unique Vocabulary (Included/Excluded)", 
            y = "TF-IDF Score: Oaks' Mean - Overall Mean"))


interesting_words = ['book mormon', 'mormon', 'holy ghost', 'prophet joseph smith', 'ministering', 'bear testimony']


most_used = dfwords.mean().sort_values(ascending = False)[interesting_words].reset_index()
most_used.columns = ['Word', 'Mean TF-IDF Score']
most_used.Word = pd.Categorical(most_used.Word, categories = most_used.sort_values('Mean TF-IDF Score')['Word'])

(ggplot(most_used, aes(x = 'Word', y = 'Mean TF-IDF Score'))
     + geom_bar(stat = 'identity')
     + coord_flip())

first_presidency = list(all_talks.Speaker.unique())[:3]
first_pres_num = [speaker_dict[mbr] for mbr in first_presidency]

dfwords['Speaker'] = y_train
by_speaker = (dfwords
              .groupby('Speaker')
              .mean()[most_used.sort_values('Mean TF-IDF Score')['Word']]
              .unstack()
              .reset_index()
              .query(f'Speaker in {first_pres_num}'))
by_speaker.columns = ['Word', 'Speaker', 'Mean TF-IDF Score']
by_speaker.Speaker = [to_speaker_dict[spkr] for spkr in by_speaker.Speaker]
by_speaker.Word = pd.Categorical(by_speaker.Word, categories = most_used.Word.sort_index(ascending=False))
by_speaker = by_speaker.append(most_used)
by_speaker.iloc[list(np.where(by_speaker.Speaker.isnull())[0]),1] = 'Overall'
by_speaker.Speaker = pd.Categorical(by_speaker.Speaker, categories = first_presidency + ['Overall'])
(ggplot(by_speaker, aes(x = 'Word', y = 'Mean TF-IDF Score', fill = 'Speaker', width = .75))
     + geom_bar(position = 'dodge', stat = 'identity')
     + coord_flip()
     + labs(title = "Word Usage in the First Presidency"))

dfwords['Date'] = X_train_all.Date.values
dfwords.Speaker = [to_speaker_dict[spkr] for spkr in dfwords.Speaker]
pres_Nelson = (dfwords
               .query(f"Speaker in {first_presidency}")
               .groupby([dfwords['Date']
               .map(lambda x: x.year), 'Speaker'])
               .mean()[interesting_words]
               .reset_index())
pres_Nelson['combined'] = [str(dt) for dt in pres_Nelson.Date] + pres_Nelson.Speaker
pres_Nelson = (pres_Nelson
               .drop(columns = ['Date', 'Speaker'])
               .set_index('combined')
               .unstack()
               .reset_index())
pres_Nelson['Date'] = [int(comb[:4]) for comb in pres_Nelson.combined]
pres_Nelson['Speaker'] = [comb[4:] for comb in pres_Nelson.combined]
pres_Nelson = pres_Nelson.drop(columns = 'combined')
pres_Nelson.columns = ['Word', 'Mean TF-IDF Score', 'Date', 'Speaker']

(ggplot(pres_Nelson, aes(x = 'Date', y = 'Mean TF-IDF Score', color = 'Word'))
     + geom_line()
     + facet_wrap('Speaker', scales = 'free', nrow = 3)
     + labs(title = 'Word Usage Change over Time in First Presidency'))


int_words = (dfwords
               .groupby(dfwords['Date']
               .map(lambda x: x.year))
               .mean()[interesting_words]
               .unstack()
               .reset_index())
int_words.columns = ['Word', 'Date', 'Mean TF-IDF Score']
(ggplot(int_words, aes(x = 'Date', y = 'Mean TF-IDF Score', color = 'Word'))
    + geom_line()
    + labs(title = 'Word Usage Change over Time in First Presidency and the 12'))

missionary_temple = (dfwords
               .groupby(dfwords['Date']
               .map(lambda x: x.year))
               .mean()[['missionary work', 'family history']]
               .unstack()
               .reset_index())
missionary_temple.columns = ['Word', 'Date', 'Mean TF-IDF Score']
(ggplot(missionary_temple, aes(x = 'Date', y = 'Mean TF-IDF Score', color = 'Word'))
    + geom_line()
    + labs(title = 'Word Usage Change over Time in First Presidency and the 12'))

youth = (dfwords
               .groupby(dfwords['Date']
               .map(lambda x: x.year))
               .mean()[['young men', 'young women']]
               .unstack()
               .reset_index())
youth.columns = ['Word', 'Date', 'Mean TF-IDF Score']
(ggplot(youth, aes(x = 'Date', y = 'Mean TF-IDF Score', color = 'Word'))
    + geom_line()
    + labs(title = 'Word Usage Change over Time in First Presidency and the 12'))


pca = PCA(n_components=3)
pca_df = pca.fit_transform(tfidf_X_train.todense())

lda = LinearDiscriminantAnalysis(n_components = 3)
lda_df = lda.fit_transform(tfidf_X_train.todense(), y_train)

principalDf = pd.DataFrame(data = pca_df, columns = ['pc1', 'pc2', 'pc3'])
principalDf['Speaker_num'] = y_train
recent_Oaks = list(np.where([X_train_all.Date[i] > datetime.datetime(2020,1,1) and X_train_all.Speaker[i] == 'Dallin H. Oaks' for i in X_train_all.index])[0])
principalDf['Speaker'] = [to_speaker_dict[y_val] for y_val in y_train]
principalDf.loc[recent_Oaks, 'Speaker'] = '2020 Dallin H. Oaks'
principalDf.loc[recent_Oaks, 'Speaker_num'] = 15

linearDF = pd.DataFrame(data = lda_df, columns = ['lda1', 'lda2', 'lda3'])
linearDF['Speaker_num'] = y_train
linearDF['Speaker'] = [to_speaker_dict[y_val] for y_val in y_train]
linearDF.loc[recent_Oaks, 'Speaker'] = '2020 Dallin H. Oaks'
linearDF.loc[recent_Oaks, 'Speaker_num'] = 15


first_presidency = list(all_talks['Speaker'].unique()[:3]) + ['2020 Dallin H. Oaks']
first_pres_pca_df = principalDf.query(f'Speaker in {first_presidency}')
first_pres_lda_df = linearDF.query(f'Speaker in {first_presidency}')

(ggplot(principalDf, aes(x = 'pc1', y = 'pc2', color = 'Speaker')) 
     + geom_point())
(ggplot(linearDF, aes(x = 'lda1', y = 'lda2', color = 'Speaker'))
    + geom_point()) 
(ggplot(linearDF.query('Speaker in ["Dallin H. Oaks", "2020 Dallin H. Oaks"]'), aes(x = 'lda1', y = 'lda2', color = 'Speaker'))
    + geom_point()) 

(ggplot(first_pres_pca_df, aes(x = 'pc1', y = 'pc2', color = 'Speaker'))      + geom_point())
(ggplot(first_pres_lda_df, aes(x = 'lda1', y = 'lda2', color = 'Speaker')) 
     + geom_point())


colors_dict = {0:'tab:red', 
               1:'lightblue', 
               2:'black', 
               3:'tab:orange',
               4:'tab:brown',
               5:'tab:orange',
               6:'tab:purple',
               7:'tab:green',
               8:'tab:pink',
               9:'tab:olive',
               10:'tab:gray',
               11:'tab:cyan',
               12:'b',
               13:'r',
               14:'darkslategray',
               15: 'blue'}


for i in range(0,180,1):
    ax = plt.axes(projection='3d')
    ax.view_init(i/3-15, i*3)
    ax.scatter3D(first_pres_pca_df.pc1, 
                 first_pres_pca_df.pc2, 
                 first_pres_pca_df.pc3, 
                 c=[colors_dict[spkr] for spkr in first_pres_pca_df.Speaker_num])
    plt.show()


for i in range(0,180,10):
    ax = plt.axes(projection='3d')
    ax.view_init(i/3-15, i*3)
    ax.scatter3D(first_pres_lda_df.lda1, 
                 first_pres_lda_df.lda2, 
                 first_pres_lda_df.lda3, 
                 c=[colors_dict[spkr] for spkr in first_pres_lda_df.Speaker_num])
    plt.show()


for i in range(0,180,10):
    ax = plt.axes(projection='3d')
    ax.view_init(i/3-15, i*3)
    ax.scatter3D(linearDF.lda1, 
                 linearDF.lda2, 
                 linearDF.lda3, 
                 c=[colors_dict[spkr] for spkr in linearDF.Speaker_num])
    plt.show()