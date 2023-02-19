###############################################################################
########                         Web Data Scraping                     ########
###############################################################################

####################################################
# Web Data Scraping

# �ʿ� ��Ű�� ��ġ �� �ҷ����� 
if(!require(devtools)) {install.packages("devtools"); library(devtools)} 
# if(!require(RSelenium)) {install.packages("RSelenium"); library(RSelenium)} 
if(!require(rvest)) {install.packages("rvest"); library(rvest)} 
if(!require(httr)) {install.packages("httr"); library(httr)} 
if(!require(stringr)) {install.packages("stringr"); library(stringr)} 
if(!require(dplyr)) {install.packages("dplyr"); library(dplyr)} 

################# õ�� ���� �̻��� �� ��ȭ�� �̿��� ���ô�.
# ����
# ��������
# �Ű��Բ�-�˿� ��
# ��������
# �����: �������
# �ܿ�ձ� 2
# �ƹ�Ÿ
# ���׶�
# ���ϵ�
# 7������ ����
# �˶��
# �ϻ�
# ����, ���� �� ����
# �Ű��Բ�-�ΰ� ��
# �ýÿ�����
# �±ر� �ֳ�����
# �λ���
# ��ȣ��
# �ؿ��
# �����: ���Ǵ�Ƽ ��
# �ǹ̵�
# ����
# ���� ����
# �����: ������ ���� ��Ʈ��
# �����
# ���ͽ��ڶ�
# �ܿ�ձ�
################ �ϳ��� ��ȭ�� ���� ���� �����͸� ��ũ���� �� ���ϴ�.
# https://movie.naver.com/movie/bi/mi/basic.nhn?code=93756 ������ ���� ������

# url ����
url1 <- 'https://movie.naver.com/movie/bi/mi/basic.nhn?code='
movie_code <- 93756
url <- paste(url1, movie_code, sep='')

html <- url %>%
  read_html()

# ��ȭ���� ��������
movie_title <- html %>%
  html_node("div.mv_info > h3.h_movie > a") %>% 
  html_text()
movie_title

# ������ �������
avg_score <- html %>%
  html_nodes("div.star_score") %>% 
  html_text()
avg_score <- gsub("(\\r|\\n|\\t)", "", avg_score) # �ٹٲ� ����, �� ����
avg_score
avg_score <- avg_score[1:3] # ù 3���� ����
avg_score
# avg_score <- str_sub(avg_score, -4, -1) 
avg_score <-substr(avg_score, nchar(avg_score)-3, nchar(avg_score)) # �� 4�� ���ڸ� ����
avg_score
avg_score <- as.numeric(avg_score)
avg_score

avg_viewer_score <- avg_score[1] # ������ �������
avg_reporter_score <- avg_score[2] # ���� ��а� �������
avg_netizen_score <- avg_score[3] # ��Ƽ�� �������

# ���ɴ뺰 �� ����
age_ratio <- html %>%
  html_nodes("strong.graph_percent") %>% 
  html_text()
age_ratio
age_ratio <- age_ratio[1:5]
age_ratio
age_ratio <-gsub("%", "", age_ratio)
age_ratio
age_ratio <- as.numeric(age_ratio)
age_ratio

# review ���� �����ɴϴ�.
review_count <- html %>%
  html_nodes("strong.total > em") %>% 
  html_text()
review_count
review_count <- as.numeric(gsub(",", "", review_count))
review_count

movie_summary <- c() # �ʱ�ȭ

# ������ ������ ����
movie_summary <- data.frame(movie_title = movie_title,
                            movie_code= movie_code, 
                            avg_viewer_score = avg_viewer_score,
                            avg_reporter_score = avg_reporter_score,
                            avg_netizen_score = avg_netizen_score,
                            age_ratio_10 = age_ratio[1], 
                            age_ratio_20 = age_ratio[2], 
                            age_ratio_30 = age_ratio[3], 
                            age_ratio_40 = age_ratio[4], 
                            age_ratio_50 = age_ratio[5],
                            review_count = review_count)

