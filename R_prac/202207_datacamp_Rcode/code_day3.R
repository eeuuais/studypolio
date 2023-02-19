###############################################################################
########                      ������� �м�                            ########
###############################################################################
data(mtcars)
str(mtcars)

# pearson�� ���� ������ ���, ��ġ�� ������ ���Ե� ��츸 ���
cor(mtcars, method = "pearson")

# spearman�� ���� ������ ���, ������ ������ ���Ե� ��츸 ���
cor(mtcars, method = "spearman")

# �׷����� ��Ÿ����
if(!require(GGally)){install.packages("GGally"); library(GGally)} 

ggpairs(mtcars)

# ������ �����
if(!require("Hmisc")){install.packages("Hmisc"); library(Hmisc)}

res2 <- rcorr(as.matrix(mtcars))
res2

###############################################################################
########                       ����ȸ�� �м�                           ########
###############################################################################

if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}

airquality.no.na <- na.omit(airquality)
data <- airquality.no.na[, 1:4]



if(!require("psych")){install.packages("psych"); library(psych)}
airquality.no.na[ , 1:4] %>%
  pairs.panels(lm=TRUE, stars=TRUE)

if(!require("GGally")){install.packages("GGally"); library(GGally)}
airquality.no.na[ , 1:4] %>%
  ggpairs()

lm_fit <- lm(Ozone~Solar.R+Wind+Temp, data=na.omit(airquality))
summary(lm_fit)

# standardized estimate
if(!require("lm.beta")){install.packages("lm.beta"); library(lm.beta)}
lm.beta::lm.beta(lm_fit)

# VIF
if(!require("car")){install.packages("car"); library(car)}
car::vif(lm_fit)

###############################################################################
########                     �г�Ƽȸ�� �м�                           ########
###############################################################################

# Linear, Lasso, and Ridge Regression with R

if(!require("plyr")){install.packages("plyr"); library(plyr)}
if(!require("readr")){install.packages("readr"); library(readr)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("caret")){install.packages("caret"); library(caret)}
if(!require("ggplot2")){install.packages("car"); library(ggplot2)}
if(!require("repr")){install.packages("repr"); library(repr)}
if(!require("mlbench")){install.packages("mlbench"); library(mlbench)}

data(BostonHousing)
glimpse(BostonHousing)
my_BostonHousing <- BostonHousing
set.seed(100) 

index = sample(1:nrow(my_BostonHousing), 0.7*nrow(my_BostonHousing)) 

train = my_BostonHousing[index,] # Create the training data 
test = my_BostonHousing[-index,] # Create the test data

dim(train)
dim(test)

# 1. Linear Regression
lm_fit = lm(medv ~ ., data = train)
summary(lm_fit)

# �������� ���� ���� ����
my_BostonHousing2 <- my_BostonHousing %>%
  select(-c(indus, age))

train = my_BostonHousing2[index,] # Create the training data 
test = my_BostonHousing2[-index,] # Create the test data

# �ٽ� lm �𵨷� �м�
lm_fit = lm(medv ~ ., data = train)
summary(lm_fit)

# standardized estimate
if(!require("lm.beta")){install.packages("lm.beta"); library(lm.beta)}
lm.beta::lm.beta(lm_fit)

# VIF
if(!require("car")){install.packages("car"); library(car)}
car::vif(lm_fit)

#Step 1 - create the evaluation metrics function
eval_metrics = function(model, df, predictions, target){
  performance <- c()
  resids = df[,target] - predictions
  resids2 = resids**2
  N = length(predictions)
  r2 = as.character(round(summary(model)$r.squared, 2))
  adj_r2 = as.character(round(summary(model)$adj.r.squared, 2))
  performance <- data.frame(
    RMSE = round(sqrt(sum(resids2)/N), 2),
    R_square = adj_r2
  )
  print(performance)
}

# Step 2 - predicting and evaluating the model on train data
predictions = predict(lm_fit, newdata = train)
eval_metrics(lm_fit, train, predictions, target = 'medv')

# Step 3 - predicting and evaluating the model on test data
predictions = predict(lm_fit, newdata = test)
eval_metrics(lm_fit, test, predictions, target = 'medv')

# Regularization
# eliminate factor variables
my_BostonHousing <- my_BostonHousing %>%
  select(-c(chas))

train = my_BostonHousing[index,] # Create the training data 
test = my_BostonHousing[-index,] # Create the test data

dummies <- dummyVars(medv ~ ., data = my_BostonHousing)
train_dummies = predict(dummies, newdata = train)
test_dummies = predict(dummies, newdata = test)
print(dim(train_dummies)); print(dim(test_dummies))

# Ridge Regression
if(!require("glmnet")){install.packages("glmnet"); library(glmnet)}

