###############################################################################
########                            K-�ֱ����̿�                       ########
###############################################################################
wbcd<-read.csv("C:/data/wisc_bc_data.csv", stringsAsFactors=FALSE)
class(wbcd)
str(wbcd)
wbcd <- wbcd[-1] 
table(wbcd$diagnosis)
wbcd$diagnosis <- factor(wbcd$diagnosis, levels = c("B", "M"), labels = c("Benign", "Malignant"))
round(prop.table(table(wbcd$diagnosis))*100, digits= 1)
summary(wbcd[c("radius_mean", "area_mean", "smoothness_mean")])
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

normalize(c(1, 2, 3, 4, 5))
normalize(c(10, 20, 30, 40, 50))
wbcd_n <- as.data.frame(lapply(wbcd[2:31], normalize))
summary(wbcd_n$area_mean)

wbcd_train <- wbcd_n[1:469, ]
wbcd_test <- wbcd_n[470:569, ]

wbcd_train_labels <- wbcd[1:469, 1]
wbcd_test_labels <- wbcd[470:569, 1]

if(!require(class)){install.packages("class"); library(class)}

wbcd_test_pred <- knn(train = wbcd_train, test = wbcd_test, cl = wbcd_train_labels,  k=21) 
# k=sqrt(469)=21

if(!require(gmodels)){install.packages("gmodels"); library(gmodels)}
CrossTable(x = wbcd_test_labels, y = wbcd_test_pred, prop.chisq=FALSE)

###############################################################################
########                        ���̺� ������                          ########
###############################################################################

if(!require("caret")){install.packages("caret"); library(caret)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("pROC")){install.packages("pROC"); library(pROC)}
if(!require("e1071")){install.packages("e1071"); library(e1071)}

iris_cat <- iris

# naiveBayes�� ������ ����������� ������ ���Ӻ����� �з���
# �Էº����� ����ȭ 
iris_cat$Sepal.Length <- cut(iris$Sepal.Length, c(-Inf, median(iris$Sepal.Length), Inf))
iris_cat$Sepal.Width <- cut(iris$Sepal.Width, c(-Inf, median(iris$Sepal.Width), Inf))
iris_cat$Petal.Length <- cut(iris$Petal.Length, c(-Inf, median(iris$Petal.Length), Inf))
iris_cat$Petal.Width <- cut(iris$Petal.Width, c(-Inf, median(iris$Petal.Width), Inf))

?naiveBayes
model <- naiveBayes(Species ~ ., data = iris_cat)
model

predict(model, iris_cat[1:5, -5], type = "raw") # class probabilities

# �����ϱ�
pred <- predict(model, iris_cat[,-5])
# Confusion Matrix
table(pred, iris$Species)

# using laplace smoothing:
model2 <- naiveBayes(Species ~ ., data = iris_cat, laplace = 1)
pred <- predict(model, iris_cat[,-5])
table(pred, iris$Species)

# data partition
trainRowNumbers <- createDataPartition(iris_cat$Species , p=0.7, list=FALSE)

# create the training dataset
trainData <- iris_cat[trainRowNumbers, ]

# creating the test dataset
testData <- iris_cat[-trainRowNumbers, ]

set.seed(12345) # ���� seed

# �н� �� �����
NaiveByes.iris_cat <- naiveBayes(Species ~ ., data = trainData, laplace = 1)

# Ȯ�� �����ϱ� 
testData$predict_prob <- predict(NaiveByes.iris_cat, testData[, -5], type = "raw")

# ���� �����ϱ�
testData$predict_class <- predict(NaiveByes.iris_cat, testData[, -5], type = "class")

# �Ʒ��ڷ��� �ε��� ����(�񺹿� ����), ������� ���� �������� �����ڷ��� �ε��� 
tr.idx <- sample(nrow(iris), nrow(iris)*0.5, replace=F)
head(tr.idx)