# �� ���� ������ ����?
num_page <- ceiling(review_count/10) # ���� ���� 10���� ������ �ø�
num_page
################# 

# url ����
url1 <- 'https://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code='
url2 <- '&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page='
movie_code <- 93756

##################################################################
# double ## is reserved for scraping multiple pages
single_movie_review_total <- c() # ���� ������ ��ũ���� ��� ��ħ
# page<-1

for (page in 1:num_page){
  url <- paste(url1, movie_code, url2, page, sep='')
  url
  html <- url %>%
    read_html()
  
  # review ���� �����ɴϴ�.
  review_count <- html %>%
    html_nodes("strong.total > em") %>% 
    html_text()
  review_count
  review_count <- as.numeric(gsub(",", "", review_count))
  review_count
  
  # ������ �����ɽô�.
  star_score <- html %>%
    html_nodes("div.star_score") %>% 
    html_text()
  star_score
  star_score <- gsub("(\\r|\\n|\\t)", "", star_score) # �ٹٲ� ����, �� ����
  star_score # �����̳׿�. ������ �ٲپ� ���ô�.
  star_score <- as.numeric(star_score)
  star_score 
  
  # ���� ������ ������ ���ô�.
  review_contnents <- html %>%
    html_nodes("div.score_reple > p") %>% # ���� element�� >�� ����
    html_text()
  review_contnents
  review_contnents <- gsub("(\\r|\\n|\\t)", "", review_contnents) # �ٹٲ� ����, �� ����
  review_contnents
  
  # �۾� �ð��� ������ ���ô�.
  review_time <- html %>%
    html_nodes("dl> dt > em:nth-child(2)") %>% 
    html_text()
  review_time
  review_time <- substr(review_time, 1, 10) # ��¥�� ������ �� ��¥�� ó�� 10�� ���ڸ� �߶� ���ô�.
  review_time
  
  # ����ۿ� ���� ���� ���� �����ɽô�.
  sympathy_count <- html %>%
    html_nodes("a._sympathyButton") %>% 
    html_text()
  sympathy_count
  sympathy_count <- gsub("(\\r|\\n|\\t)", "", sympathy_count) # �ٹٲ� ����, �� ����
  sympathy_count
  sympathy_count <- gsub("����", "", sympathy_count) # �ٹٲ� ����, �� ����
  sympathy_count
  sympathy_count <- as.numeric(sympathy_count) # ���ڷ� ��ȯ
  sympathy_count
  
  # ����ۿ� ���� ����� ���� �����ɽô�.
  unsympathy_count <- html %>%
    html_nodes("a._notSympathyButton") %>% 
    html_text()
  unsympathy_count
  unsympathy_count <- gsub("(\\r|\\n|\\t)", "", unsympathy_count) # �ٹٲ� ����, �� ����
  unsympathy_count
  unsympathy_count <- gsub("�����", "", unsympathy_count) # �ٹٲ� ����, �� ����
  unsympathy_count
  unsympathy_count <- as.numeric(unsympathy_count) # ���ڷ� ��ȯ
  unsympathy_count
  
  review_one_page <- data.frame(star_score=star_score, review_contnents=review_contnents, review_time=review_time, sympathy_count=sympathy_count, unsympathy_count=unsympathy_count )
  str(review_one_page)
  single_movie_review_total <- rbind(single_movie_review_total, review_one_page)
} # For loop ��
str(single_movie_review_total)
nrow(single_movie_review_total)

write.csv(single_movie_review_total, paste(movie_title, ".csv", sep=''))


############################################################################### 
# Text Mining # 
############################################################################### 

setwd("C:/data/") 

# JAVA ��ġ �� ����
# www.java.com �湮
# ������ �� �ý��� �� ���� �� �ý��� �� �ý��� �Ӽ� �� ���� �ý��� ������ ȯ�� ����(N) 
# �ý��� ������ JAVA_HOME �߰�, ���� C:\Program Files\Java\jrexxxxxx �߰�
# user�� ���� ����� ������ CLASSPATH �߰�, ���� C:\Program Files\Java\jrexxxxxx �߰�
# user�� ���� ����� ������ Path �߰�, ���� C:\Program Files\Java\jrexxxxxx �߰�

