id <- c(101,201,301,401,501)
sex <- c('F','F','M','F','M')
height <- c(170,162,183,158,182) 
weight <- c(62,60,75,48,80) 
grade <- c("A+","B","A","C","B???") 
(A <- data.frame(ID=id,SEX=sex,HEI=height,WEI=weight,GRADE=grade))

A[,c(1,3,4)] # ������ A�� 1, 3, 4 �� ������ ����
A$GRADE # ������ A�� GRADE (����)ǥ��
A[-2] # �� ��° ���� �����ϰ� ������ ����
A[2:4,] # ������ A�� 2~4��° �� ������ ����
A[2:4,3] # 2~4 ��° �� ������ �� �� ��° �� ����

A[A$WEI >=65, ]

x <- 20 
if(x%%2 ==0) {
  print('x�� ¦���Դϴ�.')
} else {
  print('x�� Ȧ���Դϴ�.')
}

exam <- 30
if (exam >=90){
  print('������ A+�Դϴ�.')
} else if(exam >=80) {
  print('������ Ao�Դϴ�.')
} else if(exam >=70) {
  print('������ B+�Դϴ�.')
} else if(exam >=60) {
  print('������ Bo�Դϴ�.')
} else if(exam >=50) {
  print('������ C+�Դϴ�.')
} else {
  print('������ F�Դϴ�.')
}

for(i in 1:10){
  print(i)
}

sum <- 0
for(i in 1:10){
  sum <-sum + i
}
print(sum)

x <- 1
while(x <= 10){
  print(x)
  x <- x+1
}

x <- 1
sum <- 0
while(x <= 10){
  sum <-sum + x
  x <- x+1  
}
print(sum)

x <- 0
while(x <= 10){
  x <- x+1
  if(x==7)
    break
  print(x)
}

i <- 0
sum <- 0
while(i <= 9){
  i <- i+1
  if(i%%2==1){
    next
  }
  print(i)
  sum <-sum + i
}
print(sum)

df1<-data.frame(name = c('Park','Lee','Kim','Kang'), gender = c('f','m','f','m')) 
df2<-data.frame(name = c('Min','Ahn','Choi','Kyeon'), gender = c('m','m','f','f'))
df1
df2
rbind(df1,df2)

df1<-data.frame(name = c('Park','Lee','Kim','Kang'), gender = c('f','m','f','m')) 
df3<-data.frame(age = c(22,24,28,25), city = c('Seoul','Incheon','Seoul','Busan')) 
df1
df3
cbind(df1,df3)

df4<-data.frame(name = c('Yoon', 'Seo', 'Park', 'Lee', 'Kim', 'Kang'), age = c(30, 31, 22, 24, 28, 25)) 
df5<-data.frame(name = c('Park', 'Lee', 'Kim', 'Kang', 'Ahn', 'Go'), gender=c('f', 'f', 'm', 'm', 'f', 'm'), city = c('Seoul', 'Incheon', 'Seoul', 'Busan', 'Gwangju', 'Deagu')) 
df4
df5
merge(df4, df5, by='name', all=FALSE) #name�� �������� ��ġ�� �����͸� ������ �����͸� ����

df4<-data.frame(name = c('Yoon', 'Seo', 'Park', 'Lee', 'Kim', 'Kang'), age = c(30, 31, 22, 24, 28, 25)) 
df5<-data.frame(name = c('Park', 'Lee', 'Kim', 'Kang', 'Ahn', 'Go'), gender=c('f', 'f', 'm', 'm', 'f', 'm'), city = c('Seoul', 'Incheon', 'Seoul', 'Busan', 'Gwangju', 'Deagu')) 
df4
df5
merge(df4, df5, by='name', all.x=TRUE) #name�� �������� df4�� ���� ��� ��Ÿ��, ���� ���� <NA>�� ��Ÿ��

df4<-data.frame(name = c('Yoon', 'Seo', 'Park', 'Lee', 'Kim', 'Kang'), age = c(30, 31, 22, 24, 28, 25)) 
df5<-data.frame(name = c('Park', 'Lee', 'Kim', 'Kang', 'Ahn', 'Go'), gender=c('f', 'f', 'm', 'm', 'f', 'm'), city = c('Seoul', 'Incheon', 'Seoul', 'Busan', 'Gwangju', 'Deagu')) 
df4
df5
merge(df4, df5, by='name', all.y=TRUE) #name�� �������� df5�� ���� ��� ��Ÿ��, ���� ���� <NA>�� ��Ÿ��

df4<-data.frame(name = c('Yoon', 'Seo', 'Park', 'Lee', 'Kim', 'Kang'), age = c(30, 31, 22, 24, 28, 25)) 
df5<-data.frame(name = c('Park', 'Lee', 'Kim', 'Kang', 'Ahn', 'Go'), gender=c('f', 'f', 'm', 'm', 'f', 'm'), city = c('Seoul', 'Incheon', 'Seoul', 'Busan', 'Gwangju', 'Deagu')) 
df4
df5
merge(df4, df5, by='name', all=TRUE) #name�� �������� df4, df5�� ���� ��� ��Ÿ��, ���� ���� <NA>�� ��Ÿ��

setwd("C:/data") # �۾� ���� ����, ���� ���� �� �������� �����͸� �а� ��

install.packages("dplyr") # ��Ű�� ��ġ

library(dplyr) # ��Ű�� �ҷ�����

test <- read.csv("test.csv", header=TRUE) # ������ ���� �б�
test # ������ ��� �� ����
names(test) # ������ ����
# ���ο� ���� ����� ����
test$total <- test$CLASS+test$KOREAN+test$ENGLISH+test$MATH+test$SCIENCE+test$MUSIC

