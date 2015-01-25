
#Download the data from the web and unzip
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "dataset.zip", method = "curl") 
unzip ("dataset.zip", exdir = "./")

# read in relevant files for test subset
test<-read.table("UCI HAR Dataset/test/X_test.txt")
test_activity<-read.table("UCI HAR Dataset/test/y_test.txt")
test_subject<-read.table("UCI HAR Dataset/test/subject_test.txt")

#rename columns and create single test dataframe
names(test_subject)[names(test_subject)=="V1"] <-"Subject"
names(test_activity)[names(test_activity)=="V1"] <-"Activity"
alltest<-cbind(test_subject, test_activity, test)

# read in relevant files for train subset
train<-read.table("./train/X_train.txt")
train_activity<-read.table("./train/y_train.txt")
train_subject<-read.table("./train/subject_train.txt")

#rename columns and create single train dataframe
names(train_subject)[names(train_subject)=="V1"] <-"Subject"
names(train_activity)[names(train_activity)=="V1"] <-"Activity"
alltrain<-cbind(train_subject, train_activity, train)

#merge test and train into single dataset
data<-rbind(alltest, alltrain)

#read in features
features<-read.table("./features.txt")

#subset to only those containing mean or std
features<-subset(features, grepl("mean", features$V2)|grepl("std", features$V2))


#uses subset of feature names to keeps only columns containing mean or std in master dataframe
keepcol<-features$V1
keepcolname<-paste("V", keepcol, sep = "")
keepcolname<-c( "Subject", "Activity", keepcolname)
data<-data[keepcolname]

#remove special characters from feature names so can be used as column names
features$V2<-gsub("[[:punct:]]", "", features$V2)

#renames columns with clean feature name
newcolname<-c( "Subject", "Activity", features$V2)
colnames(data) <- newcolname

#recode variable for activity with human readable activity names
data$Activity[data$Activity == 1] <- "Walking"
data$Activity[data$Activity == 2] <- "Walking Upstairs"
data$Activity[data$Activity == 3] <- "Walking Downstairs"
data$Activity[data$Activity == 4] <- "Sitting"
data$Activity[data$Activity == 5] <- "Standing"
data$Activity[data$Activity == 6] <- "Laying"

Split/Apply
x<-split(data$Subject,data$Activity, data$tBodyAccmeanX)
y = lapply(x,mean)
unlist(y)


aggdata <-aggregate(data, by=list(data$Subject, data$Activity),  FUN=mean, na.rm=TRUE)

aggdata<-subset(aggdata, select = -c(Group.1,Activity) )
names(aggdata)[names(aggdata)=="Group.2"] <-"Activity"

write.table(aggdata, "tidy summary.txt",row.name=FALSE) 


