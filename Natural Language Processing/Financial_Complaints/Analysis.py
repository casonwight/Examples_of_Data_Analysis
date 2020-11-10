import random
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from heapq import nlargest
import collections, functools, operator
from nltk.corpus import stopwords
import re


random.seed(1)

# Read in the Data
complaints = pd.read_csv('CompanyComplaints.csv')
department = pd.read_csv('WhichDepartment.csv')

# Shape of the data
print("Shape of Complaints: ",np.shape(complaints))
print("Shape of Departments: ",np.shape(department))

# Unique departments
set(complaints.iloc[:,0])

# Exogenous and Endogenous Variables
X = complaints["Complaint"]
Y = complaints["Department"]


new_X = department['Complaint']


# define punctuation
punctuations = '''!()-[];:'"\,<>.?@#%^&*_~'''

# remove punctuation from the string
def remove_punct(my_str):
    no_punct = ""
    for char in my_str:
       if char not in punctuations:
           no_punct = no_punct + char
    return no_punct.lower()

all_stopwords = stopwords.words('english') + ['time', 'received', 'information', 'also']

def word_count(str, final_list = False, the_list = []):
    counts = dict()
    words = remove_punct(str).split()
    if final_list:
        words = [word for word in words if word in the_list]
    else:
        words =  [word for word in words if not word in all_stopwords]
    
    for word in words:
        if word in counts:
            counts[word] += 1
        else:
            counts[word] = 1

    return counts

def word_present(str):
    counts = dict()
    words = remove_punct(str).split()
    words =  [word for word in words if not word in all_stopwords]
    
    for word in words:
        if word in counts:
            counts[word] = 1
        else:
            counts[word] = 1

    return counts


allSig = []
avgNums = pd.DataFrame({"Word":[],"Avg_Num":[],"Percent_Containing":[], "Dep":[]})

for dep in list(set(Y)):
    print(dep)
    this_data = X[Y==dep]
    dlist=[]
    dpresent=[]
    for i in range(np.shape(this_data)[0]):
        dlist.append(word_count(this_data.iloc[i]))
        dpresent.append(word_present(this_data.iloc[i]))
        
    allWords = dict(functools.reduce(operator.add, map(collections.Counter, dlist)))
    allPresent = dict(functools.reduce(operator.add, map(collections.Counter, dpresent)))
    biggest = nlargest(50, allWords, key = allWords.get)
    thisNum = [allWords[x] / np.shape(this_data)[0] for x in biggest]
    thisPercent = [allPresent[x] / np.shape(this_data)[0] for x in biggest]
    biggestdf = pd.DataFrame({"Word":biggest,"Avg_Num":thisNum,"Percent_Containing":thisPercent,"Dep":dep})
    avgNums = pd.concat([avgNums,biggestdf])
    allSig.append(biggest)
    
avgNums.to_csv("common_words.csv", index = False)


avgNums = pd.read_csv("common_words.csv")
wordsIncluded = avgNums["Word"].unique()
wordsIncluded = [word for word in wordsIncluded if not word in all_stopwords]
wordsIncluded = wordsIncluded


# Train-test Split
X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2)
X_train.to_csv("X_train.csv")
X_test.to_csv("X_test.csv")
Y_train.to_csv("Y_train.csv")
Y_test.to_csv("Y_test.csv")


wordsIncluded = X_train.columns[:-5].tolist()


xlist = []
print(xlist)
for i in range(np.shape(X)[0]):
    if i%10000 == 0: print(i)
    xlist.append(word_count(X.iloc[i], True, wordsIncluded))
    

xnewlist = []
for i in range(np.shape(new_X)[0]):
    if i%10000 == 0: print(i)
    xnewlist.append(word_count(new_X.iloc[i], True, wordsIncluded))


numRows = np.shape(xlist)[0]
# Fill the dataframe X with the number of times each words is mentioned
X = pd.DataFrame(0, index = range(numRows), columns = wordsIncluded)

