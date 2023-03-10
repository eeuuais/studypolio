###############################################################################
########                         Web Data Scraping                     ########
###############################################################################

####################################################
# Web Data Scraping

# 필요 패키지 설치 및 불러오기 
if(!require(devtools)) {install.packages("devtools"); library(devtools)} 
# if(!require(RSelenium)) {install.packages("RSelenium"); library(RSelenium)} 
if(!require(rvest)) {install.packages("rvest"); library(rvest)} 
if(!require(httr)) {install.packages("httr"); library(httr)} 
if(!require(stringr)) {install.packages("stringr"); library(stringr)} 
if(!require(dplyr)) {install.packages("dplyr"); library(dplyr)} 

################# 천만 관객 이상이 본 영화만 이용해 봅시다.
# 명량
# 극한직업
# 신과함께-죄와 벌
# 국제시장
# 어벤져스: 엔드게임
# 겨울왕국 2
# 아바타
# 베테랑
# 도둑들
# 7번방의 선물
# 알라딘
# 암살
# 광해, 왕이 된 남자
# 신과함께-인과 연
# 택시운전사
# 태극기 휘날리며
# 부산행
# 변호인
# 해운대
# 어벤져스: 인피니티 워
# 실미도
# 괴물
# 왕의 남자
# 어벤져스: 에이지 오브 울트론
# 기생충
# 인터스텔라
# 겨울왕국
################ 하나의 영화에 대한 개요 데이터를 스크래핑 해 봅니다.
# https://movie.naver.com/movie/bi/mi/basic.nhn?code=93756 명량의 개요 페이지

# url 생성
url1 <- 'https://movie.naver.com/movie/bi/mi/basic.nhn?code='
movie_code <- 93756
url <- paste(url1, movie_code, sep='')

html <- url %>%
  read_html()

# 영화제목 가져오기
movie_title <- html %>%
  html_node("div.mv_info > h3.h_movie > a") %>% 
  html_text()
movie_title

# 관람객 평점평균
avg_score <- html %>%
  html_nodes("div.star_score") %>% 
  html_text()
avg_score <- gsub("(\\r|\\n|\\t)", "", avg_score) # 줄바꿈 문자, 탭 제거
avg_score
avg_score <- avg_score[1:3] # 첫 3개만 추출
avg_score
# avg_score <- str_sub(avg_score, -4, -1) 
avg_score <-substr(avg_score, nchar(avg_score)-3, nchar(avg_score)) # 끝 4개 글자만 추출
avg_score
avg_score <- as.numeric(avg_score)
avg_score

avg_viewer_score <- avg_score[1] # 관람객 평점평균
avg_reporter_score <- avg_score[2] # 기자 평론가 평점평균
avg_netizen_score <- avg_score[3] # 네티즌 평점평균

# 연령대별 평가 비율
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

# review 수를 가져옵니다.
review_count <- html %>%
  html_nodes("strong.total > em") %>% 
  html_text()
review_count
review_count <- as.numeric(gsub(",", "", review_count))
review_count

movie_summary <- c() # 초기화

# 데이터 프레임 생성
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

# 총 리뷰 페이지 수는?
num_page <- ceiling(review_count/10) # 리뷰 수를 10으로 나누어 올림
num_page
################# 

# url 생성
url1 <- 'https://movie.naver.com/movie/bi/mi/pointWriteFormList.nhn?code='
url2 <- '&type=after&isActualPointWriteExecute=false&isMileageSubscriptionAlready=false&isMileageSubscriptionReject=false&page='
movie_code <- 93756

##################################################################
# double ## is reserved for scraping multiple pages
single_movie_review_total <- c() # 여러 페이지 스크래핑 결과 합침
# page<-1

