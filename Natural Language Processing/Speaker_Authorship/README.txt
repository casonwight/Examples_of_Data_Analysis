This is a personal project done while in a 
Multivariate Analysis class at BYU. While
this project relates to typical speakers at 
BYU, the concepts could be applied to many 
other forms of textual analysis/authorship 
identification.

Some typical speakers at BYU campus-wide devotionals
are the 15 main leaders of the Church of Jesus Christ
of Latter-Day Saints. Aside from regularly addressing
BYU, all of these speakers also speak to the entire
church every 6 months through "General Conference talks,"
providing a rich data source to supplement the BYU 
speech archives. 

The purpose of this project is to predict the author-
ship of a `quote` (single paragraph) from these BYU
speeches and General Conference talks. 

Files:
Scrape_Talks.py webscrapes and formats all general 
conference talks given by the 15 leaders mentioned.

Scrape_Speeches.py webscrapes and formats all BYU 
speeches given by the 15 leaders mentioned.

Feature_Selection.py breaks down quotes into TF-IDF
scores of the 2500 most frequent 1-, 2-, or 3-grams

EDA.py explores the features and plots interesting
trends

Modeling.py (to be continued) models these features 
to predict the author/speaker of each quote. There 
are many appropriate methods, but this analysis will
compare multinomial logistic regression (with regular-
ization), support vector machines, and (to be done)
deep neural nets.

clean_analysis.py is a combination of all elements of 
analysis (except for most EDA).