for i in range(np.shape(xnewlist)[0]):
    if i%1000 == 0: print(round(i/numRows,3))
    this_data_frame = pd.DataFrame.from_dict(xlist[i], orient = "index").transpose()
    colsIncluded = this_data_frame.columns.values
    if np.shape(colsIncluded)[0] > 0:
        X.loc[i,colsIncluded] = this_data_frame.values

X = X.fillna(0)


numRowsNew = np.shape(xnewlist)[0]
new_X = pd.DataFrame(0, index = range(numRowsNew), columns = wordsIncluded)

for i in range(np.shape(xnewlist)[0]):
    if i%1000 == 0: print(round(i/numRowsNew,3))
    this_data_frame = pd.DataFrame.from_dict(xnewlist[i], orient = "index").transpose()
    colsIncluded = this_data_frame.columns.values
    if np.shape(colsIncluded)[0] > 0:
        new_X.loc[i,colsIncluded] = this_data_frame.values

new_X = new_X.fillna(0)

# Also include the length of the complaint as its own variable
res = []
for i in range(numRows):
    res.append(len(complaints["Complaint"][i].split()))

X['Complaint_Len'] = res


resnew = []
for i in range(numRowsNew):
    resnew.append(len(department["Complaint"][i].split()))

new_X['Complaint_Len'] = resnew

# We want the number of dollar amount mentions, the 
# range, and mean amount mentioned
def dollar_Counts(this_str):
    return this_str.count("{$")
    
def average_dollar(this_str):
    numAmounts = this_str.count("{$")
    vals = []
    if numAmounts == 0: 
        return 0,0,0
    else:
        for i in range(numAmounts):
            if len(this_str) > 0 and this_str.count("}") > 0:
                in_Brack = this_str[(this_str.index("{$")+2):this_str.index("}")]
                in_Brack = re.sub('\n','',in_Brack)
                if len(in_Brack) > 20: in_Brack = ''
                if len(in_Brack) > 0:
                    if in_Brack[0].isdigit():
                        vals.append(float(in_Brack))
                this_str = this_str[(this_str.index("}")+1):]
        if vals == [] : 
            return 0,0,0
        else:
            return np.min(vals), np.max(vals), np.mean(vals)

Dollar = pd.DataFrame(0, index = range(numRows), 
                      columns = ["Num_Dollar","Min_Dollar","Max_Dollar","Avg_Dollar"])
for i in range(np.shape(X)[0]):
    if i%1000 == 0: print(round(i/numRows,3))
    num = dollar_Counts(complaints["Complaint"][i])
    mi, ma, avg = average_dollar(complaints["Complaint"][i])
    Dollar.iloc[i,:] = [num, mi, ma, avg]


Dollarnew = pd.DataFrame(0, index = range(numRowsNew), 
                      columns = ["Num_Dollar","Min_Dollar","Max_Dollar","Avg_Dollar"])
for i in range(np.shape(new_X)[0]):
    if i%1000 == 0: print(round(i/numRowsNew,3))
    num = dollar_Counts(department["Complaint"][i])
    mi, ma, avg = average_dollar(department["Complaint"][i])
    Dollarnew.iloc[i,:] = [num, mi, ma, avg]

# Saving all of the changes for use by other team members
Dollar.to_csv("dollar.csv")

X['Num_Dollar'] = Dollar['Num_Dollar']
X['Min_Dollar'] = Dollar['Min_Dollar']
X['Max_Dollar'] = Dollar['Max_Dollar']
X['Avg_Dollar'] = Dollar['Avg_Dollar']

X.to_csv("X.csv")
X.to_csv("X" + str(random.randint(1000,9999)) + ".csv")
Y.to_csv("Y.csv")



new_X['Num_Dollar'] = Dollarnew['Num_Dollar']
new_X['Min_Dollar'] = Dollarnew['Min_Dollar']
new_X['Max_Dollar'] = Dollarnew['Max_Dollar']
new_X['Avg_Dollar'] = Dollarnew['Avg_Dollar']

new_X.to_csv("new_X.csv")