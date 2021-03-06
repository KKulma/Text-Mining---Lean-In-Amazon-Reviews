
# installing and loading packages
pack=c("rvest", "SnowballC", "tm", "wordcloud")
install.packages(pack)
lapply(pack, require, character.only = TRUE)


# scraping amazon website
LeanIn="http://www.amazon.co.uk/product-reviews/0753541645/ref=cm_cr_dp_see_all_summary?ie=UTF8&showViewpoints=1&sortBy=helpful"
html=read_html(LeanIn)
reviews=html_nodes(html, ".a-size-base") # css pattern defined using SelectorGadget (Chrome)
text=html_text(reviews)
string=paste(text, collapse = " ")

string=gsub("\\.+", ". ", string) #not-interpreted "."
string=gsub("\\,", ", ", string)
string=gsub("\\-", "- ", string)
string=gsub("\\:", ": ", string)
string=gsub("\\?", "? ", string)
string=gsub("\\!", "! ", string)
string

Lpath=file.path("~", "MEGA", "data-science", "MyProjects", "TextMining", "LeanInRev")
write.table(string, "~/MEGA/data-science/MyProjects/TextMining/LeanInRev/RevText.txt", sep="/t")

corpus=Corpus(DirSource(Lpath))
corpus[[1]]$content


## remove punctuation
corpus = tm_map(corpus, removePunctuation)

## remove numbers
corpus = tm_map(corpus, removeNumbers)

## LowerCase
corpus = tm_map(corpus, tolower)
corpus$content


## remove stopwords and other words
myWords=c("just", "sheryl", "sandberg",  "review", "comment", "comments", "also", "many", "much", "amazon", "will")
corpus <- tm_map(corpus, removeWords, c(stopwords("english"), myWords)) 


## stemming
corpus <- tm_map(corpus, stemDocument) 
corpus$content

# remove white spaces after stemming
corpus <- tm_map(corpus, stripWhitespace) 

# treat pre-processed documents as text documents
corpus <- tm_map(corpus, PlainTextDocument) 

#turning into doc matrix
dtm <- DocumentTermMatrix(corpus)
dtm
inspect(dtm)


# displaying most frequent words
freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)   
head(freq, 20)  


## wordcloud

pal=brewer.pal(10, "Set1")

set.seed(100)
wordcloud(words = names(freq), freq = freq, max.words=50,
          random.order=FALSE,
          colors=pal)

png("LeanInWordcloud.png")
wordcloud(words = names(freq), freq = freq, max.words=50,
          random.order=FALSE,
          colors=pal)
dev.off()
