#DATA:

#US Residential Energy Consumption
#http://www.eia.gov/totalenergy/data/monthly/index.cfm#consumption
data1 <- read.csv("https://www.eia.gov/totalenergy/data/browser/csv.cfm?tbl=T02.01")

#Subset to TERCBUS Total Energy Consumed by the Residential Sector
data2 <- subset(data1,MSN=="TERCBUS")

#Subset to "Your lifetime"
data3 <- subset(data2, data2$YYYYMM>199100)

#Remove yearly total (coded "month 13", every 13th obs)
data4 <- subset(data3, data3$YYYYMM%%100 != 13)

energy <- data4$Value

head(data4[,c('YYYYMM', 'Value')])

head(energy)

#Plot EDA
plot(energy, type = "b", main = "Monthly Energy Consumption in the US", ylab = "Energy Consumption (trillion Btu)",
    xlab = "# Month (starting in 1991)")
abline(v=seq(1, 370, by=12), lty = "dotted")


#ANALYSIS:
library(astsa)

#Estimate parameters
energy.out <- sarima(energy, 1,1,1)
energy.out$ttable

#compute predictions
energy.future <- sarima.for(energy, n.ahead=27, 1, 1, 1,1,1,1,12)

#Compute 95% confidence intervals
L <- energy.future$pred-2*energy.future$se
U <- energy.future$pred+2*energy.future$se

myPreds <- cbind(energy.future$pred, L, U)

myPreds

#table of predictions and prediction intervals
energy.graph <- data.frame()
energy.graph[1:321,1] <- energy
energy.graph[1:321,2] <- rep(NA, 321)
energy.graph[1:321,3] <- rep(NA, 321)
#energy.graph <- cbind(energy.future$pred, L, U)[1:27,1:3]
colnames(energy.graph) <- c("Value", "L", "U")
colnames(myPreds) <- c("Value", "L", "U")
energy.graph <- rbind(energy.graph, myPreds)


#Graphic
library(ggplot2)

#Color coordinate the points
energy.graph$highlight <- ifelse(is.na(energy.graph$L) == FALSE, "Prediction", "Past")
textdf <- energy.graph[energy.graph$Year > 2016, ]
mycolours <- c("Prediction" = "red", "Past" = "black")

energy.graph <- energy.graph[274:348,]

#Present data in colorful graphic
ggplot(data = energy.graph, aes(x = 1:nrow(energy.graph), y = energy.graph$Value, ymin = energy.graph$L, ymax = energy.graph$U)) +
  geom_line(colour = "grey50") +
  geom_errorbar(colour = "salmon", na.rm = TRUE) +
  geom_point(size = 3, aes(colour = highlight)) +
  scale_color_manual("Year", values = mycolours) +
  labs(title = "US Energy Consumption: 2-year Visitor Predictions", y = "Energy Consumption (in Trillion Btu)", x="Indexed Month")



# Research Task: Predict Future Values
# Data Features: Time Series, Correlation observed in past on a monthly correlation is expected to continue next 2 years

# Analysis Weaknesses: There is no explanatory variable causing the seasonal trends (month to month or year to year)
#                             possible variables could be temperature, or average time inside for people, etc.


# Challenge (another research task and find data):
#   predict next 24 months of natural gas use in the US
#   data at https://www.eia.gov/dnav/ng/hist/n9140us2M.htm
