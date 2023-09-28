library('gt')
library('tidyverse')
library('here')
library('glue')
library('stringr')
library('ggsci')
library('scales')
library(Gmisc, quietly = TRUE)
library(htmlTable)
library(grid)
library(magrittr)


# # patient counts 
SUSyesno <- read_csv(here::here("output","released","made_locally","local_patient_counts_registered.csv")) %>%
  filter(subgroup == "Yes" | subgroup == "No") %>%
  mutate(subgroup =recode(subgroup, Yes = "Present",
                          No = "Absent"
  )) %>%
  arrange(group,rev(subgroup))

SUS<-read_csv(here::here("output","released","made_locally","local_patient_counts_registered.csv")) %>%
  filter(subgroup != "Yes" & subgroup != "No") %>%
  bind_rows(SUSyesno) %>%
  mutate(group = case_when(group == 'age_band' ~ 'age band',
                           group == 'learning_disability' ~ 'learning disability',
                           group == "imd" ~ "IMD",
                           TRUE ~ group),
         subgroup =recode(subgroup, F = "Female",
                          M = "Male"),
         population=as.character(scales::comma(round(as.numeric(population),0))),
         left_paren = "(",
         right_paren = ")"
         
  ) %>%
  unite("5 SNOMED:2022 pp inc",left_paren,`5 SNOMED:2022 pp inc`,right_paren,sep = "") %>%
  filter(`5 SNOMED:2022` !="- (-)") %>%
  select(-`all filled`)

my_cols <- setNames(c("group","","SNOMED 2022","SNOMED 2022 with  SUS data","Population","Percentage point increase\n with SUS data"),names(SUS))


SUS_gt <- SUS %>%
  gt( groupname_col = "group") %>%
  cols_label(!!!my_cols) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(
    table.align = "left",
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 1: Count of patients with a recorded ethnicity in OpenSAFELY-TPP (proportion of registered TPP population) by clinical and demographic subgroups. All counts are rounded to the nearest 5."),
  )


SUS_gt  %>% gtsave(here::here("output","released","made_locally","patient_counts.html"))



# # patient counts 5 group
# SUS5yesno <- read_csv(here::here("output","released","made_locally","local_patient_counts_categories_5_registered.csv")) %>%
#   filter(subgroup == "Yes" | subgroup == "No") %>%
#   mutate(subgroup =recode(subgroup, Yes = "Present",
#                           No = "Absent"
#   )) %>%
#   arrange(group,rev(subgroup))
# 
# SUS5<-read_csv(here::here("output","released","made_locally","local_patient_counts_categories_5_registered.csv")) %>%
#   filter(subgroup != "Yes" & subgroup != "No") %>%
#   bind_rows(SUS5yesno) %>%
#   mutate(group = case_when(group == 'age_band' ~ 'age band',
#                            group == 'learning_disability' ~ 'learning disability',
#                            group == "imd" ~ "IMD",
#                          TRUE ~ group),
#          subgroup =recode(subgroup, F = "Female",
#                           M = "Male"
#          )
#          ) %>%
#   filter(`Asian 5 SNOMED:2022` !="- (-)") 
#   
# my_cols <- setNames(c("group","",rep(c("SNOMED 2022","SNOMED 2022 with  SUS data"),5)),names(SUS5))
# 
#
# SUS5 <- SUS5 %>%
#   gt( groupname_col = "group") %>%
#   tab_spanner(label="Asian", columns=c(3,4)) %>%
#   tab_spanner(label="Black", columns=c(5,6)) %>%
#   tab_spanner(label="Mixed", columns=c(7,8)) %>%
#   tab_spanner(label="White", columns=c(9,10)) %>%
#   tab_spanner(label="Other", columns=c(11,12)) %>%
#   cols_label(!!!my_cols) %>%
#   tab_style(
#     style = list(
#       cell_fill(color = "gray96")
#     ),
#     locations = cells_body(
#     )
#   ) %>%
#   tab_style(
#     style = list(
#       cell_text(weight = "bold")
#     ),
#     locations = cells_column_labels(everything())
#   ) %>%
#   tab_options(     
#     table.align = "left",
#     # row_group.as_column = TRUE option not available on the OS R image
#     row_group.as_column = TRUE,
#     table.font.size = 8,
#     column_labels.border.top.width = px(3),
#     column_labels.border.top.color = "transparent",
#     table.border.top.color = "transparent",
#     heading.align = "left"
#   ) %>%
#   tab_header(
#     title = md("Table 2:  Count of patients with a recorded ethnicity in OpenSAFELY TPP by ethnicity group (proportion of registered TPP population) and clinical and demographic subgroups. All counts are rounded to the nearest 5. "),
#   )
# 
# SUS5  %>% gtsave(here::here("output","released","made_locally","patient_counts_5_group.html"))
# 



SUS16yesno <- read_csv(here::here("output","released","made_locally","local_patient_counts_categories_16_registered.csv")) %>%
  filter(subgroup == "Yes" | subgroup == "No") %>%
  mutate(subgroup =recode(subgroup, Yes = "Present",
                          No = "Absent"
  )) %>%
  arrange(group,rev(subgroup))

