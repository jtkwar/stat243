library(readr)
library(foreach)
library(doParallel)
library(doMC)

concat_obama_results_preschedule <- function() {
  
  MY_PATH <- "/global/scratch/paciorek/wikistats_full/dated_for_R/"
  
  my_files <- list.files(path=MY_PATH, pattern="part*")
  
  mcoptions <- list(preschedule=TRUE)
  NCORES <- detectCores(all.tests = FALSE, logical = TRUE)
  cores <- makeCluster(NCORES)
  registerDoParallel(cores)
  result_table =
    foreach (i=1:length(my_files), 
             .combine=rbind, 
             .packages=c('readr'),
             .options.multicore=mcoptions) %dopar% {
               library("readr")
               to_add <- readr::read_delim(paste(MY_PATH, my_files[i], sep = ""),
                                           delim = " ", 
                                           col_names = c("date", "time", "language",
                                                         "filename", "site_hits", "size")
               )
               return(subset(to_add, grepl("Barack_Obama", filename)))
               gc()
             }
  stopCluster(c8)
  
  write.table(result_table, 
              file = "~/Obama_Results.tsv",
              quote = FALSE)
}

print(system.time(concat_obama_results_preschedule()))