# RTools ��ġ
# https://cran.r-project.org/bin/windows/Rtools/ �湮 �� ��ġ

# RStudio ���� �� �ٽ� ����
if(!require("rlang")){install.packages("rlang"); library(rlang)} 
if(!require("tidyverse")){install.packages("tidyverse"); library(tidyverse)} 
if(!require("tidytext")){install.packages("tidytext"); library(tidytext)} 
if(!require("stringr")){install.packages("stringr"); library(stringr)} 
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)} 
if(!require("reshape2")){install.packages("reshape2"); library(reshape2)} 
if(!require("tm")){install.packages("tm"); library(tm)} 
if(!require("SnowballC")){install.packages("SnowballC"); library(SnowballC)} 
if(!require("multilinguer")){install.packages("multilinguer"); library(multilinguer)} 
if(!require("remotes")){install.packages("remotes"); library(remotes)} 
# if(!require("rJava")){install.packages("rJava"); library(rJava)} 
# rJava ��ġ�� �߰��� ���� : Sys.setenv("JAVA_HOME"='C:/Program Files/Java/jre1.8.0_291') 
# remove.packages("testthat") 
# install.packages("testthat") 

remotes::install_github('haven-jeon/KoNLP', force = TRUE, upgrade = "never", INSTALL_opts=c("--no-multiarch")) 
library(KoNLP) #���������� "KoNLP" ��Ű���� �ҷ��ɴϴ�

# ����ȭ ��������� �߰��� ��������� Ȱ���� ���ô�.
# ������ �ҷ��ɴϴ�.

useNIADic() # "NIADic" dic�� �ҷ��ɴϴ�. 121���� �ܾ����

text <- '�ϴ��� �Ķ��� ������ �Ͼ�� �ǹٶ��� �Ҿ�� ��Ǯ�� �� ���� �Ƹ��ٿ� ����' 
SimplePos09(text) 
SimplePos22(text) 

text <- read.csv("����.csv", header=TRUE) 

SimplePos09(text$review_contnents[1]) 

# �ٹٲ��� �������� �ٲپ� �� �ٷ� ����
?str_replace_all 
text$review_contnents <- str_replace_all(string=text$review_contnents, pattern="[\r\n]" , " ") 

text$review_contnents <- text$review_contnents %>% 
  str_replace_all("[^��-�R]", " ") %>% # �ѱ۸� �����
  str_squish() # ���� ���۰� ���� ���� ����, ���� ���� ����

text %>% 
  unnest_tokens(input = review_contnents, # ��ūȭ�� �ؽ�Ʈ
                output = word, # ��ū�� ���� ������
                token = "word", 
                drop=F) %>% # ��ūȭ �Լ�
  filter(str_count(word) > 1) %>% # �ѱ��� �̻� ����
  select(review_contnents, word)

my_text <- text %>% 
  unnest_tokens(input = review_contnents, # ��ūȭ�� �ؽ�Ʈ
                output = word, # ��ū�� ���� ������
                token = "words", 
                drop=F) %>% # ��ūȭ �Լ�
  filter(str_count(word) > 1) %>% # �ѱ��� �̻� ����
  select(review_contnents, word) 

# Ư�� �ܾ ���� ���� 10�� ����
my_text %>% 
  filter(str_detect(word, "�̼���")) %>% 
  select(review_contnents) %>% 
  head(10) 

# � �ܾ��� �󵵰� ������?
my_text %>% 
  group_by(word) %>% 
  summarise(n=n()) %>% 
  arrange(desc(n)) 

# �������� �б�
dic <- read.csv("knu_sentiment_lexicon.csv", fileEncoding = "UTF-8", header=TRUE) 