for (page in 1:num_page){
  url <- paste(url1, movie_code, url2, page, sep='')
  url
  html <- url %>%
    read_html()
  
  # review 수를 가져옵니다.
  review_count <- html %>%
    html_nodes("strong.total > em") %>% 
    html_text()
  review_count
  review_count <- as.numeric(gsub(",", "", review_count))
  review_count
  
  # 평점을 가져옵시다.
  star_score <- html %>%
    html_nodes("div.star_score") %>% 
    html_text()
  star_score
  star_score <- gsub("(\\r|\\n|\\t)", "", star_score) # 줄바꿈 문자, 탭 제거
  star_score # 문자이네요. 숫ㅈ로 바꾸어 봅시다.
  star_score <- as.numeric(star_score)
  star_score 
  
  # 리뷰 본문을 가져와 봅시다.
  review_contnents <- html %>%
    html_nodes("div.score_reple > p") %>% # 하위 element는 >로 연결
    html_text()
  review_contnents
  review_contnents <- gsub("(\\r|\\n|\\t)", "", review_contnents) # 줄바꿈 문자, 탭 제거
  review_contnents
  
  # 글쓴 시간을 가져와 봅시다.
  review_time <- html %>%
    html_nodes("dl> dt > em:nth-child(2)") %>% 
    html_text()
  review_time
  review_time <- substr(review_time, 1, 10) # 날짜만 나오게 각 날짜의 처음 10개 문자만 잘라 봅시다.
  review_time
  
  # 리뷰글에 대한 공감 수를 가져옵시다.
  sympathy_count <- html %>%
    html_nodes("a._sympathyButton") %>% 
    html_text()
  sympathy_count
  sympathy_count <- gsub("(\\r|\\n|\\t)", "", sympathy_count) # 줄바꿈 문자, 탭 제거
  sympathy_count
  sympathy_count <- gsub("공감", "", sympathy_count) # 줄바꿈 문자, 탭 제거
  sympathy_count
  sympathy_count <- as.numeric(sympathy_count) # 숫자로 변환
  sympathy_count
  
  # 리뷰글에 대한 비공감 수를 가져옵시다.
  unsympathy_count <- html %>%
    html_nodes("a._notSympathyButton") %>% 
    html_text()
  unsympathy_count
  unsympathy_count <- gsub("(\\r|\\n|\\t)", "", unsympathy_count) # 줄바꿈 문자, 탭 제거
  unsympathy_count
  unsympathy_count <- gsub("비공감", "", unsympathy_count) # 줄바꿈 문자, 탭 제거
  unsympathy_count
  unsympathy_count <- as.numeric(unsympathy_count) # 숫자로 변환
  unsympathy_count
  
  review_one_page <- data.frame(star_score=star_score, review_contnents=review_contnents, review_time=review_time, sympathy_count=sympathy_count, unsympathy_count=unsympathy_count )
  str(review_one_page)
  single_movie_review_total <- rbind(single_movie_review_total, review_one_page)
} # For loop 끝
str(single_movie_review_total)
nrow(single_movie_review_total)

write.csv(single_movie_review_total, paste(movie_title, ".csv", sep=''))


############################################################################### 
# Text Mining # 
############################################################################### 

setwd("C:/data/") 

# JAVA 설치 및 설정
# www.java.com 방문
# 제어판 → 시스템 및 보안 → 시스템 → 시스템 속성 → 고급 시스템 설정→ 환경 변수(N) 
# 시스템 변수에 JAVA_HOME 추가, 값에 C:\Program Files\Java\jrexxxxxx 추가
# user에 대한 사용자 변수에 CLASSPATH 추가, 값에 C:\Program Files\Java\jrexxxxxx 추가
# user에 대한 사용자 변수에 Path 추가, 값에 C:\Program Files\Java\jrexxxxxx 추가

# RTools 설치
# https://cran.r-project.org/bin/windows/Rtools/ 방문 후 설치

# RStudio 종료 후 다시 실행
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
# rJava 설치시 추가로 설정 : Sys.setenv("JAVA_HOME"='C:/Program Files/Java/jre1.8.0_291') 
# remove.packages("testthat") 
# install.packages("testthat") 

