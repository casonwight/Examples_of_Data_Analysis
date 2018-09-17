# Cason Wight
# Stat 330
# Diamonds


# DATA

# Data obtained from http://www.amstat.org/publications/jse/v9n2/4Cdata.txt, which was 
# used in the paper from Chu at http://www.amstat.org/publications/jse/v9n2/datasets.chu.html

# Read in the data and set the variable names
diamonds <- read.table("http://www.amstat.org/publications/jse/v9n2/4Cdata.txt", header = FALSE)
names(diamonds)<-c("Carat","Color","Clarity","Cert","Price")

str(diamonds)

# EDA: Compare the scatterplot of Carat and Price to the scatterplot of ln(Carat) and
# ln(Price). Describe which is 'better' for the model assumptions of linear relationship,
# constant variance, no unusual observations.

ggplot(diamonds, aes(x = Carat, y = Price)) +
  geom_point() +
  labs(x = "Diamond Size (Carat)", y = "Price (in Singapore Dollars)", title = "Price by Diamond Size")

par(mfrow = c(1,2))
plot(diamonds$Carat, diamonds$Price, main = "Untransformed Scatterplot",
     ylab = "Price (in Singapore $)", xlab = "Carat")
plot(log(diamonds$Carat), log(diamonds$Price), main = "Transformed Scatterplot",
     ylab = "Price (in natural log of Singapore $)", xlab = "Natural Log of Carat")


diamonds$Clarity <- as.numeric(factor(diamonds$Clarity, c("IF", "VVS1", "VVS2", "VS1", "VS2")))
diamonds$Color <- as.numeric(factor(diamonds$Color, c("D", "E", "F", "G", "H", "I")))

# ANALYSIS
# Response Variable: The natural log of price
# Explanatory Variable: The natural log of carat

# Model for price: ln(Price) = beta0 + beta1 * ln(carat) + epsilon, epsilon~N(0, sigma^2)
#      Things have a multiplicative effect, so:
# Model for price: Price = (e^beta0)*(Carat^beta1)*epsilonStar, epsilonStar~lognormal 

diamonds$lnCarat <- log(diamonds$Carat)
diamonds$lnPrice <- log(diamonds$Price)
out.diamonds <- lm(lnPrice~lnCarat + Color + Clarity + Cert, data = diamonds)
summary(out.diamonds)

reduced.diamonds <- lm(lnPrice~lnCarat + Color + Clarity, data = diamonds)

anova(reduced.diamonds, out.diamonds)

# Paramter estimates and error
summary.diamonds$coefficients

# Explanation for a non-statistician
# Poor explanation: On average, for a 1 unit increase in log(carat), there is a 1.537 unit increase in log(price) 
# Better explanation: For a 1% increase in carat we estimate an expected increase in price of 1.54%. (p-value < .001) 

# Is there a significant effect?
# With a 95% confidence interval:
confint(out.diamonds)
# Yes there is a significant effect. We are 95% confident that a 1 percent increase in Carat leads to 
# a percent increase of Price within the interval 1.500775% to 1.573739%

# Estimated model for Pricehat:
# ln(Price)hat = 9.13 + 1.54 * ln(Carat) + 0

# Graphic displaying effectiveness of model:
library(ggplot2)

qplot(lnCarat,lnPrice, data=diamonds,
      geom = "smooth", formula = y~x, method = "lm", se = TRUE,
      xlab = "ln of Carat Size",
      ylab = "ln of Price (in Singapore $)",
      main = "Estimated Effect of ln(Carat size) on ln(Price)")

# Predict for a couple buing a one-carat diamond
# log price






predict(out.diamonds, newdata = data.frame(lnCarat = 0), interval = "prediction")
# Price
exp(predict(out.diamonds, newdata = data.frame(lnCarat=0), interval = "prediction"))


plot.df <- cbind(diamonds, exp(predict(out.diamonds, newdatainterval = "prediction")))

plot.df <- as.data.frame(exp(predict(out.diamonds, newdata = data.frame(lnCarat=log(seq(.1, 1.2, length = 200))), interval = "prediction")))


ggplot(plot.df, aes(x = seq(.1, 1.2, length = 200), y = fit, ymin = lwr, ymax = upr)) +
  xlab("Diamond Size (Carat)") +
  ylab("Diamond Price (in Singapore Dollars)") +
  ggtitle("Estimated Price Range based on Diamond Size")+
  geom_ribbon(fill = "grey") + 
  geom_line(size = .71, color = "royalblue")