iris2 <- iris
cut_values <- apply(iris2[, -5], 2, quantile)
# �Էº����� ������ ������ ��ȯ (���⼭�� 4������ �̿�)
for(i in 1:4) iris2[, i] <- cut(iris2[, i], cut_values[,i])
head(iris2)

model <- naiveBayes(Species ~ ., data = iris2[tr.idx, ], k=5)

# predict
# type = "raw"�̸� ����Ȯ�� ����, �ƴϸ� Ŭ�������� ���  
predict(model, iris2[1:5, -5], type = "raw")

# �����ڷῡ ���� ���� 
pred <- predict(model, iris2[-tr.idx,-5])

# Confusion Matrix
o <- table(pred, iris2$Species[-tr.idx])
o

# using laplace smoothing:
model2 <- naiveBayes(Species ~ ., data = iris2[tr.idx, ], laplace = 3)
pred2 <- predict(model2, iris2[-tr.idx, -5])
table(pred2, iris2$Species[-tr.idx])

###############################################################################
########                      �ǻ��������: �з�����                   ########
###############################################################################

if(!require("caret")){install.packages("caret"); library(caret)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("rpart")){install.packages("rpart"); library(rpart)}
if(!require("rpart.plot")){install.packages("rpart.plot"); library(rpart.plot)}
if(!require("C50")){install.packages("C50"); library(C50)}
if(!require("Epi")){install.packages("Epi"); library(Epi)}
if(!require("ROCR")){install.packages("ROCR"); library(ROCR)}

set.seed(678)
path <- 'https://raw.githubusercontent.com/guru99-edu/R-Programming/master/titanic_data.csv'
titanic <-read.csv(path)
str(titanic)
head(titanic)

# ������ �ؼ�
# pclass : 1=1�, 2=2�, 3=3�
# Survived : 0=���, 1=����
# name : ž���� ����
# sex : ž���� ����
# age : male=����, female=����
# sibsp : ���� ž���� �ڸ� �Ǵ� ����� ��
# parch : ������ �θ� ���� �ڽ��� ��
# ticket : Ƽ�Ϲ�ȣ
# fare  : ���
# cabin : ��ȣ��
# embarked : ž���� C=�����θ�, Q=����Ÿ��, S=��콺������
# home.dest : ������

shuffle_index <- sample(1:nrow(titanic))
head(shuffle_index)

titanic <- titanic[shuffle_index, ]
head(titanic)
str(titanic)

# ������� �ʴ� ���� ����
clean_titanic <- titanic %>%
  select(-c(home.dest, cabin, name, x, ticket)) %>% 
  #Convert to factor level
  mutate(pclass = factor(pclass, levels = c(1, 2, 3), labels = c('Upper', 'Middle', 'Lower')),
         survived = factor(survived, levels = c(0, 1), labels = c('No', 'Yes'))) %>%
  filter(age!="?") %>% # age�� ����ǥ�� �ֳ׿�. 
  na.omit()

# str()������ ������ �������� �Լ�
glimpse(clean_titanic)
# str(clean_titanic)

# age�� fare�� ���ڷ� �ٲ߽ô�.
clean_titanic$age <- as.numeric(clean_titanic$age)
clean_titanic$fare <- as.numeric(clean_titanic$fare)
glimpse(clean_titanic)

set.seed(100)

# data partition
trainRowNumbers <- createDataPartition(clean_titanic$survived , p=0.8, list=FALSE)

# create the training dataset
trainData <- clean_titanic[trainRowNumbers, ]

# creating the test dataset
testData <- clean_titanic[-trainRowNumbers, ]

prop.table(table(trainData$survived))
prop.table(table(testData$survived))

fit <- rpart(survived~., data = trainData, method = 'class')
rpart.plot(fit, extra = 106)
# �׷��� �׸��� 'Export' -> 'PDF'�� ���� �� �����

testData$predict_class <-predict(fit, testData, type = 'class') # ���Ӻ����� ���� ������
predict_class

# ȥ�����
confusionMatrix(data = testData$predict_class, reference = testData$survived)