# patient counts 16 group
SUS16<-read_csv(here::here("output","released","made_locally","local_patient_counts_categories_16_registered.csv")) %>%
  filter(subgroup != "Yes" & subgroup != "No") %>%
  bind_rows(SUS16yesno) %>%
  mutate(group = case_when(group == 'age_band' ~ 'age band',
                           group == 'learning_disability' ~ 'learning disability',
                           group == "imd" ~ "IMD",
                           TRUE ~ group),
         subgroup =recode(subgroup, F = "Female",
                          M = "Male"
         )
  ) %>%
  filter(`Indian 16 SNOMED:2022` !="- (-)") 

my_cols <- setNames(c("group","",rep(c("SNOMED 2022","SNOMED 2022\n with  SUS data"),16)),names(SUS16))


SUS16 <- SUS16 %>%
  gt( groupname_col = "group") %>%
  tab_spanner(label="Indian", columns=c(3,4)) %>%
  tab_spanner(label="Pakistani", columns=c(5,6)) %>%
  tab_spanner(label="Bangladeshi", columns=c(7,8)) %>%
  tab_spanner(label="Other Asian", columns=c(9,10)) %>%
  tab_spanner(label="Caribbean", columns=c(11,12)) %>%
  tab_spanner(label="African", columns=c(13,14)) %>%
  tab_spanner(label="Other Black", columns=c(15,16)) %>%
  tab_spanner(label="White and Black Caribbean", columns=c(17,18)) %>%
  tab_spanner(label="White and Black African", columns=c(19,20)) %>%
  tab_spanner(label="White and Asian", columns=c(21,22)) %>%
  tab_spanner(label="Other Mixed", columns=c(23,24)) %>%
  tab_spanner(label="White British", columns=c(25,26)) %>%
  tab_spanner(label="White Irish", columns=c(27,28)) %>%
  tab_spanner(label="Other White", columns=c(29,30)) %>%
  tab_spanner(label="Chinese", columns=c(31,32)) %>%
  tab_spanner(label="Any other ethnic group", columns=c(33,34)) %>%
  cols_label(!!!my_cols) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(     
    table.align = "left",
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 2:  Count of patients with a recorded ethnicity in OpenSAFELY TPP by ethnicity group (proportion of registered TPP population) and clinical and demographic subgroups. All counts are rounded to the nearest 5."),
  )

SUS16 %>% gtsave(here::here("output","released","made_locally","patient_counts_16_group.html"))

# # latest / any recorded ethnicity
# anyrepeated <- read_csv(here::here("output","released","made_locally","local_state_change_ethnicity_new_5_registered.csv")) %>%
#     rename_with(str_to_title) %>%
#     gt( ) %>%
#   cols_label(`Latest Ethnicity-\n5 Snomed:2022` = "") %>%
#   cols_label(Supplemented = "Any discordant") %>%
#   tab_spanner(label="Latest Recorded Ethnicity", columns=1) %>%
#   tab_spanner(label="Any Recorded Ethnicity", columns=c(2:7)) %>%
#     tab_options(     
#       table.align = "left",
#       table.font.size = 8,
#       column_labels.border.top.width = px(3),
#       column_labels.border.top.color = "transparent",
#       table.border.top.color = "transparent",
#       heading.align = "left"
#     ) %>%
#     tab_header(
#       title = md("Table 4: Count of patients with at least one recording of each ethnicity (proportion of latest ethnicity)."),
#     )
#   
# anyrepeated %>% gtsave(here::here("output","released","made_locally","latest_any.html"))

# latest / most frequent recorded ethnicity
latestcommon <- read_csv(here::here("output","released","made_locally","local_latest_common_ethnicity_new_5_expanded_registered.csv")) %>%
  rename_with(str_to_title) %>%
  gt( ) %>%
  cols_label(`Latest Ethnicity-\n5 Snomed:2022` = "") %>%
  tab_spanner(label="Latest Recorded Ethnicity", columns=1) %>%
  tab_spanner(label="Most Frequent Ethnicity", columns=c(2:6)) %>%
  tab_options(     
    table.align = "left",
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 3: Count of patients’ most frequently recorded ethnicity (proportion of latest ethnicity). "),
  )

latestcommon %>% gtsave(here::here("output","released","made_locally","latest_frequent.html"))

                                                
# count of all ethnicities
listed <- read_csv(here::here("output","released","ethnicity","snomed_ethnicity_counts.csv"), col_types = cols(code = col_character())) %>%
  rename_with(str_to_title) %>%
  select(Code,Term,Snomedcode_count) %>%
  filter(Snomedcode_count!=0) %>%
  arrange(Term) %>%
  gt( ) %>%
  cols_label(Snomedcode_count = "Count") %>%
  tab_options(     
    table.align = "left",
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 8: Count of individual ethnicity code use"),
  )

listed %>% gtsave(here::here("output","released","made_locally","percodelist.html"))

# plot over time
time <- read_csv(here::here("output","released","across_time_years.csv")) %>%
  mutate(measure =recode(measure, First = "Earliest recorded ethnicity",
                          last = "Latest recorded ethnicity"
  ))


