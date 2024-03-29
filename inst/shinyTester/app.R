library(shiny)
devtools::install_cran("plotly") #  not yet on UW dataviz
devtools::install_cran("markdown") #  not yet on UW dataviz
devtools::install_cran("cowplot") #  not yet on UW dataviz
devtools::install_cran("ggdendro") #  not yet on UW dataviz
#devtools::install_github("byandell/foundr")
library(foundr)

dirpath <- "~/FounderDietStudy"
traitData <- readRDS(file.path(dirpath, "Enrich", "EnrichData.rds"))
traitStats <- readRDS(file.path(dirpath, "Enrich", "EnrichStats.rds"))
traitSignal <- readRDS(file.path(dirpath, "Enrich", "EnrichSignal.rds"))
traitData$dataset <- "Enrich"
traitSignal$dataset <- "Enrich"
traitStats$dataset <- "Enrich"

################################################################

title <- "Test Time Module"
testApp <- foundr::shinyTimes
testUI <- foundr::shinyTimesUI

ui <- function() {
  # INPUTS
  #   input$facet 
  #   input$strains 
  #
  # OUTPUTS
  #   output$filename
  #   output$downloadPlot
  #   output$downloadTable
  
  shiny::fluidPage(
    shiny::titlePanel(title),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput("strains"), # See SERVER-SIDE INPUTS below
        shiny::checkboxInput("facet", "Facet by strain?", FALSE),
        shiny::fluidRow(
          shiny::column(
            6,
            shiny::uiOutput("filename")), # See MODULE INPUT below
          shiny::column(
            3,
            shiny::downloadButton("downloadPlot", "Plots")),
          shiny::column(
            3,
            shiny::downloadButton("downloadTable", "Data")))
        ),
      
      shiny::mainPanel(
        testUI("shinyTest")
        )))
}

server <- function(input, output, session) {
  
  # SERVER-SIDE INPUTS
  output$strains <- shiny::renderUI({
    choices <- names(foundr::CCcolors)
    shiny::checkboxGroupInput("strains", "Strains",
                              choices = choices, selected = choices, inline = TRUE)
  })
  
  # DATA OBJECTS 
  traitDataInput <- shiny::reactive({
    traitData
  })
  traitSignalInput <- shiny::reactive({
    traitSignal
  })
  traitStatsInput <- shiny::reactive({
    traitStats
  })

  moduleOutput <- shiny::callModule(
    testApp, "shinyTest", 
    input, 
    traitDataInput, traitSignalInput, traitStatsInput)
  
  # I/O FROM MODULE
  # MODULE INPUT: File Prefix
  output$filename <- renderUI({
    shiny::req(moduleOutput())
    filename <- paste(moduleOutput()$traits, collapse = ".")
    shiny::textAreaInput("filename", "File Prefix", filename)
  })

  # MODULE OUTPUT: Plot
  output$downloadPlot <- shiny::downloadHandler(
    filename = function() {
      paste0(shiny::req(input$filename), ".pdf")
    },
    content = function(file) {
      grDevices::pdf(file, width = 9, height = 6)
      print(moduleOutput()$plot)
      grDevices::dev.off()
    })
  
  # MODULE OUTPUT: DataTable
  output$downloadTable <- shiny::downloadHandler(
    filename = function() {
      paste0(shiny::req(input$filename), ".csv")
    },
    content = function(file) {
      utils::write.csv(
        moduleOutput()$table,
        file, row.names = FALSE)
    })
}

shiny::shinyApp(ui = ui, server = server)
