library(shiny)
library(DAAG)
library(stringr)
library(knitr)
library(leaps)
library(chemometrics)

shinyServer(function(input, output) {
  

  # load data
  output$dataIsLoaded <- reactive({FALSE})
  dataLoaded <- reactive({
    inFile <- input$file
    if (is.null(inFile))
      return(NULL)
    output$dataLoaded = reactive({TRUE})
    if (input$idCol)
      return(read.table(inFile$datapath, header = TRUE, sep = "", dec = ".")[-1])
    read.table(inFile$datapath, header = input$header, sep = "", dec = ".")
  })
  output$varNames <- renderText({
    namesVector <- names(dataLoaded())
    paste(namesVector, collapse = ', ')
  })


  # fit model
  mod <- reactive({
    lm(as.formula(input$formula),data = dataLoaded())
  })
  
  # compute summary and anova
  output$summary <- renderPrint({summary(mod())})
  output$anova <- renderPrint({anova(mod())})
  # multicorrelation tab
  output$vif <- renderPrint({vif(mod())})
  output$cor <- renderPrint({cor(dataLoaded())})
  output$corPlot <- renderPlot({plot(dataLoaded())})
  # residual plots
  output$resFitPlot <- renderPlot({
    par(mfrow=c(2,2));plot(mod())
  })
  
  # model selection
  output$modelSelection <- renderTable({
    result <- summary(regsubsets(as.formula(input$formula),data = dataLoaded(), nvmax = input$nvmax, nbest=input$nbest))
    idx <- result$which
    idx <- idx[,-1]*1
    
    k <- rownames(idx)
    # r2
    r2 <- round(result$rsq,3)
    # adjr2
    adjr2 <- round(result$adjr2,3)
    # BIC
    bic <- round(result$bic,3)
    
    # table
    result_table <- cbind(k,as.matrix(idx),r2,adjr2,bic)
    data.frame(apply(result_table,2,as.numeric))
  })
  

})