str(text) 
# ���� ������ �ܾ�����̹Ƿ� ������ �ܾ� �������� ��ūȭ �ʿ�
emotional_text <- text %>% 
  unnest_tokens(input = review_contnents, # ��ūȭ�� �ؽ�Ʈ
                output = word, # ��ū�� ���� ������
                token = "words", # �ܾ���� ��ūȭ
                drop=F) %>% # ��ūȭ �Լ�
  filter(str_count(word) > 1) %>% # �ѱ��� �̻� ����
  select(review_contnents, word) 

# dplyr::left_join() : word ���� ���� ���� ����
# ���� ������ ���� �ܾ� polarity NA �� 0 �ο�
emotional_text <- emotional_text %>% 
  left_join(dic, by = "word") %>% 
  mutate(polarity = ifelse(is.na(polarity), 0, polarity)) 
str(emotional_text) 

score_df <- emotional_text %>% 
  group_by(review_contnents) %>% 
  summarise(score = sum(polarity)) 
score_df

# ���� ���� ���� �ܾ� ���캸��
emotional_text <- emotional_text %>% 
  mutate(sentiment = ifelse(polarity == 2, "pos", 
                            ifelse(polarity == -2, "neg", "neu"))) 

# � ������ ���� ���Ǿ���?
emotional_text %>%
  count(sentiment)

# ���� �׷��� �����
top10_sentiment <- emotional_text %>% 
  filter(sentiment != "neu") %>% 
  count(sentiment, word) %>% 
  group_by(sentiment) %>% 
  slice_max(n, n = 10) 
top10_sentiment 

ggplot(top10_sentiment, aes(x = reorder(word, n), 
                            y = n, 
                            fill = sentiment)) + 
  geom_col() + 
  coord_flip() + 
  geom_text(aes(label = n), hjust = -0.3) + 
  facet_wrap(~ sentiment, scales = "free") + 
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.15))) + 
  labs(x = NULL) + 
  theme(text = element_text(family = "nanumgothic"))

# ���� ���
score_df %>%
  arrange(desc(score)) 

# ���� ���
score_df %>% 
  arrange(score) 

############### �ǹ̿���� �����
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)} 
if(!require("stringr")){install.packages("stringr"); library(stringr)} 
if(!require("textclean")){install.packages("textclean"); library(textclean)} 
if(!require("KoNLP")){install.packages("KoNLP"); library(KoNLP)} 
if(!require("readr")){install.packages("readr"); library(readr)} 
if(!require("tidytext")){install.packages("tidytext"); library(tidytext)} 


# ����� ��� ��� �ҷ�����
raw_news_comment <- read_csv("news_comment_parasite.csv")
str(raw_news_comment)

news_comment <- raw_news_comment %>%
  select(reply) %>%
  mutate(reply = str_replace_all(reply, "[^��-�R]", " "), # �ѱ� �ܴ̿� ��ĭ
         reply = str_squish(reply), # ���Ӱ��� ����, ���� ó��, �� ���� ����
         id = row_number()) # �ึ�� ��ȣ �߰�

comment_pos <- news_comment %>%
  unnest_tokens(input = reply,
                output = word,
                token = SimplePos22,
                drop = F)

comment_pos %>% 
  select(word, reply)

# -------------------------------------------------------------------------
# ǰ�纰�� �� �и�
if(!require("tidyr")){install.packages("tidyr"); library(tidyr)} 

comment_pos <- comment_pos %>%
  separate_rows(word, sep = "[+]")

comment_pos %>% 
  select(word, reply)

# -------------------------------------------------------------------------
# ���� �����ϱ�
noun <- comment_pos %>%
  filter(str_detect(word, "/n")) %>%
  mutate(word = str_remove(word, "/.*$"))

noun %>%
  select(word, reply)

# -------------------------------------------------------------------------
noun %>%
  count(word, sort = T)

# -------------------------------------------------------------------------
# ����, ����� �����ϱ�
pvpa <- comment_pos %>%
  filter(str_detect(word, "/pv|/pa")) %>%         # "/pv", "/pa" ����
  mutate(word = str_replace(word, "/.*$", "��"))  # "/"�� ���� ���ڸ� "��"�� �ٲٱ�

pvpa %>%
  select(word, reply)

