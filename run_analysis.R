library(dplyr)
library(data.table)

## read data into R
## A. read definition labels
## A.1 read label codes for activitity of collected data
con <- file("~./R/dataset/UCI HAR Dataset/activity_labels.txt","r")
label<-read.csv(con, sep="",header = FALSE)  ## read label file
close(con)
label<-rename(label, Activity = V1, Activity_desc = V2 )

## A.2 read in varabile label for sensor data as analysis features
con <- file("~./R/dataset/UCI HAR Dataset/features.txt","r")
variables <- read.csv(con, header = FALSE, sep = " ")
close(con)
variables <- rename(variables, variable_code = V1, variable_name = V2 )


## B. read data from training set subjects
## B.1 read training set activity information
con <- file("~./R/dataset/UCI HAR Dataset/train/y_train.txt","r")
tn_label_code <- read.csv(con, header = F)
close(con)
tn_label_code <- rename(tn_label_code, Activity = V1)   ## rename field name


## B.2 Read in subject in training set 
con <- file("~./R/dataset/UCI HAR Dataset/train/subject_train.txt","r")
tn_subject <- read.csv(con, header = F)
close(con)
tn_subject <- rename(tn_subject, subject = V1)   ## rename field name


## B.3 Read in collected sensor data statistics (7352X561 data)
##    label the data with feature names
con <- file("~./R/dataset/UCI HAR Dataset/train/X_train.txt","r")
train <- read.table(con, sep = "",header = F, na.strings ="",stringsAsFactors= F)
close(con)
setnames(train, names(train), as.vector(variables[,2])) 

## create training set data by merging all the above information
train_data <- cbind(tn_label_code,train)   ## (7352X562 data)
train_data <- cbind(tn_subject,train_data) ## (7352X563 data)

## Repeat data loading for test data set
## c. read data from training set subjects
## c.1 read testing set activity information
con <- file("~./R/dataset/UCI HAR Dataset/test/y_test.txt","r")
ts_label_code <- read.csv(con, header = F)
ts_label_code <- rename(ts_label_code, Activity = V1)   ## rename field name
close(con)

## c.2 Read in subject in testing set
con <- file("~./R/dataset/UCI HAR Dataset/test/subject_test.txt","r")
ts_subject <- read.csv(con, header = F)
ts_subject <- rename(ts_subject, subject = V1)   ## rename field name
close(con)

## c.3 Read in collected sensor data statistics for test set subjects(2947X561)
con <- file("~./R/dataset/UCI HAR Dataset/test/X_test.txt","r")
test <- read.table(con, sep = "",header = F, na.strings ="",stringsAsFactors= F)
close(con)
setnames(test, names(test), as.vector(variables[,2]))

## merge all test subject's data (2947X561-> 2947* 563)
test_data <- cbind(ts_label_code,test)
test_data <- cbind(ts_subject,test_data)


## merge test and training into one data set
one_data_set<-rbind(train_data,test_data)

## select only mean and std columns 
means_stds<-one_data_set[,c(1:2,grep("mean|std|Mean|Std", names(one_data_set)))]

## then add in the activity description
selected1 <- merge(label, means_stds, by.x = "Activity", by.y = "Activity")

## create tidy data set with selected mean_std data
tidy_average_data <- aggregate(selected1[, 4:ncol(selected1)],
                       by=list(subject = selected1$subject, 
                               Activity_desc = selected1$Activity_desc),
                       mean)
write.table(tidy_average_data, file = "tidy_average_data.txt", sep = " ", col.names = TRUE)
