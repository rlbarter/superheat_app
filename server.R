library(shiny)
library(RColorBrewer)
library(superheat)
library(shinyjs)
library(cluster)


# iris data
iris.dat  <- iris[, -5]

# republican votes data
colnames(votes.repub) <- as.numeric(gsub("X", "", colnames(votes.repub)))
states <- !(rownames(votes.repub) %in% c("Wyoming", "Hawaii", "Alaska"))
votes.dat <- votes.repub[states, -c(1:15)]



# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  
  
  # when the plot changes, change the code as well
  html("code", code())
  
  loadedData <- reactive({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    dat <- read.csv(inFile$datapath, header = input$header)
    if (input$rowNames) {
      rownames(dat) <- dat[,1]
      dat <- dat[,-1]
    }
    
    dat

  })
  
  
  
  
  # Return the requested dataset
  datasetInput <- reactive({
 
      switch(input$dataset,
             "iris" = iris.dat,
             "votes" = votes.dat,
             "uploaded" = loadedData())
 
  })
  
    
  
  
  

  # view the first 10 rows of the data
  output$data_head <- renderTable({
    head(datasetInput(), 10)
  })
  
  
  # return the possible cluster numbers
  output$cluster_row_range <- renderUI({
    dataset <- datasetInput()
    selectInput("n.clusters.rows", "Number of row clusters",
                c("none", 1:(nrow(dataset) - 1)))
  })
  
  output$cluster_col_range <- renderUI({
    dataset <- datasetInput()
    selectInput("n.clusters.cols", "Number of column clusters",
                c("none", 1:(ncol(dataset) - 1)))
  })
  

  rowMembershipInput <- reactive({
    if (input$n.clusters.rows != "none") {
      return(kmeans(datasetInput(), centers = input$n.clusters.rows)$cluster)
    }
    else return(NULL)
  })

  colMembershipInput <- reactive({
    if (input$n.clusters.cols != "none") {
      return(kmeans(t(datasetInput()), centers = input$n.clusters.cols)$cluster)
    }
    else return(NULL)
  })

  colorsInput <- reactive({
    brewer.pal(9, input$brewer)
  })

  smoothInput <- reactive({
    input$smooth.heat
  })


  
  
  
  
  output$superheat <- renderImage({
   outfile <- tempfile(fileext = "tmp.png")
     png(outfile, 
        height = input$image_height,
        width = input$image_width)
    superheat(X = datasetInput(),
              
              membership.rows = rowMembershipInput(),
              membership.cols = colMembershipInput(),
              
              heat.pal = colorsInput(),
              smooth.heat = smoothInput(),
              
              left.text.angle = input$left_text_angle,
              bottom.text.angle = input$bottom_text_angle,
              left.text.size = input$left_text_size,
              bottom.text.size = input$bottom_text_size,
              left.heat.label = input$left_label,
              bottom.heat.label = input$bottom_label,
              left.label.size = input$left_label_size,
              bottom.label.size = input$bottom_label_size,
              
              cluster.hline = input$hlines,
              cluster.vline = input$vlines,
              cluster.hline.size = input$line_size,
              cluster.vline.size = input$line_size,
              cluster.hline.col = input$line_col,
              cluster.vline.col = input$line_col,
              
              legend.size = input$legend)
  
  dev.off()
  
  list(src = outfile, height = input$image_height, width = input$image_width) }, 
  deleteFile = TRUE) 
  





    # print the code
  datName <- reactive({
    
    switch(input$dataset,
           "iris" = "iris[,-5]",
           "votes" = "votes.repub",
           "uploaded" = "loadedData")
    
  })
  
    output$code <- renderText({
      code <- sprintf(paste0(
        "superheat(X = ", datName(), ", \n \n"))
      
      if (input$n.clusters.rows != "none")
        code <- paste0(code, "  n.clusters.rows = ", input$n.clusters.rows, ", \n")
      if (input$n.clusters.cols != "none")
        code <- paste0(code, "  n.clusters.cols = ", input$n.clusters.cols, ", \n")
      
      if ((input$n.clusters.rows != "none") | (input$n.clusters.cols != "none"))
        code <- paste0(code, "\n")
        
      
        code <- paste0(code, "  heat.pal = ", "brewer.pal(",9,", ", "'",input$brewer, "')")
        
        
      if (input$smooth.heat) {
        code <- paste0(code, ", \n")
        code <- paste0(code, "  smooth.heat = TRUE")
        code <- paste0(code, ", \n \n")
      } else {
        code <- paste0(code, ", \n \n")
        }
        
        

        
        
        code <- paste0(code, "  left.heat.label = ", '"', input$left_label, '"', ", \n")
        code <- paste0(code, "  bottom.heat.label = ", '"', input$bottom_label, '"')
        
        
        if (input$left_text_angle != 0) {
          code <- paste0(code, ", \n \n")
          code <- paste0(code, "  left.text.angle = ", input$left_text_angle)
        }
        if (input$bottom_text_angle != 0) {
          if (input$left_text_angle == 0)
            code <- paste0(code, ", \n \n")
          else 
            code <- paste0(code, ", \n")
          
          code <- paste0(code, "  bottom.text.angle = ", input$bottom_text_angle)
        }
        
        
        
        
        
        if (input$left_text_size != 5) {
          code <- paste0(code, ", \n \n")
          code <- paste0(code, "  left.text.size = ", input$left_text_size)
        }
        if (input$bottom_text_size != 5) {
          if (input$left_text_size == 5)
            code <- paste0(code, ", \n \n")
          else 
            code <- paste0(code, ", \n")
          code <- paste0(code, "  bottom.text.size = ", input$bottom_text_size)
        }
        
        
        
        
        if (input$left_label_size != 0.1) {
          code <- paste0(code, ", \n \n")
          code <- paste0(code, "  left.label.size = ", input$left_label_size)
        }
        if (input$bottom_label_size != 0.1) {
          if (input$left_label_size == 0.1)
            code <- paste0(code, ", \n \n")
          else 
            code <- paste0(code, ", \n")
          code <- paste0(code, "  bottom.label.size = ", input$bottom_label_size)
        }
        
        
        
        if (!input$hlines) {
          code <- paste0(code, ", \n \n")
          code <- paste0(code, "  cluster.hline = FALSE")
        }
        if (!input$vlines) {
          if (input$hlines)
            code <- paste0(code, ", \n \n")
          else 
            code <- paste0(code, ", \n")
          code <- paste0(code, "  cluster.vline = FALSE")
        }
        
        
        if (input$line_size != 0.5) {
          if ((!input$vlines) | (!input$hlines)) 
            code <- paste0(code, ", \n")
          else 
            code <- paste0(code, ", \n \n")
          code <- paste0(code, "  cluster.vline.size = ", input$line_size, ", \n")
          code <- paste0(code, "  cluster.hline.size = ", input$line_size)
        }
        
        
        
        if (input$line_col != "#000000") {
          if ((!input$vlines) | (!input$hlines) | (input$line_size != 0.5)) 
            code <- paste0(code, ", \n")
          else 
            code <- paste0(code, ", \n \n")
          
          code <- paste0(code, "  cluster.hline.col = ", '"', input$line_col, '"', ", \n")
          code <- paste0(code, "  cluster.vline.col = ", '"', input$line_col, '"')
        }
        
        if (input$legend != 2) {
          code <- paste0(code, ", \n \n")
          code <- paste0(code, "  legend.size = ", input$legend)
        }
        
      code <- paste0(code, ")")
      code
    })

})
