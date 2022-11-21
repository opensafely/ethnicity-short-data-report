################################################################################
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

library(tidyverse)
library(scales)
library(readr)
library(ggsci)
library(ggpubr)

fs::dir_create(here::here("output", "local", "ons"))
fs::dir_create(here::here("output", "local", "ons", "na_removed"))


###### process ONS



####### NA removed

# ethnicity_na <-
#   read_csv(here::here("output","from_jobserver","release_2022_11_09","ethnic_group_NA_registered.csv"),col_types =(cols())) %>%
#   mutate(cohort = case_when(cohort=="SNOMED"~ "SNOMED:2022",
#                             cohort=="ONS"~"2011 Census",
#                             TRUE ~cohort),
#     cohort = fct_relevel(cohort, 
#                               "2011 Census", "CTV3","SNOMED:2022")) %>%
#   filter(cohort != "CTV3" & cohort != "PRIMIS")



ethnicity_plot16_eng_na <-  ethnicity_na %>%
  filter(region == "England", group == "16") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities")

ggsave(
  filename = here::here(
    "output",
    "local",
    "ons",
    "na_removed",
    "ethnicity16_count_eng_na.png"
  ),
  ethnicity_plot16_eng_na,
  dpi = 600,
  width = 30,
  height = 30,
  units = "cm"
)

ethnicity_na_diff<-ethnicity_na %>%
  group_by(Ethnic_Group,region,group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) 


ethnicity_plot_na <- ethnicity_na_diff %>%
  filter(region != "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  # theme(panel.spacing = unit(2, "lines")) +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 12,
    hjust = 0.75,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities")  +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2011 Census","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.,hjust = -0.2) 


ggsave(
  filename = here::here("output", "local", "ons", "na_removed", "ethnicity_count_na.png"),
  ethnicity_plot_na,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
)



ethnicity_plot_eng_na <- ethnicity_na_diff %>%
  filter(region == "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities") +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="ONS","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=-0.5,hjust = -0.2)

ggsave(
  filename = here::here(
    "output",
    "local",
    "ons",
    "na_removed",
    "ethnicity_count_eng_na.png"
  ),
  ethnicity_plot_eng_na,
  dpi = 600,
  width = 30,
  height = 15,
  units = "cm"
)



ethnicity_plot16_na <- ethnicity_na %>%
  filter(region != "England", group == "16") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip() + scale_fill_lancet()  +
  xlab("") + ylab("\Proportion of ethnicities")


ggsave(
  filename = here::here("output", "local", "ons", "na_removed", "ethnicity16_count_na.png"),
  ethnicity_plot16_na,
  dpi = 600,
  width = 45,
  height = 30,
  units = "cm"
)


##### remove white / white british
ethnicity_plot_eng_nw <- ethnicity_na %>%
  filter(region == "England",Ethnic_Group!="White", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet()  +
  xlab("") + ylab("\nProportion of ethnicities")

ggsave(
  filename = here::here("output", "local", "ons", "ethnicity_count_eng_nw.png"),
  ethnicity_plot_eng_nw,
  dpi = 600,
  width = 30,
  height = 30,
  units = "cm"
)

ethnicity_plot_nw <- ethnicity_na %>%
  filter(region != "England",Ethnic_Group!="White" ,group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet()  +
  xlab("") + ylab("\nProportion of ethnicities")

ggsave(
  filename = here::here("output", "local", "ons", "ethnicity_count_nw.png"),
  ethnicity_plot_nw,
  dpi = 600,
  width = 45,
  height = 30,
  units = "cm"
)

ethnicity_plot16_nw <- ethnicity_na %>%
  filter(region != "England",Ethnic_Group!="White British", group == "16") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities")

ggsave(
  filename = here::here("output", "local", "ons", "ethnicity16_count_nw.png"),
  ethnicity_plot16_nw,
  dpi = 600,
  width = 45,
  height = 30,
  units = "cm"
)

ethnicity_plot16_eng_nw <- ethnicity_na %>%
  filter(region == "England",Ethnic_Group!="White British", group == "16") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities")

ggsave(
  filename = here::here("output", "local", "ons", "ethnicity16_count_eng_nw.png"),
  ethnicity_plot16_eng_nw,
  dpi = 600,
  width = 30,
  height = 30,
  units = "cm"
)



ethnicity_5_16 <-
  ggarrange(
    ethnicity_plot_eng_na,
    ethnicity_plot16_eng_na,
    labels = c("A", "B"),
    ncol = 1,
    nrow = 2,
    common.legend = T
  )

ggsave(
  filename = here::here("output", "local", "ons", "ethnicity_5_16_comb.png"),
  ethnicity_5_16,
  dpi = 600,
  width = 30,
  height = 45,
  units = "cm"
)

#### 2011 grouping

ethnicity_2011_na <-
  read_csv(here::here("output","from_jobserver","release_2022_11_09","ethnic_group_2011_NA_registered.csv"),col_types =(cols())) %>%
  mutate(cohort = case_when(cohort=="SNOMED"~ "SNOMED:2022",
                            TRUE ~cohort),
         cohort = fct_relevel(cohort, 
                              "ONS", "CTV3","SNOMED:2022")) %>%
  filter(cohort != "CTV3" & cohort != "PRIMIS")


ethnicity_2011_na_diff<-ethnicity_2011_na %>%
  group_by(Ethnic_Group,region,group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) 


ethnicity_2011_plot_na <- ethnicity_2011_na_diff %>%
  filter(region != "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  # theme(panel.spacing = unit(2, "lines")) +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 12,
    hjust = 0.75,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities")  +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="ONS","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.,hjust = -0.2) 


ggsave(
  filename = here::here("output", "local", "ons", "na_removed", "ethnicity_2011_count_na.png"),
  ethnicity_2011_plot_na,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
)



ethnicity_2011_plot_eng_na <- ethnicity_2011_na_diff %>%
  filter(region == "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 20,
    hjust = 0,
    vjust = 0
  )) +
  coord_flip()  + scale_fill_lancet() +
  xlab("") + ylab("\nProportion of ethnicities") +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="ONS","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=-0.5,hjust = -0.2)

ggsave(
  filename = here::here(
    "output",
    "local",
    "ons",
    "na_removed",
    "ethnicity_2011_count_eng_na.png"
  ),
  ethnicity_2011_plot_eng_na,
  dpi = 600,
  width = 30,
  height = 15,
  units = "cm"
)



