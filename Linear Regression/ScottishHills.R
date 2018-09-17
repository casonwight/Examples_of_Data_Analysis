# Cason Wight
# Stat 330-003
# 2/21/2018
# The data is obtained from StatSci.org and was accessed last on 2.21.2018

hills <- read.table("http://www.statsci.org/data/general/hills.txt", header = TRUE)

tail(hills)

plot(Time~Climb, data = hills)
identify(hills$Climb, hills$Time, labels = hills$Race)

plot(Time~Distance, data = hills)
identify(hills$Distance, hills$Time, labels = hills$Race)
# The unusual races appear to be Bens of Jura, Lairig Ghru, Two Breweries,
# Moffat Chase, Seven Hills, Knock Hill, and Ben Nevis


# Data integrity:
# Model: Time = beta0 + beta1 * distance + beta2 * climb + epsilon,   epsilon~N(0, sigma^2)

# Unusual observations: 
#  Outlier (named in vertical direction)
#       Bens of Jura
#              Prediction differs from actual
#          It could be a data problem, but it could also be a model problem
#  Influential observation (named in the horizontal direction)
#       Lairigi Ghru
#  
#
#    Leverage: Weight that an observation has in predicting itself
#    Cook's Distance (Cooks D): Compare all the betahats to the betahats(i) when you 
#                               take out the ith observation 
#    R-Studentized residuals
#

# Regression diagnostics
out.hills <- lm(Time~Distance+Climb, data = hills)

# Compute leverage for Ben Navis Race
leverage.hills <- lm.influence(out.hills)$hat
subset(leverage.hills, hills$Race=="BenNevis")
# Leverage for the Ben Navis Race is .1216

# Compute cook's distance for Moffat Chase Race
cd.hills <- cooks.distance(out.hills)
subset(cd.hills, hills$Race=="MoffatChase")
# Cook's distance for Moffat Chase race is .0524

# Compute R-studentized residuals for Cairn Table Race
R.hills <- rstudent(out.hills)
subset(R.hills, hills$Race=="CairnTable")
# This is similar to z-scores, so anyhting less than 2 or 3 is not too unusual
# The r-studentized residual for Cairn Table is .7146

# Leverage is the weight (percent) that a given point would have in predicting itself.
# Cook's distance is the difference between a point's prediction given itself or not.
# The R-studentized residals are similar to a z-score and show if a data point is out 
# of the ordinary 
# given the model.

# Histogram of R-studentized residuals
hist(R.hills)
# This histogram has outliers, and clearly does not appear to be normally distributed.


# Compute the ks test
ks.test(R.hills, "pnorm")
# p-value = .03567, which means that:
# The errors in the model are not normally distributed (p-value = .03567).


# See if Kildcon Hill is an outlier
subset(R.hills, hills$Race == "KildconHill")
# The value of .2055 is nowhere near beyond 2 or -2, so we can say that this is not an outlier.


# See if Moffat Chase is an influential observation or not
subset(cd.hills, hills$Race=="MoffatChase")
subset(leverage.hills, hills$Race=="MoffatChase")
# The leverage is .1909891, which is greater than 2(p+1)/n which means that this is an 
# influential observation

par(mfrow = c(1,2))
plot(hills$Climb, hills$Time)
points(hills$Climb[35], hills$Time[35], col = 2, pch = 19)

plot(hills$Distance, hills$Time)
points(hills$Distance[35], hills$Time[35], col = 2, pch = 19)
# It looks like it is good influential because it follows the trend

# See if Lairig Ghru is an influential observation or not
subset(cd.hills, hills$Race=="LairigGhru")
subset(leverage.hills, hills$Race=="LairigGhru")
# The leverage is .6898, which is greater than 2(p+1)/n which means that this is an 
# influential observation, also the cooks distance of .2105 is greater than .125

par(mfrow = c(1,2))
plot(hills$Climb, hills$Time)
points(hills$Climb[11], hills$Time[11], col = 2, pch = 19)

plot(hills$Distance, hills$Time)
points(hills$Distance[11], hills$Time[11], col = 2, pch = 19)
# It looks like it is bad influential because it does not follow the trend



# Is Cow hill an outlier:
subset(R.hills, hills$Race == "CowHill")
# Cow hills is not an outlier because:
2*(1-pnorm(subset(R.hills, hills$Race == "CowHill")))
# p-value is greater than .05


# Is Knock hill an outlier:
subset(R.hills, hills$Race == "KnockHill")
# Cow hills is an outlier because:
2*(1-pnorm(subset(R.hills, hills$Race == "KnockHill")))
# p-value is less than .0001, so this is an outlier, so I would not include this 
# point in prediction. This means that the concern is also statistically supported.