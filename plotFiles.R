# Plot Files from other under index directory
#
library("dplyr")
library("ggplot2")

if(!exists("book_words")) {
        book_words <- read.csv(file = "data/deepNLP.csv",
                                 stringsAsFactors = FALSE)
        }

plotWords <- function(lfile, corte = 0) {
        doc <- subset(book_words,file == lfile)
        doc <- subset(doc, tf_idf > corte)
        doc$i <- 1:length(doc$word)
        if(dim(doc)[1] > 50)
                doc <- doc[1:50,]
        doc <- doc[order(doc$tf_idf,decreasing = FALSE),]
        p <- ggplot(doc, aes(i, tf_idf, label = doc$word)) + 
                geom_text(check_overlap = TRUE,size = (doc$tf_idf*10)/max(doc$tf_idf), aes(colour = doc$tf_idf)) +
                theme(legend.position="none")
        print(p)
        corM <- lm(doc$tf_idf ~ doc$i + I(doc$i^2))
        return(corM)
}

readCentroid <- function(classCentroid) {
        if(file.exists(paste0("data/centroid.",classCentroid))) {
                return(read.csv(paste0("data/centroid.",classCentroid),stringsAsFactors = FALSE))
                
        }
}

plotFile <- function(file1 = file1, file2 = NULL, wplot = TRUE, 
                      classCentroid = NULL) {
        source("loadConfig.R")
        doc1  <- subset(book_words,file == file1)
        if(!is.null(classCentroid)) 
                ni <- readCentroid(classCentroid) 
        if(is.null(classCentroid) && !is.null(file2))
                ni <- subset(book_words,file == file2)
        corM <- 0
        ni$tfidf <- 0
        ni$i <- 0
        if(wplot) {
                soma <- 0
                for(i  in 1:length(doc1$word)[1]) {
                        ind <- which(ni$word == doc1[i,]$word)
                        if(length(ind)) 
                                ni[ind,]$tfidf <- doc1[i,]$tf_idf
                        }
                ni <- ni[order(ni$mean,decreasing = FALSE),]
                ni$i <- 1:length(ni$word)
                ni <- subset(ni, tfidf > 0)
                ni <- subset(ni, mean > 0)
                if(length(ni$word) < 3) {
                        return(paste0("File ",file2,"has less than 10 characters"))
                }
                model1 <- lm(ni$mean ~ ni$i + I(ni$i^2))
                model2 <- lm(ni$tfidf ~ ni$i + I(ni$i^2))
                corM <- abs(cor(predict(model1),predict(model2)))
                plot(ni$i, ni$mean, col = "blue", 
                     type = "p", main = paste(file1,file2),
                     xlim = c(0,max(ni$i)), ylim = c(0,max(ni$tfidf)),
                     xlab = paste("correlation: ",corM), ylab = "TF-IDF")
                lines(ni$i, predict(lm(ni$mean ~ ni$i + I(ni$i^2))), col = c("blue"))
                par(new = "T")
                plot(ni$i, ni$tfidf, col = "red", 
                     type = "p",
                     xlim = c(0,max(ni$i)), ylim = c(0,max(ni$tfidf)),
                     xlab = paste("correlation: ",corM), ylab = "TF-IDF")
                lines(ni$i, predict(lm(ni$tfidf ~ ni$i + I(ni$i^2))), col = c("red"))
                return(corM)
        }
        return(c("ERRO",length(compare)[1]))
}


