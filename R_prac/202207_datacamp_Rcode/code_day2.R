data(iris)
table(iris$Species)
prop.table(table(iris$Species))
prop.table(table(iris$Species))*100

if(!require(MASS)){install.packages("MASS"); library(MASS)}
tbl = table(survey$Smoke, survey$Exer) 
tbl                 # the contingency table 
chisq.test(tbl) 


if(!require(gmodels)){install.packages("gmodels"); library(gmodels)}
CrossTable(x=survey$Smoke,y=survey$Exer, chisq=TRUE, expected=TRUE, fisher=FALSE)
CrossTable(x=survey$Smoke,y=survey$Exer, chisq=TRUE, expected=TRUE, fisher=FALSE)

rnd <- c(75, 70)
not_rnd <- c(25, 30)
test <- cbind(rnd , not_rnd) #���� �ΰ� ���� 
rownames(test) <- c("Theory","Actual") #������ �̸� �ο�
test
chisq.test(test)

# �ʿ��� ��Ű���� �ʿ�� ��ġ�ϰ� �ҷ��ɴϴ�
if(!require(dplyr)){install.packages("dplyr"); library(dplyr)}

###############################################################################
########              �Ͽ��л�м�(one-way ANOVA) ����                 ########
###############################################################################

# �����͸� �ҷ��ɴϴ�
data(PlantGrowth)

# �������� ������ ���캾�ϴ�
str(PlantGrowth)

# �����跮�� ���캾�ϴ�
summary(PlantGrowth)

# group �������� �����͸� ������ ���� ���ܺ��� ��� ��, ���, ǥ������ ���
PlantGrowth %>%
  group_by(group) %>%
  summarise(
    count = n(),
    mean = mean(weight, na.rm = TRUE),
    sd = sd(weight, na.rm = TRUE)
  )

# �ʿ��� ��Ű���� �ʿ�� ��ġ�ϰ� �ҷ��ɴϴ�
if(!require(ggpubr)){install.packages("ggpubr"); library(ggpubr)}

# ��ġ�� ��Ű���� �̿��Ͽ� �׸��� �׷����ϴ�.
# Box plots
# ++++++++++++++++++++
# Plot weight by group and color by group
PlantGrowth %>%
  ggboxplot(x = "group", y = "weight", 
            color = "group", palette = c("#00AFBB", "#E7B800", "#FC4E07"),
            order = c("ctrl", "trt1", "trt2"),
            ylab = "Weight", xlab = "Treatment")

PlantGrowth %>%
  ggline(x = "group", y = "weight", 
         add = c("mean_se", "jitter"), 
         order = c("ctrl", "trt1", "trt2"),
         ylab = "Weight", xlab = "Treatment")


# # Box plot
# boxplot(weight ~ group, data = PlantGrowth,
#         xlab = "Treatment", ylab = "Weight",
#         frame = FALSE, col = c("#00AFBB", "#E7B800", "#FC4E07"))
# # plotmeans
# library("gplots")
# plotmeans(weight ~ group, data = PlantGrowth, frame = FALSE,
#           xlab = "Treatment", ylab = "Weight",
#           main="Mean Plot with 95% CI") 


# Compute the analysis of variance
res.aov <- aov(weight ~ group, data = PlantGrowth)
# Summary of the analysis
summary(res.aov)

# p-value��?
# Ho: ���������� ���� ���Ӻ��� ���� ���̰� ����.
# H1: ���������� ���� ���Ӻ��� ���� ���̰� �ִ�.

# ���� ���̰� �ִٸ� ���������� � ���ְ� ���̿� ���̰� �ֳ�?
# Tukey(ƩŰ) ������� ���캾�ô�
TukeyHSD(res.aov)
?pairwise.t.test

# �ٸ� ����� �ֽ��ϴ�
pairwise.t.test(PlantGrowth$weight, PlantGrowth$group, p.adjust.method = "BH")
pairwise.t.test(PlantGrowth$weight, PlantGrowth$group, p.adjust.method = "BY")
pairwise.t.test(PlantGrowth$weight, PlantGrowth$group, p.adjust.method = "BH")
pairwise.t.test(PlantGrowth$weight, PlantGrowth$group, p.adjust.method = "bonferroni")
# p.adjust.methods
# c("holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none")

############################ ANOVA ������ �������� ���캾�ô�
########## �л굿���� (homogeneity of variance) 
plot(res.aov, 1)
# ���� ���� ����
if(!require(car)){install.packages("car"); library(car)}
leveneTest(weight ~ group, data = PlantGrowth)

# p-value��?
# Ho: �л꿡 ���̰� ����.(�����ϴ�)
# H1: �л꿡 ���̰� �ִ�.

########## ���Լ�(normality assumption) ����
plot(res.aov, 2)
# Extract the residuals
aov_residuals <- residuals(object = res.aov )
# Run Shapiro-Wilk test
shapiro.test(x = aov_residuals )

