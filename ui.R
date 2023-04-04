ui <- fluidPage(
  #theme = bs_theme(bootswatch = "darkly"),
  
  # Add a nintendo theme
   theme = bs_theme(
     base_font=font_google("Press Start 2P"),
     bg="#e7e6e1", fg="#9e252a") %>%
  #   bs_add_rules('@import"https://unpkg.com/nes.css@latest/css/nes.min.css"'),
   thematic::thematic_shiny(font="auto"),
  
  # Add a title and sidebar
  titlePanel(tags$h3(tags$b("Best Games by Platform"))),
  # Put 2 inputs and an action button in the sidebar
  sidebarLayout(
    sidebarPanel(width = 3,
                 tags$br(),
                 pickerInput("console_select",
                             label = "Choose Console",
                             choices = games_sales_console,
                             # selected = 1,
                             multiple = TRUE,
                             options = pickerOptions(virtualScroll = 100,
                                                     actionsBox = TRUE,
                                                     size = 10)
                 ),
                 tags$br(),
                 tags$br(),
                 radioButtons("review_type",
                              "Review Type:",
                              choices = c("User/Critic Avg Score" = "user_critic_avg",
                                          "Critic Score" = "critic_score",
                                          "User Score" = "user_score")
                 ),
                 tags$br(),
                 tags$br(),
                 tags$br(),
                 actionButton(inputId = "go",
                              "Generate Plots and Table")
    ),
    # Add an extra tab to the main panel showing the data
    mainPanel(
      tabsetPanel(
        tabPanel("Plot",
                 fluidRow(
                   plotOutput("games_plot")
                 ),
                 fluidRow(
                   column(9, offset = 4,
                          sliderInput(inputId = "top_games",
                                      label = "Select number of top games", 
                                      min = 0, 
                                      max = 20,
                                      value = 10)
                   )
                 )
        ),
        tabPanel("Data",
                 dataTableOutput("table")
        )
      )
    )
  )
)
