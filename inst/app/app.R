
library(shiny)
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)

load(here::here("inst","backend","calculate_daily_data.rdata"))


# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Forint inflációja"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            numericInput(
              "START_AMOUNT",
              "Összeg értéke:",
              value = 10000
            ),
            checkboxInput("REVERSE", "A későbbi időpontban(?)",
                          value = FALSE),
            sliderInput("START_TIME",
                        "Earlier Date:",
                        min = as.Date("1992-01-01","%Y-%m-%d"),
                        max = as.Date("2023-01-01","%Y-%m-%d"),
                        value=as.Date("2019-05-04"),
                        timeFormat="%Y-%m-%d"),
            sliderInput("END_TIME",
                        "Későbbi időpont:",
                        min = as.Date("1992-01-01","%Y-%m-%d"),
                        max = as.Date("2023-10-30","%Y-%m-%d"),
                        value=as.Date("2023-10-01"),
                        timeFormat="%Y-%m-%d"),


            # Add your discreet message at the bottom
            tags$hr(),  # Horizontal line for separation
            tags$p("Ha megköszönnéd vagy kéne egy jó statisztikus:"),
            tags$a(href = "mailto:inquiries.mkmarton@gmail.com", "inquiries.mkmarton@gmail.com"),
            tags$p("Wallet: 0x253b92ccb486b0755b348d4b83b1c59e4819d034"),  # Replace '.....' with your wallet details
            style = "font-size: 80%; color: grey; text-align: left; padding-top: 20px;"  # Styling

        ),

        # Show a plot of the generated distribution
        mainPanel(
          textOutput("orig_val"),
          textOutput("end_val"),
          plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {


  cpi_begin     <- reactive({
    dat$cpi[dat$time == input$START_TIME]
    })

  cpi_end     <- reactive({
    dat$cpi[dat$time == input$END_TIME]
  })


  dat_react <- reactive({
    if (input$REVERSE == TRUE) {
      dat %>%
        mutate(current_forints = input$START_AMOUNT / cpi_end() * cpi )
    } else {
      dat %>%
        mutate(current_forints = input$START_AMOUNT / cpi_begin() * cpi )
    }

  })

  value_early <- reactive({
    if (input$REVERSE == TRUE) {
      input$START_AMOUNT * cpi_begin() / cpi_end()
    } else {
      input$START_AMOUNT
    }
  })

  value_late <- reactive({
    if (input$REVERSE == TRUE) {
      input$START_AMOUNT
    } else {
      input$START_AMOUNT * cpi_end() /  cpi_begin()
    }
  })

  output$distPlot <- renderPlot({

    dat_react() %>%
      ggplot( aes( x = time, y = current_forints)) +
      theme_bw() +
      theme( legend.position = "none") +
      geom_line()  +
      scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
      geom_hline( yintercept = value_early(), col = "salmon4") +
      geom_vline( xintercept = input$START_TIME, col = "salmon4") +
      geom_hline( yintercept = value_late(), col = "blue") +
      geom_vline( xintercept = input$END_TIME, col = "blue") +
      labs( x = "Dátum",
            y = "Nominális forint")
  })

  output$orig_val <- renderText({ value_early() %>% round() %>%
      paste0("Az összeg a korábbi időpontban: ",.," Ft") })
  output$end_val  <- renderText({
    value_late() %>% round() %>%
      paste0("Az összeg a későbbi időpontban: ",.," Ft")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