breakvec <- seq(from = as.Date("1900-01-01"), to = as.Date("2020-01-01"),
                   by = "10 year")

plot_time<- time %>%   ggplot(aes(x=Date,y= n,colour=measure))+
  geom_line(stat="identity") +
  theme_classic() +
  theme(
    plot.title=element_text(size=10),
    axis.text.x = element_text(
    size = 5,
    hjust = 0.3,
    vjust = 0
  )) +
  scale_color_lancet() +
  xlab("\nYear") + 
  theme(legend.title=element_blank()) +
  scale_x_date(breaks = breakvec, date_labels =  "%Y") +
  scale_y_continuous(name="Number of records", labels = scales::comma) + 
  ggtitle("Figure 4: Recording of ethnicity over time for latest and first recorded ethnicity. Unknown dates of recording may be stored as '1900-01-01'")

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "fig_4_plot_time.pdf"
  ),
  plot_time,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)



# ONS tables
ethnicity_na_2021 <-
  read_csv(here::here("output","released","made_locally",  "ethnic_group_2021_registered_with_2021_categories.csv")) %>%
  mutate(
    cohort = case_when(cohort=="ONS"~"2021 Census",
                       cohort=="new"~"SNOMED:2022\n[amended to 2021 grouping]",
                       cohort=="supplemented"~"SNOMED:2022 supplemented with SUS data\n[amended to 2021 grouping]"),
    cohort = fct_relevel(cohort, "2021 Census","SNOMED:2022\n[amended to 2021 grouping]", "SNOMED:2022 supplemented with SUS data\n[amended to 2021 grouping]"),
    Ethnic_Group = fct_relevel(Ethnic_Group,
                               "Asian","Black","Mixed", "White","Other"))

ONS_tab_2021 <- ethnicity_na_2021 %>%
  mutate(
    left_paren = " (",
    right_paren = ")",
    percentage = round(percentage,2),
    N=comma(N)
  ) %>%
  unite("N_perc",N,left_paren,percentage,right_paren,sep = "") %>%
  select(cohort,Ethnic_Group,region,N_perc) %>%
  arrange(Ethnic_Group) %>%
  pivot_wider(names_from = c("Ethnic_Group","cohort"),values_from = N_perc) %>%
  mutate(region=fct_relevel(region, "England")) %>%
  arrange(region)

my_cols_ons <- setNames(c("Region",rep(c("SNOMED 2022\n(amended to 2021 grouping)","SNOMED 2022 with SUS data\n(amended to 2021 grouping)","2021 ONS Census"),5)),names(ONS_tab_2021))

ONS_tab_2021 %>%
  gt( groupname_col = "region") %>%
  tab_spanner(label="Asian", columns=c(2,3,4)) %>%
  tab_spanner(label="Black", columns=c(5,6,7)) %>%
  tab_spanner(label="Mixed", columns=c(8,9,10)) %>%
  tab_spanner(label="White", columns=c(11,12,13)) %>%
  tab_spanner(label="Other", columns=c(14,15,16)) %>%
  cols_label(!!!my_cols_ons) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(     
    table.align = "left",
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 7:  Count of patients with a recorded ethnicity in OpenSAFELY TPP [amended to the 2021 ethnicity grouping] (proportion of registered TPP population) and 2021 ONS Census counts (proportion of 2021 ONS Census population). All counts are rounded to the nearest 5. "),
  )  %>% 
  gtsave(here::here("output","released","made_locally","ons_table_2021_with_2021_categories.html"))

#### ONS tables 2001
ethnicity_na_2001 <-
  read_csv(here::here("output","released","made_locally",  "ethnic_group_2021_registered_with_2001_categories.csv")) %>%
  mutate(Ethnic_Group = fct_relevel(Ethnic_Group, "Asian","Black","Mixed", "White","Other"))

ONS_tab_2001 <- ethnicity_na_2001 %>%
  mutate(
    left_paren = " (",
    right_paren = ")",
    percentage = round(percentage,2),
    N=comma(N)
  ) %>%
  unite("N_perc",N,left_paren,percentage,right_paren,sep = "") %>%
  select(cohort,Ethnic_Group,region,N_perc) %>%
  arrange(Ethnic_Group) %>%
  pivot_wider(names_from = c("Ethnic_Group","cohort"),values_from = N_perc) %>%
  mutate(region=fct_relevel(region, "England")) %>%
  arrange(region)

my_cols_ons <- setNames(c("Region",rep(c("SNOMED 2022","SNOMED 2022 with  SUS data","2021 ONS Census [amended to 2001 grouping]"),5)),names(ONS_tab_2001))

