library("readr")
library(foreach)
library(doParallel)

concat_obama_results <- function() {
  # path to Wikipedia web traffic
  MY_PATH <- "/global/scratch/paciorek/wikistats_full/dated_for_R/"
  # find all the files in the directory
  my_files <- list.files(path=MY_PATH, pattern="part*")
  # initiate multi-core processing
  NCORES <- detectCores(all.tests = FALSE, logical = TRUE)
  cores <- makeCluster(NCORES)
  registerDoParallel(cores)
  #output table
  result_table =
    foreach (i=1:96, # only did a small subset of the data
             .combine=rbind, 
             .packages=c('readr')) %dopar% {
               library("readr")
               #reads in files, labels the lists within
               to_add <- readr::read_delim(paste(MY_PATH, my_files[i], sep = ""),
                                           delim = " ", 
                                           col_names = c("date", "time", "language",
                                                         "filename", "site_hits", "size")
               )
               # find and return lines related to Barack Obama
               return(subset(to_add, grepl("Barack_Obama", filename)))
               gc()
             }
  stopCluster(c8)
  #write out file to home directory
  write.table(result_table, 
              file = "~/Obama_Results.tsv",
              quote = FALSE)
}
system.time(concat_obama_results())