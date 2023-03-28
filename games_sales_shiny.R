library(shiny)
library(tidyverse)
library(shinyWidgets)
library(bslib)
library(thematic)
library(rsconnect)
library(rsconnect)
rsconnect::setAccountInfo(name='sean-c-smith',
                          token='A92116A87A16764F6918175003C0B296',
                          secret='PZSTggvdLfJD5+TveDh+h8g7Wa5ZC3lb5hftsXNJ')

rsconnect::deployApp("games_sales_shiny.R")


games_sales <- CodeClanData::game_sales

# Create the user_critic_avg and pivot the table so these can
# used in a filter
games_sales_piv <- games_sales %>% 
  mutate(user_score = user_score * 10) %>% 
  mutate(user_critic_avg = (user_score + critic_score) / 2, .after = user_score) %>% 
  pivot_longer(cols = critic_score:user_critic_avg,
               names_to = "review_type",
               values_to = "review_score")

# Pull the distinct review_types, genre and platform
games_review_types <- games_sales_piv %>% 
  distinct(review_type) %>% 
  pull()

games_sales_genre <- games_sales_piv %>% 
  distinct(genre) %>% 
  pull()

games_sales_console <- games_sales_piv %>% 
  distinct(platform) %>% 
  pull()


# Create the UI
ui <- fluidPage(
  #theme = bs_theme(bootswatch = "darkly"),

  # Add a nintendo theme
  theme = bs_theme(
    base_font=font_google("Press Start 2P"),
    bg="#e7e6e1", fg="#9e252a") %>%
    bs_add_rules('@import"https://unpkg.com/nes.css@latest/css/nes.min.css"'),
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


server <- function(input, output, session) {
 
  # create games_filtered which is triggered by the action button 
  games_filtered <- eventReactive(input$go, {
    games_sales_piv %>%
      filter(review_type == input$review_type,
             # genre == input$genre_select,
             platform == input$console_select
      )
  })
 
  # create the plot 
  output$games_plot <- renderPlot({
    games_filtered() %>%  
      slice_max(review_score, n = input$top_games) %>% 
      ggplot() +
      aes(x = reorder(name, review_score),
          y = review_score,
          fill = genre) +
      geom_bar(stat = "identity",
               position = "dodge"
      ) +
      geom_text(aes(label = ifelse(review_score == max(review_score), review_score, "")),
                position = position_dodge(width=0.5), 
                size = 4,
                hjust = -0.1
      ) +
      coord_flip() + 
      ylim(0, 100) +
      labs(y = "Rating",
           x = "Games",
           fill = "Genre") +
      scale_fill_brewer(palette = "Set3") +
      theme_classic() +
      theme(
        text = element_text(size = 16, face = "bold")
      )
  })
  # create the table for the second tab
  output$table <- renderDataTable({
    games_filtered()
  })
}

shinyApp(ui, server)