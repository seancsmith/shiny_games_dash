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