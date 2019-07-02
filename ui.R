# setwd("D:/EDUCATION/MDS Sem 2/DEV/Assign4/4 R Shiny/shinyChiProject-master/www")
library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin="red", 
    
  dashboardHeader(title = "Chicago Crime Analysis"), 
  dashboardSidebar(
    
    sidebarMenu(
      menuItem(text = "Heat Map", tabName = "heatmap", icon = icon("fire")),
      menuItem(text = "Circle Map", tabName = "map", icon = icon("map-pin")),
      menuItem("Time Series", tabName = "timeseries", icon = icon("hourglass"),
               menuSubItem("Yearly Crime Rates", tabName="yearcrimerate"),
               menuSubItem("Yearly Crime Types", tabName="yearcrimetype"),
               menuSubItem("Hourly Crimes & Locations", tabName="hourcrimelocations"),
               menuSubItem("CLEAR (Arrests & Crimes)", tabName= "arrestscrimes")),
      menuItem("Data", tabName = "data", icon = icon("database")))
  ), 
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
    
    tabItems(
      tabItem(tabName = 'arrestscrimes',
              fluidRow((highchartOutput('hcontainer'))),
              fluidRow((highchartOutput('hcontainer1')))),
      
      
      tabItem(tabName = 'yearcrimetype',
              selectInput(inputId='crimetype', label=h3('Yearly Crime Type'), choices = c4, selected = 'HOMICIDE'),
              plotlyOutput('crimetypesyear', height = "auto", width ="auto")),
      
      tabItem(tabName = 'yearcrimerate',
              selectInput(inputId='crimerate', label=h3('Yearly Crime Rates'), choices = c4, selected = 'CRIMINAL TRESPASS'),
              plotlyOutput('crimeratesyear', height = "auto", width ="auto")),
      
      tabItem(tabName = 'hourcrimelocations',
              fluidRow(
                column(3, 
                       selectInput(inputId='location_type', label=h3('Select Locations'), choices = c3, selected = 'RESIDENCE')),
                
                column(9,
                       plotlyOutput(outputId = "bargraphlocationsbyhour", height="auto", width ="auto"))),
              
              fluidRow(
                column(3, 
                        selectInput(inputId='crime_type2', label=h3('Select Crime'), choices = c4,
                            selected = 'HOMICIDE')),
                column(9,
                       plotlyOutput(outputId = "areacrimesbyhour", 
                                    height="auto", width ="auto")))
              ),
              
      
      tabItem(tabName = "data",
              # datatable
              fluidRow(box(DT::dataTableOutput("table"), width = 12))), 
      
      tabItem(tabName='heatmap',
              div(class="map",
              tags$head(
                tags$style(type = "text/css", "#heatmap {height: calc(100vh - 50px) !important;}"
              ))),
              
                         leafletOutput("heatmap",width = '100%',height = '100%'),
                                      
                                       div(class="map"), 
                         absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE, draggable = TRUE,
                                       top = 150, left = "auto", right = 15, bottom = "auto",
                                       width = 200, height = "auto",
                                       
                                       checkboxGroupInput(inputId="classes", label=h4("Select Location"),
                                                          choices=c3),
                                       
                                       checkboxGroupInput(inputId="types", label=h4("Select Arrest Type"),
                                                   choices=c1, selected = "True"),

                                        sliderInput(inputId = "years", label = h4("Select Year"), min=2012, max=2016, step =1,
                                        sep='', value = c(2012,2016)))),
      
      tabItem(tabName='map',
              div(class="map",
                  tags$head(
                    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
                  )),
                        leafletOutput("map",width = '100%',height = '100%'),
                        
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE, draggable = TRUE, 
                                      top = 150, left = "auto", right = 15, bottom = "auto",
                                      width = 200, height = "auto",
                                      checkboxGroupInput(inputId = "classes1", label = h4("Select Locality"), 
                                                         choices = c3),
                                      checkboxGroupInput(inputId = "types1", label = h4("Select Arrest Type"), 
                                                   choices = c1, selected = "True"),
                                      sliderInput(inputId = "years1", label = h4("Select Year"), min=2012, max=2016, step =1,
                                                   sep='', value = c(2012,2016)))
                                      
)))))




