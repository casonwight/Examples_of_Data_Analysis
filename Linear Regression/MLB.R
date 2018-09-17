# MLB- Orioles "grass is always greener"
# Cason Wight
# The data was obtained from http://espn.go.com/mlb/standings/_/season/2017
# and was accessed on 3/1/2018

# DATA
# Response Variable: 
# number of wins in a season (wins)
# Explanatory Variables: 
# Factor division with levels East, Central, West
# run.diff, the run differential for the season

library(XML)
library(ggplot2)
scrape <- function(url) {
  MLB <- readHTMLTable(url, 
                     which = 1, colClasses = c(rep('numeric', 4), 
                                               'character', 'character', 
                                               rep('numeric', 3), 'character', 
                                               'character'), header = FALSE)
  rowsRmv <- which(is.na(MLB$V1))
  MLB <- MLB[-rowsRmv,]
  colnames(MLB) <- c("W", "L", "PCT", "GB", "HOME", "AWAY", "RS", "RA", "DIFF", "STRK", "L10")
  MLB$Division <- as.factor(c(rep("East", 5), rep("Central", 5), rep("West", 5)))
  MLB
}

MLB <- scrape("http://www.espn.com/mlb/standings/_/season/2017")


data <- aggregate(W~Division, data = MLB, FUN = quantile)
data <- cbind(data, W.mean = aggregate(W~Division, data = MLB, FUN = mean)[,2])
data <- cbind(data, aggregate(DIFF~Division, data = MLB, FUN = quantile)[,-1])
data <- cbind(data, DIFF.mean = aggregate(DIFF~Division, data = MLB, FUN = mean)[,2])


ggplot(MLB, aes(x = DIFF, y = W, col = Division)) + geom_point() + ggtitle("Wins by Run.DIFF")


# Model

# Division is a categorical Variable
MLB$Division <- factor(MLB$Division)
out1.MLB <- lm(W~Division+DIFF, data = MLB, x=TRUE, y=TRUE)
out1.MLB$y
out1.MLB$x


# To specify the comparison case (y-intercept) as East
MLB$Division <- relevel(MLB$Division, "East")
out2.MLB <- lm(W~Division+DIFF, data = MLB, x=TRUE, y=TRUE)
out2.MLB$y
out2.MLB$x
# Notice that the X matrix does not have a column for Central, but it does 
# have "not East or West" by putting zero for both East and West

summary(out2.MLB)

# Analysis of DIFF coefficient:
# For one additional run scored or prevented, we estimate an expected increase of 0.08 
# in wins, keeping the division the same. 

# Interpreting the effect of division is complicated because we need to actually run a test to 
# see if the it is reasonable to not take division into account in the model (comparing the original
# to a reduced model). This is because division is a non-numeric explanatory variable. 


# Estimated Models:
# For East:     y = 81.0970 + .082029*DIFF
# For Central:  y = (81.0970-.1680) + .082029*DIFF
# For West:     y = (81.0970+.1383) + .082029*DIFF

mycolours <- c("East" = "deepskyblue3", "Central" = "darkolivegreen3","West" = "red4")

# Graphic showing predicted model (3 lines)
ggplot(MLB, aes(x = DIFF, y = W, col = Division)) + 
  geom_point(aes(colour = Division)) +
  scale_color_manual("Division", values = mycolours) +  
  ggtitle("Wins by Run.DIFF") +
  geom_abline(slope = out2.MLB$coefficients[4], intercept = out2.MLB$coefficients[1], col = "red4")+
  geom_abline(slope = out2.MLB$coefficients[4], intercept = out2.MLB$coefficients[1]+out2.MLB$coefficients[2], col = "darkolivegreen3")+
  geom_abline(slope = out2.MLB$coefficients[4], intercept = out2.MLB$coefficients[1]+out2.MLB$coefficients[3], col = "deepskyblue3")


# Test H0: no difference between divisions after adjusting run.diff
reduced.MLB2 <- lm(W~DIFF, data = MLB)
summary(reduced.MLB2)
anova(reduced.MLB2, out2.MLB)

# There is no statistically significant difference of division on wins (p-value: .9919). 
# There was an F statistic of 0.0082 with 2 degrees of freedom. 

# Research Task:
# Determine if there is a significant effect of division on how many wins a team can get.

# Data Features that Match Analysis Strengths:
# We have other explanatory variables to help us in our analysis. 
# Wins are easily tracked and make for a good response variable.

# Analysis Weaknesses:
# Maybe not quite enough data, and There might be a better response than simply "wins"

# Challenge: Provide a research task and find data with the same characteristics as this
# assignment.
# Find if race significantly affects birth weight
# Data: https://raw.githubusercontent.com/vincentarelbundock/Rdatasets/master/csv/MASS/birthwt.csv

