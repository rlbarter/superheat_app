library(shiny)
library(shinyjs)



# Define UI for application that draws a superheatmap


shinyUI(
  navbarPage("Superheat",
             tabPanel("data",
                      wellPanel(
                      tabsetPanel(
                         tabPanel("Select data",
                             selectInput("dataset", 
                                         "Select a loaded dataset",
                                         choices = c("Iris" = "iris", 
                                                     "Republican Votes" = "votes",
                                                     "Uploaded Dataset" = "uploaded")),
                             fileInput('file1', 'Choose a .csv file to upload',
                                       accept = c(
                                         'text/csv',
                                         'text/comma-separated-values',
                                         'text/tab-separated-values',
                                         'text/plain',
                                         '.csv',
                                         '.tsv'
                                       )
                             ),
                             checkboxInput('header', 'Column names', TRUE),
                             checkboxInput('rowNames', 'Row names', TRUE),
                             
                             p('After loading a .csv file, select "Uploaded dataset" from the drop-down menu above.')
                             
                        ),
                          tabPanel("View data",
                                p("View the first 10 rows of the dataset:"),
                                uiOutput("data_head")
                             )))

             ),
             tabPanel("heatmap",
                      wellPanel(
                        tabsetPanel(
                          tabPanel("Clustering",
                                   uiOutput("cluster_row_range"),
                                   uiOutput("cluster_col_range")),
                          tabPanel("Color",
                                   selectInput("brewer",
                                               "Color brewer palette:",
                                               choices = c("Blue/Green (sequential)" = "BuGn",
                                                           "Blue/Purple (sequential)" = "BuPu",
                                                           "Blue (sequential)" = "Blues",
                                                           "Green/Blue (sequential)" = "GnBu",
                                                           "Green (sequential)" = "Greens",
                                                           "Grey (sequential)" = "Greys",
                                                           "Orange (sequential)" = "Oranges",
                                                           "Orange/Red (sequential)" = "OrRd",
                                                           "Purple/Blue (sequential)" = "PuBu",
                                                           "Purple/Blue/Green (sequential)" = "PuBuGn",
                                                           "Purple/Red (sequential)" = "PuRd",
                                                           "Purple (sequential)" = "Purples",
                                                           "Red/Purple (sequential)" = "RdPu",
                                                           "Red (sequential)" = "Reds",
                                                           "Yellow/Green (sequential)" = "YlGn",
                                                           "Yellow/Green/Blue (sequential)" = "YlGnBu",
                                                           "Yellow/Orange/Brown (sequential)" = "YlOrBr",
                                                           "Yellow/Orange/Red (sequential)" = "YlOrRd",
                                                           "Brown/Green (diverging)" = "BrBG",
                                                           "Pink/Green (diverging)" = "PiYG",
                                                           "Purple/Green (diverging)" = "PRGn",
                                                           "Purple/Orange (diverging)" = "PuOr",
                                                           "Red/Blue (diverging)" = "RdBu",
                                                           "Red/Grey (diverging)" = "RdGy",
                                                           "Red/Yellow/Blue (diverging)" = "RdYlBu",
                                                           "Red/Yellow/Green (diverging)" = "RdYlGn")),
                                   #                 numericInput("n.col",
                                   #                       "Number of different palette colors",
                                   #                        min = 3,
                                   #                        max = 9,
                                   #                        value = 9),
                                   checkboxInput("reverse_col_order",
                                                 "Reverse palette order",
                                                 value = FALSE),
                                   checkboxInput("smooth.heat",
                                                 "Smooth heatmap within clusters",
                                                 value = FALSE),
                                   checkboxInput("manual_col",
                                                 "Manually select color",
                                                 value = FALSE),
                                   conditionalPanel(condition = "input.manual_col",
                                                    column(2.5, wellPanel(
                                                      class = "settings",
                                                      shinyjs::colourInput("low_col", 
                                                                           "Low", 
                                                                           "red", 
                                                                           showColour = "background")
                                                    )),
                                                    column(2.5, wellPanel(
                                                      class = "settings",
                                                      shinyjs::colourInput("med_col", 
                                                                           "Mid", 
                                                                           "white", 
                                                                           showColour = "background")
                                                    )),
                                                    column(2.5, wellPanel(
                                                      class = "settings",
                                                      shinyjs::colourInput("high_col", 
                                                                           "High", 
                                                                           "blue", 
                                                                           showColour = "background"))),
                                                    sliderInput("midpoint",
                                                                "Midpoint",
                                                                min = 0, max = 1, value = 0.5)
                                   )
                          ),
                          tabPanel("Grid",
                                   checkboxInput("hlines",
                                                 "Horizontal grid lines",
                                                 value = TRUE),
                                   checkboxInput("vlines",
                                                 "Vertical grid lines",
                                                 value = TRUE),
                                   sliderInput("line_size",
                                               "Grid thickness",
                                               min = 0,  max = 5, step = 0.5, value = 0.5),
                                   shinyjs::colourInput("line_col", 
                                                        "Grid colour", 
                                                        "black", 
                                                        showColour = "background"))
                          
                        ))
             ),
             tabPanel("labels",
                      wellPanel(
                        tabsetPanel(
                          tabPanel("Label type",
                                   radioButtons("left_label", label = "Left labels",
                                                choices = list("variable" = "variable", 
                                                               "cluster" = "cluster", 
                                                               "none" = "none"), 
                                                selected = "variable"),
                                   radioButtons("bottom_label", label = "Bottom labels",
                                                choices = list("variable" = "variable", 
                                                               "cluster" = "cluster", 
                                                               "none" = "none"), 
                                                selected = "variable")
                          ),
                          tabPanel("Label size",
                                   sliderInput("left_label_size",
                                               "Left label size",
                                               min = 0.1, max = 2, value = 0.1),
                                   sliderInput("bottom_label_size",
                                               "Bottom label size",
                                               min = 0.1, max = 2, value = 0.1)
                          ),
                          tabPanel("Text size",
                                   sliderInput("left_text_size",
                                               "Left text size",
                                               min = 1,  max = 20, value = 5),
                                   sliderInput("bottom_text_size",
                                               "Bottom text size",
                                               min = 1,  max = 20, value = 5)),
                          tabPanel("Text angle",
                                   sliderInput("left_text_angle",
                                               "Left text angle",
                                               min = 0,  max = 360, value = 0),
                                   sliderInput("bottom_text_angle",
                                               "Bottom text angle",
                                               min = 0,  max = 360, value = 0))
                          
                        ))
             ),
             tabPanel("image dimension",
                      wellPanel(
                        sliderInput("image_width",
                                    "Image width",
                                    min = 100, max = 3000, value = 800),
                        sliderInput("image_height",
                                    "Image height",
                                    min = 100, max = 3000, value = 600),
                        
                        sliderInput("legend",
                                    "Legend size",
                                    min = 0, max = 20, value = 2))
             ),
             tabPanel("view code",
                      wellPanel(
                        p("R code to produce the plot:"),
                        textOutput("code", container = pre)
                      )
             ),
             tabPanel("download",
                      wellPanel(
                        h4("Save the superheatmap"),
                        downloadButton('save_png', 'Download'),
                        h4("Download the row cluster membership vector"),
                        downloadButton('download_row', 'Download'),
                        h4("Download the column cluster membership vector"),
                        downloadButton('download_col', 'Download')
                      )),
             footer = column(12, plotOutput("superheat"))
             
             
  )
)

