# LOL skills
# DATA
# 2017 Worlds from leaguepedia
source("http://grimshawville.byu.edu/eSports2017.R")
all.players


# EDA
set.seed(100)
rows.train <- sample(nrow(all.players), round(nrow(all.players)*.8, 0), replace = FALSE)
LOL.train <- all.players[rows.train,]
LOL.test <- all.players[-rows.train,]

str(LOL.train)

boxplot(Kills~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")
boxplot(Deaths~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")
boxplot(Time~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")
boxplot(Time~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")

# ANALYSIS
# Response Variable: Win or not
# Explanatory variables: 
# Kills
# Deaths
# Assists
# Time of gameplay (minutes)

# Model
# log( P(Win=1) / P(Win = 0)) = beta0 + beta1 Kills + beta2 Deaths + beta3 Assists + beta4 Time
out.LOL <- glm(Win ~ Kills + Deaths + Assists + Time, data = LOL.train, family = "binomial")

summary(out.LOL)

# For each additional kill, we estimate an increase of .424 in log odds of winning, 
# holding all else constant. 
exp(out.LOL$coefficients[2])
# For each additional kill, we estimate the odds of winning to increase by 1.528 times, 
# holding all else constant. 
# Another way to say it:
# For each additional kill, we estimate a 52.8% increase in the odds of winning, 
# holding all else constant (95% CI: 44.6% to 61.9%). 

# Interpret change in odd
exp(coef(out.LOL))[-1]-1
# For each additional death, we estimate a 57% decrease in the odds of winning, 
# holding all else constant (95% CI: 53.4% to 60.5%).

# For each additional assist, we estimate a 66.1% increase in the odds of winning, 
# holding all else constant (95% CI: 59.4% to 73.6%).

# For each additional minute of gameplay, we estimate a 6.65% decrease in the odds
# of winning, holding all else constant (95% CI: 5.18% to 8.11%).




# Explanation of distribution of Kills
kills <- summary(LOL.train$Kills)
sd(LOL.train$Kills)
hist(LOL.train$Kills, main = "Histogram of Game Times")
boxplot(Kills~Win, data = LOL.train, main = "Boxplots of Winning or not by Kills")


# Explanation of distribution of Deaths
deaths <- summary(LOL.train$Deaths)
sd(LOL.train$Deaths)
hist(LOL.train$Deaths, main = "Histogram of Game Times")
boxplot(Deaths~Win, data = LOL.train, main = "Boxplots of Winning or not by Deaths")


# Explanation of distribution of Assists
assists <- summary(LOL.train$Assists)
sd(LOL.train$Assists)
hist(LOL.train$Assists, main = "Histogram of Game Times")
boxplot(Assists~Win, data = LOL.train, main = "Boxplots of Winning or not by Kills")


# Explanation of distribution of time:
time <- summary(LOL.train$Time)
sd(LOL.train$Time)
hist(LOL.train$Time, main = "Histogram of Game Times")
boxplot(Time~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")
# A typical league of legends game lasts 34.42 minutes, with a standard deviation of 7.85 minutes. 
# Games last between 20.25 minutes and 77.95 minutes. Half of the games arebetween 30.05 and 35.73 
# minutes. It appears right-skewed and non-normal.

# Table of all summary statistics
rbind(kills,deaths,assists,time)

# One graph for all plots
par(mfrow = c(2,2))
boxplot(Kills~Win, data = LOL.train, main = "Boxplots of Winning or not by Kills")
boxplot(Deaths~Win, data = LOL.train, main = "Boxplots of Winning or not by Deaths")
boxplot(Assists~Win, data = LOL.train, main = "Boxplots of Winning or not by Kills")
boxplot(Time~Win, data = LOL.train, main = "Boxplots of Winning or not by Time")
par(mfrow = c(1,1))



par(mfrow = c(2,2))

# Plot for kills
xstar <- data.frame(Kills = seq(0,10,length = 200), Deaths = 2, Assists = 6, Time = 35)
plot(xstar$Kills, predict(out.LOL, newdata = xstar, type = "response"), 
     type = 'l', main = "Probability of Winning Based on Kills", xlab = "Kills", 
     ylab = "P(Win) holding all else at median", col = 2, lwd = 2)

logit.hat <- predict(out.LOL, newdata = xstar, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(xstar$Kills,phat.L, lty = 2, col = "blue")
lines(xstar$Kills,phat.U, lty = 2, col = "blue")

# Plot for Deaths
xstar <- data.frame(Deaths = seq(0,10,length = 200), Kills = 2, Assists = 6, Time = 35)
plot(xstar$Deaths, predict(out.LOL, newdata = xstar, type = "response"), 
     type = 'l', main = "Probability of Winning Based on Deaths", xlab = "Deaths", 
     ylab = "P(Win) holding all else at median", col = 2, lwd = 2)

logit.hat <- predict(out.LOL, newdata = xstar, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(xstar$Deaths,phat.L, lty = 2, col = "blue")
lines(xstar$Deaths,phat.U, lty = 2, col = "blue")

# Plot for Assists
xstar <- data.frame(Assists = seq(0,24,length = 200), Kills = 2, Deaths = 2, Time = 35)
plot(xstar$Assists, predict(out.LOL, newdata = xstar, type = "response"), 
     type = 'l', main = "Probability of Winning Based on Assists", xlab = "Assists", 
     ylab = "P(Win) holding all else at median", col = 2, lwd = 2)

logit.hat <- predict(out.LOL, newdata = xstar, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(xstar$Assists,phat.L, lty = 2, col = "blue")
lines(xstar$Assists,phat.U, lty = 2, col = "blue")

# Plot for time
xstar <- data.frame(Time = seq(20,80,length = 200), Kills = 2, Deaths = 2, Assists = 6)
plot(xstar$Time, predict(out.LOL, newdata = xstar, type = "response"), 
     type = 'l', main = "Probability of Winning Based on Time", xlab = "Time", 
     ylab = "P(Win) holding all else at median", col = 2, lwd = 2)

logit.hat <- predict(out.LOL, newdata = xstar, type = "link", se.fit = TRUE)
logit.L <- logit.hat$fit-qnorm(.975)*logit.hat$se.fit
logit.U <- logit.hat$fit+qnorm(.975)*logit.hat$se.fit
phat.L <- 1/(1+exp(-logit.L))
phat.U <- 1/(1+exp(-logit.U))
lines(xstar$Time,phat.L, lty = 2, col = "blue")
lines(xstar$Time,phat.U, lty = 2, col = "blue")

par(mfrow = c(1,1))

# 95% Confidence Interval on exp(beta), which is the percent change in odds of winning
1 - exp(confint(out.LOL))[-1,]

# For every additional kill, there is a 53.8% increase in odds of winning 
# (95% CI: 44.6% to 61.9%) holding all else constant

# For every additional death, there is a 57.0% decrease in odds of winning 
# (95% CI: 53.4% to 60.5%) holding all else constant

# For every additional assist, there is a 66.1% increase in odds of winning 
#(95% CI: 59.4% to 73.6%) holding all else constant

# For every additional minute of gameplay, there is a 6.6% decrease in odds 
# of winning (95% CI: 5.2% to 8.1%) holding all else constant

# Test Ho: aggressive strategy has no effect
# Test Ho: Time has no effect
summary(out.LOL)
# An aggressive strategy does have a statistically significant effect on odds of winning a LOL game (p-value: <.001).

# LRT X^2
reduced.LOL <- glm(Win~Kills+Deaths+Assists, data = LOL.train, family = "binomial")
anova(reduced.LOL, out.LOL, test="Chisq")
# An aggressive strategy does have a statistically significant effect on odds of winning a LOL game (p-value: <.001).


# Prediction for Faker and Ambition
predict(out.LOL, newdata = data.frame(Kills = 2, Deaths = 3, Assists = 8, Time = 40), type = "response")
predict(out.LOL, newdata = data.frame(Kills = 2, Deaths = 2, Assists = 14, Time = 40), type = "response")

# Confidence Intervals for the predictions for Faker
logit.Faker <- predict(out.LOL, newdata = data.frame(Kills = 2, Deaths = 3, Assists = 8, Time = 40), type = "link", se.fit = TRUE)
logit.L <- logit.Faker$fit - qnorm(.975)*logit.Faker$se.fit
logit.U <- logit.Faker$fit + qnorm(.975)*logit.Faker$se.fit
phat.L.Faker <- 1/(1+exp(-logit.L))
phat.U.Faker <- 1/(1+exp(-logit.U))

# Confidence Intervals for the predictions for Ambition
logit.Ambition <- predict(out.LOL, newdata = data.frame(Kills = 2, Deaths = 2, Assists = 14, Time = 40), type = "link", se.fit = TRUE)
logit.L <- logit.Ambition$fit - qnorm(.975)*logit.Ambition$se.fit
logit.U <- logit.Ambition$fit + qnorm(.975)*logit.Ambition$se.fit
phat.L.Ambition <- 1/(1+exp(-logit.L))
phat.U.Ambition <- 1/(1+exp(-logit.U))


# ROC curve
library(ROCR)
train.pred <- prediction(predict(out.LOL, type = "response"), LOL.train$Win)
train.perf <- performance(train.pred, measure = "tpr", x.measure = "fpr")
plot(train.perf, xlab = "1 - Specificity", ylab = "Sensitivity", main = "ROC Curve")
abline(0,1,col = "grey")

# AUC stat
performance(train.pred, measure = "auc")

# Overlay the training ROC (out of sample validation)
test.pred <- prediction(predict(out.LOL, newdata = LOL.test, type = "response"), LOL.test$Win)
test.perf <- performance(test.pred, measure ="tpr", x.measure = "fpr")
plot(test.perf, col = 2, add = TRUE)

# Compute test data auc
performance(test.pred, measure = "auc")
# They have different auc values, or have differing performance by random chance of the data points in the train and test datasets.

# Research Task:
# Determine the effects of kills, deaths, assists, and time of gameplay on the probability of a team winning a game of LOL or not.

# Data Features that Match Analysis Strengths:
# All of the explanatory variables are numeric, which helps a lot with running the regression analysis. We also have a lot of data
# which will help to perform prediction. There is enough data to create reasonable train and test datasets.

# Analysis Weaknesses:
# One weakness is that Deaths/Kills/Assists/etc. may not accurately represent the things we are trying to capture. For example, the
# data attempts to track errors with deaths, but is dying is part of a strategy, that may not be the same as a death by error.

# Challenge:
# Using the data at: http://users.stat.ufl.edu/~winner/data/fieldgoal.dat, determine what the effects (if any) are from the # of weeks 
#into a football season and the distance (yards away) have on the probability of a field goal being a success. 

