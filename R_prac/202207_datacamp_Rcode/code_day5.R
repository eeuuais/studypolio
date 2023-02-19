###############################################################################
########                    ���κм��� �ŷڵ� �м�                     ########
###############################################################################

if(!require("psych")){install.packages("psych"); library(psych)}
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)}
if(!require("GPArotation")){install.packages("GPArotation"); library(GPArotation)}
if(!require("Hmisc")){install.packages("Hmisc"); library(Hmisc)}
if(!require("ltm")){install.packages("ltm"); library(ltm)}

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
# Ho: �������� ���̵�ƼƼ ����̴�. ������ ������谡 ����.
# H1: �������� ���̵�ƼƼ ����� �ƴϴ�. ������ ������谡 �ִ�.
# �� �Ϻ� �������� �������� ���� ���ɼ��� �ִ�.
cortest.bartlett(cor(state.x77), nrow(state.x77))

# Kaiser-Meyer-Olkin's Measure of Sampling Adequacy, KMO's MSA
rcorr(as.matrix(state.x77))
rcorr(as.matrix(state.x77))$r
KMO(rcorr(as.matrix(state.x77))$r) # KMO's MSA 0.66

# Cronbach's alpha
state.x77[, 3:6] %>% cronbach.alpha() # raw_alpha 0.72