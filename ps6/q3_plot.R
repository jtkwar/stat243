library(dplyr)
library(chron)

setwd('/home/jkwarsick/Documents/STAT243_Fall2017/ps6-2017/')

spl <- read.csv('part-00000')

#name four columns of list of lists
names(spl) <- c('date','time','lang','pagehits')
#transform to characters for processing
spl$date <- as.character(spl$date)
spl$time <- as.character(spl$time)
#corrects midnight times
spl$time[spl$time %in%  c("0", "1")] <- "000000"
wh <- which(nchar(spl$time) == 5)
spl$time[wh] <- paste0("0", spl$time[wh])
#creates combined list of date-time
spl$chron <- chron(spl$date, spl$time,
                  format = c(dates = 'ymd', times = "hms"))
#switch to EST time
spl$chron <- spl$chron - 5/24 # GMT -> EST

#look only at the english data
spl <- spl %>% filter(spl$lang == 'en')
#look at the peak of page hits
sub <- spl %>% filter(spl$date > 20081006 & spl$date < 20081010)

pdf('subprime_lending_traffic.pdf', width = 5, height = 5)
par(mfrow = c(2, 1), mgp = c(1.8, 0.7, 0), mai = c(0.6, 0.6, 0.1, 0.1))
plot(spl$chron, spl$pagehits, type = 'l', xlab = 'Time', ylab = 'Page Hits')
title("Wed Traffic on ")
plot(sub$chron, sub$pagehits, type = 'l', xlab = 'Time', ylab = 'Page Hits')
points(spl$chron, spl$pagehits)
dev.off()
