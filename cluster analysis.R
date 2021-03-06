
library('cluster')
install.packages('stringr')
library('stringr')
install.packages('tm', dependencies = TRUE)
library('tm')
install.packages('wordcloud')
library('wordcloud')
require(graphics)
require(ggplot2)
install.packages("dendextend")
install.packages("dendextendRcpp")
library("dendextend")
library("dendextendRcpp")

setwd("~/ADAProject")
emailbody <- Corpus(DirSource('~/ADAProject/top10Emails'))
#emailbody consists of 10 txt files 
#each txt file is read as a list where the first item of the list
#contains all email text of a certain account

#inspect a particular document
writeLines(as.character(emailbody[[2]][[1]][1]))
mode(emailbody)


###TEXT TRANSFORMATION######
#Transform to lower case
emailbody <- tm_map(emailbody,content_transformer(tolower))
#remove problematic symbols
toSpace <- content_transformer(function(x, pattern) 
  { return (gsub(pattern, '', x))})
emailbody <- tm_map(emailbody, toSpace, '-')
emailbody <- tm_map(emailbody, toSpace, ':')
emailbody <- tm_map(emailbody, toSpace, ' " ')
emailbody <- tm_map(emailbody, removePunctuation)
emailbody <- tm_map(emailbody, removeNumbers)

#remove stop words
emailbody <- tm_map(emailbody, removeWords, stopwords('english'))
stopw <- c('date','can', 'me', 'one','you','and','said','pm','am',
           'is','are','http','unclassifi', 'unclassified', 'doc',
           'huma','cheryl', 'mills','abedin','may','sullivan',
           'millscdstategov','abedinhstategov', 'hroddintonemailcom',
           'case','sent', 'message','original','part',
           'state','subject','department','dept','also','will',
           '�???"', 'jacob')
emailbody<- tm_map(emailbody, removeWords, stopw)  
emailbody <- tm_map(emailbody, stripWhitespace)

#inspect certain text 
emailbody[[10]][[1]]
writeLines(as.character(emailbody[[10]][[1]]))


for (i in 1:10){
  print(length(emailbody[[i]][[1]]))
}


#convert all documents into a Document-term matrix
dtmat <- DocumentTermMatrix(emailbody)

###CLUSTERING#################
mat <- as.matrix(dtmat)
rownames(mat)<-top10names
mat<-mat[,-c(2:54)]
write.csv(mat,file='top10DTM.csv')
dim(mat)
# 10 20792
#compute distance between document vectors
top10dist <- dist(mat)

#hierarchical clustering using WARD.D method
top10clusters <- hclust(top10dist,method='ward.D')
par(mar=c(5, 3, 5, 13))

top10clusters %>% color_labels(k=3) %>% 
  plot(horiz=TRUE,xlab = "Height", 
       main='Top 10 receivers Cluster Dendrogram')

#k-means
#determining the optimum k
wss <- 1:9
for (i in 1:9) {wss[i] <- sum(kmeans(top10dist,center=i)$withinss)}
par(mar=c(7, 5, 5, 3))
plot(1:9, wss[1:9], type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

#plot the clusters
par(mfrow=c(1,1), mar=c(7, 5, 5, 3))
kfit <- kmeans(top10dist, 2)
clusplot(as.matrix(top10dist), kfit$cluster, color=T, 
         shade=T, labels=3, lines=0, cex=0.7, main='cluster plot')
kfit <- kmeans(top10dist, 3)
clusplot(as.matrix(top10dist), kfit$cluster, color=T, 
         shade=T, labels=3, lines=0, cex=0.7, main='cluster plot')


#TEXT FREUQUENCY####
dind<-list(c(5, 10),c(2, 6,9), c(1,3,4,7,8) )

f<-c(100,100,100)
for (i in 1:3)
  {
freq <- sort(colSums(as.matrix(dtmat[dind[[i]],])), decreasing=TRUE)   
wordfreq <- data.frame(word=names(freq), freq=freq)   

plotfreq <- ggplot(subset(wordfreq, freq>f[i]), aes(word, freq))    
plotfreq <- plotfreq + geom_bar(stat="identity")   
plotfreq <- plotfreq + theme(axis.text.x=element_text(angle=45, hjust=1))   
print(plotfreq )

}

#word cloud
freqwc = data.frame(sort(colSums(as.matrix(dtmat)), decreasing=TRUE))
wordcloud(rownames(freqwc), freqwc[,1], max.words=100, 
          colors=brewer.pal(1, "Dark2"))