testData$predict_prob <- predict(fit, testData, type = 'prob')# ���Ӻ����� ���� Ȯ�� ����
testData$predict_prob

dtree_ROC <- ROC(form=survived~testData$predict_prob, data = testData, plot="ROC")
dtree_ROC


##### iris �����ͷ� ������ ���ô�.
set.seed(100)
# data partition
trainRowNumbers <- createDataPartition(iris$Species , p=0.8, list=FALSE)

# create the training dataset
trainData <- iris[trainRowNumbers, ]

# creating the test dataset
testData <- iris[-trainRowNumbers, ]

# �ּ� �и� ��� ���� �ִ� Ʈ�� ���� ����
rpart.control(minsplit = 3, maxdepth = 10)

# cp: complexity parameter, Ʈ���� �������� ���� ���� ����� R-squared ���� �ּ����� ũ�⸦ ����
# ���� ũ�� ������ �� ���ڶ�, �ʹ� ������ ������ �ʹ� ũ�� ����, 0.1~0.2 ���� ����

fit <- rpart(Species~., data = trainData, method = 'class', cp = .02)

rpart.plot(fit, type = 2, extra = 104)
?rpart.plot # extra option����

testData$predict_class <-predict(fit, testData, type = 'class') # ���Ӻ����� ���� ������
testData$predict_class

# ȥ�����
confusionMatrix(data = testData$predict_class, reference = testData$Species)

testData$predict_prob <-predict(fit, testData, type = 'prob')# ���Ӻ����� ���� Ȯ�� ����
testData$predict_prob
str(testData)

# ROC curve �׸���
dtree_ROC <- ROC(form=Species~testData$predict_prob, data = testData, plot="ROC")
dtree_ROC

# cp�� ���� error�� �پ��� ������ ������
printcp(fit)

# cp�� ���� error�� �پ��� ������ �׷�����
plotcp(fit)

# ����ġ��
prtfit<- prune(fit, cp=0.033) # from cptable 
prtfit

# ����ģ �� �׸� �׸���
rpart.plot(prtfit, uniform=TRUE, main="Pruned Regression Tree")

write.csv(testData, "C:/data/iris_prediction.csv")

################## C5.0���� �м��ϱ�

fit_iris_C50 <- C5.0(Species~., data=trainData)
testData$predict_class<- predict(fit_iris_C50, testData, type="class")
testData$predict_class
plot(fit_iris_C50) # �׸��� �׸��� �Լ��� �˰����뿡 ���� ������
confusionMatrix(data = testData$predict_class, reference = testData$Species)

dtree_ROC <- ROC(form=Species~testData$predict_prob, data = testData, plot="ROC")
dtree_ROC

# ����� �˰������� IRIS �������� Species ������ �����ϴµ� �� ��Ȯ�Ѱ�?
# CA, AUC?

###############################################################################
#                    �ǻ�������� : ��������                                  #
###############################################################################

if(!require("caret")){install.packages("caret"); library(caret)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("party")){install.packages("party"); library(party)}
if(!require("mlbench")){install.packages("mlbench"); library(mlbench)}

airquality_data <- airquality %>%
  select(-c(Month, Day)) %>%
  na.omit()

str(airquality_data)
fit_ctree <- ctree(Ozone~., data=airquality_data)
fit_ctree

plot(fit_ctree)

# data partition
trainRowNumbers <- createDataPartition(airquality_data$Ozone, p=0.8, list=FALSE)

# create the training dataset
trainData <- airquality_data[trainRowNumbers, ]

# creating the test dataset
testData <- airquality_data[-trainRowNumbers, ]

fit_ctree <- ctree(Ozone~., data=trainData)

testData$predict_value <- predict(fit_ctree , testData) # ���Ӻ����� �� ����
testData$predict_value
str(testData)

predictions <- model1 %>% predict(swiss)
data.frame(
  R = R2(testData$predict_value, testData$Ozone),
  RMSE = RMSE(testData$predict_value, testData$Ozone),
  MAE = MAE(testData$predict_value, testData$Ozone)
)