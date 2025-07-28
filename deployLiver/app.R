# https://connect.doit.wisc.edu/OldFounderLiverDietStudy/

devtools::install_cran("plotly") #  not yet on UW dataviz
devtools::install_cran("markdown") #  not yet on UW dataviz
devtools::install_cran("cowplot") #  not yet on UW dataviz
devtools::install_cran("ggdendro") #  not yet on UW dataviz
devtools::install_github("byandell/foundr", ref = "v1.4")
options(shiny.sanitize.errors = FALSE)

dirpath <- file.path(".")
liverData <- readRDS(file.path(dirpath, "liverData.rds"))
liverSignal <- readRDS(file.path(dirpath, "liverSignal.rds"))
liverStats <- readRDS(file.path(dirpath, "liverStats.rds"))
liverModule <- readRDS(file.path(dirpath, "traitModule.rds"))

#source("appSetup.R")
datasets <- readRDS("datasets.rds")

customSettings <- list(
  help = "help.md",
  condition = "diet",
  entrykey = "Founder",
  dataset = datasets)

################################################################

title <- "Founder Liver Diet Study"

ui <- foundr::ui(title)

server <- function(input, output, session) {
  
  foundr::server(input, output, session,
                 liverData, liverSignal, liverStats,
                 customSettings, liverModule)
  
  # Allow reconnect with Shiny Server.
  session$allowReconnect(TRUE)
}

shiny::shinyApp(ui = ui, server = server)