


# Welcome to the Tutorial!

This tutorial is intended for people who are new to HTTP GET/POST requests and would like to utilise Gorilla's endpoints to pull down data automatically. I am uploading an example in R but will follow with examples in Python and cURL sometime later in the summer (of 2020). 

The full R file for downloading is available in this repo (Github slang for repository where all these files are stored). If you are confident with R, just download the file and just have a quick glance over this short text. 

## This is a fairly short tutorial but will cover a number of concepts 

## First, what is a HTTP Request? 

Well, whenever you do something on the web that requires an interaction with a database or retrieving anything, you need to make some sort of action that will tell it what to do. In this case, we are going to ask **Gorilla** for a couple of things:

1) We will go through the API (the non-published bit that internally points to different URLs - which are known as **endpoints**  to call the login page and then send our login details). 
2) We will then call the experiment page that you would call visually - except we are going to call the **endpoints** that the buttons refer to when you press on 'Generate Data' and 'Download Data' - I will show you how to edit 
3) Just like the Gorilla script that is called on the page when you press 'Generate Data', we will ping the server every 3 seconds (anymore would be spamming!) till our report is ready and we can download it - we will do this using a **do-while** loop in R. 
4) Once the file is ready, we download the file and then we unzip it and stick all the CSVs we download together (if you want to separate out your CSVs, that's beyond the scope of this tutorial. This is purely for 'how do I get the data out of Gorilla without logging in on an actual webpage' - something which you can automate if you need!. 

## What type of HTTP requests are there and which ones do we need?

Well, there's a couple - *GET*, *POST*, *PUT*, *DELETE* - but we only need **GET** and **POST**. 

## What does GET do?

It quite simply 'GETS' us a webpage - ie the one where our data download link is held.

## What does POST do? 

It sends data - such as credentials to a login endpoint. 

## Ok, but how do we get setup in R to start sending these requests?

Well, good question! Emma James has a brilliant tutorial about getting started with Tidyverse in R that gives you pointers about how to get setup for Tidyverse use in R for your Gorilla data - available [here](https://emljames.github.io/GorillaR/index.html).

*What is R?* R is a statistical scripting language that is designed, amongst other things, for data analysis and data science. You can download R the language and use an R console, or you can make it easier on yourself if you are new and download **R Studio**. R Studio is basically a contained environment in which to run R and then to manage your packages (basically, R's versions of addons where people have put together functions so you don't have to reinvent the wheel). 

The rest of this tutorial does assume that you have some exposure to R and R studio and that you can follow an R script generally - I will go line by line to explain everything so do not worry! (P.S. the code is commented - what this means is that the code has *comments* on it that do not execute code and are there to tell the user what each section of code does. So if you are comfortable enough, you can go ahead and use the file in this repo). 

## Why haven't you made this into a proper site like Emma's tutorial? 

Mostly as a programmer, I am just overworked (and a tad bit lazy with UX after I've solved a problem if I'm being honest) - if people would prefer a nice tutorial with pagination and so on, do let me know and I'll see if I can make it better (I'm sticking this all into the README on Github to make everyone's lives easier for now).  

## How can I get in touch with you?

You can email [me](mailto::f.igali@sheffield.ac.uk). 

## Ok, so where we get started? 

Well, that is a good question. Probably in R studio - the first thing we'll need to do is install some packages. Here is a screenshot of what my R studio setup looks like for those that are unfamiliar with it:

![R studio setup]({{site.url}}/Images/R-Studio.png )

So, once you have R Studio open, let's install the packages we need for this one - they're loaded at the top of the script but for those that are new to R, let's show you how to install them. 

The packages we are going to be using are **httr, downloader, plyr and keyring**. 

Let's start with *keyring*. 

Now obviously I trust you, dear reader - just not with my Gorilla login! (*Hint, this package is just one way of making sure you don't end up saving R files with your login available everywhere!*). What keyring does, is it allows you to store your passwords away and then call them in an R script by calling the function get them back out whenever you need them - so any pesky lab user in your department (or any reader of your tutorial) won't get to know your login!

So how do we actually **install** a package? 

Well, it's pretty easy - either in an R script or in the R console, we just run/execute the following line of code: 

`install.packages("keyring")`

If you want the even easier way, R has a button on the bottom right hand corner section called **Packages** that you can use to manage your packages and to install new ones - it even has an auto-complete when you download. 

So once keyring is setup, how do we actually launch it/add it to our active session? Well, we just use another bit of code - this has to be done **every script, for every time you open R**:

`library("keyring")`

## Cool, I got it installed and all, but make it do something now?

Well, there is a very good tutorial on the benefits and what keyring can do as well as other methods for securing your credentials, that is available [here](https://db.rstudio.com/best-practices/managing-credentials/) so I won't delve too far into it - I will just show you how to setup a quick username and password storage using a generic database saved connection (don't worry, it doesn't connect to a database until you call it - a database name is just used as a key to retrieve your username and password so you can save different credentials for different logins with keyring). 

```keyring::key_set(service = "my-database", username = "f.igali@sheffield.ac.uk")
```

Using their example, I set the service to be called 'my-database' but feel free to call this 'Gorilla' or whatever else makes sense to you - it is the name of the connection. For Username, enter your Gorilla username as I have done above. When you run the command, you will be able to set a password that will be retrievable once you type it in. 

In my R script, I quite simply do the following: 

```
  #this is to retrieve your password and username 
  login <- list(
    email = keyring::key_list("my-database")[1,2],
    password = keyring::key_get("my-database", "f.igali@sheffield.ac.uk")
  )
  ```

### That's cool, but what does that mean?

Well, the first line is a comment so that's just telling you, the user, what it does. The second line creates 'login' and we tell R that we want it to be a list - this list will have two elements, 'email' and 'password' which are retrieved using keyring'. 

## Now that we got credentials out the way, let's setup the rest of the libraries we need!

So go ahead and install **httr, plyr and downloader** which are all available as packages. 

## Now onto the script:

The first part of the script goes like this: 
```
#we set up a directory to store our zip files in
outDir = "C:\\Users\\Ferenc\\Desktop\\Gorilla_Test"

#we go to that directory
setwd(outDir)

#this is the ID of your experiment
experiment_id = '19847'

#this is the verison you want to download  
experiment_version = '2'

#this is the node you want to download
tree_node_key = 'all'

```

### Again, cool, but what does it do?

Well, putting aside all the comments, the first thing we do is define a directory where we want our data to go on our PC - you'll notice I use \\ instead of \. This is because R will stop at \ and your code will break as it will be intepreted as a signal for R, as opposed to being part of a directory path. 

Then we go (set) to the directory we just set up - setwd() just takes us to the working directory so that when we download the data, we aren't downloading it somewhere *random*. 

Next is the **EXPERIMENT ID** - you can get this one of two ways - either programmatically or by logging into Gorilla and checking the URL. Gorilla communicates with it's server by calling endpoints - so when you click on experiment A, basically what happens is:

Gorilla goes to the base URL - gorilla.sc
It then reroutes to the experiment based on a retrieved number based on the project you clicked on. 
In my case, I am using an ID of 19847 - you can see this in the image below:

![Gorilla Experiment URL](https://github.com/University-of-Sheffield-EduTech/data-endpoint-gorilla.io/blob/master/Images/Experiment_ID.png)

Why is experiment ID and version important? Well it's how Gorilla navigates around the webpages to show you the correct thing. If you use developer tools on Chrome, you'll find a file called a file about Gorilla Metrics that has a function that shows you how this call is done for example when you press the generate or regenarate data buttons: 

![Gorilla Build Report Function](https://github.com/University-of-Sheffield-EduTech/data-endpoint-gorilla.io/blob/master/Images/Gorilla_Build_Report_Function.png)

Basically, the Gorilla call goes like this - I'll include the HTTP request and headers so you can see what it looks like: 

```

Request URL: https://gorilla.sc/api/experiment/19847/2/node/all/report/build
Request Method: POST
Status Code: 200 OK

{unblind: false, time_from: 0, time_to: 0, filetype: "csv", form: "long"}
filetype: "csv"
form: "long"
time_from: 0
time_to: 0
unblind: false

```

The JavaScript function that gets called is like this: 
```
var buildReport = function (treeNodeKey, nodeLabel, nodeType, unblind, form, timeFrom, timeTo, filetype) {
        return runtime.apiAsync({
            url: '/api/experiment/' + experimentID + '/' + experimentVersion + '/node/' + treeNodeKey + '/report/build',
            method: 'POST',
            data: {
                unblind: unblind,
                time_from: timeFrom,
                time_to: timeTo,
                filetype: filetype,
                form: form
            }
        })
```

So basically, what happens is that when buildReport is called, with that XHR request, a function is made that takes a few parameters. These parameters are the options you see on your screen when you are downloading the data and it is ones that we can manipulate in R:

![Gorilla Data Download Options](https://github.com/University-of-Sheffield-EduTech/data-endpoint-gorilla.io/blob/master/Images/Experiment_Download_Options.png)

The bit where you see data: - that's what is known as JSON - which is just basically a fancy matrix/array of key:value pairs - ie a key like 'name' and a value like 'Ferenc'. In this case, when the request goes, Gorilla asks for whether we want to blind/unblind, what time from and to we want, what file type we want and what form we want it in. 

Now if we go back to the R code:

```
#these are the options you get when downloading your data
download_options_2 <- list (
  filetype =  "csv",
  form = "long",
  time_from = 0,
  time_to = 0,
  unblind = "false"
) 

```

Hey look - we just made another list where we fed it the same options like name and password for the first list, easy right? 

Well, in between you'll notice that I put a line that does the following: 

```
#this logs you in
login_res <- POST("https://gorilla.sc/api/login", body = login, encode = "form")
```
What this line does is log you in by sending a POST request with the body of that request (ie the data we send it) by utilising that name and password we got from keyring earlier. 

## Cool, now we got that setup, what next?

Well, next is pretty simple: we want to Gorilla to create or refresh the data of our experiment. We do this exactly the same as if you had clicked the button - we ask it to make that buildReport function. 

Well, how can R do that? Currently, we are logged in using our login_res code so we're already authenticated. The next step is to go directly to the experiment and make it build a report - and that's what we do here:
```

#request report
report_generate_request <- POST(paste("https://gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/",tree_node_key,"/report/build", sep = "", collapse = NULL), body = download_options_2, encode = "json")
```

What we are doing here is concatenating/pasting together a URL and then giving it our download options list and telling Gorilla that it is JSON. So the paste function takes several parameters - in this case, a base URL, the experiment ID, the experiment version, the node key and the /report/build endpoint to make Gorilla generate that data for us. The 'body=' bit is a parameter to tell Gorilla what we are POSTing to it. Then we tell it that it's JSON (not that it wouldn't already know by the structure! Always better safe then sorry). 

Next bit of code is fairly straightforward: 

We basically try downloading our data. It won't happen because just like the message you get from Gorilla about the data waiting to be downloaded and ready, we get the same message from the endpoint (which is how they display it to you using XHR/Ajax). Gorilla stores these in blob storage on Azure so we're just trying to retrieve our specific data storage.  
```

#set up initial variables for download 
experiment_download_url <- GET(paste("https://gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/", tree_node_key,"/report/download", sep = "", collapse = NULL))

file_download_url_resp <- content(experiment_download_url)

file_download_url <- toString(file_download_url_resp[2])

```

The last line just literally retrieves the content from the webpage that we are GETting. Before Gorilla is ready to give us any data, we won't get a URL back, we'll get back a 'THis report is being generated' which we use in the next bit of code. 

```
#this do while basically waits until the report is ready and keeps pinging the server - I use 3 second pings like the gorilla metrics JS code
while (file_download_url == "The report is currently being generated") {
  experiment_download_tester <- GET(paste("https://gorilla.sc/api/experiment/", experiment_id, "/", experiment_version,"/node/",tree_node_key,"/report", sep = "", collapse = NULL))
  
  experiment_download_url <- GET(paste("https://gorilla.sc/api/experiment/", experiment_id, "/", experiment_version, "/node/",tree_node_key,"/report/download", sep = "", collapse = NULL))
  
  file_download_url_resp <- content(experiment_download_url)
  
  file_download_url <- toString(file_download_url_resp[2])
  Sys.sleep(3)
  
}

```

This is basically a do-while loop - do while means **do this while this is true, stop once no longer true**. So while the contents is not a URL but a message saying 'The report is being currently generated', it will keep looping. It loops every 3 seconds, just like the JavaScript version that gets called on the page when you wait for your data to become available. 

Once we get a URL, we will move on and R will cancel the loop. 

The next bit is fairly self-explanatory - we download the zip file, name it 'downloader.zip' and we set a mode to download in (rememebr, we asked for all nodes so we're downloading all the CSVs for the experiment). 


```
#download the file
download(file_download_url,"downloader.zip", mode = "wb")

```

Then the final bit is just a bit of plyr magic to basically list all file types with .zip in our directory, then unzip them all and then smush them all together by retrieving all csvs. 

Now you can edit this to your hearts content to aim for a specific file or do whatever you like with the files once you have them - that is beyond the scope of this tutorial though! I can possibly follow up in the future with some basic data analysis and cleaning/organising/analysing your data, but for this tutorial, I just wanted to show how you can download files from R without having to use the web interface. 

# Thank you for reading this far if you made it - any questions, please direct them to [f.igali@sheffield.ac.uk](f.igali@sheffield.ac.uk). 

I hope you enjoyed this relatively short tutorial and hopefully it's given you a bit of insight into how websites communicate with the outside world/users/internally. 

The code isn't the *cleanest* by far - for example, the conditional for the do-while loop could behave abnormally so you are welcome to edit it if you wish - it will work in the majority of use cases. 

A full copy of the code is available [here](https://github.com/University-of-Sheffield-EduTech/data-endpoint-gorilla.io/blob/master/File_Downloader.R). 

## How did you figure this out?

Well, I just looked at how the site communicates with itself when every button is pressed on that data page - looked at the calls and what information they sent and then just worked backwards. The only tool I used to decipher this was Google Chrome's Inspector/Developer Tools just to watch the calls and to look at the files that Gorilla loads up. Then I basically did what Gorilla does but just in R!