# p-value��?
# Ho: �����ʹ� ���Լ��� ���̰� ����.(���Լ��� ��Ÿ����)
# H1: �����ʹ� ���Լ��� ���̰� �ִ�.

###############################################################################
########              �̿��л�м�(one-way ANOVA) ����                 ########
###############################################################################

data(ToothGrowth)
# 60�� ��� �Ǳ��� ġ�� ���忡 ��Ÿ�� C�� ��ġ�� ������ ������ ��� 
# len�� ġ�� ����, supp�� ��Ÿ�� ���� ����, dose�� ���뷮
# OJ�� �������ֽ�, VC�� ��Ÿ��C

str(ToothGrowth)
# �� ���� ������(factor) ����

summary(ToothGrowth)
# ���� ����

# Convert dose as a factor and recode the levels
# as "D0.5", "D1", "D2"
my_data <- ToothGrowth
my_data$dose <- factor(my_data$dose, 
                       levels = c(0.5, 1, 2),
                       labels = c("D0.5", "D1", "D2"))
head(my_data)

# ���� ǥ ����
table(my_data$supp, my_data$dose)

# Box plot with multiple groups
# +++++++++++++++++++++
# Plot tooth length ("len") by groups ("dose")
# Color box plot by a second group: "supp"
if(!require(ggpubr)){install.packages("ggpubr"); library(ggpubr)}
my_data %>%
  ggboxplot(x = "dose", y = "len", color = "supp",
            palette = c("#00AFBB", "#E7B800"))
?ggboxplot

my_data %>%
  ggline(x = "dose", y = "len", color = "supp",
         add = c("mean_se", "dotplot"),
         palette = c("#00AFBB", "#E7B800"))

# # Box plot with two factor variables
# boxplot(len ~ supp * dose, data=my_data, frame = FALSE, 
#         col = c("#00AFBB", "#E7B800"), ylab="Tooth Length")
# # Two-way interaction plot
# interaction.plot(x.factor = my_data$dose, trace.factor = my_data$supp, 
#                  response = my_data$len, fun = mean, 
#                  type = "b", legend = TRUE, 
#                  xlab = "Dose", ylab="Tooth Length",
#                  pch=c(1,19), col = c("#00AFBB", "#E7B800"))

res.aov2 <- aov(len ~ supp + dose, data = my_data)
summary(res.aov2)

# p-value��?
# Ho: ���������� ���� ���Ӻ��� ���� ���̰� ����.
# H1: ���������� ���� ���Ӻ��� ���� ���̰� �ִ�.

# dose�� ���ĺм�(post-hoc analysis) �Ͽ� multiple pairwise-comparisons�� ���ô�
TukeyHSD(res.aov2, which = "dose")

# supp, dose���� Ư¡�� ���캾�ô�
my_data %>%
  group_by(supp, dose) %>%
  summarise(
    count = n(),
    mean = mean(len, na.rm = TRUE),
    sd = sd(len, na.rm = TRUE)
  )

# �̿� �̻��� �л�м��� ��ȣ�ۿ� ȿ���� Ȯ���ؾ� �մϴ�

# These two calls are equivalent
res.aov3 <- aov(len ~ supp*dose, data = my_data)
res.aov3 <- aov(len ~ supp + dose + supp:dose, data = my_data)
summary(res.aov3)

# ��ȣ�ۿ� ȿ������ p-value��?
# ��ȣ�ۿ� ���� �����Ѱ�?

# dose�� ���ĺм�(post-hoc analysis) �Ͽ� multiple pairwise-comparisons�� ���ô�
TukeyHSD(res.aov3, which = "dose")

############################ ANOVA ������ �������� ���캾�ô�
########## �л굿���� (homogeneity of variance) 
plot(res.aov3, 1)
# ���� ���� ����
if(!require(car)){install.packages("car"); library(car)}
leveneTest(len ~ supp*dose, data = my_data)

# p-value��?
# Ho: �л꿡 ���̰� ����.(�����ϴ�)
# H1: �л꿡 ���̰� �ִ�.

########## ���Լ�(normality assumption) ����
# Extract the residuals
plot(res.aov3, 2) 
aov_residuals <- residuals(object = res.aov3)
# Run Shapiro-Wilk test
shapiro.test(x = aov_residuals)

# p-value��?
# Ho: �����ʹ� ���Լ��� ���̰� ����.(���Լ��� ��Ÿ����)
# H1: �����ʹ� ���Լ��� ���̰� �ִ�.

################### ���ܳ� ��� ���� �ұ����� ���
my_anova <- aov(len ~ supp*dose, data = my_data)
Anova(my_anova, type = "III")

pairwise.t.test(my_data$len, my_data$dose, p.adjust.method = "BH")


if(!require(agricolae)){install.packages("agricolae"); library(agricolae)}
?scheffe.test
scheffe.test(my_anova,  # anova model �̸�
             "dose", # name of independent variable
             alpha = 0.05, # significant level
             group=TRUE,
             console=TRUE, # print out
             main="Yield of sweetpotato\nDealt with different virus")
# ���� �׷����� ���� ���ִ� ���̰� ����