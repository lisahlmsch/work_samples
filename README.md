# Work samples
In this github repo I am show casing previous data science projects as part of my studies at Central European University (MSc Business Analytics) or Johns Hopkins University (Data Science Specialisation) or private projects (Kaggle competitions, ...)


## R Package
I created the mr R package that queries historical exchange rates for any currency (so configurable symbol and base currency) for the past number of days and converts it to forint.
I also included a unit test for the forint function to make sure that forint(42) returns 42 HUF.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/mr-package)

## Shiny Application
I created a shiny web application that allows the user to select a station within the Viennese local transportation system and will be shown the upcoming departures at the selected station, together with a map indicating where the station is located. 
The application can be accessed here: https://lisahlmsch.shinyapps.io/DV3_homework_assignment/

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/shiny%20app%20departure%20monitor)

## Natural Language Processing
I used a whats app chat history to analyse the patterns in the conversations. I used sentiment analysis, topic modelling, checked similarities among chat members, unique words (TF-IDF), and authorship and - as fun side project, analysed the use of emojis.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/natural%20language%20processing)

## NLP Word Prediction
This folder contains the Milestone Report for the Coursera Data Science Capstone project. The goal of this project is to create a text-prediction web application with R Shiny, that predicts the next word based on previous input using a natural language processing model.

## Stream processing
I create a stream processing application using the AWR.Kinesis R package's daemon + Redis to record the overall amount of coins exchanged on Binance (per symbol) in the most recent micro-batch.
Then I created a Jenkins job that reads from this Redis cache and prints the overall value (in USD) of the transactions -- based on the coin prices reported by the Binance API at the time of request. 
I report two charts to the "#bots-final-project" Slack channel.

I documented my steps to show my general understanding on how to build data pipelines using Amazon Web Services and R and how to implement a stream processing application (either running in almost real-time or batched/scheduled way) in practice.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/stream%20processing)

## Data visualisation
Using the spotify dataset provided in the 4th week of #tidytuesday at https://github.com/rfordatascience/tidytuesday -- I generated data visualizations using ggplot to give some meaningful insights.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/data%20visualisation)

## Image class prediction using deep neural net models
Together with my peer Alex we took the “Fashion MNIST dataset” where images of fashion items were to be classified . Images were provided as 28x28 pixel grayscale images. We built deep neural net models  using accuracy as a measure of predictive power.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/image%20class%20prediction)

## Binary classification
The task of this kaggle competition was to predict which articles are shared the most in social media. I submitted several types of solutions:

Using the caret package, I trained a LASSO model, a random forest model, a gradient boosting machine model and a neural net. Among these random forest had the best results in terms of AUC on the validation set. Using h2o I trained an elastic net model, a random forest, a gradient boosting machine model and a neural net and stacked them using both glm and gbm as a meta learner. The stacked model using glm as a metalearner produced the best results in terms of AUC on the validation set. Among the base models gbm showed the best results, while gbm using caret was rather weak in predicting the target variable.

[-> files](https://github.com/lisahlmsch/work_samples/tree/master/binary%20classification)

# Coming up:

## GDPR presentation 
## Data visualisation with tableau







