##Function for Problem 2 Part (b) of Problem Set II
##Write a function to extract the Article Title, Authors, Journal Information, number of citations
##and year published to a dataframe.
gs_citation_dataframe<-function(html_citation_page)
{
  #Relevant libraries for the operation of the function
  library('bitops')
  library('XML')
  library('curl')
  library('RCurl')
  library('stringr')
  
  #function for converting contents of node lists to character class, from 'externalptr'
  character_conv<-function(NODELIST)
  {
    linklist<-c()
    for (item in NODELIST) {
      temp<-as(item, "character")
      linklist<-c(linklist, temp)
    }
    return(linklist)
  }
  
  #Take the html text from the output from the previous function
  #Use getNodeSet() in order to extract article information, citation numbers, and year published
  articleinfoNode<-getNodeSet(html_citation_page,'//tr[@class="gsc_a_tr"]')
  citationNode<-getNodeSet(html_citation_page,'//td[@class="gsc_a_c"]')
  yearNode<-getNodeSet(html_citation_page,'//td[@class="gsc_a_y"]')
  
  #Convert the lists of relevant information to characters for string processing
  articleinfoList<-character_conv(articleinfoNode)
  citationList<-character_conv(citationNode)
  yearList<-character_conv(yearNode)
  
  #Now perform string processing to extract the following--
  #title, author, journal info, number of citations, year published
  #Extracts the desired information by stripping away text before and after important text
  
  #Number of Citations
  cL<-gsub('(</a>.*)',"",citationList)
  num_cite<-gsub('(.*">)',"",cL)
  #Year Published
  year_1<-gsub('.*gsc_a_h">',"",yearList)
  year_pub<-gsub('</span>.*',"",year_1)
  #article title
  title_1<-gsub('(.*gsc_a_at">)',"",articleinfoList)
  titles<-gsub('(</a>.*)',"",title_1)
  #authors
  author_1<-gsub('(</div>\\n.*)',"",articleinfoList)
  authors<-gsub('(.*gs_gray">)',"",author_1)
  #journal information
  journal_info_1<-gsub('(.*gs_gray">)',"",articleinfoList)
  journal_info<-gsub('(<span.*)',"",journal_info_1)

  #Now create the dataframe of citations for user profile on Google Scholar
  user_profile_info<-data.frame(titles, authors, journal_info, year_pub, num_cite)
  return(user_profile_info)
}