# -------------------------------------------------------------------------
pvpa %>%
  count(word, sort = T)

# -------------------------------------------------------------------------
# ǰ�� ����
comment <- bind_rows(noun, pvpa) %>%
  filter(str_count(word) >= 2) %>%
  arrange(id)

comment %>%
  select(word, reply)

# -------------------------------------------------------------------------
# �ڵ带 ��Ƽ�
comment_new <- comment_pos %>%
  separate_rows(word, sep = "[+]") %>%
  filter(str_detect(word, "/n|/pv|/pa")) %>%
  mutate(word = ifelse(str_detect(word, "/pv|/pa"),
                       str_replace(word, "/.*$", "��"),
                       str_remove(word, "/.*$"))) %>%
  filter(str_count(word) >= 2) %>%
  arrange(id)


# -------------------------------------------------------------------------
if(!require("widyr")){install.packages("widyr"); library(widyr)} 

pair <- comment %>%
  pairwise_count(item = word,
                 feature = id,
                 sort = T)
pair

# -------------------------------------------------------------------------
pair %>% filter(item1 == "��ȭ")

pair %>% filter(item1 == "����ȣ")


# 05-2 --------------------------------------------------------------------
if(!require("tidygraph")){install.packages("tidygraph"); library(tidygraph)} 

graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph()

graph_comment


# -------------------------------------------------------------------------
if(!require("ggraph")){install.packages("ggraph"); library(ggraph)} 

ggraph(graph_comment) +
  geom_edge_link() +                 # ����
  geom_node_point() +                # ���
  geom_node_text(aes(label = name))  # �ؽ�Ʈ

# -------------------------------------------------------------------------
if(!require("showtext")){install.packages("showtext"); library(showtext)} 

font_add_google(name = "Nanum Gothic", family = "nanumgothic")
showtext_auto()

# -------------------------------------------------------------------------
set.seed(1234)                              # ���� ����
ggraph(graph_comment, layout = "fr") +      # ���̾ƿ�
  geom_edge_link(color = "gray50",          # ���� ����
                 alpha = 0.5) +             # ���� ����
  geom_node_point(color = "lightcoral",     # ��� ����
                  size = 5) +               # ��� ũ��
  geom_node_text(aes(label = name),         # �ؽ�Ʈ ǥ��
                 repel = T,                 # ���� ǥ��
                 size = 5,                  # �ؽ�Ʈ ũ��
                 family = "nanumgothic") +  # ��Ʈ
  theme_graph()                             # ��� ����


# -------------------------------------------------------------------------
# �Լ��� ����� ����� ���ô�.
word_network <- function(x) {
  ggraph(x, layout = "fr") +
    geom_edge_link(color = "gray50",
                   alpha = 0.5) +
    geom_node_point(color = "lightcoral",
                    size = 5) +
    geom_node_text(aes(label = name),
                   repel = T,
                   size = 5,
                   family = "nanumgothic") +
    theme_graph()
}

# -------------------------------------------------------------------------
set.seed(1234)
word_network(graph_comment)

# -------------------------------------------------------------------------
# ���Ǿ� ó���ϱ�
comment <- comment %>%
  mutate(word = ifelse(str_detect(word, "����") &
                         !str_detect(word, "������"), "����ȣ", word), 
         word = ifelse(word == "������", "�ø���", word),
         word = ifelse(str_detect(word, "����"), "����", word))

# �ܾ� ���� ���� �� ���ϱ�
pair <- comment %>%
  pairwise_count(item = word,
                 feature = id,
                 sort = T)

# ��Ʈ��ũ �׷��� ������ �����
graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph()

# ��Ʈ��ũ �׷��� �����
set.seed(1234)
word_network(graph_comment)

# -------------------------------------------------------------------------
# �����߽ɼ��� ����ϰ� �������� ������ ���ô�.
set.seed(1234)
graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph(directed = F) %>%
  mutate(centrality = centrality_degree(),        # ���� �߽ɼ�
         group = as.factor(group_infomap()))      # Ŀ�´�Ƽ

graph_comment

