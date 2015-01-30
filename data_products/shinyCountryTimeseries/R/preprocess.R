library(RCurl)
library(stringr)
library(reshape2)
library(dplyr)
##############
# FUNCTIONS
##############
getData <- function(url) {
    ## gets ebola data from GitHub repo
    data <- getURL(url, ssl.verifypeer = FALSE)
    df <- read.csv(textConnection(data), stringsAsFactors = FALSE)
    return(df)
}
standardizeDate <- function(date) {
    ## converts non-stanard dates to ISO 8601 format
    newDate <- format(as.Date(date, "%m/%d/%Y"))
    return(newDate)
}
getCountry <- function(string) {
    ## extracts string following an underscore
    country <- unlist(str_split(string, "[_]"))[2]
    country
}
toJsDate <- function(date) {
    ## convers date into a format that the Rickshaw library likes
    val <- as.POSIXct(as.Date(date),origin="1970-01-01")
    as.numeric(val)
}
splitByIndicator <- function(df) {
    ## subsets data on indicator
    df_cases <- df %>%
        filter(Type == "Cases") %>%
        select(Date, Country, Count)
    df_deaths <- df %>%
        filter(Type == "Deaths") %>%
        select(Date, Country, Count)
    df_list <- list("Cases" = df_cases,
                    "Deaths" = df_deaths)
    return(df_list)
}
mergeCasesAndDeaths <- function(df_list) {
    merge(df_list$Cases, df_list$Deaths, by = c("Date", "Country"))
}
getLongFormat <- function(df) {
    ## converts data.frame from wide to long for plotting
    df %>%
        mutate(Date = sapply(Date, standardizeDate, USE.NAMES = FALSE)) %>%
        melt() %>%
        ## get rid of Day variable
        filter(variable != "Day") %>%
        mutate(Country = as.factor(sapply(variable, getCountry, USE.NAMES = FALSE)),
               Count = value,
               Type = as.factor(ifelse(str_detect(variable, "Deaths"),
                                       "Deaths", "Cases"))) %>%
        select(Date, Country, Type, Count) %>%
        filter(!is.na(Count))
}