library(dplyr)
library(stringr)
library(RCurl)
library(reshape2)
library(ggplot2)
library(rCharts)

url <- "https://raw.githubusercontent.com/cmrivers/ebola/master/country_timeseries.csv"
getData <- function(url) {
    data <- getURL(url, ssl.verifypeer = FALSE)
    df <- read.csv(textConnection(data), stringsAsFactors = FALSE)
    return(df)
}

standardizeDate <- function(date) {
    if (nchar(date) < 9) {
        newDate <- format(as.Date(date, "%m/%d/%y"))  
    } else {
        newDate <- format(as.Date(date, "%m/%d/%Y"))
    }
    return(newDate)
}

getCountry <- function(string) {
    country <- unlist(str_split(string, "[_]"))[2]
    country
}
df <- getData(url)
df$Date <- sapply(df$Date, standardizeDate, USE.NAMES = FALSE)
df_melt <- melt(df)

ebola <- df_melt %>%
    filter(variable != "Day") %>%
    mutate(Country = as.factor(sapply(variable, getCountry, USE.NAMES = FALSE)),
           Count = value,
           Type = as.factor(ifelse(str_detect(variable, "Deaths"), "Deaths", "Cases")),
           Date = as.Date(Date)) %>%
    select(Date, Country, Type, Count) %>%
    filter(!is.na(Count))

ebola_cases <- ebola %>%
    filter(Type == "Cases") %>%
    select(Date, Country, Count)
ebola_deaths <- ebola %>%
    filter(Type == "Deaths") %>%
    select(Date, Country, Count)

ebola_merge <- merge(ebola_cases, ebola_deaths, by = c("Date", "Country"))
names(ebola_merge) <- c("Date", "Country", "Cases", "Deaths")

ebola_max <- ebola %>%
    group_by(Country) %>%
    top_n(n=1)

n1 <- nPlot(Count ~ Type, group = "Country", data = ebola, type = "multiBarChart")
n1

ggplot(ebola, aes(Date, Count, col = Country)) + 
    geom_line() + 
    facet_grid(~Type)