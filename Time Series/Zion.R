#DATA:

#Predict Zion National Park Annual Visitors for the next 5 years

#﻿Title,Bookmark
#Zion NP,Bookmark this report: https://irma.nps.gov/Stats/SSRSReports/Park%20Specific%20Reports/Annual%20Park%20Recreation%20Visitation%20(1904%20-%20Last%20Calendar%20Year)

#Accessed Mon 8 Jan 2018

#Create a data frame called "zion", reading in all of the data

zion <- read.csv(header = TRUE, text = '
  Year,RecreationVisitors,TotalRecreationVisitors
  1919,"1,814","111,311,078"
  1920,"3,692","111,311,078"
  1921,"2,937","111,311,078"
  1922,"4,109","111,311,078"
  1923,"6,408","111,311,078"
  1924,"8,400","111,311,078"
  1925,"16,817","111,311,078"
  1926,"21,964","111,311,078"
  1927,"24,303","111,311,078"
  1928,"30,016","111,311,078"
  1929,"33,383","111,311,078"
  1930,"55,297","111,311,078"
  1931,"59,186","111,311,078"
  1932,"51,650","111,311,078"
  1933,"48,763","111,311,078"
  1934,"68,801","111,311,078"
  1935,"97,280","111,311,078"
  1936,"124,393","111,311,078"
  1937,"137,404","111,311,078"
  1938,"149,075","111,311,078"
  1939,"158,063","111,311,078"
  1940,"165,029","111,311,078"
  1941,"192,805","111,311,078"
  1942,"68,797","111,311,078"
  1943,"44,089","111,311,078"
  1944,"42,243","111,311,078"
  1945,"78,280","111,311,078"
  1946,"212,280","111,311,078"
  1947,"273,953","111,311,078"
  1948,"297,571","111,311,078"
  1949,"307,881","111,311,078"
  1950,"323,402","111,311,078"
  1951,"331,079","111,311,078"
  1952,"352,921","111,311,078"
  1953,"389,445","111,311,078"
  1954,"416,800","111,311,078"
  1955,"406,800","111,311,078"
  1956,"421,200","111,311,078"
  1957,"525,100","111,311,078"
  1958,"590,700","111,311,078"
  1959,"585,000","111,311,078"
  1960,"575,800","111,311,078"
  1961,"604,700","111,311,078"
  1962,"622,100","111,311,078"
  1963,"681,100","111,311,078"
  1964,"705,200","111,311,078"
  1965,"763,600","111,311,078"
  1966,"815,200","111,311,078"
  1967,"788,400","111,311,078"
  1968,"877,100","111,311,078"
  1969,"904,300","111,311,078"
  1970,"903,600","111,311,078"
  1971,"897,000","111,311,078"
  1972,"889,417","111,311,078"
  1973,"993,800","111,311,078"
  1974,"859,300","111,311,078"
  1975,"1,055,200","111,311,078"
  1976,"1,090,000","111,311,078"
  1977,"1,105,900","111,311,078"
  1978,"1,193,212","111,311,078"
  1979,"1,040,528","111,311,078"
  1980,"1,123,846","111,311,078"
  1981,"1,288,808","111,311,078"
  1982,"1,246,290","111,311,078"
  1983,"1,273,030","111,311,078"
  1984,"1,377,254","111,311,078"
  1985,"1,503,272","111,311,078"
  1986,"1,670,503","111,311,078"
  1987,"1,777,619","111,311,078"
  1988,"1,948,332","111,311,078"
  1989,"1,998,856","111,311,078"
  1990,"2,102,400","111,311,078"
  1991,"2,236,997","111,311,078"
  1992,"2,390,626","111,311,078"
  1993,"2,392,580","111,311,078"
  1994,"2,270,871","111,311,078"
  1995,"2,430,162","111,311,078"
  1996,"2,498,001","111,311,078"
  1997,"2,445,534","111,311,078"
  1998,"2,370,048","111,311,078"
  1999,"2,449,664","111,311,078"
  2000,"2,432,348","111,311,078"
  2001,"2,217,779","111,311,078"
  2002,"2,592,545","111,311,078"
  2003,"2,458,792","111,311,078"
  2004,"2,677,342","111,311,078"
  2005,"2,586,665","111,311,078"
  2006,"2,567,350","111,311,078"
  2007,"2,657,281","111,311,078"
  2008,"2,690,154","111,311,078"
  2009,"2,735,402","111,311,078"
  2010,"2,665,972","111,311,078"
  2011,"2,825,505","111,311,078"
  2012,"2,973,607","111,311,078"
  2013,"2,807,387","111,311,078"
  2014,"3,189,696","111,311,078"
  2015,"3,648,846","111,311,078"
  2016,"4,295,127","111,311,078"
')


#Check that the data was read in properly
head(zion)
tail(zion)


#Remove the commas from within the numbers, and convert to numeric data
zion$RecreationVisitors <- as.numeric(gsub(',','',zion$RecreationVisitors))/10^6

mean(zion$RecreationVisitors)
sd(zion$RecreationVisitors)

#EDA- simple plot of the data
plot(RecreationVisitors~Year, data = zion, type = 'b', ylab = "Zion NP Annual Visitors (millions)", main = "Zion NP Annual Visitors")

#ANALYSIS:

#Because of the outliers during WW2, there is evidence of non-constant mean change
#We will cut the data off from before 1950, to ignore these outliers
zion1950 <- subset(zion, Year > 1950)

#Because the data has curvature there is evidence of a multiplicative, rather than additive model
#We want to predict future visitors, so we will perform a log transform.
zion1950$lnRecreationVisitors <- log(zion1950$RecreationVisitors)

#New plot showing the transformed, filtered data (check to see if it looks better)
plot(lnRecreationVisitors~Year, data = zion1950, type = 'b', ylab = "Log of Zion NP Annual Visitors (millions)", main = "Zion NP Annual Visitors")

#Fit the model Arima(1, 1, 1)- because we want to look at change year to 
#year, with some long and some short term memory
library(astsa)

zion1950.out <- sarima(zion1950$lnRecreationVisitors,1,1,1)
zion1950.out$ttable


#Here, constant refers to mu hat
#the phi hat is named ar1
#theta hat is named ma1
#REMEMBER THAT THIS IS OF THE LOG MILIIONS OF VISITORS


#Now we get a forecast/predictions for the next 5 years
zion1950.future <- sarima.for(zion1950$lnRecreationVisitors,n.ahead=5,1,1,1)

#The following are our predictions and the standard error
zion1950.future

#Compute the 95% prediction intervals
lowerBound <- zion1950.future$pred - qnorm(.975) * zion1950.future$se
upperBound <- zion1950.future$pred + qnorm(.975) * zion1950.future$se

myPredictions <- cbind(visitors = zion1950.future$pred, lowerBound, upperBound)


#Create data used for the graphic presentation

zion.graph <- zion[67:98, 1:2]
zion.graph[33:37, 2] <- exp(myPredictions[1:5, 1])
zion.graph[33:37, 1] <- 2017:2021


#un-transform

library(ggplot2)

myPredictions <- myPredictions[1:5, 1:3]
myPredictions <- data.frame(myPredictions)
myPredictions[,1:3] <- exp(myPredictions[,1:3])

#Color coordinate the points
zion.graph$highlight <- ifelse(zion.graph$Year > 2016, "Prediction", "Past")
textdf <- zion.graph[zion.graph$Year > 2016, ]
mycolours <- c("Prediction" = "red", "Past" = "black")

zion.graph$L <- c(rep(NA, 32), myPredictions[,2])
zion.graph$U <- c(rep(NA, 32), myPredictions[,3])

#Present data in colorful graphic
ggplot(data = zion.graph, aes(x = Year, y = RecreationVisitors, ymin = L, ymax = U)) +
  geom_line(colour = "grey50") +
  geom_errorbar(colour = "salmon", na.rm = TRUE) +
  geom_point(size = 3, aes(colour = highlight)) +
  scale_color_manual("Year", values = mycolours) +
  labs(title = "Zion NP: 5-year Visitor Predictions", y = "Number of Visitors (Millions)")


# Research Task: Predict Future Values
# Data Features: Time Series, Looking at correlation from past that goes 5 years into the future

# Analysis Weaknesses: No examination of "why" ... that is, no explanatory variables


# Challenge (another research task and find data):
#   predict annual visitors at the Lincoln Memorial for the next 5 years
#   data at https://irma.nps.gov/Stats/Reports/Park

