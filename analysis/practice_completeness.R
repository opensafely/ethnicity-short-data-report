## Completeness of ethnicity recording by practice

library(arrow)
library("tidyverse")


data <- read_feather(here::here("output", "extract_5", "input_5.feather"))

data_count <- data %>%
  filter(registered == T) %>%
  summarise(practice,
    n = 1,
    recorded_ethnicity = case_when(
      !is.na(ethnicity_new_5) ~ 1,
      TRUE ~ 0
    )
  ) %>%
  group_by(practice) %>%
  summarise(
    n = sum(n),
    n_recorded_ethnicity = sum(recorded_ethnicity),
    completeness = n_recorded_ethnicity / n * 100
  ) %>%
  filter(n > 1000) %>%
  ungroup() %>%
  summarise(
    p05 = quantile(completeness, probs = seq(0, 1, 0.05), na.rm = TRUE)["5%"] %>% round(digits = 1),
    Q1 = quantile(completeness, na.rm = TRUE)["25%"] %>% round(digits = 1),
    median = median(completeness, na.rm = TRUE) %>% round(digits = 1),
    Q3 = quantile(completeness, na.rm = TRUE)["75%"] %>% round(digits = 1),
    p95 = quantile(completeness, probs = seq(0, 1, 0.05), na.rm = TRUE)["95%"] %>% round(digits = 1)
  )

write_csv(data_count, here::here("output", "extract_5", "practice_completeness.csv"))
