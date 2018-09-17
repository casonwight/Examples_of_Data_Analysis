# Montgomery County Traffic Stops Data

stops.full<-read.csv("http://data.montgomerycountymd.gov/api/views/4mse-ku6q/rows.csv?accessType=DOWNLOAD",
                     header=TRUE,as.is=TRUE)


#Class Participation 1
#Data
# subset to last year
last.year<-2017
stops.full$AutoYear<-as.numeric(stops.full$Year)
stops.full$Year<-as.numeric(substr(stops.full$Date.Of.Stop,7,10))
stops.last<-subset(stops.full,Year==last.year)
# delete the really big data set ... don't need to tie up the memory
rm(stops.full)

# Create Month and Hour variables
stops.last$Month<-as.numeric(substr(stops.last$Date.Of.Stop,1,2))
stops.last$Hour<-as.numeric(substr(stops.last$Time.Of.Stop,1,2))

# clean up dataset
stops.last$AutoState<-stops.last$State
stops.last$Out.of.State<-(stops.last$AutoState!="MD")

stops.last$Color<-as.character(stops.last$Color)
stops.last$Color[stops.last$Color %in% c("CAMOUFLAGE","CHROME","COPPER","CREAM","MULTICOLOR","N/A","PINK")]<-"OTHER"
stops.last$Color<-factor(stops.last$Color)

# other filters
stops.last<-subset(stops.last,Color != "N/A")
stops.last<-subset(stops.last,Color != "")
stops.last<-subset(stops.last,Gender != "U")
stops.last<-subset(stops.last,HAZMAT == "No")
stops.last<-subset(stops.last,AutoYear > 1990 & AutoYear < last.year+2)

# convert character variables to factors
stops.last$SubAgency<-factor(stops.last$SubAgency)
stops.last$Accident<-factor(stops.last$Accident)
stops.last$Belts<-factor(stops.last$Belts)
stops.last$Personal.Injury<-factor(stops.last$Personal.Injury)
stops.last$Property.Damage<-factor(stops.last$Property.Damage)
stops.last$Commercial.License<-factor(stops.last$Commercial.License)
stops.last$Commercial.Vehicle<-factor(stops.last$Commercial.Vehicle)
stops.last$Alcohol<-factor(stops.last$Alcohol)
stops.last$Work.Zone<-factor(stops.last$Work.Zone)
stops.last$Contributed.To.Accident<-factor(stops.last$Contributed.To.Accident)
stops.last$Race<-factor(stops.last$Race)
stops.last$Gender<-factor(stops.last$Gender)
stops.last$Out.of.State<-factor(stops.last$Out.of.State)


# Create dataset for Speeding
#  example: EXCEEDING MAXIMUM SPEED: 49 MPH IN A POSTED 40 MPH ZONE
speed.last1<-subset(stops.last,substr(Description,1,23)=="EXCEEDING MAXIMUM SPEED")
# difference between cited speed and posted speed limit
speed.last1$speed<-as.numeric(substr(speed.last1$Description,26,27))-as.numeric(substr(speed.last1$Description,45,46))
speed.last1<-subset(speed.last1,!is.na(speed))
#  example: EXCEEDING POSTED MAXIMUM SPEED LIMIT: 39 MPH IN A POSTED 30 MPH ZONE
speed.last2<-subset(stops.last,substr(Description,1,30)=="EXCEEDING POSTED MAXIMUM SPEED")
# difference between cited speed and posted speed limit
speed.last2$speed<-as.numeric(substr(speed.last2$Description,39,40))-as.numeric(substr(speed.last2$Description,58,59))
speed.last2<-subset(speed.last2,!is.na(speed))
# combine and subset to columns of interest
speed.last<-rbind(speed.last1,speed.last2)
speed.last<-speed.last[,c(4,9:12,14,16:18,24,28:30,36:38,40,41)]





# make a prediction at a new observation
#  note: grab an observation in the dataset that is very similar to my situation and change it
new.obs<-speed.last[25,]
new.obs$AutoYear<-2017
new.obs$Month<-8
new.obs$Hour<-18

#Response variable is speed (numeric), and the other 17 are explanatory

#EDA

#Analysis predicting speeding
summary(speed.last$speed)
hist(speed.last$speed, breaks = 25)

str(speed.last)

dim(speed.last)



# ANALYSIS

# Create Train and Test
# SRS without replacement
set.seed(12)


# split train and test (train- 80%, and test- 20%)
# We will round to 8000 of the 9773 for train, and the rest go to test.
train.rows <- sample(9773, 8000)
speed.train <- speed.last[train.rows,]
speed.test <- speed.last[-train.rows,]

