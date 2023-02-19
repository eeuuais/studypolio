setwd("N:/. Personal_folder/�� ����/����/���̳�/��������/")

######## ���� �غ�
# 1. ����
# 2. ���ÿ��� ã�� �� ���� ����
# 3. ���� ���� �� ȸ��
# 4. Ž���� ���κм� & �ŷڵ� �м� : ������ ���� Ž��
# 5. Ȯ���� ���κм�
# 6. ���������� ���� �м�

################# Ž���� ���κм� & �ŷڵ� �м�
if(!require("readxl")){install.packages("readxl"); library(readxl)}

data <- read_excel("car_data.xlsx")
str(data)

if(!require("psych")){install.packages("psych"); library(psych)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("GPArotation")){install.packages("GPArotation"); library(GPArotation)}
if(!require("Hmisc")){install.packages("Hmisc"); library(Hmisc)}
if(!require("ltm")){install.packages("ltm"); library(ltm)}

factor_data <- principal(data, rotate='none')
str(factor_data)

# Eigen value : �ϳ��� �������� �����ϴ� ������ ��, ���� 1�̻��� �߿�
factor_data$values
# �� 4���� �������� 1�� ���� -> ������ 4�� ���� ���� ���ɼ��� ����

factor_data_varimax <- principal(data, nfactor=5, rotate='varimax')
factor_data_varimax

# h2�� communality(���뼺)�� ��Ÿ�� 0.4 �̻� ����
# RC1~RC3�� ���κ��Ϸ�(Factor Loading)
# SS Loading�� ������ �����ϴ� �л��� ��
# Proportion Var�� �� ������ �����ϴº������� �� 79% ����

# Bartlett��s Test of Sphericity
# Ho: �������� ���̵�ƼƼ ����̴�. ������ ������谡 ����.
# H1: �������� ���̵�ƼƼ ����� �ƴϴ�. ������ ������谡 �ִ�.
# �� �Ϻ� �������� �������� ���� ���ɼ��� �ִ�.
cortest.bartlett(cor(data), nrow(data))

# Kaiser-Meyer-Olkin's Measure of Sampling Adequacy, KMO's MSA
rcorr(as.matrix(data))
rcorr(as.matrix(data))$r
KMO(rcorr(as.matrix(data))$r) # KMO's MSA 0.92

# Cronbach's alpha
data[, 1:3] %>% cronbach.alpha() # raw_alpha 0.910
data[, 4:6] %>% cronbach.alpha() # raw_alpha 0.929
data[, 7:9] %>% cronbach.alpha() # raw_alpha 0.897
data[, 10:12] %>% cronbach.alpha() # raw_alpha 0.887
data[, 13:15] %>% cronbach.alpha() # raw_alpha 0.879

################# Ȯ���� ���κм�

if(!require(lavaan)){install.packages("lavaan"); library(lavaan)}

CFA_model <- '�ڵ����̹��� =~ ������ + ������� + ������
�귣���̹��� =~ �������� + ������ +������
��ȸ������ =~ ��ȸ���� + ceo + �Ҽ�����
������ =~  ����1+ ����2 + ����3
�籸�� =~ �籸��1 + �籸��2 + �籸��3'
CFA_fit <- cfa(CFA_model, data =data)
summary(CFA_fit, standardized = TRUE, fit.measure=TRUE)

if(!require(semPlot)){install.packages("semPlot"); library(semPlot)}

diagram<-semPlot::semPaths(CFA_fit,
                           whatLabels="std", intercepts=FALSE, style="lisrel",
                           nCharNodes=0, 
                           nCharEdges=0,
                           curveAdjacent = TRUE,title=TRUE, layout="tree2", curvePivot=TRUE)

################# ���������� ���� �м�

SEM_model <- '�ڵ����̹��� =~ ������ + ������� + ������
�귣���̹��� =~ �������� + ������ +������
��ȸ������ =~ ��ȸ���� + ceo + �Ҽ�����
������ =~  ����1+ ����2 + ����3
�籸�� =~ �籸��1 + �籸��2 + �籸��3
������ ~ �ڵ����̹��� + �귣���̹��� + ��ȸ������
�籸�� ~ ������'
SEM_fit <- sem(SEM_model, data =data)
summary(SEM_fit, standardized = TRUE, fit.measures=TRUE)

######## �������� ã��
mi <- modindices(SEM_fit)
mi[mi$op =="~",]

# ������ �ڵ�
SEM_model2 <- '�ڵ����̹��� =~ ������ + ������� + ������
�귣���̹��� =~ �������� + ������ +������
��ȸ������ =~ ��ȸ���� + ceo + �Ҽ�����
������ =~  ����1+ ����2 + ����3
�籸�� =~ �籸��1 + �籸��2 + �籸��3
������ ~ �ڵ����̹��� + �귣���̹��� + ��ȸ������
�籸�� ~ ������ + �귣���̹���'
SEM_fit2 <- sem(SEM_model2, data =data)
summary(SEM_fit2, standardized = TRUE, fit.measures=TRUE)

# �����𵨰� �ʱ� ���� ���̸� ��������� ����
# Ho: �𵨰� ���̴� ����.
# H1: �𵨰� ���̴� �ִ�. 
# p-value�� 
1-pchisq(156.109-131.542, df=1)
# ���̰� ����

######## �ֿ� ��跮 �����
fitMeasures(SEM_fit2) # �������յ� ����
parameterEstimates(SEM_fit2) # Unstandardized Estimates (��ǥ��ȭ��� ����)
standardizedSolution(SEM_fit2) # Standardized Estimates (ǥ��ȭ��� ����)

# ǥ��ȭ ��� ǥ�� �׸�
diagram<-semPlot::semPaths(SEM_fit2, whatLabels = "std", fade=F, edge.label.cex = 1, edge.color = "black")

# ��ǥ��ȭ ��� ǥ�� �׸�
diagram<-semPlot::semPaths(SEM_fit2, whatLabels = "est", fade=F, edge.label.cex = 1, edge.color = "black")