# ��� ���
test$rank <- rank(-test$total, ties.method="min") 

nrow(test) # ���� ���� ���
(test$rank /nrow(test))
test

# filter : �࿡ ������ �ְ� ���ǿ� �����ϴ� �ุ ����
# ��: 7�� (CLASS==7)�� ������ �˰� �ʹٸ�

filter(test, CLASS == 7)

# 7���� ������ test_7�̶�� ������ �ְ� �ʹٸ�
test_7 <- filter(test, CLASS == 7)

# ������ ������ �ְ� �ʹٸ� AND OR ! ���� �̿�����.
# �ѱ��� ������ 50�� ���� (KOREANN <= 50) �̰ų� (|) ���� ������ 50�� ���� (ENGLISH <= 50) �� �л��� ����?
filter(test, KOREAN <= 50 | ENGLISH <= 50)

# �ѱ��� ������ 50�� �̻� (KOREANN >= 50) �̰� (&) ���� ������ 50�� �̻�  (ENGLISH >= 50) �� �л��� ����?
filter(test, KOREAN >= 50 & ENGLISH >= 50)

# 5�ݰ� 9�� �л��� ������ �˰� ���� ���
filter(test, CLASS == 5 | CLASS ==9)

# 7���� ������ �л��� ������ �˰� ���� ���
filter(test, CLASS == !7)

# %in% c()�� �̿��Ͽ� ��� �� ��ġ�ϴ� ��� �����ϱ�
# 2��, 4��, 7��, 9���� ������ �˰� �ʹٸ�
filter(test, CLASS %in% c(2, 4, 7, 9))

# arrange() �Լ��� �̿��� ����(sorting)
# CLASS �켱 ����, ID�� ���� �������� �Ͽ� ���������� ������ ���̴�. 
# ��ȣ �ȿ� ù ��° ���ڷ� ������ �����Ӹ��� �����ϰ�, 
# �� ��° ���ڷ� ���� �켱������ ������ ���� ���� �����ϰ� �������� ���� ������� �����ϸ� �ȴ�.
arrange(test, CLASS, ID, desc(KOREAN))

# select() �Լ��� Ȱ���� �� ������ �����ϱ�
select(test, KOREAN,ENGLISH,MATH)
select(test, KOREAN : MATH)
select(test, -MUSIC)

# pipe �̿��ϱ�, %>% ���� ����� �����ʿ� �Ѱ��ֱ�
test %>% filter(MUSIC >= 95) %>% select(CLASS,ID)

# mutate() �Լ��� Ȱ���� �Ļ����� �߰��ϱ�
test %>% mutate(TOTAL=KOREAN+ENGLISH+MATH+SCIENCE+MUSIC)

test %>% 
  mutate(TOTAL=KOREAN+ENGLISH+MATH+SCIENCE+MUSIC,MEAN=(KOREAN+ENGLISH+MATH+SCIENCE+MUSIC)/5) %>%
  head

# �ѱ�� 80�� �̻��̸� "P"�� �ƴϸ� "F"�� ����
test%>%
  mutate(result=ifelse(KOREAN >= 80, "P","F")) %>%
  head

# mutate() �Լ��� Ȱ���ϸ� ���� ������ �� �� ���� �Ļ������� ����� ���ο� ���� �߰��� �� �ִ�
test %>%
  mutate(TOTAL=KOREAN+ENGLISH+MATH+SCIENCE+MUSIC)

test%>%
  mutate(TOTAL=KOREAN+ENGLISH+MATH+SCIENCE+MUSIC,
         MEAN=(KOREAN+ENGLISH+MATH+SCIENCE+MUSIC)/5) %>%
  head

# mutate() �Լ��� ifelse() �� ���� ���ǹ��� �Բ� ����Ͽ� ���ǿ� ���� �ٸ� ���� �ο��� ������ �߰��� �� �ִ�. 
test%>%
  mutate(result=ifelse(KOREAN >= 80, "P","F"))%>%
  head

# group_by(������_������) �Լ��� ������ ������ ���� �����͸� ���� ���� �����Ѵ�.
# �ַ� ���ܺ��� �����ٸ� ���� �� Ư¡�� ����ϱ� ���� ����ϸ� ����� ���ؼ��� summarise( ) �Լ��� ���ȴ�. 
test %>% 
  group_by(CLASS) %>%
  summarise(C_mean_K_ = mean(KOREAN))

# ����� ���غ���.
test %>% summarise(mean_K = mean(KOREAN))

# �ݺ��� ���� ���� ���, �߾Ӱ�,  ǥ������, �л����� ����ϱ�
# ~���̶�� �ܾ ������ group_by( )�� ���

test %>% 
  group_by(CLASS) %>%
  summarise(
    C_mean_K_ = mean(KOREAN),
    C_med_K = median(KOREAN),
    C_sd_K = sd(KOREAN),
    C_student = n()
  )

# �ѱ���, ����, ���� ������ ���� ����� ����ϰ� �������� �����غ���.
test %>%
  group_by(ID, CLASS) %>%
  summarise(mean_KEM = mean(KOREAN,ENGLISH,MATH)) %>%
  arrange(mean_KEM)

# ���� ����� mean_KEM�̶�� ������ �ְ� �̸� "mean_KEM.csv"�� ������ ����.
mean_KEM <- test %>%
  group_by(ID, CLASS) %>%
  summarise(mean_KEM = mean(KOREAN,ENGLISH,MATH)) %>%
  arrange(mean_KEM)

write.csv(mean_KEM, "mean_KEM.csv")