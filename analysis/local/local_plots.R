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
library('glue')

fs::dir_create(here::here("output", "local", "ons"))
fs::dir_create(here::here("output", "local", "ons", "na_removed"))

####### NA removed
ethnicity <-
  read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_registered.csv"),col_types =(cols())) %>%
  select("group","subgroup",starts_with("ethnicity_new_5"),starts_with("any"),"population") %>%
  mutate(ethnicity_new_5_percentage = round(ethnicity_new_5_filled / population *100,1),
         any_percentage = round(any_filled / population *100,1),
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
  filter(subgroup!="missing") %>%
  mutate(any_percentage=any_percentage-ethnicity_new_5_percentage) %>%
  pivot_longer(
    cols=c(starts_with("ethnicity_new_5"),starts_with("any")),
    names_to = c( "ethnicity",".value"),
    names_pattern = "(.*)_(.*)"
  ) %>%
  mutate(ethnicity=case_when(ethnicity=="ethnicity_new_5"~"SNOMED:2022",
                             ethnicity=="any"~"SNOMED:2022 supplemented with SUS data"),
         ethnicity=fct_relevel(ethnicity,"SNOMED:2022 supplemented with SUS data","SNOMED:2022"))
         


ethnicity_plot<-  ethnicity %>%
  ggplot(aes(x = subgroup, y = percentage,alpha=ethnicity, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1))+
  geom_hline(aes(yintercept=percentage[which(group=="All"& ethnicity =="SNOMED:2022")]),color="#00468BFF",alpha = 0.5) +
  geom_hline(aes(yintercept=sum(percentage[which(group=="All")])),color="#00468BFF",alpha = 0.1) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid( group~., scales = "free_y", space = 'free_y') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") +
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom")

ggsave(
  filename = here::here(
    "output",
    "from_jobserver",
    "release_2022_11_18",
    "made_locally",
    "ethnicity_plot.png"
  ),
  ethnicity_plot,
  dpi = 600,
  width = 50,
  height = 65,
  units = "cm"
)

######### Categories
ethnicity_cat <-
  read_csv(here::here("output","from_jobserver","release_2022_11_18","simple_patient_counts_categories_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  mutate(Asian_anydiff=Asian_any-Asian_new,
         Black_anydiff=Black_any-Black_new,
         Mixed_anydiff=Mixed_any-Mixed_new,
         White_anydiff=White_any-White_new,
         Other_anydiff=Other_any-Other_new,) 



  # select("group","subgroup",ends_with("_5_filled"),"population")


ethnicity_cat_pivot <- ethnicity_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
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

ethnicityhline_new<-ethnicity_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage))  %>% ungroup %>% filter(codelist=="new")
ethnicityhline_any<-ethnicity_cat_pivot  %>% arrange(ethnicity,group) %>% group_by(ethnicity,codelist) %>% mutate(percentage=first(percentage)) %>% ungroup %>% filter(codelist=="any")

ethnicity_cat_pivot <- ethnicity_cat_pivot %>%
  mutate(codelist=case_when(codelist=="new"~"SNOMED:2022",
                            codelist=="anydiff"~"SNOMED:2022 supplemented with SUS data"),
         codelist=fct_relevel(codelist,"SNOMED:2022 supplemented with SUS data","SNOMED:2022"))


  
ethnicity_cat_plot<-  ethnicity_cat_pivot %>%
  filter(codelist!="any") %>%
  ggplot(aes(x = subgroup, y = percentage,alpha = codelist, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1))+
  geom_hline(data=ethnicityhline_new,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.6) +
  geom_hline(data=ethnicityhline_any,
             aes(yintercept=percentage),color="#00468BFF",alpha = 0.1) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid( group~ethnicity, scales = "free", space = 'free') +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of registered TPP patients") + 
  guides(fill = "none",alpha=guide_legend("")) +
  theme(legend.position = "bottom")

ethnicity_cat_plot

ggsave(
  filename = here::here(
    "output",
    "from_jobserver",
    "release_2022_11_18",
    "made_locally",
    "ethnicity_cat_plot.png"
  ),
  ethnicity_cat_plot,
  dpi = 600,
  width = 80,
  height = 65,
  units = "cm"
)
