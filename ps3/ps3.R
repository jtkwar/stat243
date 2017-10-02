###Part (a) of Question 2 of Problem Set 3
fileString <- "/home/jkwarsick/Documents/STAT243_Fall2017/ps3-2017/pg100.txt"
filecon <- file(fileString)

readLines(filecon)
#This function changes the inconsistent format of occurrences of scene
scene_cleanup <- function(entry) {
  #entry <- entry[entry != ""]
  gsub("[[:punct:]]?([[:space:]]{1}SCENE[[:space:]]{1})|([[:space:]]{1}Scene[[:space:]]{1})|(SCENE[[:space:]]{1}|(Scene[[:space:]]{1}))", "|SC_", entry)
}
#This function cleans up the format of the occurences of act
#Dont to determine number of acts with greater ease
act_cleanup <- function(entry) {
  gsub("(ACT )|(Act )", "ACT_", entry)
}

#Function looks for String = Dramatis Personae and <<
#Then removes the Dramatis Personae from the play text
rm_dramatis_personae <- function(entry) {
  dram_strt <- grep("(Dramatis Personae)|(DRAMATIS PERSONAE)", entry)
  dram_end <- grep("<<", entry)
  entry <- entry[-(dram_strt:dram_end[1]-1)]
}

#Function to remove the stage directions and descriptions
rm_stage_dir <- function(entry) {
  #removes whitespace, cases of enter, exeunt, and exit then other characters
  gsub("([[:space:]]+)((Enter)|(Exeunt)|(Exit))([[:print:]]+)?$", "", entry)
}

#This function removes the punctuation from spoken chunks
rm_punct <- function(entry) {
  gsub("(\\.)|(\\?)|(\\!)|(\\:)|(\\;)|(,)", "", entry)
}

#Sentence counter per chunk
count_sentences <- function(entry) {
  num_sentences <- str_count(entry, "(\\.)|(\\?)|(\\!)")
  return(num_sentences)
}
#counts the number of words per chunk
count_words <- function(entry) {
  num_words <- str_count(entry, "[[:alpha:]]+")
  return(num_words)
}

#Extracts the play year, play title, number of acts, and number of scenes
extract_play_information <- function(entry) {
  acts_cnt <-length(grep("ACT_", entry))
  scenes <- length(grep("SC_", entry))
  entry <- entry[entry != ""]
  play_year  <- as.integer(entry[1])
  play_title <- entry[2]
  return(list(play_year, play_title, acts_cnt, scenes))
}

find_characters <- function(entry) {
  charc_loc <- grep("(^  )([[:alpha:]]+)([[:space:]]{1}[[:alpha:]]+){0,}(\\.)", entry)
  print(charc_loc)
  #list that contains locations of all occurrences of character in play text
  charc_list <- c()
  for (item in charc_loc) {
    tmp <- str_extract(entry[item], "(^  )([[:alpha:]]+)([[:space:]]{1}[[:alpha:]]+){0,}(\\.)")
    print(tmp)
    charc_list <- c(charc_list, tmp)
  }
  return(charc_list)
}

find_characters_lines <- function(entry) {
  charc_loc <- grepl("(^  )([[:alpha:]]+)([[:space:]]{1}[[:alpha:]]+){0,}(\\.)", entry)
  line_indices <- which(charc_loc)
  line_indices <- c(line_indices, length(entry))
  block_coordinates <- lapply(seq(1, length(line_indices)-1), 
                              function(i) { seq(line_indices[i], line_indices[i+1]-1) } )
  
  str_blocks <- lapply(block_coordinates, function(i) { entry[i] })
  lapply(str_blocks, create_charblock_type)
  blocks <- as.data.frame(matrix(unlist(lapply(str_blocks, create_charblock_type)), 
                                 ncol = 2, byrow = TRUE),
                          stringsAsFactors = FALSE)
  sentences_p_chunk <- lapply(blocks$V2, count_sentences)
  words_p_chunk <- lapply(blocks$V2, count_words)
  num_spoken_chunks <- length(blocks$V2)  #number of spoken chunks per play
  unique_character_names <- unique(blocks$V1)
  return_df <- data.frame(unique_character_names,
                          unlist(lapply(
                            unique_character_names, get_all_spoken_lines, my_blocks=blocks)))
  names(return_df) <- c("character", "all_text")
  returnables <- c(return_df, num_spoken_chunks, sentences_p_chunk, words_p_chunk)
  return(returnables)
}

