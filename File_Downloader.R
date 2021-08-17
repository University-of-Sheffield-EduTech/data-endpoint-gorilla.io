#Here are all the libraries we need for this to work - please note, you need to install them first with install.packages('library') or install them in R studio

library(httr)
library(plyr)
library(downloader)
library(keyring)

#we set up a directory to store our zip files in
outDir = "C:\\Users\\Ferenc\\Desktop\\Gorilla_Test"

#we go to that directory
setwd(outDir)

#this is the ID of your experiment - change this to the ID of the one that you are interested in!
experiment_id = '19847'

#this is the version you want to download  
experiment_version = '2'

#this is the node you want to download - in this case, we want them all
tree_node_key = 'all'

#this is to retrieve your password and username 
login <- list(
  email = keyring::key_list("my-database")[1,2],
  password = keyring::key_get("my-database", "f.igali@sheffield.ac.uk")
)

#this logs you in
login_res <- POST("https://app.gorilla.sc/api/login", body = login, encode = "form")

#these are the options you get when downloading your data
download_options_2 <- list (
  filetype =  "csv",
  form = "long",
  time_from = 0,
  time_to = 0,
  unblind = "false"
) 

#request report
report_generate_request <- POST(paste("https://app.gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/",tree_node_key,"/report/build", sep = "", collapse = NULL), body = download_options_2, encode = "json")

#set up initial variables for download 
experiment_download_url <- GET(paste("https://app.gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/", tree_node_key,"/report/download", sep = "", collapse = NULL))

file_download_url_resp <- content(experiment_download_url)

file_download_url <- toString(file_download_url_resp[2])

#this do while basically waits until the report is ready and keeps pinging the server - I use 3 second pings like the gorilla metrics JS code
while (file_download_url == "The report is currently being generated") {
  experiment_download_tester <- GET(paste("https://app.gorilla.sc/api/experiment/", experiment_id, "/", experiment_version,"/node/",tree_node_key,"/report", sep = "", collapse = NULL))
  
  experiment_download_url <- GET(paste("https://app.gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/",tree_node_key,"/report/download", sep = "", collapse = NULL))
  
  file_download_url_resp <- content(experiment_download_url)
  
  file_download_url <- toString(file_download_url_resp[2])
  Sys.sleep(3)
  
}




#download the file
download(file_download_url,"downloader.zip", mode = "wb")



# get all the zip files
zipF <- list.files(path = outDir, pattern = "*.zip", full.names = TRUE)


# unzip all your files
ldply(.data = zipF, .fun = unzip, exdir = outDir)

# get the csv files
csv_files <- list.files(path = outDir, pattern = "*.csv")

# read the csv files
my_data <- ldply(.data = csv_files, .fun = read.csv)