ONS_tab_2001 %>%
  gt( groupname_col = "region") %>%
  tab_spanner(label="Asian", columns=c(2,3,4)) %>%
  tab_spanner(label="Black", columns=c(5,6,7)) %>%
  tab_spanner(label="Mixed", columns=c(8,9,10)) %>%
  tab_spanner(label="Other", columns=c(14,15,16)) %>%
  tab_spanner(label="White", columns=c(11,12,13)) %>%
  cols_label(!!!my_cols_ons) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(     
    table.align = "left",
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 6:  Count of patients with a recorded ethnicity in OpenSAFELY TPP by ethnicity group (proportion of registered TPP population) and 2021 ONS Census counts [amended to 2001 grouping] (proportion of 2021 ONS Census population). All counts are rounded to the nearest 5. "),
  )  %>% 
  gtsave(here::here("output","released","made_locally","ons_table_2021_with_2001_categories.html"))


### ONS with 2021 categories
ethnicity_na_2021 <-
  read_csv(here::here("output","released","made_locally",  "ethnic_group_2021_registered_with_2021_categories.csv")) %>%
  mutate(
    cohort = case_when(cohort=="ONS"~"2021 Census",
                       cohort=="new"~"SNOMED:2022\n[amended to 2021 grouping]",
                       cohort=="supplemented"~"SNOMED:2022 supplemented with SUS data\n[amended to 2021 grouping]"),
    cohort = fct_relevel(cohort, "2021 Census","SNOMED:2022\n[amended to 2021 grouping]", "SNOMED:2022 supplemented with SUS data\n[amended to 2021 grouping]"),
    Ethnic_Group = fct_relevel(Ethnic_Group,
                               "Asian","Black","Mixed", "White","Other"))


## create difference in percentage between ONS and TPP (for plotting)
ethnicity_plot_na_diff_2021 <- ethnicity_na_2021 %>%
  group_by(Ethnic_Group,region,group) %>%
  arrange(cohort) %>%
  mutate(diff = percentage - first(percentage)) %>%
  select(region,Ethnic_Group,cohort,diff,group)

ethnicity_na_2021 <-ethnicity_na_2021 %>% 
  left_join(ethnicity_plot_na_diff_2021, by=c("region","Ethnic_Group","cohort","group"))
## 5 group ethnicity plot NA removed for Regions
ethnicity_plot_na_2021 <- ethnicity_na_2021 %>%
  filter(region != "England", group == "5") %>%
  ggplot(aes(x = Ethnic_Group, y = percentage, fill = cohort)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap( ~ region) +
  theme_classic() +
  theme(text = element_text(size = 20)) +
  theme(axis.text.x = element_text(
    size = 12,
    hjust = 0.75,
    vjust = 0
  )) +
  coord_flip()  +  scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#925E9FFF")) +
  xlab("") + ylab("\nProportion of ethnicities")  +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3,hjust = -0.2)  + 
  ggtitle("Figure 3: Barplot showing the proportion of 2021 Census and TPP populations (amended to 2021 grouping) per ethnicity grouped into 5 groups per NUTS-1 region (excluding\nthose without a recorded ethnicity). Annotated with percentage point difference between 2021 Census and TPP populations.") +
  theme(plot.title = element_text(size = 16))



ggsave(
  filename =here::here("output","released","made_locally",  "ONS_ethnicity_regions_2021_with_2021_regions.pdf"),
  ethnicity_plot_na_2021,
  dpi = 600,
  width = 50,
  height = 30,
  units = "cm"
)


## 5 group ethnicity plot NA removed for England
ethnicity_plot_eng_na_2021 <- ethnicity_na_2021 %>%
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
  coord_flip()  + scale_fill_manual(values = c("#00468BFF", "#ED0000FF", "#925E9FFF")) +
  xlab("") + ylab("\nProportion of ethnicities") +
  theme(legend.position="bottom",
        legend.title=element_blank()) +
  geom_text(aes(x=Ethnic_Group,y=percentage,label=ifelse(cohort=="2021 Census","",paste0(round(diff,digits =1),"%"))), size=3.4, position =position_dodge(width=0.9), vjust=0.3 ,hjust = -0.2)  + 
  ggtitle("Figure 2: Barplot showing the proportion of 2021 Census and TPP populations (amended to 2021 grouping) per ethnicity grouped into 5 groups (excluding those\nwithout a recorded ethnicity). Annotated with percentage point difference between 2021 Census and TPP populations.") +
  theme(plot.title = element_text(size = 10))



ggsave(
  filename =here::here("output","released","made_locally", "ONS_ethnicity_eng_2021_with_2021_regions.pdf"
  ),
  ethnicity_plot_eng_na_2021,
  dpi = 600,
  width = 30,
  height = 15,
  units = "cm"
)

### SUS and New codelist comparison
df_sus_new_cross = read_csv(here::here("output","released","simple_sus_crosstab_long_5_registered.csv")) 


### Get count of patients with unknown ethnicity 
population  <-   read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  filter( group=="all" ) %>%
  summarise(ethnicity_new_5 = "Unknown",
            population= population-ethnicity_new_5_filled) 

### Get count of patients per 5 group ethnicity 
ethnicity_cat <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_sus_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  mutate(Asian_anydiff=Asian_any-Asian_new,
         Black_anydiff=Black_any-Black_new,
         Mixed_anydiff=Mixed_any-Mixed_new,
         White_anydiff=White_any-White_new,
         Other_anydiff=Other_any-Other_new,) 

