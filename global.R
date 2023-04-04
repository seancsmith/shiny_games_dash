library(shiny)
library(tidyverse)
library(shinyWidgets)
library(bslib)
library(thematic)
library(here)
library(rsconnect)

# rsconnect::setAccountInfo(name='sean-c-smith',
#                           token='A92116A87A16764F6918175003C0B296',
#                           secret='PZSTggvdLfJD5+TveDh+h8g7Wa5ZC3lb5hftsXNJ')
# 
# rsconnect::deployApp(here("../shiny_games_dash/"))

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