# Prediction performance: R^2 is based on the log transforms, which isn't what we want
# the real R^2
# R^2 = 1 - [sum(actual y - predicted y)^2]/[sum(actual y - mean(y))^2]
# Real R^2:
1-sum((diamonds$Price-exp(predict(out.diamonds)))^2) / sum((diamonds$Price - mean(diamonds$Price))^2) 
# This model correctly accounts for 90.53% of the variance of the data, which is pretty high, so I 
# would say that the model is pretty good at prediciting price.


# Summary statistics of the 'absolute prediction error' distribution 
summary(abs(diamonds$Price-exp(predict(out.diamonds))))
# according to these summary statistics, about half of the time, the prediction is within $330 of the
# real price paid. The biggest difference between predicted and actual price paid is $6658.77 and the 
# smallest difference is $2.75. about 75% are within $723.18 and 25% are within $143.85. 
# This model predicts worse and worse as the carats get bigger, with more variance. This is because
# there can be much more negotiation with these bigger diamonds. Also, we know that there are many other 
# factors, such as color, cut, etc. that play into the pricing of a diamond. To make the model more
# accurate, we should also get data on those explanatory variables and include them in the model.
#
#
# Research Task:
# Model the relationship between diamonds' Carat and its Price (and make predictions of price
# based on the carat)
#
# Model Strengths: 
# After log-transformations, this data pretty nicely follows a linear pattern (additive relationship)
# and so a linear regression model fits the data nicely.
#
# Analysis weaknesses:
# As stated above, the model does not account for ither factors in diamond quality, and so it gets
# harder and harder to predict price as the carat gets bigger, because these other factors play
# large roles as well.
#
# Challenge:
# http://www2.stetson.edu/~jrasp/data.htm has a data set called "Body Fat" that has body fat
# percentage data as well as other bodily measurements. We could pick one body measurement and 
# and model the percent body fat from that variable in the same way we just estimated price.



plot1 <- qplot(as.factor(diamonds$Cert), main = "Certification Agency", xlab = "Certificate")
plot2 <- qplot(as.factor(diamonds$Clarity), main = "Clarity", xlab = "Clarity")
plot3 <- qplot(diamonds$Carat, main = "Carat", xlab = "Carat", bins = 20, xlim = c(-.01, 1.2))
plot4 <- qplot(as.factor(diamonds$Color), main = "Color", xlab = "Color")
grid.arrange(plot1, plot2, plot3, plot4, ncol=2)

ggplot(diamonds, aes(Carat)) +
  geom_histogram(binwidth = .01) + 
  ggtitle("Distribution of Diamond Sizes") + 
  ylab("Number of Diamonds") +
  xlab("Diamond Size (Carat)") +
  scale_x_continuous(breaks = c(.3, .5, .7, 1))



forplot <- exp(predict(out.diamonds, newdata = data.frame(lnCarat=log(seq(0.15,1.2, length = 100)), Color = 4,
                                               Cert = "GIA", Clarity = 3), interval = "prediction"))
forplot <- cbind(forplot, len = seq(0.15,1.2,length = 100))
forplot <- as.data.frame(forplot)
ggplot(data = forplot,aes(x = len, y = fit, ymin = lwr, ymax = upr)) + 
  geom_ribbon(col = "red", fill = "red") + geom_line(size = .71) + 
  labs(title = "Price by Carat Size (holding all else at median)",
       x = "Carat", y = "Price (in Singapore Dollars)")



plot5 <- qplot(x = diamonds$Carat, y = diamonds$Price, main = "Diamond Price by Carat", xlab = "Carat", ylab = "Price (in Singapore Dollars)")
plot6 <- qplot(x = diamonds$Color, y = diamonds$Price, main = "Diamond Price by Color", xlab = "Color (1 is best and 6 is worst)", ylab = "Price (in Singapore Dollars)")
plot7 <- qplot(x = diamonds$Clarity, y = diamonds$Price, main = "Diamond Price by Clarity", xlab = "Clarity (1 is best and 5 is worst)", ylab = "Price (in Singapore Dollars)")

grid.arrange(plot6, plot5, plot7, ncol=2)



out.diamonds <- lm(lnPrice ~ lnCarat, data = diamonds)
summary(out.diamonds)
confint(out.diamonds)
