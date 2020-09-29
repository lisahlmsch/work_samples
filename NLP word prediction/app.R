#
# This is a Shiny web application. I takes a sequence of words as input and returns the best fitting word to follow.

library(shiny)
library(tidyverse) # column separation
library(caret)
library(tm) #text mining
library(stringr)
library(tidytext)
library(logger)

log_threshold(DEBUG)

# Define UI for application that takes text as input
ui <- fluidPage(

    # Application title
    titlePanel("Word prediction"),

    # Sidebar  
    sidebarLayout(position = "right",  # sidebar panel is displayed on the right side of the browser window
        
        # Sidebar panel for user info ----
        sidebarPanel("Info",
            
            # Include clarifying text
            helpText("This application shall demonstrate the ability", 
                    "to predict the next word given a short text input", 
                    "by the user.",
                    h5("Instructions"),
                    "Enter a phrase in English into the textbox and it",
                    "will be auto completed by the application."), 
        ),
        
        # Main panel for displaying inputs and outputs ----
        mainPanel(
            
            h4("Text input"),
            br(),
            
            # Input: Text  ----
            textInput(inputId = "sentence",
                      label = "Please enter your input text here:",
                       value = ""),
            
            # Input: actionButton() to defer the rendering of output ----
            # until the user explicitly clicks the button (rather than
            # doing it immediately when inputs change). This is useful if
            # the computations required to render output are inordinately
            # time-consuming.
            # actionButton("update", "Show word prediction"),
            
            # Output: sentence 
            h4("Word prediction"),
            verbatimTextOutput("sentence"),
        )
    )
)

# Define server logic required to return word prediction
server <- function(input, output) {
    
    freq_lookup_function <- function(sentence, freq_table) {
        ## clean
        sent_clean <- iconv(sentence, from = "", to = "ASCII", sub="")
        # sub replaces any non-convertible bytes in the input.  
        
        # load data as a corpus
        corpus <- VCorpus(VectorSource(sent_clean))
        
        # clean corpus
        corpus <- tm_map(corpus, content_transformer(tolower))
        toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))
        corpus <- tm_map(corpus, toSpace, "(f|ht)tp(s?)://(.*)[.][a-z]+")
        corpus <- tm_map(corpus, toSpace, "@[^\\s]+")
        corpus <- tm_map(corpus, toSpace, " . ") # remove single letters
        corpus <- tm_map(corpus, removeNumbers)
        corpus <- tm_map(corpus, removePunctuation)
        remURL <- function(x) gsub("http[[:alnum:]]*", "", x)
        corpus <- tm_map(corpus, content_transformer(remURL))
        corpus <- tm_map(corpus, stripWhitespace)
        corpus <- tm_map(corpus, removeWords, stopwords("english"))
        profanity_words <- readLines("http://www.bannedwordlist.com/lists/swearWords.txt")
        corpus <- tm_map(corpus, removeWords, profanity_words)
        corpus <- tm_map(corpus, stemDocument)
        
        ## make prediction
        # convert corpus to dataframe
        d <- data.frame(text=unlist(sapply(corpus, '[', "content")), stringsAsFactors=F, row.names = "")
        
        # separate character vector into datafram with multiple rows
        words <- unnest_tokens(d, word, text, token = "words")
        # quiz <- separate(d, text, sep = " ", remove = TRUE)
        
        # decide which ngram to use
        # if ngram = 2, then sentence = one word
        # if ngram = 3, then sentence = 2 words, 
        # if ngram = 4, then sentence is 3 words or more 
        if(nrow(words) >= 4) {ngram <- 4} else {ngram <- nrow(words)+1}

        # look up word combination in frequency table
        # if input word appears in frequency table, filter it accordingly
        if(nrow(freq_table[freq_table$word3 == words[nrow(words),1],]) != 0) {
            # filter frequency table for word 3
            freq_table2 <- freq_table[freq_table$word2 == words[nrow(words),1],]
            log_info("rows after word3 filter: {nrow(freq_table2)}")
            
            # filter frequency table for word 2
            if(ngram > 1) {
                if(nrow(freq_table2[freq_table2$word1 == words[nrow(words)-1,1],]) != 0) {
                    freq_table2 <- freq_table2[freq_table2$word1 == words[nrow(words)-1,1],]
                }
            }
            log_info("rows after word2 filter: {nrow(freq_table2)}")
            
            # filter frequency table for word 1
            if(ngram > 2) {
                if(nrow(freq_table2[freq_table2$word1 == words[nrow(words)-2,1],]) != 0) {
                    freq_table2 <- freq_table2[freq_table2$word1 == words[nrow(words)-2,1],]
                }
            }
            log_info("rows after word1 filter: {nrow(freq_table2)}")
            
            # sort frequency table by frequency (decreasing)
            freq_table2 <- freq_table2[order(freq_table2$freq, decreasing = TRUE),]
            log_info("final rows: {nrow(freq_table2)}")
            
            
            # pick most common combination as prediction for word 4
            pred <- as.character(freq_table2[1,4])
            
        } else {
            pred <- "?"
        }

        return(pred)
    } 

    # Return the provided sentence ----
    textInput <- reactive(input$sentence)
    
    output$sentence <- renderPrint({
        input <- textInput()
        
        load(file = "fourgram_sep.rda")
        
        pred <- freq_lookup_function(input, freq_table = fourgram_sep)
        paste(input, pred)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
