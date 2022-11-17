# Description: Script to plot TPP & ONS data for deaths, imd, sex and age
#
# Input:  /output/tables/ethnic_group.csv
#
# output: output/ons/ethnicity_count.png
#         output/ons/ethnicity_count_eng.png
#         output/ons/ethnicity16_count.png
#         output/ons/ethnicity16_count_eng.png
#
# Author: Colm D Andrews
# Date:   14/07/2022
#
################################################################################
library(rlang,lib.loc = "C:/Users/candrews/Documents")
library(vctrs,lib.loc = "C:/Users/candrews/Documents")
library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)
library(ggforce)

fs::dir_create(here::here("output", "local", "ons"))
fs::dir_create(here::here("output", "local", "ons", "na_removed"))

####### NA removed
ethnicity <-
  read_csv(here::here("output","from_jobserver","release_2022_11_11","simple_patient_counts_registered.csv"),col_types =(cols())) %>%
  select("group","subgroup",starts_with("ethnicity_new_5"),"population") %>%
  mutate(percentage = round(ethnicity_new_5_filled / population *100,1),
         group=case_when(group=="age_band"~"Age\nBand",
                         group=="all"~"All",
                         group=="dementia"~"Dementia",
                         group=="diabetes"~"Diabetes",
                         group=="hypertension"~"Hypertension",
                         group=="imd"~"IMD",
                         group=="learning_disability"~"Learning\nDisability",
                         group=="region"~"Region",
                         group=="sex"~"Sex"),
         group = fct_relevel(group, 
                             "All","Age\nBand","Sex", "Region","IMD",
                             "Dementia","Diabetes","Hypertension","Learning\nDisability"),
         subgroup=case_when(subgroup=="M"~"Male",
                            subgroup=="F"~"Female",
                            TRUE~subgroup),
         across('subgroup', str_replace, 'True', 'Present'),
         across('subgroup', str_replace, 'False', 'Absent')
         ) %>%
  filter(subgroup!="missing")
         
 


ethnicity_plot<-  ethnicity %>%
  ggplot(aes(x = subgroup, y = percentage, fill = group)) +
  geom_hline(aes(yintercept=percentage[which(group=="All")]),color="#00468BFF",alpha = 0.5) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid( group~., scales = "free_y", space = 'free_y') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") + theme(legend.position = "none")

ggsave(
  filename = here::here(
    "output",
    "local",
    "ons",
    "na_removed",
    "ethnicity_plot.png"
  ),
  ethnicity_plot,
  dpi = 600,
  width = 50,
  height = 65,
  units = "cm"
)


######### Categories
ethnicity <-
  read_csv(here::here("output","from_jobserver","release_2022_11_11","simple_patient_counts_categories_registered.csv"),col_types =(cols())) %>%
  select("group","subgroup",ends_with("ethnicity_new_5_filled"),"population") %>%
  pivot_longer(
    cols = ends_with("ethnicity_new_5_filled"),
    names_to = "ethnicity",
    values_to = "n",
    values_drop_na = TRUE
  ) %>%
  mutate(percentage = round(n / population *100,1),
         group=case_when(group=="age_band"~"Age\nBand",
                         group=="all"~"All",
                         group=="dementia"~"Dementia",
                         group=="diabetes"~"Diabetes",
                         group=="hypertension"~"Hypertension",
                         group=="imd"~"IMD",
                         group=="learning_disability"~"Learning\nDisability",
                         group=="region"~"Region",
                         group=="sex"~"Sex"),
         group = fct_relevel(group, 
                             "All","Age\nBand","Sex", "Region","IMD",
                             "Dementia","Diabetes","Hypertension","Learning\nDisability"),
         subgroup=case_when(subgroup=="M"~"Male",
                            subgroup=="F"~"Female",
                            TRUE~subgroup),
         across('subgroup', str_replace, 'True', 'Present'),
         across('subgroup', str_replace, 'False', 'Absent'),
         across('ethnicity', str_replace, '_ethnicity_new_5_filled', '')
  ) %>%
  mutate(
  ethnicity = fct_relevel(ethnicity,
                      "Asian","Black","Mixed", "White","Other")
)

ethnicityhline<-ethnicity  %>% arrange(ethnicity,group) %>% group_by(ethnicity) %>%  mutate(across(percentage, first)) %>% ungroup

ethnicity_plot<-  ethnicity %>%
  ggplot(aes(x = subgroup, y = percentage, fill = group)) +
  geom_hline(data=ethnicityhline, 
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.5) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid( group~ethnicity, scales = "free", space = 'free') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients with a recorded ethnicity") + theme(legend.position = "none")

ethnicity_plot

ggsave(
  filename = here::here(
    "output",
    "local",
    "ons",
    "na_removed",
    "ethnicity_plot_category.png"
  ),
  ethnicity_plot,
  dpi = 600,
  width = 80,
  height = 65,
  units = "cm"
)

