 data <- read.csv("~/ADAProject/Emails_cleaned.csv",header = TRUE)
 names(data)
 id <- data[data$MetadataFrom == "H",]$Id
 id_H_81 <- data[data$MetadataFrom == "H" && data$MetadataTo == "abedinh@state.gov", ]$Id
 id_H_81 <- grep("H", data[grep("abedinh@state.gov", data$MetadataTo),]$MetadataFrom)
 length(id)
 sum <- summary(data[id, ]$MetadataTo)[1: 11]
 recv <- names(sum)
 names(data)
 for (i in 1 : 11){
    text <- ""
     for (j in 1 : length(grep(recv[i], data[id, ]$MetadataTo))){
         text <- paste(text, data[grep(recv[i], data[id, ]$MetadataTo), ]$RawText[j])
       }
     write(text, file = paste(recv[i], ".txt"))
 }

 
 top10names <- c('Huma Abedin (work)', 'Cheryl Mills (work)', 
                 'Jacob Sullivan (work)', 'Lauren Jiloty (work)', 
                 'Lona Valmoro (work)', 'Philippe Reines (personal)', 
                 'Sidney Blumenthal (personal)', 'Cheryl Mills (personal)', 
                 'Monica Hanley (work)', 'Huma Abedin (personal)'  )