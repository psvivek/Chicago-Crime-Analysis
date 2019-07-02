#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#



# server logic
shinyServer(function(input, output, session) {
  
  ############## BAR GRAPH FOR YEARLY CRIME RATE #################   
  
  # For Reactiv Plotting.
  primarytype<-reactive({
    bar1 <- Chicago_Crimes_sub[Chicago_Crimes_sub$primary_type == input$crimerate,] %>%
      group_by(year) %>%
      summarise(crime=(n()/chicago.population)*100000)
  })
  
  # Render Plotly.
  output$crimeratesyear = renderPlotly({
    
    p <- plot_ly(data=primarytype(), x = ~year, y = ~crime, type = 'bar', width =0.1,
                 marker = list(color = 'rgb(96, 207, 23)'),
                 add_text = list(text= ~crime, textposition="top left")) %>%
      layout(title = "Yearly Crime Rate",
             xaxis = list(title = "Year"),
             yaxis = list(title = "Rate"),
             plot_bgcolor = "#ecf0f5",
             paper_bgcolor='#ecf0f5',
             height=480,
             width=640,
             bargap = 0.6)
    
  })   
  
  
  ############## AREA GRAPH FOR YEARLY CRIME TYPES ####################    
  
  primarytype1<-reactive({
    bar2 <- Chicago_Crimes_sub[Chicago_Crimes_sub$primary_type == input$crimetype,] %>%
      group_by(year) %>%
      summarise(Total = n())
  })
  
  
  output$crimetypesyear = renderPlotly({
    
    p <- plot_ly(data=primarytype1(), x = ~year, y = ~Total, type = 'bar', width =0.1,
                 marker = list(color = 'rgb(229, 43, 43)'),
                 add_text = list(text= ~Total, textposition="top left")) %>%
      layout(title = "Yearly Crime Type",
             xaxis = list(title = "Year"),
             yaxis = list(title = "Total"),
             plot_bgcolor = "#ecf0f5",
             paper_bgcolor='#ecf0f5',
             height=480,
             width=640,
             bargap = 0.6)
    
  }) 
    
  
  ################## AREA GRAPH FOR HOURLY LOCATIONS  ##################     
  
  locbyhour<-reactive({
    validate(
      need(input$location_type != "", "Please Select Location"))
    if (input$location_type=='ALL'){
      Chicago_Crimes_sub
    }
    else{
      Chicago_Crimes_sub %>% filter(class %in% input$location_type)
    }
    
    bar3 <- Chicago_Crimes_sub[Chicago_Crimes_sub$class == input$location_type,] %>%
      group_by(hour) %>%
      summarise(Total = n())
  })
  
  
  output$bargraphlocationsbyhour = renderPlotly({
    
    p = plot_ly(locbyhour(), x= ~hour, y = ~Total, type = 'scatter', mode = 'markers',
                fill = 'tonexty') %>%
      layout(yaxis=list(title="Total Crimes per Hour by Location"))
    
  })
  
  
  ###################### CRIME TYPE BY HOUR ######################
  
  crimebyhour<-reactive({
    bar4 <- Chicago_Crimes_sub[Chicago_Crimes_sub$primary_type == input$crime_type2,] %>%
      group_by(hour) %>%
      summarise(Total = n())
  })
  
  
  output$areacrimesbyhour = renderPlotly({
    
    p = plot_ly(crimebyhour(), x= ~hour, y = ~Total, type = 'scatter', mode = 'markers',
                fill = 'tozeroy', fillcolor= input$crime_type2) %>%
      layout(yaxis=list(title="Total Crimes per Location per Hour"))
    
  })
  
  
  ################## HEATMAP #######################   
  
  # Reactive Heat Map
  reactheatmap <- reactive({
    Chicago_Crimes_sub %>%
      filter(arrest %in% input$types &
               class %in% input$classes &
               year %in% cbind(input$years[1],input$years[2]))
    
    
  })
  
  ################## HEATMAP USING CARTODB & LEAFLET #######################    
  output$heatmap <- renderLeaflet({
      
      leaflet() %>% 
      addProviderTiles(providers$CartoDB.DarkMatter) %>% 
      setView(-87.6298, 41.8781,zoom=12)
    
  })
  
  
  observe({
    proxy <- leafletProxy("heatmap", data = reactheatmap()) %>%
      removeWebGLHeatmap(layerId='a') %>%
      addWebGLHeatmap(layerId='a',data=reactheatmap(),
                      lng=~longitude, lat=~latitude,
                      size=130)
  })
  
  reactmap=reactive({
    Chicago_Crimes_sub %>% 
      filter(arrest %in% input$types1 &
               class %in% input$classes1 &
               year %in% cbind(input$years1[1],input$years1[2]))
    
  })
  
  ############## REGULAR MAP WITH LEAFLET ###################
  output$map=renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$Esri.WorldStreetMap) %>% 
      setView(-87.6298, 41.8781,zoom=12)
    
    
  })
  observe({
    proxy=leafletProxy("map", data=reactmap()) %>% 
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addCircleMarkers(clusterOptions=markerClusterOptions(), 
                       lng=~longitude, lat=~latitude,radius=6, group='Cluster',
                       popup=~paste('<b><font color="Black">','Crime Info','</font></b><br/>',
                                    'Crime Type:', primary_type,'<br/>',
                                    'Crime Desc:', description,'<br/>',
                                    'Date:', date,'<br/>',
                                    #'Time:', Time,'<br/v',
                                    'Arrest:', arrest, '<br/>',
                                    'Location:', location_description,'<br/>',
                                    'IUCR Code:', iucr,'<br/>')) 
    
  })
  
  ############### DATA TABLE ###################
  
  output$table <- DT::renderDataTable({
    datatable(Chicago_Crimes_sub, rownames=FALSE) %>% 
      formatStyle(input$selected,  
                  background="cyan", fontWeight='bold')
  })
  
  ############## TIMESERIES ################
  
  arrests.date <- na.omit(Chicago_Crimes_sub[Chicago_Crimes_sub$arrest == 'True',]) %>% 
    group_by(date) %>% 
    summarise(Total = n())
  
  time.series.arrests <- xts(arrests.date$Total, order.by=as.POSIXct(arrests.date$date))
  
  output$hcontainer <-renderHighchart({
    
    yaxis = time.series.arrests
    
    highchart(type="stock") %>%
      hc_exporting(enabled = TRUE) %>%
      hc_xAxis(anydate(time.series.arrests, tz="America/Chicago")) %>%
      hc_title(text = "Time Series Forcasting (Arrests)", margin = 10, align = "center") %>%
      hc_add_series(yaxis, name = "Arrests 2012 to 2016", id="T1", smoothed = TRUE, forced = TRUE, groupPixelWidth = 25) %>%
      hc_rangeSelector(buttons = list(
        list(type = 'all', text = 'All'),
        list(type = 'day', count = 7, text = '1 Week'),
        list(type = 'day', count = 30, text = '1 Month'),
        list(type = 'month', count = 3, text = '3 Months'),
        list(type = 'month', count = 6, text = '6 Months'),
        list(type = 'month', count = 12, text = '1 Year')
        )) %>%
      
      # Highcharter Theme
      hc_add_theme(hc_theme_darkunica())
  })
  
  # Group by date to summarise for Time series plot
  group.by.date <- na.omit(Chicago_Crimes_sub) %>% 
    group_by(date) %>% 
    summarise(Total = n())
  
  # create Extensable Time Series
  ts <- xts(group.by.date$Total, order.by=as.POSIXct(group.by.date$date))

  # Render Highcharter
  output$hcontainer1 <-renderHighchart({
    z.val = ts

    highchart(type="stock") %>%
      hc_exporting(enabled = TRUE) %>%
      hc_add_series(z.val, name = "Time Series Forcasting (Crimes)", smoothed = TRUE, forced = TRUE, groupPixelWidth = 25) %>%
      hc_title(text = "Crimes 2012 to 2016", margin = 20, align = "center") %>%
      hc_add_theme(hc_theme_darkunica()) %>% #,

      hc_rangeSelector(buttons = list(
        list(type = 'all', text = 'All'),
        list(type = 'day', count = 7, text = '1 Week'),
        list(type = 'day', count = 30, text = '1 Month'),
        list(type = 'month', count = 3, text = '3 Months'),
        list(type = 'month', count = 6, text = '6 Months'),
        list(type = 'month', count = 12, text = '1 Year')
      ))

  })
  
})

