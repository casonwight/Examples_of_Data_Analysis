This is a personal project done while in a 
Statistical/machine learning class at BYU.
This project relates to mapping customer 
complaints at financial instutions to the 
department that ended up resolving the 
complaint.

More details can be found in Resolving Complaints.ppt

Note that this was a group project, so some things 
found in this ppt are not produced by the included 
code. All code here was written by Cason Wight.

Files:
Analysis.py breaks down complaints word counts for 
some of the most common words across departments. 
There are better methods, but this specific methodology 
was implemented manually instead of through the many
available module.

Neural Net.py models these features to predict the 
author/speaker of each quote using a tuned deep neural 
net.

Boxplots.R produces the EDA for the features created by 
Analysis.py.

CompanyComplaints.csv and WhichDepartment.csv are too 
large, but are random samples from the data found at 
catalog.data.gov/.