remotes::install_github('haven-jeon/KoNLP', force = TRUE, upgrade = "never", INSTALL_opts=c("--no-multiarch")) 
library(KoNLP) #최종적으로 "KoNLP" 패키지를 불러옵니다

# 정보화 진흥원에서 추가한 명사사전을 활용해 봅시다.
# 사전을 불러옵니다.

useNIADic() # "NIADic" dic을 불러옵니다. 121만개 단어사전

text <- '하늘은 파랗게 구름은 하얗게 실바람도 불어봐 부풀은 내 마음 아름다운 강산' 
SimplePos09(text) 
SimplePos22(text) 

text <- read.csv("명량.csv", header=TRUE) 

SimplePos09(text$review_contnents[1]) 

# 줄바꿈을 공백으로 바꾸어 한 줄로 만듦
?str_replace_all 
text$review_contnents <- str_replace_all(string=text$review_contnents, pattern="[\r\n]" , " ") 

text$review_contnents <- text$review_contnents %>% 
  str_replace_all("[^가-힣]", " ") %>% # 한글만 남기기
  str_squish() # 문자 시작과 끝의 공백 제거, 연속 공백 제거

text %>% 
  unnest_tokens(input = review_contnents, # 토큰화할 텍스트
                output = word, # 토큰을 담을 변수명
                token = "word", 
                drop=F) %>% # 토큰화 함수
  filter(str_count(word) > 1) %>% # 한글자 이상만 추출
  select(review_contnents, word)

my_text <- text %>% 
  unnest_tokens(input = review_contnents, # 토큰화할 텍스트
                output = word, # 토큰을 담을 변수명
                token = "words", 
                drop=F) %>% # 토큰화 함수
  filter(str_count(word) > 1) %>% # 한글자 이상만 추출
  select(review_contnents, word) 

# 특정 단어가 사용된 문장 10개 추출
my_text %>% 
  filter(str_detect(word, "이순신")) %>% 
  select(review_contnents) %>% 
  head(10) 

# 어떤 단어의 빈도가 높은가?
my_text %>% 
  group_by(word) %>% 
  summarise(n=n()) %>% 
  arrange(desc(n)) 

# 감정사전 읽기
dic <- read.csv("knu_sentiment_lexicon.csv", fileEncoding = "UTF-8", header=TRUE) 

str(text) 
# 감정 사전은 단어기준이므로 원문을 단어 기준으로 토큰화 필요
emotional_text <- text %>% 
  unnest_tokens(input = review_contnents, # 토큰화할 텍스트
                output = word, # 토큰을 담을 변수명
                token = "words", # 단어기준 토큰화
                drop=F) %>% # 토큰화 함수
  filter(str_count(word) > 1) %>% # 한글자 이상만 추출
  select(review_contnents, word) 

# dplyr::left_join() : word 기준 감정 사전 결합
# 감정 사전에 없는 단어 polarity NA → 0 부여
emotional_text <- emotional_text %>% 
  left_join(dic, by = "word") %>% 
  mutate(polarity = ifelse(is.na(polarity), 0, polarity)) 
str(emotional_text) 

score_df <- emotional_text %>% 
  group_by(review_contnents) %>% 
  summarise(score = sum(polarity)) 
score_df

# 자주 사용된 감정 단어 살펴보기
emotional_text <- emotional_text %>% 
  mutate(sentiment = ifelse(polarity == 2, "pos", 
                            ifelse(polarity == -2, "neg", "neu"))) 

# 어떤 감정이 많이 사용되었나?
emotional_text %>%
  count(sentiment)

# 막대 그래프 만들기
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

# 긍정 댓글
score_df %>%
  arrange(desc(score)) 

# 부정 댓글
score_df %>% 
  arrange(score) 

