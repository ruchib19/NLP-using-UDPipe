#################################################
#               NLP using UDPipe                #
#################################################

# initialize shiny server
shinyServer(function(input, output,session) {
  set.seed=2092014 
  options(shiny.maxRequestSize = 30*1024^2)

#annotating the document with the POS tags in the udpipe model  
dataset <- reactive({
    
    validate(
      need(input$file1 != "", "Please input a .txt file")
    )
    
    validate(
      need(input$file2 != "", "Please input a UDPipe model")
    )
       con <- file(input$file1$datapath, open="r")
       test <- readLines(con, warn = FALSE,encoding="UTF-8")
       udp_model = udpipe_load_model(input$file2$datapath)
  
     anotation <- udpipe_annotate(udp_model, x = test)
     return(as.data.frame(anotation))
  })

#filtering out nouns and adjectives to get major themes in the word cloud
output$wordCloud <- renderPlot({
  topics = dataset() %>% subset(., upos %in% c("NOUN","ADJ","PROPN"))
  top_topics = txt_freq(topics$lemma)
  wordcloud(words = top_topics$key, 
            freq = top_topics$freq, 
            min.freq = 2, 
            max.words = 100,
            random.order = FALSE, 
            colors = brewer.pal(6, "Dark2"))
})

#frequency plot for all the used POS tags in the input file
output$posPlot <- renderPlot({
  stats <- txt_freq(dataset()$upos)
  stats$key <- factor(stats$key, levels = rev(stats$key))
  barchart(key ~ freq, data = stats, col = "orange", 
           main = "UPOS Occurrence", 
           xlab = "Freq")
})

#calculating Cooccurrences within a sentence
test_cooc_s <- reactive({
    validate(
      need(input$checkGroup != "", "Please select atleast 1 Xpos type")
    )
    test <- cooccurrence(
    x = subset(dataset(), upos %in% c(input$checkGroup)), 
    term = "lemma", 
    group = c("doc_id", "paragraph_id", "sentence_id"))
    return(test)
    
  })

#plotting Cooccurrences within a sentence
test_cooc <- reactive({
  
  validate(
    need(input$checkGroup != "", "Please select atleast 1 Xpos type")
  )
  x = dataset()
  test <-  cooccurrence(x = x$lemma, 
  relevant = x$upos %in% c(input$checkGroup), skipgram = input$skipgramN)
  return(test)
  
})

#pclaculating Cooccurrences within selected (from the input) words
  output$coocPlot_s <- renderPlot({
      wordnetwork <- head(test_cooc_s(),input$topN)
      wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
      ggraph(wordnetwork, layout = "fr") +  
      
      geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "red") +  
      geom_node_text(aes(label = name), col = "blue", size = 4) +
      theme_graph(base_family = "Arial Narrow") +  
      
      labs(title = "Co-occurrence graph within the same Sentence")
      
  })
      
  #plotting Cooccurrences within selected (from the input) words
  output$coocPlot <- renderPlot({
  wordnetwork <- head(test_cooc(),input$topN)
  wordnetwork <- igraph::graph_from_data_frame(wordnetwork)
  ggraph(wordnetwork, layout = "fr") +  
    
  geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "red") +  
  geom_node_text(aes(label = name), col = "blue", size = 4) +
  theme_graph(base_family = "Arial Narrow") +  
          
  labs(title = "Cooccurrences within N words distance")
  }) 
  
})


