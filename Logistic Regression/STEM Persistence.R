# Cason Wight
# STEM Persistors
# 4/2/2018
# Data obtained from Colorado State Statistics Department

# DATA
source("http://grimshawville.byu.edu/STEMgetdata.R")
head(STEM)
dim(STEM)

# EDA
par(mfrow = c(2,2))
boxplot(nST ~ y, data = STEM, main = "Standardized Test Percentile")
boxplot(new.teach ~ y, data = STEM, main = "Instructor Quality")
boxplot(new.stu ~ y, data = STEM, main = "Student-Centered")
par(mfrow = c(1,1))

table1 <- table(STEM$prevCalc, STEM$y)
rownames(table1) <- c("HS Experience", "College", "None")
colnames(table1) <- c("Stayed", "Left STEM")
table2 <- table(STEM$newMJ, STEM$y)
rownames(table2) <- c("STEM Major", "Engineering", "Pre-Med", "non-STEM", "Undecided")
colnames(table2) <- c("Stayed", "Left STEM")
table3 <- table(STEM$gender, STEM$y)
rownames(table3) <- c("Male", "Female")
colnames(table3) <- c("Stayed", "Left STEM")

for (i in 1:3) {
  print(get(paste("table", i, sep = "")))
  print(prop.table(get(paste("table", i, sep = ""))))
  print(prop.table(get(paste("table", i, sep = "")), margin = 1))
}

# ANALYSIS
# declare categorical explanatory variables as R class "factor"
STEM$gender <- factor(STEM$gender)
STEM$gender <- relevel(STEM$gender, ref = "1")
STEM$prevCalc <- factor(STEM$prevCalc)
STEM$prevCalc <- relevel(STEM$prevCalc, ref = "1")
STEM$newMJ <- factor(STEM$newMJ)
STEM$newMJ <- relevel(STEM$newMJ, ref = "1")

# Response Variable: Whether they switched from the calculus sequence or not
# Explanatory variables: 
#   Previous Calculus Experience
#   Standardized Testing Percentile
#   Intended Major
#   Instructor Quality
#   Student-centered practices
#   Gender

# Fit the Model:
# Logit(y=1)=logit(Switchers)
# = beta0 + beta1 nST + beta2 new.teach + beta3 new.stu + gender_i + prevCalc_j + newMJ_k

out.STEM <- glm(y~nST + new.teach + new.stu + gender + prevCalc + newMJ, data = STEM, family = "binomial")
summary(out.STEM)

exp(out.STEM$coefficients)[-1]

# Interpretation of the effect of gender for a non-statistician
# We estimate that women are 1.428 more likely to switch from the calculus sequence than men 
# holding all else constant.


# Create a graphic showing the difference between men and women
# all other factors at "best" case
# men
x.star <- data.frame(gender = "1", nST = seq(2,99,length = 200), 
                     new.teach = 6, new.stu = 6, prevCalc = "1", newMJ = "1")
plot(x.star$nST,predict(out.STEM, newdata = x.star, type = "response"), type = 'l', 
     xlab = "Testing Percentile", ylab = "Pr(Switch from Calc Sequence)", ylim = c(0,0.25), 
     lwd = 2, main = "Difference Between Men and Women Switching")

logit.hat <- predict(out.STEM, newdata = x.star, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(x.star$nST,phat.L, lty = 2, col = "grey")
lines(x.star$nST,phat.U, lty = 2, col = "grey")

x.star2 <- data.frame(gender = "2", nST = seq(2,99,length = 200), 
                     new.teach = 6, new.stu = 6, prevCalc = "1", newMJ = "1")
lines(x.star2$nST, predict(out.STEM, newdata = x.star2, type = "response"), col = 2, lwd = 2)
logit.hat <- predict(out.STEM, newdata = x.star2, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(x.star2$nST,phat.L, lty = 2, col = "indianred1")
lines(x.star2$nST,phat.U, lty = 2, col = "indianred1")

# Is there a statistically significant difference between men & women holding all else constant?
# 95% CI:
exp(confint(out.STEM)[-1,])
# There is a statistically significant difference in switching from the calculus sequence 
# between men and women, holding all else constant (95% CI: 1.126 to 1.813). We estimate women 
# to be 1.428 more likely to switch from the calculus sequence than menholding all else constant 
# (95% CI: 1.126 to 1.813). 

# z-test:
summary(out.STEM)

# Chisq:
red1.STEM <- glm(y~nST + new.teach + new.stu + prevCalc + newMJ, data = STEM, family = "binomial")
anova(red1.STEM, out.STEM, test = "Chisq")
# There is a statistically significant difference between men & women holding all else constant



# Is there a "calculus prep" effect?
red2.STEM <- glm(y~nST + new.teach + new.stu + gender + newMJ, data = STEM, family = "binomial")
anova(red2.STEM, out.STEM, test = "Chisq")
# There is no calculus prep effect on switching from the calculus sequence (p-value = .4455).

# Predict/classify yhat = {0, 1} (persistors, or switchers)


# ROC curve
library(ROCR)
STEM.pred <- prediction(predict(out.STEM, type = "response"), STEM$y)
STEM.perf <- performance(STEM.pred, measure = "tpr", x.measure = "fpr")
plot(STEM.perf, xlab = "1-specificity", ylab = "sensitivity", main = "ROC Curve")
abline(0,1, col = "grey")

# Compute AUC
performance(STEM.pred, measure = "auc")
# The closer the auc approaches 1 (with a minimum of .5), the better the prediction, and the less
# error in predicting correctly both switchers and persistors. An auc of 0.76 shows that there is
# a lot of room for prediction improvement, especially with more specialized data. 


# Research Task:
# Determine if there is a statistically significant differene between men and women in switching
# from the calculus sequence, holding all else constant. Also to determine what other factors
# play a part in switching from the calculus sequence.

# Data Features that Match Analysis Strengths:
# There is a lot of data, and it is a binary response, which helps in probability.

# Analysis Weaknesses:
# The data is too general, and the auc shows that it needs a lot of improvement in prediction.
# To improve it, the data should be for a specific college or state of interest, with specific
# factors that would help explain the trend for the given college or state.

# Challenge: 
# The Data is found at https://archive.ics.uci.edu/ml/machine-learning-databases/00222/ 
# Determine the relationship between whether a subscribtion for a term deposit is made by a client based
# on many other factors.