ethnicity_cat_pivot <- ethnicity_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  filter(codelist=="new",group=="all") %>%
  summarise(ethnicity_new_5 =ethnicity,
            population=n) %>%
  bind_rows(population)



df_sus_new_cross_perc <-df_sus_new_cross %>%
  left_join(ethnicity_cat_pivot,by="ethnicity_new_5") %>%
  mutate(percentage=round(`0`/population*100,1),
         ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Asian","Black","Mixed", "White","Other","Unknown"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other","Unknown"),
         left_paren = " (",
         right_paren = ")",
         N = scales::comma(as.numeric(`0`)),
         population = scales::comma(as.numeric(population))
  ) %>%
  arrange(ethnicity_new_5,ethnicity_sus_5) %>%
  unite("labl",N,left_paren,percentage,right_paren,sep = "",remove = F) %>%
  unite("ethnicity_new_5",ethnicity_new_5,left_paren,population,right_paren,sep = "") %>%
  select(-`0`,-percentage,-N) %>%
  pivot_wider(names_from = c("ethnicity_sus_5"),values_from = labl) 
  
my_cols <- setNames(c("","Asian","Black","Mixed", "White","Other","Unknown"),names(df_sus_new_cross_perc))


df_sus_new_cross_table <- df_sus_new_cross_perc %>%
  gt( groupname_col = "") %>%
  tab_spanner(label="SNOMED: 2022", columns=c(1)) %>%
  tab_spanner(label="SUS", columns=c(2:7)) %>%
  cols_label(!!!my_cols) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(     
    table.align = "left",
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 4:  Count of patients with a recorded ethnicity in SUS by ethnicity group (proportion of SNOMED:2022 population). All counts are rounded to the nearest 5. "),
  )


df_sus_new_cross_table  %>% gtsave(here::here("output","released","made_locally","df_sus_new_cross_table.html"))


### Heatmap for SUS with Unknown
### Get count of patients with unknown ethnicity 
population  <-   read_csv(here::here("output","released","simple_patient_counts_5_sus_registered.csv"),col_types =(cols())) %>%
  filter( group=="all" ) %>%
  summarise(ethnicity_new_5 = "Unknown",
            population= population-ethnicity_new_5_filled) 

### Get count of patients per 5 group ethnicity 
ethnicity_cat <-
  read_csv(here::here("output","released","simple_patient_counts_categories_5_sus_registered.csv"),col_types =(cols())) %>%
  rename_with(~sub("ethnicity_","",.),contains("ethnicity_")) %>%
  rename_with(~sub("_5_filled","",.),contains("_5_filled")) %>%
  select(-contains("filled"),-contains("missing"),-contains("sus")) %>%
  mutate(Asian_anydiff=Asian_any-Asian_new,
         Black_anydiff=Black_any-Black_new,
         Mixed_anydiff=Mixed_any-Mixed_new,
         White_anydiff=White_any-White_new,
         Other_anydiff=Other_any-Other_new,) 

ethnicity_cat_pivot <- ethnicity_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c( "ethnicity","codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  filter(codelist=="new",group=="all") %>%
  summarise(ethnicity_new_5 =ethnicity,
            population=n) %>%
  bind_rows(population)


df_sus_new_cross_nowhite <- df_sus_new_cross %>% 
  filter(ethnicity_new_5!="White",ethnicity_sus_5!="White")


df_sus_new_cross_perc <-df_sus_new_cross %>%
  left_join(ethnicity_cat_pivot,by="ethnicity_new_5") %>%
  mutate(percentage=round(`0`/population*100,1)) %>%
  mutate(ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Unknown","Other","White","Mixed", "Black","Asian"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other")
  )


# sus_heat_perc<- ggplot(df_sus_new_cross_perc, aes( ethnicity_sus_5,ethnicity_new_5, fill= percentage)) + 
#   geom_tile() +
#   # scale_fill_viridis(discrete=FALSE,direction=-1) +
#   # scale_fill_gradient(low="white", high="blue") +
#   scale_fill_distiller(palette = "OrRd",direction = 1,name = "Proportion of SNOMED:2022") +
#   geom_text(aes(label=percentage)) +
#   ylab("SNOMED:2022\n") + xlab("\nSUS") +
#   theme_ipsum() +
#   theme(
#     plot.title=element_text(size=10)) +
#   ggtitle("Figure 1: Heat map showing frequency of pairwise occurrence of primary care and secondary care recorded ethnicity\nas a proportion of latest primary care recorded ethnicity")
# 
# ggsave(
#   filename = here::here(
#     "output",
#     "released",
#     "made_locally",
#     "fig_1_sus_plot_time.png"
#   ),
#   sus_heat_perc,
#   dpi = 600,
#   width = 30,
#   height = 10,
#   units = "cm"
# )

### SUS and New codelist comparison without unknown
df_sus_new_cross = read_csv(here::here("output","released","simple_sus_crosstab_long_5_registered.csv")) 