x = as.matrix(train_dummies)
y_train = train$medv

x_test = as.matrix(test_dummies)
y_test = test$medv

lambdas <- 10^seq(2, -3, by = -.1)
ridge_reg = glmnet(x, y_train, nlambda = 25, alpha = 0, family = 'gaussian', lambda = lambdas)

summary(ridge_reg)
cv_ridge <- cv.glmnet(x, y_train, alpha = 0, lambda = lambdas)
optimal_lambda <- cv_ridge$lambda.min
optimal_lambda

# Compute R^2 from true and predicted values
eval_results <- function(true, predicted, df) {
  SSE <- sum((predicted - true)^2)
  SST <- sum((true - mean(true))^2)
  R_square <- 1 - SSE / SST
  RMSE = sqrt(SSE/nrow(df))
  
  
  # Model performance metrics
  data.frame(
    RMSE = RMSE,
    R_square = R_square
  )
}

# Prediction and evaluation on train data
predictions_train <- predict(ridge_reg, s = optimal_lambda, newx = x)
eval_results(y_train, predictions_train, train)

# Prediction and evaluation on test data
predictions_test <- predict(ridge_reg, s = optimal_lambda, newx = x_test)
eval_results(y_test, predictions_test, test)

# Lasso Regression
lambdas <- 10^seq(2, -3, by = -.1)

# Setting alpha = 1 implements lasso regression
lasso_reg <- cv.glmnet(x, y_train, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 5)

# Best 
lambda_best <- lasso_reg$lambda.min 
lambda_best

lasso_model <- glmnet(x, y_train, alpha = 1, lambda = lambda_best, standardize = TRUE)

predictions_train <- predict(lasso_model, s = lambda_best, newx = x)
eval_results(y_train, predictions_train, train)

predictions_test <- predict(lasso_model, s = lambda_best, newx = x_test)
eval_results(y_test, predictions_test, test)

# Elastic Net Regression
# Set training control
train_cont <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 5,
                           search = "random",
                           verboseIter = TRUE)

# Train the model
elastic_reg <- train(medv ~ .,
                     data = train,
                     method = "glmnet",
                     preProcess = c("center", "scale"),
                     tuneLength = 10,
                     trControl = train_cont)


# Best tuning parameter
elastic_reg$bestTune

# Make predictions on training set
predictions_train <- predict(elastic_reg, x)
eval_results(y_train, predictions_train, train) 

# Make predictions on test set
predictions_test <- predict(elastic_reg, x_test)
eval_results(y_test, predictions_test, test)

###############################################################################
########                    ���κм��� �ŷڵ� �м�                     ########
###############################################################################

if(!require("psych")){install.packages("psych"); library(psych)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("GPArotation")){install.packages("GPArotation"); library(GPArotation)}
if(!require("Hmisc")){install.packages("Hmisc"); library(Hmisc)}

str(state.x77)

# Population: �����α�
# Income: 1�δ� �ҵ� 
# Illiteracy: ���ͷ�
# Life Exp: ������
# Murder: 10������ ���η�
# HS Grad: �����б� ��������
# Frost: ����� 0�� ������ ��¥ ��
# Area: ������ ũ��

factor_state <- principal(state.x77, rotate='none')
str(factor_state)

# Eigen value : �ϳ��� �������� �����ϴ� ������ ��, ���� 1�̻��� �߿�
factor_state$values
# �� 3���� �������� 1�� ���� -> ������ 3�� ���� ���� ���ɼ��� ����

# RC1�� Life Exp, Illiteracy, Murder, HS Grad�� ��ǥ�ϴ� ����
# RC2�� Area, Income, HS Grad�� ��ǥ�ϴ� ����
# RC3�� Population, Frost�� ��ǥ�ϴ� ����

factor_state_varimax <- principal(state.x77, nfactor=3, rotate='varimax')
factor_state_varimax

# h2�� communality(���뼺)�� ��Ÿ�� 0.4 �̻� ����
# RC1~RC3�� ���κ��Ϸ�(Factor Loading)
# SS Loading�� ������ �����ϴ� �л��� ��
# Proportion Var�� �� ������ �����ϴº������� �� 79% ����

# Bartlett��s Test of Sphericity
cortest.bartlett(cor(state.x77), nrow(state.x77))

# Kaiser-Meyer-Olkin's Measure of Sampling Adequacy, KMO's MSA
rcorr(as.matrix(state.x77))
rcorr(as.matrix(state.x77))$r
KMO(rcorr(as.matrix(state.x77))$r) # KMO's MSA 0.66

# Cronbach's alpha
state.x77[, 3:6] %>% alpha() # raw_alpha 0.72