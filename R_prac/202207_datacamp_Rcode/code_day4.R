###############################################################################
########                        ������ƽ ȸ�ͺм�                      ########
###############################################################################

##################���׷�����ƽ �м�
# ���� ������ƽ �м��� ���Ӻ����� ���ְ� 2���� �����
# ���Ӻ��� ���ָ� �ΰ��� �����սô�.
data(iris)
a <- iris %>%
  filter(Species == "setosa" | Species == "versicolor")

# ������ƽȸ�ͺм������� ���Ӻ����� �������̾�� ��
a$Species <- factor(a$Species)
str(a) # Species �� ���� setosa�� versicolor�� ��

b <- glm(Species~Sepal.Length, data=a, family = binomial)
summary(b) # ������ƽ ȸ�ͺм� ���

coef(b) # ������ƽ ȸ�Ͱ���� setosa ��� versicolor ����
exp(coef(b)["Sepal.Length"]) 

exp(confint(b, parm = "Sepal.Length"))
fitted(b)[c(1:5,96:100)]

# P(Y=2) / 1 - P(Y=2) = exp(-28.831 + 5.140X)

################## ���� ������ƽ(���� ��������, ���� ���Ӻ���) �м� ��

glm.vs <- glm(vs~mpg+am, data=mtcars, family=binomial)
str(glm.vs)
# ��� Ȯ��
summary(glm.vs)

# ������ƽ ���� ���յ� ���� : ī����������
# Null Deviance(ȸ�ͽĿ��� �����׸� ������ ����(null ����)�� ��Ż��)�� ���� 
# ������ƽȸ�͸����� Residual(����) ���Ұ� ��������� 
# �����ϸ� ���ȵ� ������ �� ������ ���� ���� ���յ��� ������ ������ �ǹ�
with(glm.vs, pchisq(null.deviance - deviance, 
                    df.null - df.residual, lower.tail = FALSE)) 
# 9.102985e-06 < 0.05
# ���� ���� �������� ȸ�͸����� �ξ� ����

# ���ָ� ������ ���ô�.
glm.predict <- predict(glm.vs, data=mtcars, type="response")

# ���� ���� 0.5���� ũ�� 1��, ������ 0���� ����
glm.predict <- ifelse(glm.predict>0.5, 1, 0)

# ���ֺ� �з��� ������ ��Ȯ���� ���ô�.
table(actual=mtcars$vs, predicted=glm.predict)

# ���������� caret ��Ű���� �˾ƺ��ô�.
confusionMatrix(as.factor(glm.predict), as.factor(mtcars$vs))

##################  ���׷�����ƽ(���� ��������, ���� ���Ӻ���) �м�
if(!require("nnet")){install.packages("nnet"); library(nnet)}
if(!require("caret")){install.packages("caret"); library(caret)}
if(!require("e1071")){install.packages("e1071"); library(e1071)}

# ���� ������ƽ ȸ�� �м�(Multinomial Logistic Regression) �� multinom �Լ��� ���
multi.result <- multinom(Species~., data=iris)
summary(multi.result)
str(multi.result)
# ������ ������� ���õ��� ���� ������ setasa��
# logit("versicolor��")=log(P(Y="versicolor��")/P(Y="setasa")) = 
# 18.69037+(-5.458424)*Sepal.Length+(-8.707401)*Sepal.Width
#       +14.24477*Petal.Length+(-3.097684)*Petal.Width

# Sepal.Length�� versicolor�� ���� ��� -5.458424
exp(-5.458424)
# 0.004260265 
# �ؼ� : Sepal.Length�� 1 �����ϸ� iris ���� setosa���� versicolor�� �� ���ɼ���
# 0.004260265 �� �����Ѵ�.

# �ۼ��� ���� �־��� �Ʒ� �����Ϳ� ��� ���յǾ������� fitted( )�� ����� ���� �� �ִ�.
head(fitted(multi.result))

# ������ ���� ���
multi.predict <-predict(multi.result, iris, type="class")

#  ������ ���ֺ� Ȯ�� ���
# multi.predict <-predict(multi.result, iris, type="probs")

table(multi.predict, iris$Species)

confusionMatrix(multi.predict, iris$Species)

###############################################################################
########                            �����м�                          ########
###############################################################################
if(!require("tidyverse")){install.packages("tidyverse"); library(tidyverse)}  # data manipulation
if(!require("cluster")){install.packages("cluster"); library(cluster)} # clustering algorithms
if(!require("factoextra")){install.packages("factoextra"); library(factoextra)} # clustering algorithms & visualization

str(USArrests)
summary(USArrests)

USArrests_scaled <- scale(USArrests) # Normalize data
USArrests_distance <- get_dist(USArrests_scaled)
fviz_dist(USArrests_distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

str(USArrests_distance)
set.seed(123)

# center : ������ ��, nstart: 
USArrests_cluster <- kmeans(USArrests_distance, centers = 5, nstart = 25)
str(USArrests_cluster)

USArrests_cluster

# cluster: ��ʰ� ���� ������ ��ȣ ����
# centers: ������ �߽� ��ǥ ����
# totss: tot.withinss + betweenss
# withinss: �� ������ ��ʿ� ���� �߽� ���� ����
# tot.withinss: ������ ��ʿ� ���� �߽� ���� �Ÿ� ��
# betweenss: ������ �Ÿ� ���� ��
# size: �� ������ ��� ��

USArrests_cluster$cluster
USArrests_cluster$centers
USArrests_cluster$totss
USArrests_cluster$withinss
USArrests_cluster$tot.withinss
USArrests_cluster$betweenss
USArrests_cluster$size

fviz_cluster(USArrests_cluster, data = USArrests_distance)

USArrests %>%
  mutate(Cluster = USArrests_cluster$cluster) %>%
  group_by(Cluster) %>%
  summarise_all("mean")


# Hierarchical Clustering
USArrests_hc <- hclust(d=dist(USArrests_scaled), method="average")
plot(USArrests_hc, labels=row.names(USArrests_scaled))
rect.hclust(USArrests_hc, k=4)
h_cluster <- cutree(USArrests_hc, k=4)
h_cluster

USArrests %>%
  mutate(Cluster = h_cluster) %>%
  group_by(Cluster) %>%
  summarise_all("mean")