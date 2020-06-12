


# Welcome to the Tutorial!

This tutorial is intended for people who are new to HTTP GET/POST requests and would like to utilise Gorilla's endpoints to pull down data automatically. I am uploading an example in R but will follow with examples in Python and cURL sometime later in the summer (of 2020). 

The full R file for downloading is available in this repo (Github slang for repository where all these files are stored). If you are confident with R, just download the file and just have a quick glance over this short text. 

## This is a fairly short tutorial but will cover a number of concepts 

## First, what is a HTTP Request? 

Well, whenever you do something on the web that requires an interaction with a database or retrieving anything, you need to make some sort of action that will tell it what to do. In this case, we are going to ask **Gorilla** for a couple of things:

1) We will go through the API (the non-published bit that internally points to different URLs - which are known as **endpoints**  to call the login page and then send our login details. 
2) We will then call the experiment page that you would call visually - except we are going to call the **endpoints** that the buttons refer to when you press on 'Generate Data' and 'Download Data' - I will show you how to edit 
3) Just like the Gorilla script that is called on the page when you press Generate Data, we will ping the server every 3 seconds (anymore would be spamming!) till our report is ready and we can download it - we will do this using a **do-while** loop in R. 
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

Mostly as a programmer, I am just lazy - if people would prefer a nice tutorial with pagination and so on, do let me know. 

## How can I get in touch with you?

You can email [me](mailto::f.igali@sheffield.ac.uk). 