df_sus_new_cross_known <- df_sus_new_cross %>%
  filter(ethnicity_new_5!="Unknown",
         ethnicity_sus_5!="Unknown") %>%
  group_by(ethnicity_new_5 ) %>%
  mutate(population = sum(`0`)) %>%
  ungroup() %>%
  mutate(percentage=round(`0`/population*100,1),
         ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Asian","Black","Mixed", "White","Other"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other"),
         left_paren = " (",
         right_paren = ")",
         N = scales::comma(as.numeric(`0`)),
         population = scales::comma(as.numeric(population))
  ) %>%
  arrange(ethnicity_new_5,ethnicity_sus_5) %>%
  unite("labl",N,left_paren,percentage,right_paren,sep = "",remove = F) %>%
  unite("ethnicity_new_5",ethnicity_new_5,left_paren,population,right_paren,sep = "") %>%
  select(-`0`,-percentage,-N) %>%
  pivot_wider(names_from = c("ethnicity_sus_5"),values_from = labl) 



df_sus_new_cross_known_perc <-df_sus_new_cross %>%
  filter(ethnicity_new_5!="Unknown",
         ethnicity_sus_5!="Unknown") %>%
  left_join(ethnicity_cat_pivot,by="ethnicity_new_5") %>%
  mutate(percentage=round(`0`/population*100,1),
         ethnicity_new_5 = fct_relevel(ethnicity_new_5,
                                       "Asian","Black","Mixed", "White","Other"),
         ethnicity_sus_5=fct_relevel(ethnicity_sus_5,
                                     "Asian","Black","Mixed", "White","Other"),
         left_paren = " (",
         right_paren = ")",
         N = scales::comma(as.numeric(`0`)),
         population = scales::comma(as.numeric(population))
  ) %>%
  arrange(ethnicity_new_5,ethnicity_sus_5) %>%
  unite("labl",N,left_paren,percentage,right_paren,sep = "",remove = F) %>%
  unite("ethnicity_new_5",ethnicity_new_5,left_paren,population,right_paren,sep = "") %>%
  select(-`0`,-percentage,-N) %>%
  pivot_wider(names_from = c("ethnicity_sus_5"),values_from = labl) 

my_cols <- setNames(c("","Asian","Black","Mixed", "White","Other"),names(df_sus_new_cross_known_perc))

df_sus_new_cross_known_table <- df_sus_new_cross_known_perc %>%
  gt( groupname_col = "") %>%
  tab_spanner(label="SNOMED: 2022", columns=c(1)) %>%
  tab_spanner(label="SUS", columns=c(2:6)) %>%
  cols_label(!!!my_cols) %>%
  tab_style(
    style = list(
      cell_fill(color = "gray96")
    ),
    locations = cells_body(
    )
  ) %>%
  tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_options(     
    table.align = "left",
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 5:  Count of patients with a recorded ethnicity in SUS by ethnicity group excluding Unknown ethnicites (proportion of SNOMED:2022 population). All counts are rounded to the nearest 5. "),
  )


df_sus_new_cross_known_table  %>% gtsave(here::here("output","released","made_locally","df_sus_new_cross_known_table.html"))

###### across time measures framework

demographic_covariates = c("age_band", "sex", "region", "imd")
clinical_covariates = c("dementia", "diabetes", "hypertension", "learning_disability")
covariates =c(demographic_covariates,clinical_covariates)

input<-read_csv(here::here("output","released",glue("ethnicity_5_rate.csv"))) 
counts_plot <-input %>%
  ggplot(aes(x=date,y= value,colour=factor(ethnicity)))+
  geom_line(stat="identity") +
  ylim(0, 1) +
  scale_x_date(date_labels = "%Y",
               breaks = seq.Date(from = as.Date("1900-01-01"),
                                 to = as.Date("2022-01-01"),
                                 by = "5 years")) +
  geom_vline(xintercept = as.numeric(as.Date("2006-01-01"))) +
  geom_vline(xintercept = as.numeric(as.Date("2012-01-01"))) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5),
        panel.grid.minor = element_blank())  +
  scale_color_lancet()   +
  guides(colour=guide_legend(title="")) +
  ggtitle("Ethncity")
ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    glue("qof_ethnicity_rate.png")),
  counts_plot,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

for (covar in covariates){
  input<-read_csv(here::here("output","released",glue("{covar}_rate.csv"))) 
  fact<-names(input[,1])
  counts_plot <-input %>%
    ggplot(aes(x=date,y= value,colour=factor(covariant)))+
    geom_line(stat="identity") +
    ylim(0, 1) +
    scale_x_date(date_labels = "%Y",
                 breaks = seq.Date(from = as.Date("1900-01-01"),
                                   to = as.Date("2022-01-01"),
                                   by = "5 years")) +
    geom_vline(xintercept = as.numeric(as.Date("2006-01-01"))) +
    geom_vline(xintercept = as.numeric(as.Date("2012-01-01"))) +
    theme_bw()+
    theme(axis.text.x = element_text(angle = 90, vjust=0.5),
          panel.grid.minor = element_blank())  +
    scale_color_lancet()   +
    guides(colour=guide_legend(title="")) +
    ggtitle(covar)
  counts_plot
  ggsave(
    filename = here::here(
      "output",
      "released",
      "made_locally",
      glue("qof_{covar}_rate.png")),
    counts_plot,
    dpi = 600,
    width = 30,
    height = 10,
    units = "cm"
  )
}


