researcherHTML<-function()
{
  #Relevant libraries for the operation of the function
  library('bitops')
  library('XML')
  library('curl')
  library('RCurl')
  library('stringr')
  
  #Parts of the url needed for the researcher query
  base_url<-"https://scholar.google.com"
  url1<-"/scholar?q="
  
  #User input to obtain name of researcher of interest
  usr_input<-readline(prompt="Enter researcher name (first then last, space delimited): ")
  spltname<-strsplit(usr_input, " ") #Splits the name based on prescence of whitespace
  #completed url needed for query
  complete_url<-paste0(base_url,url1,spltname[[1]][1],"+",spltname[[1]][2])
  
  #Reads lines from the url given. Stores locally for processing
  doc<-htmlParse(readLines(complete_url))
  
  Sys.sleep(2) #time for the system to sleep so rapid querying does not occur
  #Collects list of nodes from downloaded html
  #pattern is "//a[@href]"
  listofANodes<-getNodeSet(doc, "//a[@href]")
  
  #Empty vector linklist needed for type conversion
  #for-loop handles conversion from 'externalptr' to 'character'
  linklist<-c()
  for (item in listofANodes) {
    temp<-as(item, "character")
    linklist<-c(linklist, temp)
  }
  ##search1<-paste0(spltname[[1]][1]," ",spltname[[1]][2])
  ##search2<-paste0(spltname[[1]][2]," ",spltname[[1]][1])
  #locates the position of the user name of interest in the link
  occurence_position<-grep(spltname[[1]][2], linklist)
  #now it takes the first occurence and extracts the url needed for researcher user profile citation page
  location<-as.numeric(occurence_position[[2]])
  loc<-linklist[[location]]
  url2<-gsub('(<a href=\\")|(".*)',"",loc)
  #constructs the full url of researcher user profile
  full_url<-paste0(base_url,url2)
  #grabs the user ID from the string version of the extracted link
  user_ID<-gsub('(.*user=)|(&.*)',"",loc)
  
  doc2<-htmlParse(readLines(full_url))
  Sys.sleep(2)
  returnlist<-c(user_ID, doc2)
  return(returnlist)
}