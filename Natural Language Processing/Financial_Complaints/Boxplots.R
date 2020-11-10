# Boxplots for NLP Analysis of Financial complaints
# Data manipulation and plotting can sometimes be easier in R, so 
# this script manipulates and plots the features of the complaints,
# Which are extracted in the python script Analysis.py

# Read in the data
X <- read.csv("X_train.csv", header = TRUE)
Y <- read.csv("Y_train.csv", header = TRUE)[,2]

head(X)

# All data combined
complaints <- cbind("Department" = Y, X)

library(ggplot2)
library(reshape2)
library(plyr)

deps <- as.character(unique(complaints$Department))

complaints$Department <- revalue(complaints$Department,
                                 c("Debt collection" = "Debt", 
                                   "Credit reporting, credit repair services, or other personal consumer reports" = "Credit", 
                                   "Student loan" = "Student", 
                                   "Credit card or prepaid card" = "Credit Card",
                                   "Checking or savings account" = "Checking/Saving", 
                                   "Payday loan, title loan, or personal loan" = "Loan",
                                   "Mortgage" = "Mortgage", 
                                   "Vehicle loan or lease" = "Vehicle",
                                   "Money transfer, virtual currency, or money service" = "Money"))

dollar_cols <- which(colnames(complaints) %in% c("Department","Avg_Dollar",'Num_Dollar'))
word_cols <- which(colnames(complaints) %in% c("Department",'debt','credit','account'))

df1_long <- melt(complaints[,dollar_cols], id.vars=c("Department"))
df2_long <- melt(complaints[,word_cols], id.vars=c("Department"))

ggplot(df1_long, aes(y = value, fill = Department)) + 
  geom_boxplot() + 
  facet_wrap(~variable, scales = 'free_y') +
  ylab("Average Dollar Amount Mentioned") + 
  theme(legend.position="bottom")

ggplot(df2_long, aes(y = value, fill = Department)) + 
  geom_boxplot() + 
  facet_wrap(~variable) +
  ylab("Average Dollar Amount Mentioned") + 
  scale_y_continuous(limits=c(0,10)) +
  theme(legend.position="bottom")