### null dates

input<-read_csv(here::here("output","released","nulldate_rate.csv")) 
counts_plot <-input %>%
  ggplot(aes(x=date,y= null_date))+
  # geom_line(aes(x=date,y= population_living)) +
  geom_line(stat="identity") +
  scale_x_date(date_labels = "%Y",
               breaks = seq.Date(from = as.Date("1900-01-01"),
                                 to = as.Date("2022-01-01"),
                                 by = "5 years")) +
  # geom_vline(xintercept = as.numeric(as.Date("2006-01-01"))) +
  # geom_vline(xintercept = as.numeric(as.Date("2012-01-01"))) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5),
        panel.grid.minor = element_blank())  +
  scale_color_lancet()   +
  guides(colour=guide_legend(title="")) +
  ggtitle("Null Dates") + 
  scale_y_continuous(label=comma,"n")

counts_plot
ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    glue("null_dates.png")),
  counts_plot,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)

input<-read_csv(here::here("output","released","nulldate_rate.csv")) 
counts_plot <-input %>%
  ggplot(aes(x=date,y= null_date, color = "null dates"))+
  geom_line(aes(x=date,y= population_living, color= "population")) +
  geom_line(stat="identity") +
  scale_x_date(date_labels = "%Y",
               breaks = seq.Date(from = as.Date("1900-01-01"),
                                 to = as.Date("2022-01-01"),
                                 by = "5 years")) +
  # geom_vline(xintercept = as.numeric(as.Date("2006-01-01"))) +
  # geom_vline(xintercept = as.numeric(as.Date("2012-01-01"))) +
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, vjust=0.5),
        panel.grid.minor = element_blank())  +
  scale_color_lancet()   +
  guides(colour=guide_legend(title="")) +
  ggtitle("Null Dates") + 
  scale_y_continuous(label=comma,"n")

counts_plot
ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    glue("popn_null_dates.png")),
  counts_plot,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)


######### Categories
prop_reg_cat <-
  read_csv(here::here("output", "released", "simple_patient_counts_categories_5_group_registered.csv"), col_types = (cols())) %>%
  rename_with(~ sub("ethnicity_", "", .), contains("ethnicity_")) %>%
  rename_with(~ sub("_5_filled", "", .), contains("_5_filled")) %>%
  select(-contains("filled"), -contains("missing"), -contains("sus"), -contains("any")) %>%
  mutate(
    Asian_supplementeddiff = Asian_supplemented - Asian_new,
    Black_supplementeddiff = Black_supplemented - Black_new,
    Mixed_supplementeddiff = Mixed_supplemented - Mixed_new,
    White_supplementeddiff = White_supplemented - White_new,
    Other_supplementeddiff = Other_supplemented - Other_new,
  )


prop_reg_cat_pivot <- prop_reg_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c("ethnicity", "codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  mutate(
    percentage = round(n / population * 100, 1),
    group = case_when(
      group == "age_band" ~ "Age\nBand",
      group == "all" ~ "All",
      group == "dementia" ~ "Dementia",
      group == "diabetes" ~ "Diabetes",
      group == "hypertension" ~ "Hypertension",
      group == "imd" ~ "IMD",
      group == "learning_disability" ~ "Learning\nDisability",
      group == "region" ~ "Region",
      group == "sex" ~ "Sex"
    ),
    group = fct_relevel(
      group,
      "All", "Age\nBand", "Sex", "Region", "IMD",
      "Dementia", "Diabetes", "Hypertension", "Learning\nDisability"
    ),
    subgroup = case_when(
      subgroup == "M" ~ "Male",
      subgroup == "F" ~ "Female",
      TRUE ~ subgroup
    ),
    across("subgroup", str_replace, "True", "Present"),
    across("subgroup", str_replace, "False", "Absent"),
    across("ethnicity", str_replace, "_ethnicity_new_5_filled", "")
  ) %>%
  mutate(
    ethnicity = fct_relevel(
      ethnicity,
      "Asian", "Black", "Mixed", "White", "Other"
    )
  )

prop_reg_cat_hline_new <- prop_reg_cat_pivot %>%
  arrange(ethnicity, group) %>%
  group_by(ethnicity, codelist) %>%
  mutate(percentage = first(percentage)) %>%
  ungroup() %>%
  filter(codelist == "new")
prop_reg_cat_hline_supplemented <- prop_reg_cat_pivot %>%
  arrange(ethnicity, group) %>%
  group_by(ethnicity, codelist) %>%
  mutate(percentage = first(percentage)) %>%
  ungroup() %>%
  filter(codelist == "supplemented")

prop_reg_cat_pivot <- prop_reg_cat_pivot %>%
  mutate(
    codelist = case_when(
      codelist == "new" ~ "SNOMED:2022",
      codelist == "supplementeddiff" ~ "SNOMED:2022 supplemented with SUS data",
      T ~ codelist
    ),
    codelist = fct_relevel(codelist, "supplemented", "SNOMED:2022 supplemented with SUS data", "SNOMED:2022")
  )