############### 의미연결망 만들기
if(!require("dplyr")){install.packages("dplyr"); library(dplyr)} 
if(!require("stringr")){install.packages("stringr"); library(stringr)} 
if(!require("textclean")){install.packages("textclean"); library(textclean)} 
if(!require("KoNLP")){install.packages("KoNLP"); library(KoNLP)} 
if(!require("readr")){install.packages("readr"); library(readr)} 
if(!require("tidytext")){install.packages("tidytext"); library(tidytext)} 


# 기생충 기사 댓글 불러오기
raw_news_comment <- read_csv("news_comment_parasite.csv")
str(raw_news_comment)

news_comment <- raw_news_comment %>%
  select(reply) %>%
  mutate(reply = str_replace_all(reply, "[^가-힣]", " "), # 한글 이외는 빈칸
         reply = str_squish(reply), # 연속공백 제거, 문장 처음, 끝 공백 제거
         id = row_number()) # 행마다 번호 추가

comment_pos <- news_comment %>%
  unnest_tokens(input = reply,
                output = word,
                token = SimplePos22,
                drop = F)

comment_pos %>% 
  select(word, reply)

# -------------------------------------------------------------------------
# 품사별로 행 분리
if(!require("tidyr")){install.packages("tidyr"); library(tidyr)} 

comment_pos <- comment_pos %>%
  separate_rows(word, sep = "[+]")

comment_pos %>% 
  select(word, reply)

# -------------------------------------------------------------------------
# 명사 추출하기
noun <- comment_pos %>%
  filter(str_detect(word, "/n")) %>%
  mutate(word = str_remove(word, "/.*$"))

noun %>%
  select(word, reply)

# -------------------------------------------------------------------------
noun %>%
  count(word, sort = T)

# -------------------------------------------------------------------------
# 동사, 형용사 추출하기
pvpa <- comment_pos %>%
  filter(str_detect(word, "/pv|/pa")) %>%         # "/pv", "/pa" 추출
  mutate(word = str_replace(word, "/.*$", "다"))  # "/"로 시작 문자를 "다"로 바꾸기

pvpa %>%
  select(word, reply)

# -------------------------------------------------------------------------
pvpa %>%
  count(word, sort = T)

# -------------------------------------------------------------------------
# 품사 결합
comment <- bind_rows(noun, pvpa) %>%
  filter(str_count(word) >= 2) %>%
  arrange(id)

comment %>%
  select(word, reply)

