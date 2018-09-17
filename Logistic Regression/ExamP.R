# Cason Wight
# Data obtained from http://grimshawville.byu.edu/ExamP.csv
# DATA
p <- read.csv("http://grimshawville.byu.edu/ExamP.csv", header = TRUE)
head(p)
str(p)

# EDA
# Create a proportion table
table <- table(p$GPA>3.5, p$ExamP)
rownames(table) <- c("Below 3.5", "Above 3.5")
prop.table(table)
prop.table(table, margin = 1)

# Create side by side boxplots
boxplot(GPA~ExamP, data = p, ylab = "GPA", main = "Side by Side Boxplots")

# Rename the explanatory variable so that it isn't confusing
p$Pass <- ifelse(p$ExamP == "Passed", 1, 0)

# Model 
# log(P(pass|GPA)/P(no pass|GPA)) = beta0 + beta1 * GPA
out.p <- glm(Pass~GPA, data = p, family = "binomial")

summary(out.p)

# Explanataion of beta1hat
# For a one unit increase in GPA, we estimate the log(odds of passing exam P)
# increasing by 2.256
exp(out.p$coefficients[2])

# Better explanation:
# For a one unit increase in GPA (for example, moving from a B to an A) we 
# estimate the odds of passing exam P to increase 9.54 times

# Does GPA have a statistically significant effect on passing ecam P?




# Test H0: Beta1 = 0, GPA does not have a statistically significant effect on passing P

# Z test
summary(out.p)
# We reject Ho: beta1 = 0, in favor of H1: beta1 != 0
# GPA has a statistically significant effect on passing exam p (p-value = .0329)

# LRT X^2 test of Ho: beta1=0
reduced.p <- glm(Pass~ +1, data = p, family = "binomial")
anova(reduced.p, out.p, test = "Chisq")
# We reject Ho: beta1 = 0, in favor of H1: beta1 != 0
# GPA has a statistically significant effect on passing exam p (p-value = .01055)

# 95% confidence interval on beta1 (log odds)
GPA.int <- confint(out.p)[-1,]
GPA.int
# 95% confidence interval on beta1 (odds)
exp(GPA.int)
# We reject Ho: beta1 = 0, in favor of H1: beta1 != 0
# For a one unit increase in GPA (for example moving from a B to an A) we estimate 
# the odds of passing to increase 9.54 times (95% CI: 1.6 to 111.8, which does not 
# contain 1). 

# Predict the probability of passing Exam P for two students: one with a 3.25 GPA
# and one with a 3.85 GPA.
predict(out.p,newdata = data.frame(GPA = c(3.25, 3.85)), type = "response")
# For a student with a 3.25 GPA, there is a 16.917% chance of passing exam P
# For a student with a 3.85 GPA, there is a 44.076% chance of passing exam P

# Create a graphic of the logistic regression model that uses GPA to model passing
# Exam P.
plot(Pass~GPA, data = p, xlim = c(0,4), col = "darkgreen", pch = 16, main = "Graphical Representation of the Model")
# Overlay the predicted probability
xstar <- seq(0,4,length=300)
phat <- predict(out.p, newdata = data.frame(GPA = xstar), type = "response")
lines(xstar,phat,col = "red")
# 95% confidence intervals on the proabilities
logit.hat <- predict(out.p, newdata = data.frame(GPA = xstar), type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(xstar,phat.L, lty = 2, col = "blue")
lines(xstar,phat.U, lty = 2, col = "blue")

# Research Task:
# Model the odds of someone passing exam p based on their GPA.

# Data Features that Match Analysis Strengths:
# The response is binary an we have seemingly continuous GPA's

# Analysis Weaknesses:
# We do not have much or any data on people with GPAs much lower than 2, so predictions for them will
# be extrapolation. We also do not have a lot of data in general.

# Challenge: Provide a research task and find data with the same characteristics as this
# assignment.
# Does the average temperature during a day affect if there is precipitation or not?
# The data can be found at https://www.usclimatedata.com/climate/provo/utah/united-states/usut0208/2017/1
# for January and for the rest of 2017 can be found on other close tabs.