### completeness proportion categorical
prop_reg_cat <-
  read_csv(here::here("output", "released", "simple_patient_counts_categories_5_group_registered.csv"), col_types = (cols())) %>%
  rename_with(~ sub("ethnicity_", "", .), contains("ethnicity_")) %>%
  rename_with(~ sub("_5_filled", "", .), contains("_5_filled")) %>%
  select(-contains("filled"), -contains("missing"), -contains("sus"), -contains("any")) %>%
  mutate(
    Asian_supplementeddiff = Asian_supplemented - Asian_new,
    Black_supplementeddiff = Black_supplemented - Black_new,
    Mixed_supplementeddiff = Mixed_supplemented - Mixed_new,
    White_supplementeddiff = White_supplemented - White_new,
    Other_supplementeddiff = Other_supplemented - Other_new,
  )

prop_reg_cat_pivot <- prop_reg_cat %>%
  pivot_longer(
    cols = c(contains("_")),
    names_to = c("ethnicity", "codelist"),
    names_pattern = "(.*)_(.*)",
    values_to = "n"
  ) %>%
  mutate(
    percentage = round(n / population * 100, 1),
    group = case_when(
      group == "age_band" ~ "Age\nBand",
      group == "all" ~ "All",
      group == "dementia" ~ "Dementia",
      group == "diabetes" ~ "Diabetes",
      group == "hypertension" ~ "Hypertension",
      group == "imd" ~ "IMD",
      group == "learning_disability" ~ "Learning\nDisability",
      group == "region" ~ "Region",
      group == "sex" ~ "Sex"
    ),
    group = fct_relevel(
      group,
      "All", "Age\nBand", "Sex", "Region", "IMD",
      "Dementia", "Diabetes", "Hypertension", "Learning\nDisability"
    ),
    subgroup = case_when(
      subgroup == "M" ~ "Male",
      subgroup == "F" ~ "Female",
      TRUE ~ subgroup
    ),
    across("subgroup", str_replace, "True", "Present"),
    across("subgroup", str_replace, "False", "Absent"),
    across("ethnicity", str_replace, "_ethnicity_new_5_filled", "")
  ) %>%
  mutate(
    ethnicity = fct_relevel(
      ethnicity,
      "Asian", "Black", "Mixed", "White", "Other"
    )
  )

prop_reg_cat_hline_new <- prop_reg_cat_pivot %>%
  arrange(ethnicity, group) %>%
  group_by(ethnicity, codelist) %>%
  mutate(percentage = first(percentage)) %>%
  ungroup() %>%
  filter(codelist == "new")
prop_reg_cat_hline_supplemented <- prop_reg_cat_pivot %>%
  arrange(ethnicity, group) %>%
  group_by(ethnicity, codelist) %>%
  mutate(percentage = first(percentage)) %>%
  ungroup() %>%
  filter(codelist == "supplemented")

prop_reg_cat_pivot <- prop_reg_cat_pivot %>%
  mutate(
    codelist = case_when(
      codelist == "new" ~ "SNOMED:2022",
      codelist == "supplementeddiff" ~ "SNOMED:2022 supplemented with SUS data",
      T ~ codelist
    ),
    codelist = fct_relevel(codelist, "supplemented", "SNOMED:2022 supplemented with SUS data", "SNOMED:2022")
  )


prop_reg_cat_plot <- prop_reg_cat_pivot %>%
  filter(
    codelist != "supplemented",
    subgroup != "missing"
  ) %>%
  ggplot(aes(x = subgroup, y = percentage, alpha = codelist, fill = group)) +
  scale_alpha_discrete(range = c(0.2, 1)) +
  geom_hline(
    data = prop_reg_cat_hline_new,
    aes(yintercept = percentage), color = "#00468BFF", alpha = 0.6
  ) +
  geom_hline(
    data = prop_reg_cat_hline_supplemented,
    aes(yintercept = percentage), color = "#00468BFF", alpha = 0.1
  ) +
  geom_bar(stat = "identity", position = "stack") +
  facet_grid(group ~ ethnicity, scales = "free", space = "free", shrink = FALSE) +
  theme_classic() +
  theme(text = element_text(size = 30)) +
  theme(axis.text.x = element_text(
    size = 25,
    hjust = 0.5,
    vjust = 0
  )) +
  theme(strip.text.y = element_text(angle = 0)) +
  coord_flip() +
  scale_fill_lancet() +
  xlab("") +
  ylab("\nProportion of registered TPP patients") +
  guides(fill = "none", alpha = guide_legend("")) +
  theme(
    legend.position = "bottom",
    panel.spacing = unit(1.1, "lines")
  )  + 
  ggtitle("Figure 1: Barplot showing proportion of registered TPP population with a recorded ethnicity by clinical and demographic subgroups,\nbased on primary care records (solid bars) and when supplemented with secondary care data (pale bars).")


prop_reg_cat_plot

ggsave(
  filename =here::here("output","released","made_locally", "completeness_cat.pdf"
  ),
  prop_reg_cat_plot,
  dpi = 600,
  width = 100,
  height = 60,
  units = "cm"
)