create_charblock_type <- function(string_list) {
  # Get the character's name, this code can be cleaned up
  tmp.string_list <- string_list
  character_str <- trimws(strsplit(string_list[1], '\\.')[[1]][1])
  first_line_text <- strsplit(string_list[1], '\\.')[[1]][2]
  tmp.string_list[1] <- first_line_text
  return(c(character_str, paste(trimws(tmp.string_list), collapse=" ")))
}

get_all_spoken_lines <- function(char_name, my_blocks) {
  return(paste(my_blocks[my_blocks$V1 == char_name,]$V2, collapse=" "))
}

#List of the unprocessed play text initialization
play_texts <- list()
output_start <- FALSE
DEBUG <- TRUE
current_play_text_lines <- c()

for (line in readLines(filecon)) {
  new_play <- grepl("^[[:digit:]]{4}$", line)
  if (new_play && DEBUG) {
    print(line)
  }
  if (new_play) {
    output_start <- TRUE
    play_texts[[length(play_texts)+1]] <- current_play_text_lines
    current_play_text_lines <- c()
  }
  if (output_start) {
    current_play_text_lines <- c(current_play_text_lines, line)
  }
}

#Cleans the scene formatting in play texts
scene_clean_text <- lapply(play_texts[2:length(play_texts)], scene_cleanup)
#Cleans up ACT formatting in the play texts
act_clean_text <- lapply(scene_clean_text, act_cleanup)

#Line to extract play objects of Part (b) of the problem
#Play year, Play Title, Number of Acts, Number of Scenes
play_objects <- lapply(act_clean_text[-4], extract_play_information)

#Remobve Dramatis Personae from play text
dram_free_text <- lapply(act_clean_text, rm_dramatis_personae)

#Stage free text version 1.0, now to grab the characters and their word chunks
stagedir_free_txt <- lapply(dram_free_text, rm_stage_dir)

#Extracts all relevant character information.
#Excluding the play, Comedy of Errors
all_plays_spkr_processing <- lapply(stagedir_free_txt[-4], find_characters_lines)

#Determine the number of words per play
word_play_tot <- list()
for (i in 1:length(all_plays_spkr_processing)) {
  tmp <- 0
  low_bound <- length(all_plays_spkr_processing[[i]])-all_plays_spkr_processing[[i]][[3]]
  for (j in low_bound:length(all_plays_spkr_processing[[i]])) {
    tmp <- tmp + all_plays_spkr_processing[[i]][[j]]
  }
  word_play_tot <- c(word_play_tot, tmp)
}

#Calulates the number of words per chunk for each play
#then saves it to a list
avg_wdp_chunk_per_play <- c()
for (i in 1:length(words_per_play)) {
  tmp <- 0
  tmp <- words_per_play[1]/all_plays_spkr_processing[[i]][[3]]
  avg_wdp_chunk_per_play <- c(avg_wdp_chunk_per_play, tmp)
}

#Extract play years into their own list to eas plot making
years <- c()
for (i in 1:length(play_objects)) {
  year <- play_objects[[i]][[1]]
  years <- c(years, year)
}
#extracting the number of chunks per play for plotting
chunks_p_play <- c()
for (i in 1:length(all_plays_spkr_processing)) {
  num_chunks <- all_plays_spkr_processing[[i]][[3]]
  chunks_p_play <- c(chunks_p_play, num_chunks)
}
#Extract Number of Acts per play
acts <- c()
for (i in 1:length(play_objects)) {
  num_act <- play_objects[[i]][[3]]
  acts <- c(acts, num_act)
}
#Extract the scenes per play
scenes <- c()
for (i in 1:length(play_objects)) {
  num_scene <- play_objects[[i]][[4]]
  scenes <- c(scenes, num_scene)
}
#Extract the titles of the plays
titles <- c()
for (i in 1:length(play_objects)) {
  title1 <- play_objects[[i]][[2]]
  titles <- c(titles, title1)
}
meta_data_df <- data.frame(titles, acts, scenes)
#extracting the number of unique speakers per play
uniq_spkrs_p_play <- c()
for (i in 1:length(all_plays_spkr_processing)) {
  num_spkrs <- length(all_plays_spkr_processing[[i]][[1]])
  uniq_spkrs_p_play <- c(uniq_spkrs_p_play, num_spkrs)
}
meta_data_df <- data.frame(titles, acts, scenes)
#Plot of years vs words per play
plot(years, word_play_tot)
#plot of years vs words per spoken chunk per play
plot(years, avg_wdp_chunk_per_play)
#Number of Chunks per play.
plot(years, chunks_p_play)
#plot of years vs number of unique speakers per play
plot(years, uniq_spkrs_p_play)