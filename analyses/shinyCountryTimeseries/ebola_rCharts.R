library(dplyr)
library(stringr)
library(RCurl)
library(reshape2)
library(ggplot2)
library(rCharts)
setwd("~/GitHub/ebola/analyses/shinyCountryTimeseries/")

url <- "https://raw.githubusercontent.com/cmrivers/ebola/master/country_timeseries.csv"
getData <- function(url) {
## gets ebola data from GitHub repo
    data <- getURL(url, ssl.verifypeer = FALSE)
    df <- read.csv(textConnection(data), stringsAsFactors = FALSE)
    return(df)
}

standardizeDate <- function(date) {
## converts non-stanard dates to ISO 8601 format     
    if (nchar(date) < 9) {
        newDate <- format(as.Date(date, "%m/%d/%y"))  
    } else {
        newDate <- format(as.Date(date, "%m/%d/%Y"))
    }
    return(newDate)
}

getCountry <- function(string) {
# extracts string following an underscore
    country <- unlist(str_split(string, "[_]"))[2]
    country
}

toJsDate <- function(date){
# convers date into a format that the Rickshaw library likes
    val <- as.POSIXct(as.Date(date),origin="1970-01-01")
    as.numeric(val)
}


df <- getData(url)
df$Date <- sapply(df$Date, standardizeDate, USE.NAMES = FALSE)
df_melt <- melt(df)

ebola <- df_melt %>%
    filter(variable != "Day") %>%
    mutate(Country = as.factor(sapply(variable, getCountry, USE.NAMES = FALSE)),
           Count = value,
           Type = as.factor(ifelse(str_detect(variable, "Deaths"), 
                                   "Deaths", "Cases"))) %>%
    select(Date, Country, Type, Count) %>%
    filter(!is.na(Count))
# ebola_cases <- ebola %>%
#     filter(Type == "Cases") %>%
#     select(Date, Country, Count)
# ebola_deaths <- ebola %>%
#     filter(Type == "Deaths") %>%
#     select(Date, Country, Count)
# 
# ebola_merge <- merge(ebola_cases, ebola_deaths, by = c("Date", "Country"))
# names(ebola_merge) <- c("Date", "Country", "Cases", "Deaths")

## multibarchart with NVD3
ebola_last <- ebola %>%
    group_by(Country) %>%
    top_n(Date, n = 1)

n1 <- nPlot(Count ~ Type, group = "Country", data = ebola_last, type = "multiBarChart")
n1

## timeline with slider with Rickshaw
ebola_rickshaw <- ebola %>%
    mutate(Date = toJsDate(Date)) %>%
    filter(Type == "Cases") %>%
    arrange(Date)

r1 <- Rickshaw$new()
r1$layer(Count ~ Date, group = "Country", data = ebola_rickshaw, type = "line")
r1$set(slider = TRUE)
r1


