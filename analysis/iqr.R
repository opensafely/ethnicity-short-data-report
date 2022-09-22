# Author: Colm D Andrews
# Date: 22/09/2022
#
################################################################################

library("tidyverse")
library("dplyr")


fs::dir_create(here::here("output", "simplified_output","5_group","tables"))

input<-arrow::read_feather(here::here("output","data","input.feather")) %>%
  mutate(ethnicity_new_5=as.numeric(as.character(ethnicity_new_5)),
         ethnicity_5=as.numeric(as.character(ethnicity_5)),
         ethnicity_primis_5=as.numeric(as.character(ethnicity_primis_5)))

summary_full <- input %>% 
  summarise_at(vars(ethnicity_5,ethnicity_new_5,ethnicity_primis_5), na.rm = TRUE,
               list(min=min, Q1=~quantile(., probs = 0.25, na.rm = TRUE),
                    median=median, Q3=~quantile(., probs = 0.75, na.rm = TRUE),
                    max=max))

summary_full<-summary_full  %>% pivot_longer(
  everything(),
  names_to = c( "codelist","measure"),
  names_pattern = "(.*)_(.*)",
  values_to = "value"
)  %>% pivot_wider(names_from = measure, values_from = value) %>%
  rowwise() %>%
  mutate(n_max = nrow(input[which(input[,codelist]==max),]),
         n_min = nrow(input[which(input[,codelist]==min),]))

write_csv(summary_full,here::here("output", "simplified_output","5_group","tables","range_fullset.csv"))

input_reg <-input %>%
  filter(registered)

summary_reg <- input_reg %>%
  summarise_at(vars(ethnicity_5,ethnicity_new_5,ethnicity_primis_5), na.rm = TRUE,
               list(min=min, Q1=~quantile(., probs = 0.25, na.rm = TRUE),
                    median=median, Q3=~quantile(., probs = 0.75, na.rm = TRUE),
                    max=max))

  summary_reg<-summary_reg  %>% pivot_longer(
  everything(),
  names_to = c( "codelist","measure"),
  names_pattern = "(.*)_(.*)",
  values_to = "value"
)  %>% pivot_wider(names_from = measure, values_from = value) %>%
  rowwise() %>%
  mutate(n_max = nrow(input_reg[which(input_reg[,codelist]==max),]),
         n_min = nrow(input_reg[which(input_reg[,codelist]==min),]))

write_csv(summary_reg,here::here("output", "simplified_output","5_group","tables","range_registered.csv"))
