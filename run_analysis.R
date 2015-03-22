## run_analysis.R is to create a tidy data set from the raw data. This data is collected from the accelerometers from the Samsung Galaxy S smartphone.


## 1.Merges the training and the test sets to create one data set.
## 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3.Uses descriptive activity names to name the activities in the data set
## 4.Appropriately labels the data set with descriptive variable names. 
## 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## if data.table package is not loaded then load it first
if (!require("data.table")) { 
   install.packages("data.table") 
} 

##if dplyr is not installed then load it
if (!require("reshape2")) { 
 install.packages("reshape2") 
} 

require("data.table") 
require("reshape2") 

## Load the acitivity labels

activity_label <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names

feature <- read.table("./UCI HAR Dataset/features.txt")[,2] 

extract_feature <- grepl("mean|std", feature)

# Load and process X_test & y_test data. 
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt") 
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt") 
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt") 
 

names(X_test) = feature

##for each measurement

X_test = X_test[,extract_feature]

# Load activity labels 
y_test[,2] = activity_label[y_test[,1]] 
names(y_test) = c("Activity_ID", "Activity_Label") 
names(subject_test) = "subject" 

# Bind data 
test_data <- cbind(as.data.table(subject_test), y_test, X_test) 

# Load and process X_train & y_train data. 
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt") 
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt") 

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt") 

names(X_train) = feature 

# Extract only the measurements on the mean and standard deviation for each measurement. 
X_train = X_train[,extract_feature] 

# Load activity data 
y_train[,2] = activity_label[y_train[,1]] 
names(y_train) = c("Activity_ID", "Activity_Label") 
names(subject_train) = "subject" 

# Bind data 
train_data <- cbind(as.data.table(subject_train), y_train, X_train) 

# Merge test and train data 
data = rbind(test_data, train_data) 

id_label = c("subject", "Activity_ID", "Activity_Label") 
data_label = setdiff(colnames(data), id_label) 
melt_data = melt(data, id = id_label, measure.vars = data_label) 

# Apply mean function to dataset using dcast function 
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean) 

write.table(tidy_data, file = "./tidy_data.txt") 





