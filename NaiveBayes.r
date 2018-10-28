
# This R script will run on our backend. You can write arbitrary code here!

# Many standard libraries are already installed, such as e1071, which has naiveBayes
library(e1071)

# The train and test data is stored in the ../input directory
train <- read.csv("../input/train.csv")
test  <- read.csv("../input/test.csv")

# We can inspect the train data. The results of this are printed in the log tab below
#summary(train)


BayesTitanicModel<-naiveBayes(as.factor(Survived)~., train)

str(BayesTitanicModel)

BayesPrediction<-predict(BayesTitanicModel, test)

str(BayesPrediction)

summary(BayesPrediction)

output<-data.frame(test$PassengerId, BayesPrediction)

str(output)

colnames(output)<-cbind("PassengerId","Survived")

write.csv(output, file = 'Rushton_Solution.csv', row.names = F)