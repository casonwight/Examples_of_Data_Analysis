# Cason Wight
# Stat 330
# Galton's Peas


# DATA

# Data obtained from http://grimshawville.byu.edu/SLR.pdf

# Read in the data
galton <- read.table(text = "Parent,Offspring
                     .21,.1726
                     .2,.1707
                     .19,.1637
                     .18,.1640
                     .17,.1613
                     .16,.1617
                     .15,.1598",
                      sep = ",", header = TRUE)


# Check that the data was read in correctly (only seven observations)
galton

# EDA
# Find the correlation coefficient
cor(galton$Offspring, galton$Parent)

# Create a plot showing that the correlation
plot(Offspring~Parent, data=galton, type = 'b', col="4", main = "Scatterplot of Peas")
abline(lm(Offspring~Parent, data=galton)$coefficients[1], 
       lm(Offspring~Parent, data=galton)$coefficients[2],
       col = "2", lty = 2)

# Create the plot in ggplot
library(ggplot2)

qplot(Parent,Offspring, data=galton,
       geom = "point",
      xlab = "Diameter of Parent Pea",
      ylab = "Diameter of Offspring Pea")


# ANALYSIS

# The response variable is the diameter of the offspring peas (inches)
# The explanatory variable is the diameter of the parent peas (inches)


# We write a model that we think we are fitting:

# model: offspring = beta0 + beta1 parent + epsilon, epsilon~N(0, sigma^2)
# The assumptions are: 
# Homoscedasticity of samples
# A linear relationship
# The sample has at least some variability
# A large enough sample size


# Fit model/ Estimate the model parameters
peas.out <- lm(Offspring~Parent, data = galton)

# Table of estimates and standard errors
summary(peas.out)

# Parent estimate is the slope, or beta1hat = 0.21 is the estimated slope (better 
# explanation: for a one inch increase in parent sweet pea diameter, we expect 
# an estimated (or average) increase of .21 inches of offspring sweet pea diameter)

# Best explanation: For a one- one hundredth of an inch increase in parent sweet pea diameter, we expect 
# an estimated (or average) increase of .0021 inches of offspring sweet pea diameter)


# Intercept or beta0hat = .127029
# The std. error of beta1hat is .006993
# The std. error of beta0hat is .038614
# The RMSE (residual standard error) = .002043


#Statistically significant inheritance effect?

# T-Test:
# The null hypothesis is that there is no significant inheritance 
# effect (beta1 = 0). The alternative hypothesis is that there is a 
# significant inheritance effect (beta1 != 0)

# The T-stat was calculated to be 5.438 (p-value: .00285)
# There is a statistically significant inheritance effect (p-value = 0.0029).

# ANOVA:
# The null hypothesis is that there is no significant inheritance 
# effect (beta1 = 0). The alternative hypothesis is that there is a 
# significant inheritance effect (beta1 != 0)

# The F-stat was calculated to be 29.58 (p-value: .00285)
# There is a statistically significant inheritance effect (p-value = 0.0029)

# Confidence Interval:
# 95% confidence interval for beta1
confint(peas.out)
# 95% CI is 0.1107 to 0.3093

# There is a statistically significant inheritance effect (p-value = 0.0029). 
# For a one inch increase in parent sweet pea diameter, we expect an estimated 
# (or average) increase of .21 inches (95% CI: 0.1107 to 0.3093 inches) of 
# offspring sweet pea diameter.


# Publication-quality graph of estimated line and uncertainty:
qplot(Parent,Offspring, data=galton,
      geom = "smooth", formula = y~x, method = "lm", se = TRUE,
      xlab = "Diameter of Parent Pea",
      ylab = "Diameter of Offspring Pea",
      main = "Estimated Inheritence Effect of Pea Diameter")


anova(peas.out)


# 95% confidence interval on the mean offspring diameter where parent diameter = 0.20
predict(peas.out, newdata = data.frame(Parent = 0.2), interval = "confidence")



# model: offspring = beta0 + beta1*parent + epsilon, epsilon~N(0, error^2)
# estimated model: offspring_hat = .127029 + .210*parent_hat + 0 (error) , error~N(0, .002043^2)

# 95% of future values at this x will be between (L, U) - this is really a 95% CI

# 95% PI on future offspring pea diameter for parent diameter 0.18
predict(peas.out, newdata = data.frame(Parent = 0.18), interval = "prediction")


# Graphic showing prediction performance
library(ggplot2)
plot.df <- cbind(galton, predict(peas.out, interval = "prediction"))
ggplot(plot.df, aes(Parent, Offspring)) +
    xlab("Diameter of Parent Pea") +
    ylab("Diameter of Offspring Pea") +
    geom_point() +
    geom_line(aes(y=fit), color = "royalblue") + 
    geom_line(aes(y=lwr), color = "red", linetype = "dashed") +
    geom_line(aes(y=upr), color = "red", linetype = "dashed")


# R^2 is .8554, calculated above
pea.sum <- summary(peas.out)
pea.sum$r.squared

# This model has strong predictions, as R^2 is somewhat close to 1 (.8554) this means
# that the model predicts about 85.54% of the variance in the data.




# Research Task and Data Features that Match Analysis Strengths:
# We are trying to predict the diameter of offspring peas, given  the 
# diameter of parentpeas. We assume some sort of linear relationship, 
# so the simple linear regression model is perfect for this task. It
# will also help us see the error involved in predictions using the model.
# 

# Analysis Weaknesses:
# There is not very much data, so our predictions are not that strong
# We are assuming that there are no nuissance factors.



# CHALLENGE:
# Another data set that coud be used to perform the same regression analysis is as follows:
# There is a data set that relates peoples' temperature with their heart rate at a given point in time found at 
# http://staff.bath.ac.uk/pssiw/stats2/page16/page16.html, under the data link temperature.sav

# The task is to see how the temperature could affect the expected heart rate of a person.

