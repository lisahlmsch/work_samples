Word prediction application
========================================================
author: Lisa Lang 
date: Sep 25, 2020
autosize: true

Introduction
========================================================

As part of the Coursera Data Science Specialisation my final capstone project was about creating a web application that allows the user to input a phrase (mulitple words) into a text box, which is then auto-completed by the application. The prediction of the next word is based on an algorithm that I have built.

Tasks included: 

* Understanding the problem
* Getting and cleaning the data 
* Exploratory Data Analysis (EDA); 
* Tokenization of words
* Building a prediction model 
* Developing a shiny application



Approach
========================================================

I was provided with a SwiftKey company dataset, that contains several text files from different sources (blogs, news, twitter) in different languages.

The English datafiles were used to extract a data sample for cleaning and tokenization.

I created n-grams (contiguous sequence of n items from a given sample of text) to train an algorithm which is able to predict the next word based on an input of words by the user.

Several machine learning algorithms were trained, including naive bayes and random forest. 
Finally a simple frequency table look up was used and implemented in the shiny app.


Technical details
========================================================
* The English text documents had a filesize between 160 and 200 MB.
* The blog document had the fewest number of lines (>900.000), while twitter had the most lines (> 2,3 Mio).
* The number of words exceeded 30 million per file.
* Since Twitter restricts the users in how long the tweets can be, the longest line of a twitter feed is only 140 characters. Blogs and News are less restricted. The longest blog had roughly 41.000, the longest newstext 11.000 characters. The news file contained long paragraphs, while blogs were a sequence of sentences.

In order to train the algorithm properly some data preparation steps were necessary:

1. Random sampling - In order to produce a representative sample from the population, the three datasets were combined to a Corpus (collection of documents) and 10% of the data was randomly extracted as a training dataset. 

2. Cleaning - This step included for example converting text to lower case, removing punctuations, profanity filtering, etc.

3. Tokenization - The text corpus was seperated into tokens (words) in order to build n-grams and to understand variation in the frequencies of words and word pairs in the data.

App
========================================================

The prediction application is hosted on shinyapps.io: [link to app] (https://lisahlmsch.shinyapps.io/word_prediction_app/)

The user is able to input several words which are cross checked by the application in an ngram frequency table.
The ngram that most often appears in the frequency table that starts with the words taken from the users input, is displayed as output in the main panel of the app.


*Further notes:*

With increased sample size accuracy could be improved, but the application slows down.

The code of this application, the milestone report, and this project presentation can be found in this GitHub repo: [lisahlmsch.github.io](lisahlmsch.github.io)


