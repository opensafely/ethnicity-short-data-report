library('gt')
library('tidyverse')
library('here')
library('glue')
library('stringr')
library('ggsci')

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
         population=as.character(scales::comma(round(as.numeric(population),0)))
  ) %>%
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



# patient counts 5 group
SUS5yesno <- read_csv(here::here("output","released","made_locally","local_patient_counts_categories_5_registered.csv")) %>%
  filter(subgroup == "Yes" | subgroup == "No") %>%
  mutate(subgroup =recode(subgroup, Yes = "Present",
                          No = "Absent"
  )) %>%
  arrange(group,rev(subgroup))

SUS5<-read_csv(here::here("output","released","made_locally","local_patient_counts_categories_5_registered.csv")) %>%
  filter(subgroup != "Yes" & subgroup != "No") %>%
  bind_rows(SUS5yesno) %>%
  mutate(group = case_when(group == 'age_band' ~ 'age band',
                           group == 'learning_disability' ~ 'learning disability',
                           group == "imd" ~ "IMD",
                         TRUE ~ group),
         subgroup =recode(subgroup, F = "Female",
                          M = "Male"
         )
         ) %>%
  filter(`Asian 5 SNOMED:2022` !="- (-)") 
  
my_cols <- setNames(c("group","",rep(c("SNOMED 2022","SNOMED 2022 with  SUS data"),5)),names(SUS5))


SUS5 <- SUS5 %>%
  gt( groupname_col = "group") %>%
  tab_spanner(label="Asian", columns=c(3,4)) %>%
  tab_spanner(label="Black", columns=c(5,6)) %>%
  tab_spanner(label="Mixed", columns=c(7,8)) %>%
  tab_spanner(label="White", columns=c(9,10)) %>%
  tab_spanner(label="Other", columns=c(11,12)) %>%
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
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 2:  Count of patients with a recorded ethnicity in OpenSAFELY TPP by ethnicity group (proportion of registered TPP population) and clinical and demographic subgroups. All counts are rounded to the nearest 5. "),
  )



SUS5  %>% gtsave(here::here("output","released","made_locally","patient_counts_5_group.html"))




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
    # row_group.as_column = TRUE option not available on the OS R image
    row_group.as_column = TRUE,
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 3:  Count of patients with a recorded ethnicity in OpenSAFELY TPP by ethnicity group (proportion of registered TPP population) and clinical and demographic subgroups. All counts are rounded to the nearest 5."),
  )

SUS16 %>% gtsave(here::here("output","released","made_locally","patient_counts_16_group.html"))

# latest / any recorded ethnicity
anyrepeated <- read_csv(here::here("output","released","made_locally","local_state_change_ethnicity_new_5_registered.csv")) %>%
    rename_with(str_to_title) %>%
    gt( ) %>%
  cols_label(`Latest Ethnicity-\n5 Snomed:2022` = "") %>%
  cols_label(Supplemented = "Any discordant") %>%
  tab_spanner(label="Latest Recorded Ethnicity", columns=1) %>%
  tab_spanner(label="Any Recorded Ethnicity", columns=c(2:7)) %>%
    tab_options(
      table.font.size = 8,
      column_labels.border.top.width = px(3),
      column_labels.border.top.color = "transparent",
      table.border.top.color = "transparent",
      heading.align = "left"
    ) %>%
    tab_header(
      title = md("Table 4: Count of patients with at least one recording of each ethnicity (proportion of latest ethnicity)."),
    )
  
anyrepeated %>% gtsave(here::here("output","released","made_locally","latest_any.html"))

# latest / most frequent recorded ethnicity
latestcommon <- read_csv(here::here("output","released","made_locally","local_latest_common_ethnicity_new_5_expanded_registered.csv")) %>%
  rename_with(str_to_title) %>%
  gt( ) %>%
  cols_label(`Latest Ethnicity-\n5 Snomed:2022` = "") %>%
  tab_spanner(label="Latest Recorded Ethnicity", columns=1) %>%
  tab_spanner(label="Most Frequent Ethnicity", columns=c(2:6)) %>%
  tab_options(
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 5: Count of patients’ most frequently recorded ethnicity (proportion of latest ethnicity). "),
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
    table.font.size = 8,
    column_labels.border.top.width = px(3),
    column_labels.border.top.color = "transparent",
    table.border.top.color = "transparent",
    heading.align = "left"
  ) %>%
  tab_header(
    title = md("Table 6: Count of individual ethnicity code use"),
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
  ggtitle("Figure 1: Recording of ethnicity over time for latest and first recorded ethnicity.Unknown dates of recording may be stored as '1900-01-01'")

ggsave(
  filename = here::here(
    "output",
    "released",
    "made_locally",
    "plot_time.pdf"
  ),
  plot_time,
  dpi = 600,
  width = 30,
  height = 10,
  units = "cm"
)
