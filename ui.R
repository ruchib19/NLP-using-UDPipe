#################################################
#               NLP using UDPipe                #
#################################################

# Load all required libraries

library(shiny)
library(text2vec)
library(tm)
library(tokenizers)
library(wordcloud)
library(slam)
library(maptpx)
library(igraph)
library(udpipe)
library(textrank)
library(lattice)
library(ggraph)
library(ggplot2)
library(wordcloud)
library(stringr)
library(data.table)
library(dplyr)
library(wordcloud)


# initialize shiny UI
shinyUI(fluidPage(

 titlePanel("NLP using UDPipe"),
  
  # Inputs in sidepanel:
  sidebarPanel(
    
    fileInput("file1", "Upload text file (UTF-8)"),
    
    fileInput("file2", "Upload UDPipe model"),
    
    checkboxGroupInput("checkGroup", label = h3("Select XPOS"), 
                       choices = list("Adjective" = "ADJ",
                                      "Noun" = "NOUN",
                                      "Proper noun" = "PROPN",
                                      "Adverb" = "ADV",
                                      "Verb" = "VERB"),
                       selected = c("ADJ","NOUN","PROPN")),
    
    numericInput("topN", "Select top number of words to plot the Cooccurrences:", 50),
    
    sliderInput("skipgramN", "Select value of Skipgram (N-1)",
                min = 1, max = 25,
                value = 2)

    ),
  
  # Main Panel:
  mainPanel( 
    
    # Overview tab with Instructions to use the app
    tabsetPanel(type = "tabs",
                #
                tabPanel("Overview",h4(p("How to use this App")),
                         p("The app lets you do basic text analysis of a text document(languages for which UDPipe models are available) 
                            with specific pos tags."),
                         br(),
                         
                         p("1. Enter a text file that you want to process and the UDPipe model for the language of the input file, click on Browse in left-sidebar panel and upload the txt file."),
                         br(),
                        
                         p("2. The Summary Tab shows a chart of all POS tags used in the input file with their frequency of occurrence. The Word cloud shows the major themes present in the input file."),
                         br(),
                         
                         p("3. The Cooccurrences within Sentence shows how frequent do words occur in the same sentence"),
                         br(),
                         
                         p("4. The Cooccurrences within N words distance shows How frequent do words follow one another even if we would skip n-1* words in between"),
                         br(),
                         
                         p("Input: # of words to plot the Cooccurrences (applicable to both Cooccurrence plots): You can change the number of Top words to be considered for the plots"),
                         p("Input: Skipgram (N-1)* (applicable to Cooccurrence plots within N words): You can change the number of words to skip for the cooccurrence.
                            For Example, If Skipgram input is selected as 2 (N-1), the Cooccurrence plots will be within 3 (N) words"),
                        
                         br(),
                         br(),
                         
                         p("Note: Please follow the link to download UDPipe model for available languages: https://rdrr.io/cran/udpipe/man/udpipe_download_model.html"),
                         p("--------------------------------------Save your input text file in UTF-8 encoding to avoid issues----------------------------------------")

                ),
                
                # Summary tab to show basic POS tags used and major themes highlghted in the input text
                tabPanel("Summary",
                         plotOutput("posPlot"),
                         br(),
                         br(),
                         h4("Major Themes of the Input Text",align = "center"),
                         plotOutput("wordCloud")),
                
                # Cooccurrences Plots
                
                tabPanel("Cooccurrences within Sentence",
                         plotOutput("coocPlot_s",height = 700, width = 700)),
                         
                tabPanel("Cooccurrences within N words distance",
                                  plotOutput("coocPlot",height = 700, width = 700))
                ))
 ))

