#Download the data set
download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', destfile='./R/data/dataset.zip')
#upzip the file
upzipfile <- unzip('./R/data/dataset.zip')
#load dplyr package
library(dplyr)
#assign data frames
activity <- read.table('UCI HAR Dataset/activity_labels.txt', col.names=c('act','act_name'))
feature <- read.table('UCI HAR Dataset/features.txt', col.names=c('no', 'features'))
subject_test <- read.table('UCI HAR Dataset/test/subject_test.txt', col.names='subject')
subject_train <- read.table('UCI HAR Dataset/train/subject_train.txt', col.names = 'subject')
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names=feature$features)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names='act')
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=feature$features)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names='act')
#merge the training and test data sets to create one data set
all_feature <- rbind(x_test, x_train)
all_act <- rbind(y_test, y_train)
all_subject <- rbind(subject_test, subject_train)
merge_data <- cbind(all_subject, all_act, all_feature)
#extract only the measurements on the mean and standard deviation for each measurement
extract_data <- merge_data %>% select(subject, act, contains('mean'), contains('std'))
#use descriptive activity names to name the activities in the data set
extract_data$act <- activity[extract_data$act, 2]
#label the data set with descriptive variable names
#review all names of the data set and rename the variables
names(extract_data)
extract_data <- rename(extract_data, activity=act)
names(extract_data) <- gsub('^t', 'Time', names(extract_data))
names(extract_data) <- gsub('^f', 'Frequency', names(extract_data))
names(extract_data)<- gsub('Acc', 'Accelerometer',
                           gsub('Gyro', 'Gyroscope',
                           gsub('Mag', 'Magnitude',
                           gsub('BodyBody', 'Body',
                           gsub('tBody', 'TimeBody', names(extract_data))))))
#create a second, independent tidy data set with the average of each variable for each activity and each subject
final_data <- extract_data %>% 
  group_by(subject, activity) %>% 
  summarise_all(funs(mean))
write.table(final_data, file='./R/data/FinalProject.txt', row.name=FALSE)