# -------------------------------------------------------------------------
# 코드를 모아서
comment_new <- comment_pos %>%
  separate_rows(word, sep = "[+]") %>%
  filter(str_detect(word, "/n|/pv|/pa")) %>%
  mutate(word = ifelse(str_detect(word, "/pv|/pa"),
                       str_replace(word, "/.*$", "다"),
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
pair %>% filter(item1 == "영화")

pair %>% filter(item1 == "봉준호")


# 05-2 --------------------------------------------------------------------
if(!require("tidygraph")){install.packages("tidygraph"); library(tidygraph)} 

graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph()

graph_comment


# -------------------------------------------------------------------------
if(!require("ggraph")){install.packages("ggraph"); library(ggraph)} 

ggraph(graph_comment) +
  geom_edge_link() +                 # 엣지
  geom_node_point() +                # 노드
  geom_node_text(aes(label = name))  # 텍스트

# -------------------------------------------------------------------------
if(!require("showtext")){install.packages("showtext"); library(showtext)} 

font_add_google(name = "Nanum Gothic", family = "nanumgothic")
showtext_auto()

# -------------------------------------------------------------------------
set.seed(1234)                              # 난수 고정
ggraph(graph_comment, layout = "fr") +      # 레이아웃
  geom_edge_link(color = "gray50",          # 엣지 색깔
                 alpha = 0.5) +             # 엣지 명암
  geom_node_point(color = "lightcoral",     # 노드 색깔
                  size = 5) +               # 노드 크기
  geom_node_text(aes(label = name),         # 텍스트 표시
                 repel = T,                 # 노드밖 표시
                 size = 5,                  # 텍스트 크기
                 family = "nanumgothic") +  # 폰트
  theme_graph()                             # 배경 삭제


# -------------------------------------------------------------------------
# 함수로 만들어 사용해 봅시다.
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
# 유의어 처리하기
comment <- comment %>%
  mutate(word = ifelse(str_detect(word, "감독") &
                         !str_detect(word, "감독상"), "봉준호", word), 
         word = ifelse(word == "오르다", "올리다", word),
         word = ifelse(str_detect(word, "축하"), "축하", word))

# 단어 동시 출현 빈도 구하기
pair <- comment %>%
  pairwise_count(item = word,
                 feature = id,
                 sort = T)

# 네트워크 그래프 데이터 만들기
graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph()

# 네트워크 그래프 만들기
set.seed(1234)
word_network(graph_comment)

# -------------------------------------------------------------------------
# 연결중심성을 계산하고 집단으로 구분해 봅시다.
set.seed(1234)
graph_comment <- pair %>%
  filter(n >= 25) %>%
  as_tbl_graph(directed = F) %>%
  mutate(centrality = centrality_degree(),        # 연결 중심성
         group = as.factor(group_infomap()))      # 커뮤니티

graph_comment

# -------------------------------------------------------------------------
set.seed(1234)
ggraph(graph_comment, layout = "fr") +      # 레이아웃
  geom_edge_link(color = "gray50",          # 엣지 색깔
                 alpha = 0.5) +             # 엣지 명암
  geom_node_point(aes(size = centrality,    # 노드 크기
                      color = group),       # 노드 색깔
                  show.legend = F) +        # 범례 삭제
  scale_size(range = c(5, 15)) +            # 노드 크기 범위
  geom_node_text(aes(label = name),         # 텍스트 표시
                 repel = T,                 # 노드밖 표시
                 size = 5,                  # 텍스트 크기
                 family = "nanumgothic") +  # 폰트
  theme_graph()                             # 배경 삭제

# -------------------------------------------------------------------------
graph_comment %>%
  filter(name == "봉준호")

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
# 단어가 사용된 원문과 함께 이해하기
news_comment %>%
  filter(str_detect(reply, "봉준호") & str_detect(reply, "대박")) %>%
  select(reply)

news_comment %>%
  filter(str_detect(reply, "박근혜") & str_detect(reply, "블랙리스트")) %>%
  select(reply)

news_comment %>%
  filter(str_detect(reply, "기생충") & str_detect(reply, "조국")) %>%
  select(reply)

# --------------------------------------------------------------------
# 파이계수로 단어간 상관관계 분석
word_cors <- comment %>%
  add_count(word) %>%
  filter(n >= 20) %>%
  pairwise_cor(item = word,
               feature = id,
               sort = T)

word_cors

# -------------------------------------------------------------------------
word_cors %>% 
  filter(item1 == "대한민국")

word_cors %>% 
  filter(item1 == "역사")

# -------------------------------------------------------------------------
# 관심 단어 목록 생성
target <- c("대한민국", "역사", "수상소감", "조국", "박근혜", "블랙리스트")

top_cors <- word_cors %>%
  filter(item1 %in% target) %>%
  group_by(item1) %>%
  slice_max(correlation, n = 8)

# -------------------------------------------------------------------------
# 키워드별로 파이계수가 높은 단어 그리기
if(!require("ggplot2")){install.packages("ggplot2"); library(ggplot2)} 

# 그래프 순서 정하기
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
                 aes(edge_alpha = correlation,   # 엣지 명암
                     edge_width = correlation),  # 엣지 두께
                 show.legend = F) +              # 범례 삭제
  scale_edge_width(range = c(1, 4)) +            # 엣지 두께 범위
  geom_node_point(aes(size = centrality,
                      color = group),
                  show.legend = F) +
  scale_size(range = c(5, 10)) +
  geom_node_text(aes(label = name),
                 repel = T,
                 size = 5,
                 family = "nanumgothic") +
  theme_graph()