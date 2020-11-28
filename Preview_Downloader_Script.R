
#This script was written by Ferenc Igali, The University of Sheffield, 28/11/2020

#This script will use a downloaded preview data file to download files from the CSV so that you don't have to download them one by one from preview mode

#To see how the login part of the script works, please refer to my other tutorial: https://university-of-sheffield-edutech.github.io/data-endpoint-gorilla.io/


#THE MAJOR CAVEAT WITH THIS SCRIPT IS: if you have special characters in your password and you are using a Mac, there is an encoding error with R and the HTTR package. 
# There are two workarounds: one is to make a temporary password change on Gorilla that doesn't include special characters or two is to use a Windows machine to run this script (or run under a Windows emulation)


#Here are all the libraries we need for this to work - please note, you need to install them first with install.packages('library') or install them in R studio

library(httr)
library(plyr)
library(downloader)
library(keyring)
library(data.table)

#we set up a directory to store our downloaded files - you will have to choose your own output file
outDir = "C:\\Users\\Ferenc\\Desktop\\Gorilla Preview Tester"

#we go to that directory
setwd(outDir)

#You need to select your downloaded preview CSV file here (if not in CSV, you will need to re-tool this next bit)
preview_downloaded_data_file <- file.choose(new = FALSE)

main_preview_file <- read.csv(preview_downloaded_data_file, stringsAsFactors = FALSE)



#this is to retrieve your password and username 
login <- list(
  email = keyring::key_list("my-database")[1,2],
  password = keyring::key_get("my-database", "f.igali@sheffield.ac.uk")
)

#this logs you in - this will be needed for getting the files
login_res <- POST("https://gorilla.sc/api/login", body = login, encode = "form")


# Then we extract the URLs 

preview_download_urls <- main_preview_file[grepl('https', main_preview_file$Response), ]


# Then we roll through them here in a loop 

for (url in 1:length(preview_download_urls$Response)) {
  
  file_end <- ""
  
  
  experiment_download_url <- GET(preview_download_urls$Response[url])
  
  content_type_you_need_to_save <- experiment_download_url$headers$`content-type`
  
  ##THIS IS A NON EXHAUSTIVE LIST - please change it for the type of file you want to download
  
  ##What these if statements do is basically content negotiation
  
  ##You will need to check the type of file you are downloading 
  
  ##The content type is in the content_type_you_need_to_save variable - so if it's missing from this list, add your own, these are the common ones from Gorilla
  
  if (content_type_you_need_to_save == "text/csv") {
    
    file_end <- ".csv"
    
  }
  
  if (content_type_you_need_to_save == "audio/wav") {
    
    file_end <- ".weba"
    
  }
  
  if (content_type_you_need_to_save == "video/webm;codecs=vp8") {
    
    file_end <- ".webm"
    
  }
  
  
  file_download_url <- experiment_download_url$url
  
  ##This saves your files named sequentially - 1 to the number of URLs you have with the file extension type saved 
  ##If you want to save participant ID or something else, you can use the columns that you have in your data to download as this data frame just contains the rows that have URLs in
  file_name_saver <- paste(url, file_end, sep="")
  
  
  #download the file
  download(file_download_url,file_name_saver)
  
  
} 