# -------------------------------------------------------------------------
set.seed(1234)
ggraph(graph_comment, layout = "fr") +      # ���̾ƿ�
  geom_edge_link(color = "gray50",          # ���� ����
                 alpha = 0.5) +             # ���� ����
  geom_node_point(aes(size = centrality,    # ��� ũ��
                      color = group),       # ��� ����
                  show.legend = F) +        # ���� ����
  scale_size(range = c(5, 15)) +            # ��� ũ�� ����
  geom_node_text(aes(label = name),         # �ؽ�Ʈ ǥ��
                 repel = T,                 # ���� ǥ��
                 size = 5,                  # �ؽ�Ʈ ũ��
                 family = "nanumgothic") +  # ��Ʈ
  theme_graph()                             # ��� ����

# -------------------------------------------------------------------------
graph_comment %>%
  filter(name == "����ȣ")

# -------------------------------------------------------------------------
graph_comment %>%
  filter(group == 4) %>%
  arrange(-centrality) %>%
  data.frame()

graph_comment %>%
  arrange(-centrality)

# -------------------------------------------------------------------------
graph_comment %>%
  filter(group == 2) %>%
  arrange(-centrality) %>%
  data.frame()

# -------------------------------------------------------------------------
# �ܾ ���� ������ �Բ� �����ϱ�
news_comment %>%
  filter(str_detect(reply, "����ȣ") & str_detect(reply, "���")) %>%
  select(reply)

news_comment %>%
  filter(str_detect(reply, "�ڱ���") & str_detect(reply, "��������Ʈ")) %>%
  select(reply)

news_comment %>%
  filter(str_detect(reply, "�����") & str_detect(reply, "����")) %>%
  select(reply)

# --------------------------------------------------------------------
# ���̰���� �ܾ ������� �м�
word_cors <- comment %>%
  add_count(word) %>%
  filter(n >= 20) %>%
  pairwise_cor(item = word,
               feature = id,
               sort = T)

word_cors

# -------------------------------------------------------------------------
word_cors %>% 
  filter(item1 == "���ѹα�")

word_cors %>% 
  filter(item1 == "����")

# -------------------------------------------------------------------------
# ���� �ܾ� ��� ����
target <- c("���ѹα�", "����", "����Ұ�", "����", "�ڱ���", "��������Ʈ")

top_cors <- word_cors %>%
  filter(item1 %in% target) %>%
  group_by(item1) %>%
  slice_max(correlation, n = 8)

# -------------------------------------------------------------------------
# Ű���庰�� ���̰���� ���� �ܾ� �׸���
if(!require("ggplot2")){install.packages("ggplot2"); library(ggplot2)} 

# �׷��� ���� ���ϱ�
top_cors$item1 <- factor(top_cors$item1, levels = target)

ggplot(top_cors, aes(x = reorder_within(item2, correlation, item1),
                     y = correlation,
                     fill = item1)) +
  geom_col(show.legend = F) +
  facet_wrap(~ item1, scales = "free") +
  coord_flip() +
  scale_x_reordered() +
  labs(x = NULL) +
  theme(text = element_text(family = "nanumgothic"))


# -------------------------------------------------------------------------
set.seed(1234)
graph_cors <- word_cors %>%
  filter(correlation >= 0.15) %>%
  as_tbl_graph(directed = F) %>%
  mutate(centrality = centrality_degree(),
         group = as.factor(group_infomap()))

# -------------------------------------------------------------------------
set.seed(1234)
ggraph(graph_cors, layout = "fr") +
  geom_edge_link(color = "gray50",
                 aes(edge_alpha = correlation,   # ���� ����
                     edge_width = correlation),  # ���� �β�
                 show.legend = F) +              # ���� ����
  scale_edge_width(range = c(1, 4)) +            # ���� �β� ����
  geom_node_point(aes(size = centrality,
                      color = group),
                  show.legend = F) +
  scale_size(range = c(5, 10)) +
  geom_node_text(aes(label = name),
                 repel = T,
                 size = 5,
                 family = "nanumgothic") +
  theme_graph()