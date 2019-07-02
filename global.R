library(shiny)
library(shinydashboard)
library(leaflet.extras)
library(xts)
library(leaflet)
library(plotly)
library(DT)
library(highcharter)
library(shinythemes)
library(dplyr)

# setwd("D:/EDUCATION/MDS Sem 2/DEV/Assign4/4 R Shiny/shinyChiProject-master/")

#Read the file
Chicago_Crimes = readRDS("Chicago_Crimes_cln.rds")

#Convert the column values in to factors.
Chicago_Crimes$year = factor(Chicago_Crimes$year, levels=2012:2017)
Chicago_Crimes$month = factor(Chicago_Crimes$month, levels =1:12)
Chicago_Crimes$hour = factor(Chicago_Crimes$hour, levels=0:23)

Chicago_Crimes_sub=Chicago_Crimes[Chicago_Crimes$year==2013 | Chicago_Crimes$year ==2014 | Chicago_Crimes$year == 2015 | Chicago_Crimes$year == 2016,]


primary.type.count <- Chicago_Crimes %>%
  group_by(primary_type) %>%
  summarise(Count=n())


arrest.count = Chicago_Crimes %>%
  group_by(arrest) %>%
  summarise(Count=n())

month.count = Chicago_Crimes %>% 
  group_by(month) %>%
  summarise(Count=n())

hour.count = Chicago_Crimes %>%
  group_by(hour) %>%
  summarise(Count=n())

class.count= Chicago_Crimes %>%
  group_by(class) %>%
  summarise(Count=n())

c1=unique(arrest.count$arrest)

c3=unique(class.count$class)

c4=unique(primary.type.count$primary_type)

chicago.population=2716000
