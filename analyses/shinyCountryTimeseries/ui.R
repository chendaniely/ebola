# ui.R

# devtools::install_github("rCharts", "ramnathv", ref = "dev")
library(rCharts)
library(shiny)


shinyUI(pageWithSidebar(
    
    ## Application title
    headerPanel("Plotting Ebola"),
    ## tags$header(includeScript("google-analytics.js")),
    
    sidebarPanel(
        ## Tab 1 - ggplot2
        conditionalPanel(condition = "input.conditionedPanels==1",
                         helpText("Interactive plot components"),
                         checkboxGroupInput("countries",
                                            label = h3("Countries to display"),
                                            choices = c("Guinea" = "Guinea",
                                                        "Liberia" = "Liberia",
                                                        "Sierra Leone" = "SierraLeone",
                                                        "Nigeria" = "Nigeria",
                                                        "Senegal" = "Senegal",
                                                        "All" = "All"),
                                            selected = "All"),
                         checkboxInput("log", "Plot y-axis on log scale")
        ),
        ## Tab 2 - Rickshaw
        conditionalPanel(condition = "input.conditionedPanels==2",
                         helpText("Please select an indicator to display."),
                         radioButtons("indicator",
                                      label = h3("Indicators"),
                                      choices = c("Cases" = "Cases",
                                                  "Deaths" = "Deaths"),
                                      selected = "Cases")
        ),
        ## Tab3 - NVD3
        conditionalPanel(condition = "input.conditionedPanels==3",
                         helpText("Panel 3"),
                         selectInput("type",
                                     label = h3("Choose chart type"),
                                     choices = c("multiBarChart", "multiBarHorizontalChart"),
                                     selected = "multiBarHorizontalChart"),
                         checkboxInput("stack",
                                       label = strong("Stacked Bars"),
                                       value = FALSE)
        )
    ),
    mainPanel(
        tabsetPanel(
            tabPanel("ggplot2", value = 1,
                     p("This graphs the cases and deaths of each country and normalizes the onset dates all to '0' so countries can be compared"),
                     "Data was all taken from Caitlin River's 'ebola' repository",
                     a('here', href = 'https://github.com/cmrivers/ebola'),
                     
                     plotOutput("plot")
            ),
            tabPanel("Rickshaw", value = 2,
                     p("This graphs the cases and deaths of each country on an absolute time scale."),
                     div(style = "display:inline;position:absolute",
                         includeCSS("css/rickshaw.css"),
                         showOutput("rickshaw", "rickshaw"))
            ),
            tabPanel("NVD3", value = 3,
                     p("This graphs the most recently reported cumulative cases and deaths for each country."),
                     showOutput("nvd3", "nvd3")
                     
            ),
            ## param needed to generate tabs
            id = "conditionedPanels"
        )
    )
))