# Validate the similarity between train and test
summary(speed.train$speed)
summary(speed.test$speed)

# Grow a random forest on train 
# validate predictions on test

library(randomForest)

# fit model 
out.speed<- randomForest(x = speed.train[,-18], y = speed.train$speed,
                         xtest= speed.test[,-18], ytest=speed.test$speed, 
                         replace=TRUE, #with replacement because we are bootstrapping samples for trees
                         keep.forest=TRUE, #if the trees aren't kept, they are thrown away due to memory
                         ntree= 50, #usually 50-100 are reasonable
                         mtry= 5, #usually a third, a fourth, or a tenth of exp. variables (this draws out middle variables)
                         nodesize= 25) #usually 25 or 30


# We are going to use all 50 of the trees to make the prediction and take the average of them all

#Prediction performance
out.speed

#Compute RMSE
sqrt(49.46469) # for train
sqrt(50.24) # for test

# We want to know which explanatory variables are important
# Model insight (interpretation)
importance(out.speed)
varImpPlot(out.speed)


#Top 3 most important
importance(out.speed)[1:3,]

#Predict a new observation-
predict(out.speed, newdata=new.obs)
# predicted 13.7772 mph over the speed limit for a ticket

# Research Task and Data features that match analysis strengths
# We wanted to know the features that are most important in determining the speed at which someone
# gets a ticket.The forest aproach is useful, because it randomly generates trees based on several of 
# the variables, and helps us see which ones are best. Here, we have 17 explanatory variables, so
# this approach seems reasonable. Also, we have enough data to support the many different trees.


#Analysis Weaknesses:
# Clearly, the model not telling us specifics of the explanatory variables other 
# than "importance" is a weakness of the model

# Challenge:
# Research question:
# What hour do people speed the most?


# Create dataset for Ticket/Warning
ticket.last<-subset(stops.last,Violation.Type %in% c("Citation","Warning") )
ticket.last$Ticket<-factor(ticket.last$Violation.Type=="Citation")
# subset to columns of interest
ticket.last<-ticket.last[,c(4,9:12,14,17,18,24,28:30,36:38,40,41)]

table1 <- table(ticket.last$Ticket)
table1
prop.table(table1)

# We need to split this up so that it is 50/50 before doing the RF model

# We are going to take all of the "bads" or "FALSE"s or tickets, because we have less of them

# We are going to take a SRS of the goods, equal to 79591, or the number of "bads"

# Create a data set with half goods (warnings) and half bads (tickets)

all.bad <- subset(ticket.last, Ticket=="TRUE")
n.bad <- nrow(all.bad)
  
# SRS without replacement from the goods
all.good <- subset(ticket.last, Ticket=="FALSE")
n.good <- nrow(all.good)
set.seed(12)
rows.good <- sample(n.good, n.bad, replace = FALSE)
sample.good <- all.good[rows.good,]

ticket.model <- rbind(all.bad, sample.good)

nrow(ticket.model)

train.row<- sample(nrow(ticket.model), round(.8*nrow(ticket.model), 0))
sample.train <- ticket.model[train.row,]
sample.test <- ticket.model[-train.row,]


# Confirm the numbers are similar
summary(sample.train$Ticket)/.8
summary(sample.test$Ticket)/.2

library(randomForest)

out.ticket <-randomForest(x = sample.train[,-17], y = sample.train$Ticket,
                               xtest= sample.test[,-17], ytest=sample.test$Ticket, 
                               replace=TRUE, #with replacement because we are bootstrapping samples for trees
                               keep.forest=TRUE, #if the trees aren't kept, they are thrown away due to memory
                               ntree= 50, #usually 50-100 are reasonable
                               mtry= 5, #usually a third, a fourth, or a tenth of exp. variables (this draws out middle variables)
                               nodesize= 25) #depends on number of observations



#Check RMSE
out.ticket

# looh at error rate

# We want to know which explanatory variables are important
# Model insight (interpretation)
importance(out.ticket)
varImpPlot(out.ticket)

# Make a prediction if "new obs" would get a ticket or a warning
predict(out.ticket, new.obs)


# The three most important variables seem to be color, hour, and autoYear

#Research Task and Data Features that Match Analysis Strengths:
# Predict if someone will get a ticket or a warning in Montgomery County when pulled
# over, depending on 16 explanatory variables

# Data features:
# We used tree models, because the data is very tall and wide (17 columns) with most being 
# explanatory variables

#Analysis Weaknesses:
# This form of prediction is wrong roughly up to 30% of the time (for this data) and 
# deeming an explanatory variable "important" is rather arbitrary.

# Challenge:
# Another question that we could ask given this data could be what year of car model would
# be the worst for receiveing tickets instead of warnings?




